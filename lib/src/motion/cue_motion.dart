import 'package:cue/cue.dart';
import 'package:cue/src/motion/cue_simulation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Describes how a value travels from one point to another over time.
///
/// A [CueMotion] is a **description**, not a running animation. It holds the
/// parameters (duration, curve, spring config, etc.) and produces a
/// [CueSimulation] on demand via [build]. The simulation is what actually
/// drives the value forward — [CueMotion] only describes the rules.
/// [build] receives the runtime context — direction, start value, end value,
/// velocity, and so on.
///
/// ## Duration and partial travel
///
/// [baseDuration] always represents the **full 0→1 reference duration**.
/// It is a nominal value — the actual playback time lives on the
/// [CueSimulation] produced by [build], as [CueSimulation.duration].
/// That value is computed dynamically from [SimulationBuildData]: timed
/// motions scale it by `|endValue - startValue|`, spring motions derive it
/// from physics given the start/end/velocity. Either way, the simulation
/// knows its own real duration once built.
///
/// ## Phases
///
/// Most motions have a single phase ([totalPhases] == 1). Composite motions
/// declare multiple phases — Cue builds one simulation with the initial phase
/// via [build], and the simulation itself advances through remaining phases
/// internally as each one completes.
///
/// ## Built-in presets
///
/// [CueMotion] groups its factory constructors into three families:
///
/// - **Timed** — fixed-duration curve-based motions:
///   [CueMotion.linear], [CueMotion.curved], [CueMotion.easeIn],
///   [CueMotion.easeOut], [CueMotion.easeInOut], and variants.
/// - **Spring presets** — physics-driven motions with sensible defaults:
///   [CueMotion.smooth], [CueMotion.bouncy], [CueMotion.snappy], and others.
/// - **Custom spring** — [CueMotion.spring] accepts a `duration` and `bounce`
///   to describe a spring without picking a named preset.
///
/// All constructors are designed for shorthand dot syntax when the type is
/// already inferred — e.g. `motion: .smooth()`, `motion: .linear(200.ms)`.
abstract class CueMotion {
  /// Creates a CueMotion.
  const CueMotion();

  /// The number of phases this motion contains. Defaults to `1`.
  ///
  /// Single-phase motions ignore [SimulationBuildData.phase] — the built
  /// simulation covers the full journey. Multi-phase motions use this value
  /// to know when all phases have been traversed.
  int get totalPhases => 1;

  /// The reference duration for a full **0→1** travel of this motion.
  ///
  /// This is a nominal value used for scheduling and delay calculations.
  /// The simulation's actual playback time is determined at build time —
  /// see [build] and [CueSimulation.duration].
  Duration get baseDuration;

  /// Builds a [CueSimulation] for the given runtime [data].
  ///
  /// [data] carries the dynamic context: travel direction, start and end
  /// values, current velocity, and the active phase index. The returned
  /// simulation knows its own real duration and drives the value forward
  /// independently of this motion description.
  CueSimulation build(SimulationBuildData data);

  /// Convenience wrapper around [build] that constructs a default
  /// [SimulationBuildData] for a full forward or reverse run.
  ///
  /// Starts from `0.0` when [forward] is `true`, from `1.0` otherwise.
  /// [phase] defaults to the first phase going forward, and the last phase
  /// going in reverse.
  CueSimulation buildBase({bool forward = true, int? phase}) => switch (forward) {
    true => build(SimulationBuildData.forward(phase: phase ?? 0)),
    false => build(SimulationBuildData.reverse(phase: phase ?? totalPhases - 1)),
  };

  /// Creates a delayed version of this motion with the given delay.
  @internal
  CueMotion delayed(Duration delay) => DelayedMotion(this, delay);

  /// {@macro cue.motion.linear}
  const factory CueMotion.linear(Duration duration) = TimedMotion;

  /// {@macro cue.motion.threshold}
  const factory CueMotion.threshold(Duration duration, {required double breakpoint}) = _ThresholdMotion;

  /// {@macro cue.motion.curved}
  const factory CueMotion.curved(Duration duration, {required Curve curve}) = TimedMotion.curved;

  /// {@macro cue.motion.ease_in}
  const factory CueMotion.easeIn(Duration duration) = TimedMotion.easeIn;

  /// {@macro cue.motion.ease_out}
  const factory CueMotion.easeOut(Duration duration) = TimedMotion.easeOut;

