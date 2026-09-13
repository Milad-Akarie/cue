import 'dart:math' as math;

import 'package:cue/src/motion/cue_motion.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// A mixin that extends [Simulation] with Cue-specific capabilities.
///
/// This mixin adds two key features to Flutter's `Simulation` base class:
/// - **Phasing**: Supports multi-phase animations where different transforms
///   can occur at different times within a single animation lifecycle.
///   Mainly used for keyframe-based motions.
/// - **Progress-based sampling**: The [valueAtProgress] method allows querying
///   the animation value at any normalized 0→1 progress point, independent of
///   internal time dynamics. This is essential for scrubbing, interrupted
///   animations, and timeline-based layouts.
///
/// Standard [Simulation] methods (`x`, `dx`, `isDone`) remain driven by actual
/// elapsed time `t` in seconds. Implementations should ensure both time-based
/// and progress-based queries remain consistent.
mixin CueSimulation on Simulation {
  /// The current animation phase (segment).
  ///
  /// For single-phase simulations, this is always `0`. For segmented
  /// animations (e.g., composed springs or timed motions), the phase indicates
  /// which segment is currently active.
  int get phase => 0;

  /// The actual animation duration in seconds for this built simulation.
  ///
  /// This is **not** the nominal `CueMotion.baseDuration`, but the real,
  /// computed duration accounting for the specific start/end values:
  ///
  /// - **Timed** ([CurvedSimulation]): Calculated as `baseDuration × |endValue − startValue|`.
  ///   E.g., a linear motion with 200 ms base animating from 0.3 to 0.8 (distance 0.5)
  ///   has actual duration = 200 ms × 0.5 = 100 ms.
  ///
  /// - **Spring** ([CueSpringSimulation]): Computed dynamically by numerically
  ///   integrating the spring physics until settlement within [Simulation.tolerance].
  ///   Different start/end values and velocities yield different durations.
  ///
  /// - **Delayed** ([DelayedSimulation]): Sum of the delay and the base simulation's duration.
  ///
  /// - **Segmented** ([SegmentedSimulation]): Sum of all phase durations.
  double get duration;

  /// Queries the animation value at a normalized progress point (0→1).
  ///
  /// - [progress]: A value from 0 (start) to 1 (end), independent of actual
  ///   elapsed time.
  /// - [forceLinear]: If `true`, ignores the simulation's curve/physics and
  ///   returns a linear interpolation. Useful for drag scrubbing and direct
  ///   timeline scrubbing, where measuring motion progress visually without
  ///   animation artifacts matters more than physical accuracy.
  ///
  /// Returns a tuple of `(value, phase)` — the interpolated value and the
  /// phase it occurred in.
  (double value, int phase) valueAtProgress(double progress, {bool forceLinear = false});
}

/// A simulation that delays the start of a base simulation by a fixed amount.
///
/// The delay is treated as part of the animation timeline, not as a separate
/// sequential phase. This means:
/// - Progress 0→`(delay / totalDuration)` returns the base's starting value
/// - Progress `(delay / totalDuration)`→1 maps to the base's 0→1 timeline
/// - `valueAtProgress` with `forceLinear` correctly scales the base's
///   progress to account for the delay offset
///
/// This approach ensures that delayed animations scrub and seek correctly
/// when interrupted mid-delay, and that the base simulation receives the
/// correct scaled progress even if the delay extends the timeline.
///
/// Implement via [DelayedMotion] in the public API.
class DelayedSimulation extends Simulation with CueSimulation {
  /// Creates a delayed wrapper around a base simulation.
  ///
  /// - [base]: The simulation to delay.
  /// - [delay]: Number of seconds to wait before the base starts (in seconds).
  DelayedSimulation({
    required CueSimulation base,
    required double delay,
  }) : _base = base,
       _delay = delay;

  /// The underlying simulation to delay.
  final CueSimulation _base;

  /// The delay in seconds before [_base] starts.
  final double _delay;

  @override
  double get duration => _delay + _base.duration;

  @override
  int get phase => _base.phase;

  // Core progress mapping - delay is first portion of progress
  @override
  (double value, int phase) valueAtProgress(double progress, {bool forceLinear = false}) {
    final totalDuration = duration;
    final delayProgress = totalDuration <= 0 ? 0.0 : _delay / totalDuration;

    if (delayProgress >= 1.0) {
      return progress < 1.0
          ? _base.valueAtProgress(0.0, forceLinear: true)
          : _base.valueAtProgress(1.0, forceLinear: forceLinear);
    }

    if (progress < delayProgress) {
      return _base.valueAtProgress(0.0, forceLinear: true);
    }

    final localProgress = ((progress - delayProgress) / (1.0 - delayProgress)).clamp(0.0, 1.0);

    return _base.valueAtProgress(localProgress, forceLinear: forceLinear);
  }

  @override
  double x(double t) {
    if (t < _delay) {
      return _base.valueAtProgress(0.0, forceLinear: true).$1;
    }
    final tAfterDelay = (t - _delay).clamp(0.0, double.infinity);
    return _base.x(tAfterDelay);
  }

  @override
  double dx(double t) => t <= _delay ? 0.0 : _base.dx(t - _delay);

  @override
  bool isDone(double t) => t >= _delay && _base.isDone(t - _delay);
}

/// A timed animation simulation driven by an easing curve.
///
/// The animation travels from [_from] to [_to] over [_duration], with the
/// curve determining how position changes over time.
///
/// **Duration scaling**: The constructor takes `baseDuration` as input but
/// computes the actual duration as `baseDuration * |to - from|`. This allows
/// the same timing curve to apply proportionally across different value ranges:
/// animating from 0 to 1 takes the full nominal duration, while animating from
/// 0 to 0.5 takes half.
///
/// [forceLinear] support: The [valueAtProgress] method can skip the curve
/// entirely and return a linear interpolation for scrubbing.
///
/// Created internally by [CueMotion.build] for all [TimedMotion] instances.
class CurvedSimulation extends Simulation with CueSimulation {
  /// The easing curve to apply.
  final Curve _curve;

  /// The start value of the animation range.
  final double _from;

  /// The end value of the animation range.
  final double _to;

  /// The total animation duration in seconds.
  final double _duration;

  @override
  double get duration => _duration;

  /// Creates a timed simulation with an easing curve.
  ///
  /// - [baseDuration]: Reference duration for a full 0→1 range.
  /// - [curve]: The easing curve to apply to progress.
  /// - [from], [to]: Value range; actual duration scales by `|to - from|`.
  CurvedSimulation({
    required double baseDuration,
    required Curve curve,
    required double from,
    required double to,
  }) : _duration = baseDuration * (to - from).abs(),
       _curve = curve,
       _from = from,
       _to = to;

  @override
  double x(double t) {
    final progress = (t / _duration).clamp(0.0, 1.0);
    return _from + (_to - _from) * _curve.transform(progress);
  }

  @override
  double dx(double t) {
    final double epsilon = tolerance.time;
    return (x(t + epsilon) - x(t - epsilon)) / (2 * epsilon);
  }

  @override
  bool isDone(double t) => t >= _duration;

  @override
  (double value, int phase) valueAtProgress(double progress, {bool forceLinear = false}) {
    if (forceLinear) {
      return (_from + (_to - _from) * progress, 0);
    }
    return (x(progress * duration), 0);
  }
}

/// A simulation constructed from a `Keyframes<T>` object.
///
/// Each element in [_motions] represents a keyframe motion. The simulator
/// progresses through keyframes sequentially, transitioning between them when
/// the current keyframe settles ([isDone]). Exit velocity is preserved: the
/// velocity at the end of one keyframe becomes the starting velocity for the next.
///
/// **Mapping to SegmentedTween**: This simulation is eventually mapped to
/// [SegmentedTween], which maintains an equal number of tweens—one per motion.
/// The tween selects the active tween based on the current [phase], enabling
/// multi-stage transformations where different tweens operate at different times.
///
/// The [endPhase] and [_endValue] parameters allow early termination: when
/// [_phase] reaches [endPhase], [_endValue] is passed to the final keyframe so
/// it knows to aim for a specific target.
class SegmentedSimulation extends Simulation with CueSimulation {
  final List<CueMotion> _motions;
  final bool _forward;
  late double _duration;