  /// {@macro cue.motion.ease_in_out}
  const factory CueMotion.easeInOut(Duration duration) = TimedMotion.easeInOut;

  /// {@macro cue.motion.ease_out_back}
  const factory CueMotion.easeOutBack(Duration duration) = TimedMotion.easeOutBack;

  /// {@macro cue.motion.ease_in_back}
  const factory CueMotion.easeInBack(Duration duration) = TimedMotion.easeInBack;

  /// {@macro cue.motion.fast_out_slow_in}
  const factory CueMotion.fastOutSlowIn(Duration duration) = TimedMotion.fastOutSlowIn;

  /// A zero-duration motion that resolves immediately — useful as a no-op
  /// placeholder when a [CueMotion] is required but no animation is wanted.
  static const none = TimedMotion(Duration.zero);

  /// The default fallback motion: 300 ms linear.
  ///
  /// Used internally when no explicit motion is provided to a [Cue] widget.
  static const CueMotion defaultTime = TimedMotion(Duration(milliseconds: 300));

  /// {@macro cue.motion.spring}
  factory CueMotion.spring({
    Duration duration,
    double bounce,
  }) = Spring;

  /// {@macro cue.motion.smooth}
  const factory CueMotion.smooth({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.smooth;

  /// {@macro cue.motion.gentle}
  const factory CueMotion.gentle({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.gentle;

  /// {@macro cue.motion.bouncy}
  const factory CueMotion.bouncy({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.bouncy;

  /// {@macro cue.motion.wobbly}
  const factory CueMotion.wobbly({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.wobbly;

  /// {@macro cue.motion.snappy}
  const factory CueMotion.snappy({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.snappy;

  /// {@macro cue.motion.spatial}
  const factory CueMotion.spatial({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.spatial;

  /// {@macro cue.motion.spatial_slow}
  const factory CueMotion.spatialSlow({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.spatialSlow;

  /// {@macro cue.motion.spatial_fast}
  const factory CueMotion.spatialFast({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.spatialFast;

  /// {@macro cue.motion.effect}
  const factory CueMotion.effect({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.effect;

  /// {@macro cue.motion.effect_slow}
  const factory CueMotion.effectSlow({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.effectSlow;

  /// {@macro cue.motion.effect_fast}
  const factory CueMotion.effectFast({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.effectFast;
}

class _ThresholdMotion extends TimedMotion {
  final double breakpoint;

  @override
  Curve get curve => Threshold(breakpoint);

  const _ThresholdMotion(super.duration, {required this.breakpoint});
}

/// A [CueMotion] that drives animations with a fixed [Duration] and a [Curve].
///
/// The actual playback time is `baseDuration × |endValue − startValue|` —
/// so a half-way start (0.5→1.0) uses half the duration. Use the named
/// constructors to pick a curve, or [TimedMotion.curved] for a custom one.
///
/// Prefer the [CueMotion] factory shorthands (e.g. `.easeOut(...)`,
/// `.linear(...)`) over constructing [TimedMotion] directly.
class TimedMotion extends CueMotion {
  /// The [Curve] applied to the animation. Defaults to [Curves.linear].
  final Curve curve;

  /// {@template cue.motion.linear}
  /// A constant-speed timed motion — no acceleration or deceleration.
  ///
  /// Useful when you need perfectly uniform movement, or as a neutral
  /// baseline. For most UI prefer [CueMotion.easeOut] or a spring preset.
  ///
  /// - [duration]: Reference time for a full **0→1** travel. Actual playback
  ///   time scales proportionally with `|endValue − startValue|`.
  ///
  /// ```dart
  /// Cue.onToggle(
  ///   toggled: isVisible,
  ///   motion: .linear(200.ms),
  ///   child: Actor(acts: [.fadeIn()], child: MyWidget()),
  /// )
  /// ```
  /// {@endtemplate}
  const TimedMotion(this.baseDuration) : curve = Curves.linear;

  /// {@template cue.motion.curved}
  /// A timed motion with an arbitrary [Curve].
  ///
  /// Use this when none of the named presets fit — pass any [Curve] from
  /// [Curves] or a custom implementation.
  ///
  /// - [duration]: Reference time for a full **0→1** travel. Actual playback
  ///   time scales proportionally with `|endValue − startValue|`.
  /// - [curve]: The easing curve to apply.
  ///
  /// ```dart
  /// Cue.onToggle(
  ///   toggled: isVisible,
  ///   motion: .curved(200.ms, curve: Curves.elasticOut),
  ///   child: Actor(acts: [.scale(from: 0.8)], child: MyWidget()),
  /// )
  /// ```
  /// {@endtemplate}
  const TimedMotion.curved(this.baseDuration, {required this.curve});

  /// {@template cue.motion.ease_in}
  /// A timed motion that starts slow and accelerates toward the end.
  ///
  /// Equivalent to [Curves.easeIn]. Best suited for elements leaving the
  /// screen, where a gentle start feels natural before picking up speed.
  ///
  /// - [duration]: Reference time for a full **0→1** travel. Actual playback
  ///   time scales proportionally with `|endValue − startValue|`.
  ///
  /// ```dart
  /// Cue.onToggle(
  ///   toggled: isVisible,
  ///   motion: .easeIn(200.ms),
  ///   child: Actor(acts: [.fadeIn(), .slideY(from: -0.2)], child: MyWidget()),
  /// )
  /// ```
  /// {@endtemplate}
  const TimedMotion.easeIn(this.baseDuration) : curve = Curves.easeIn;

  /// {@template cue.motion.ease_out}
  /// A timed motion that starts fast and decelerates smoothly to rest.
  ///
  /// Equivalent to [Curves.easeOut]. Good for elements entering the screen —
  /// the fast start gives a sense of energy while the gentle finish feels
  /// settled.
  ///
  /// - [duration]: Reference time for a full **0→1** travel. Actual playback
  ///   time scales proportionally with `|endValue − startValue|`.
  ///
  /// ```dart
  /// Cue.onToggle(
  ///   toggled: isVisible,
  ///   motion: .easeOut(200.ms),
  ///   child: Actor(acts: [.fadeIn(), .slideY(from: 0.2)], child: MyWidget()),
  /// )
  /// ```
  /// {@endtemplate}
  const TimedMotion.easeOut(this.baseDuration) : curve = Curves.easeOut;

  /// {@template cue.motion.ease_in_out}
  /// A timed motion that accelerates from rest, then decelerates back to rest.
  ///
  /// Equivalent to [Curves.easeInOut]. A symmetric S-curve — natural for
  /// transitions where both the start and finish should feel smooth.
  ///
  /// - [duration]: Reference time for a full **0→1** travel. Actual playback
  ///   time scales proportionally with `|endValue − startValue|`.
  ///
  /// ```dart
  /// Cue.onToggle(
  ///   toggled: isVisible,
  ///   motion: .easeInOut(300.ms),
  ///   child: Actor(acts: [.sizedClip(from: NSize.width(80), to: NSize.width(240))], child: MyWidget()),
  /// )
  /// ```
  /// {@endtemplate}
  const TimedMotion.easeInOut(this.baseDuration) : curve = Curves.easeInOut;

  /// {@template cue.motion.ease_out_back}
  /// A timed motion that overshoots slightly past the target before settling.
  ///
  /// Equivalent to [Curves.easeOutBack]. The overshoot adds a springy,
  /// playful quality without full physics simulation.
  ///
  /// - [duration]: Reference time for a full **0→1** travel. Actual playback
  ///   time scales proportionally with `|endValue − startValue|`.
  ///
  /// ```dart
  /// Cue.onToggle(
  ///   toggled: isVisible,
  ///   motion: .easeOutBack(200.ms),
  ///   child: Actor(acts: [.scale(from: 0.8)], child: MyWidget()),
  /// )
  /// ```
  /// {@endtemplate}
  const TimedMotion.easeOutBack(this.baseDuration) : curve = Curves.easeOutBack;

  /// {@template cue.motion.ease_in_back}
  /// A timed motion that pulls back slightly before accelerating forward.
  ///
  /// Equivalent to [Curves.easeInBack]. The anticipation dip gives a
  /// wind-up feel before the element moves away.
  ///
  /// - [duration]: Reference time for a full **0→1** travel. Actual playback
  ///   time scales proportionally with `|endValue − startValue|`.
  ///
  /// ```dart
  /// Cue.onToggle(
  ///   toggled: isVisible,
  ///   motion: .easeInBack(200.ms),
  ///   child: Actor(acts: [.scale(from: 1.0, to: 0.8)], child: MyWidget()),
  /// )
  /// ```
  /// {@endtemplate}
  const TimedMotion.easeInBack(this.baseDuration) : curve = Curves.easeInBack;

  /// {@template cue.motion.fast_out_slow_in}
  /// A timed motion with a sharp acceleration followed by a long, gradual
  /// deceleration — the standard Material motion curve.
  ///
  /// Equivalent to [Curves.fastOutSlowIn]. Recommended for shared-axis
  /// and container transitions that follow Material Design guidelines.
  ///
  /// - [duration]: Reference time for a full **0→1** travel. Actual playback
  ///   time scales proportionally with `|endValue − startValue|`.
  ///
  /// ```dart
  /// Cue.onToggle(
  ///   toggled: isVisible,
  ///   motion: .fastOutSlowIn(200.ms),
  ///   child: Actor(acts: [.slideY(from: 0.3), .fadeIn()], child: MyWidget()),
  /// )
  /// ```
  /// {@endtemplate}
  const TimedMotion.fastOutSlowIn(this.baseDuration) : curve = Curves.fastOutSlowIn;

  /// {@template cue.motion.threshold}
  /// A timed motion that jumps instantly to the end value once the animation
  /// crosses [breakpoint] (a 0→1 progress fraction).
  ///
  /// No interpolation occurs — the value stays at the start until the
  /// threshold is reached, then snaps to the end. Useful for visibility
  /// toggles that must align precisely with another ongoing animation.
  ///
  /// - [duration]: Reference time that controls when the breakpoint is
  ///   reached relative to sibling animations.
  /// - [breakpoint]: Progress fraction (0→1) at which the jump occurs.
  ///
  /// ```dart
  /// Cue.onToggle(
  ///   toggled: isVisible,
  ///   motion: .threshold(200.ms, breakpoint: 0.5),
  ///   child: Actor(acts: [.fadeIn()], child: MyWidget()),
  /// )
  /// ```
  /// {@endtemplate}
  const factory TimedMotion.threshold(Duration duration, {required double breakpoint}) = _ThresholdMotion;

  @override
  final Duration baseDuration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimedMotion &&
          runtimeType == other.runtimeType &&
          baseDuration == other.baseDuration &&
          curve == other.curve;

  @override
  int get hashCode => baseDuration.hashCode ^ curve.hashCode;

  @override
  CueSimulation build(SimulationBuildData data) {
    return CurvedSimulation(
      baseDuration: baseDuration.inMilliseconds / Duration.millisecondsPerSecond,
      curve: curve,
      from: data.startValue,
      to: data.endValue,
    );
  }
}

/// Base class for physics-driven motions that produce a specific simulation
/// type [S].
///
/// Extend this instead of [CueMotion] directly when your motion always
/// produces a known [CueSimulation] subtype — e.g. [Spring] produces
/// [CueSpringSimulation]. The type parameter lets call sites and tooling
/// reason about the concrete simulation without a cast.
abstract class SimulationMotion<S extends CueSimulation> extends CueMotion {
  /// Creates a SimulationMotion.
  const SimulationMotion();
}

/// A [CueMotion] composed of an ordered list of child [motions], each
/// playing one after the other.
///
/// Each element in [motions] corresponds to one phase. [totalPhases] equals
/// `motions.length`. [baseDuration] is the sum of all children's
/// [CueMotion.baseDuration].
///
/// When [build] is called, a single [SegmentedSimulation] is created starting
/// at [SimulationBuildData.phase]. The simulation transitions between phases
/// internally — [build] is only called once per animation start.
@internal
class SegmentedMotion extends CueMotion {
  /// The ordered list of motions that make up each phase.
  final List<CueMotion> motions;
  const SegmentedMotion(this.motions);

  @override
  Duration get baseDuration => motions.fold(
    Duration.zero,
    (total, motion) => total + motion.baseDuration,
  );

  @override
  int get totalPhases => motions.length;

  @override
  CueSimulation build(SimulationBuildData data) {
    return SegmentedSimulation(
      motions: motions,
      forward: data.forward,
      initialPhase: data.phase,
      startValue: data.startValue,
      velocity: data.velocity ?? 0.0,
      endPhase: data.endPhase ?? (data.forward ? motions.length - 1 : 0),
      endValue: data.endValue,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SegmentedMotion && runtimeType == other.runtimeType && listEquals(motions, other.motions);

  @override
  int get hashCode => Object.hashAll(motions);
}

/// A [CueMotion] that prepends a silent pause before the motion plays.
///
/// [delay] is baked into the motion itself — [baseDuration] includes it, and
/// the built [DelayedSimulation] embeds the delay so the animation can be
/// scrubbed and seeked correctly across the full `0→1` range (delay + actual
/// motion). This is different from scheduling a delayed start externally;
/// the delay is part of the animation's timeline.
///
/// Created internally via [CueMotion.delayed]. Stacking multiple calls
/// accumulates the delays into a single [DelayedMotion] rather than nesting.
@internal
class DelayedMotion extends CueMotion {
  /// The underlying motion that plays after the delay.
  final CueMotion base;

  /// The silent pause prepended before [base] begins.
  final Duration delay;
  const DelayedMotion(this.base, this.delay);

  @override
  CueMotion delayed(Duration delay) => DelayedMotion(base, delay + this.delay);

  @override
  Duration get baseDuration => base.baseDuration + delay;

  @override
  CueSimulation build(SimulationBuildData data) {
    final baseSim = base.build(data);
    double delaySeconds = delay.inMilliseconds / Duration.millisecondsPerSecond;
    if (data.startProgress case final progress?) {
      final totalDuration = delaySeconds + baseSim.duration;
      final elapsedTime = data.forward ? progress * totalDuration : (1.0 - progress) * totalDuration;
      delaySeconds = (delaySeconds - elapsedTime).clamp(0.0, double.infinity);
    }
    return DelayedSimulation(base: baseSim, delay: delaySeconds);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DelayedMotion && runtimeType == other.runtimeType && base == other.base && delay == other.delay;

  @override
  int get hashCode => Object.hash(base, delay);
}

/// Runtime context passed to [CueMotion.build] when constructing a simulation.
///
/// Every field describes the state of the animation at the moment it starts —
/// or restarts after an interruption. [CueMotion] implementations use these
/// values to produce a [CueSimulation] with the correct start point, end
/// point, direction, and initial velocity.
///
/// Use the named constructors [SimulationBuildData.forward] and
/// [SimulationBuildData.reverse] for the common case of a full run.
class SimulationBuildData {
  /// Whether the animation is travelling toward `1.0` (`true`) or
  /// toward `0.0` (`false`).
  final bool forward;

  /// The active phase index within a multi-phase motion.
  ///
  /// Single-phase motions always receive `0`. For multi-phase motions this
  /// indicates which segment is currently running.
  final int phase;

  /// The last phase that should play before the simulation stops.
  ///
  /// `null` means run to the natural end (last phase when [forward],
  /// first phase when reversing).
  final int? endPhase;

  final double? _endValue;

  /// The value the simulation starts from, in the `0.0–1.0` range.
  final double startValue;

  /// The progress fraction at which the simulation begins, if the animation
  /// was interrupted mid-way.
  ///
  /// Used by [DelayedMotion] to skip the portion of the delay that has
  /// already elapsed. `null` for fresh starts.
  final double? startProgress;

  /// The initial velocity to hand off to the simulation, in units per second.
  ///
  /// Non-zero when an animation is interrupted by a gesture or a direction
  /// reversal and the velocity should carry through to the new simulation.
  /// `null` is treated as `0.0` by most implementations.
  final double? velocity;

  /// The value the simulation should reach. Defaults to `1.0` when
  /// [forward] is `true`, `0.0` when `false`.
  /// The end value for the simulation.
  double get endValue => _endValue ?? (forward ? 1.0 : 0.0);

  /// Creates a SimulationBuildData with the given configuration.
  const SimulationBuildData({
    required this.forward,
    required this.startValue,
    this.phase = 0,
    this.endPhase,
    this.velocity,
    this.startProgress,
    double? endValue,
  }) : _endValue = endValue;

  /// A forward run starting from [startValue] (defaults to `0.0`).
  const SimulationBuildData.forward({
    this.phase = 0,
    this.endPhase,
    this.startValue = 0.0,
    this.velocity,
    this.startProgress,
    double? endValue,
  }) : forward = true,
       _endValue = endValue;

  /// A reverse run starting from [startValue] (defaults to `1.0`).
  const SimulationBuildData.reverse({
    this.phase = 0,
    this.endPhase,
    this.startValue = 1.0,
    this.velocity,
    this.startProgress,
    double? endValue,
  }) : forward = false,
       _endValue = endValue;
}