  /// The final phase at which the simulation should end. When this phase is reached, the current keyframe receives [_endValue] as its target.
  final int endPhase;

  /// The value to pass to the final keyframe when the simulation ends early.
  final double? _endValue;

  @override
  double get duration => _duration;

  int _phase;

  late CueSimulation _current;

  @override
  int get phase => _phase;

  double _phaseStartTime = 0;

  List<CueSimulation> _buildSeekableSegments() {
    if (_forward) {
      return List.unmodifiable(_motions.map((m) => m.buildBase()));
    }
    return List.unmodifiable(_motions.reversed.map((m) => m.buildBase(forward: false)));
  }

  late final _seekableSegments = _buildSeekableSegments();

  /// Creates a segmented simulation from a list of motions.
  SegmentedSimulation({
    required List<CueMotion> motions,
    required bool forward,
    required double velocity,
    int initialPhase = 0,
    double startValue = 0,
    int? endPhase,
    double? endValue,
  }) : _motions = motions,
       _forward = forward,
       _phase = initialPhase,
       endPhase = endPhase ?? (forward ? motions.length - 1 : 0),
       _endValue = endValue {
    final computedEndPhase = endPhase ?? (forward ? motions.length - 1 : 0);
    _current = motions[initialPhase].build(
      SimulationBuildData(
        forward: forward,
        startValue: startValue,
        endValue: initialPhase == computedEndPhase ? endValue : null,
        phase: initialPhase,
        velocity: velocity.abs(),
      ),
    );
    _duration = _current.duration;
    if (_forward) {
      for (int i = initialPhase + 1; i <= this.endPhase; i++) {
        _duration += motions[i].baseDuration.inMilliseconds / 1000.0;
      }
    } else {
      for (int i = this.endPhase; i < initialPhase; i++) {
        _duration += motions[i].baseDuration.inMilliseconds / 1000.0;
      }
    }
  }

  @override
  double x(double time) {
    _advanceIfNeeded(time);
    return _current.x(time - _phaseStartTime);
  }

  @override
  double dx(double time) {
    _advanceIfNeeded(time);
    return _current.dx(time - _phaseStartTime);
  }

  @override
  bool isDone(double time) {
    if (_forward) {
      return _phase >= endPhase && _current.isDone(time - _phaseStartTime);
    } else {
      return _phase <= endPhase && _current.isDone(time - _phaseStartTime);
    }
  }

  @override
  (double value, int phase) valueAtProgress(double progress, {bool forceLinear = false}) {
    if (_motions.isEmpty) return (0.0, 0);
    final totalBaseDuration = _seekableSegments.fold(0.0, (sum, value) => sum + value.duration);
    if (totalBaseDuration <= 0.0) {
      return _seekableSegments.first.valueAtProgress(1.0, forceLinear: forceLinear);
    }
    double elapsed = progress * totalBaseDuration;
    int phase = 0;
    while (phase < _seekableSegments.length - 1 && elapsed >= _seekableSegments[phase].duration) {
      elapsed -= _seekableSegments[phase].duration;
      phase++;
    }

    final segmentDuration = _seekableSegments[phase].duration;

    final localProgress = segmentDuration <= 0.0 ? 1.0 : (elapsed / segmentDuration).clamp(0.0, 1.0);
    final (value, _) = _seekableSegments[phase].valueAtProgress(localProgress, forceLinear: forceLinear);
    _phase = _forward ? phase : _motions.length - 1 - phase;

    return (value, _phase);
  }

  void _advanceIfNeeded(double time) {
    final localTime = time - _phaseStartTime;
    final canAdvance = _forward ? _phase < endPhase : _phase > endPhase;
    if (canAdvance && _current.isDone(localTime)) {
      double exitVelocity = _current.dx((localTime).clamp(0.0, double.infinity));
      // Negate velocity when reversing
      if (!_forward) {
        exitVelocity = -exitVelocity;
      }
      _phaseStartTime = time;
      _forward ? _phase++ : _phase--;
      final initialProgress = _forward ? 0.0 : 1.0;
      _current = _motions[phase].build(
        SimulationBuildData(
          forward: _forward,
          startValue: initialProgress,
          endValue: _phase == endPhase ? _endValue : null,
          velocity: exitVelocity,
        ),
      );
    }
  }
}

/// A spring simulation that computes its settle duration on demand.
///
/// Extends [SpringSimulation] (from Flutter) with [CueSimulation] to enable
/// progress-based queries and duration introspection.
///
/// The [duration] is computed via [calculateSettleDuration], which numerically
/// integrates the spring's physics using the provided [samplingStepSize]. This
/// allows animations to reserve time upfront based on spring parameters, even
/// though spring settlement can be sensitive to initial conditions.
///
/// [forceLinear] support: When `true`, [valueAtProgress] bypasses the spring
/// physics and returns linear interpolation from [_start] to [_end]. Useful for
/// scrubbing or measuring spring progress without the physics artifacts.
///
/// Created internally by [Spring.build] for all spring-based motions.
class CueSpringSimulation extends SpringSimulation with CueSimulation {
  /// Creates a spring simulation with Cue integration.
  ///
  /// - [spring]: The [SpringDescription] defining physics.
  /// - [start], [end]: Value range.
  /// - [velocity]: Initial velocity.
  /// - [tolerance], [snapToEnd]: Inherited from [SpringSimulation].
  /// - [samplingStepSize]: Time step (in seconds) for settle duration computation.
  CueSpringSimulation(
    super.spring,
    super.start,
    super.end,
    super.velocity, {
    super.tolerance,
    super.snapToEnd,
    this.samplingStepSize = 1 / 60,
  }) : _end = end,
       _start = start,
       _spring = spring;

  /// The time step (in seconds) used for numeric integration in [calculateSettleDuration].
  ///
  /// Typical value is `1 / 60` for 60 fps. Smaller values are more precise
  /// but increase computation time.
  final double samplingStepSize;

  /// Cache of the base spring description parameters.
  final SpringDescription _spring;

  /// Cached start and end values for linear interpolation in scrub mode.
  final double _start;
  final double _end;

  @override
  late final double duration = calculateSettleDuration(spring: _spring, stepSize: samplingStepSize);

  @override
  (double value, int phase) valueAtProgress(double progress, {bool forceLinear = false}) {
    if (forceLinear) {
      return (_start + (_end - _start) * progress, 0);
    }
    return (x(progress * duration), 0);
  }

  /// Numerically computes the time for a spring to settle within [tolerance].
  ///
  /// Uses the spring's natural frequency and damping ratio to estimate where
  /// settlement occurs. The actual settlement point is then verified by
  /// stepping through the simulation in [stepSize] increments.
  ///
  /// - [stepSize]: Sampling interval in seconds (default 1/60 for 60 fps).
  ///   Smaller values are more accurate but slower.
  /// - [spring]: The [SpringDescription] defining mass, stiffness, and damping.
  ///
  /// **Note**: This is a heuristic estimate. The actual settlement depends on
  /// initial velocity and the numerical precision of [isDone] checks. Use the
  /// result as a timeline bound, not a guarantee.
  double calculateSettleDuration({
    double stepSize = 1 / 60,
    required SpringDescription spring,
  }) {
    final omega0 = math.sqrt(spring.stiffness / spring.mass);
    final zeta = spring.damping / (2 * math.sqrt(spring.stiffness * spring.mass));
    final amplitude = (_start - _end).abs();

    final estimate = math.max(0.0, -math.log(tolerance.distance / amplitude) / (zeta * omega0));
    double t = (estimate / stepSize).floor() * stepSize;
    while (t < 100.0) {
      if (isDone(t)) return t;
      t += stepSize;
    }

    return t;
  }
}
