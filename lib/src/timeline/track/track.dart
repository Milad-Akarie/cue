
import 'package:cue/cue.dart';
import 'package:cue/src/motion/cue_simulation.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/material.dart';

/// A single animation track that manages forward and reverse animations.
///
/// Tracks are the building blocks of timelines. Each track:
/// - Drives a specific animation with forward and reverse motions
/// - Maintains progress (0-1) and computed animation values
/// - Respects the track's [ReverseBehaviorType] configuration
/// - Can be prepared for animation or have progress set directly
///
/// Tracks are typically managed by a [CueTimeline] which coordinates
/// multiple tracks with different timings into a unified animation.
class CueTrackImpl extends CueTrack with AnimationLocalStatusListenersMixin {
  /// The configuration defining forward and reverse animation timing.
  @override
  final TrackConfig config;

  double _progress = 0.0;

  int _phase = 0;

  @override
  double get progress => _progress;

  CueSimulation? _activeSim;
  int _listenres = 0;

  bool _needsPrepare = false;

  late final CueSimulation _seekableSim = config.motion.buildBase();
  late final CueSimulation _seekableReverseSim = config.reverseMotion.buildBase(forward: false);

  /// Duration of the forward animation in seconds.
  @override
  double get forwardDuration => _seekableSim.duration;

  /// Duration of the reverse animation in seconds.
  @override
  double get reverseDuration => _seekableReverseSim.duration;

  double _value = 0.0;
  double _localT = 0.0;
  double _startProgress = 0.0;
  double _targetProgress = 1.0;
  bool _done = true;

  AnimationStatus _status = AnimationStatus.dismissed;

  CueTrackImpl(this.config);

  /// The current computed animation value.
  ///
  /// Reflects all motion curves and phases. For spring-based motions this
  /// may momentarily exceed 0-1 due to overshoot. Always 0-1 for curve-based motions.
  @override
  double get value => _value;

  /// Current animation status (forward, reverse, completed, dismissed).
  @override
  AnimationStatus get status => _status;

  bool _forward = true;

  (double, int) _valueAtProgress(double progress, bool forward, {bool forceLinear = false}) {
    final sim = forward ? _seekableSim : _seekableReverseSim;
    progress = forward ? progress : (1.0 - progress);
    return sim.valueAtProgress(progress, forceLinear: forceLinear);
  }

  /// Sets animation progress directly to a normalized value (0-1).
  ///
  /// Immediately updates the animation value without time-based stepping.
  /// Useful for seeking or scrubbing. Marks the track as needing [prepare]
  /// before the next [tick] call.
  ///
  /// [t] - Progress value (0-1)
  /// [forward] - Whether to use forward or reverse motion
  /// [alwaysNotify] - Force notifying listeners even if value didn't change
  /// [forceLinear] - Ignore curves/springs and use linear interpolation
  @override
  void setProgress(double t, {bool forward = true, bool alwaysNotify = false , bool forceLinear = false}) {
    assert(t >= 0.0 && t <= 1.0, 'Progress value must be between 0.0 and 1.0. Received: $t');
    _forward = forward;
    _needsPrepare = true;
    _progress = t;
    double value = _value;
    int phase = _phase;
    if (forward && !reverseType.isExclusive) {
      (value, phase) = _valueAtProgress(t, true, forceLinear: forceLinear);
      _done = t >= 1.0;
    } else if (!forward && !reverseType.isNone) {
      (value, phase) = _valueAtProgress(t, false, forceLinear: forceLinear);
      _done = t <= 0.0;
    } else {
      _done = true;
    }
    _localT = 0.0;
    _activeSim = null;
    if (alwaysNotify || _value != value || _phase != phase) {
      _value = value;
      _phase = phase;
      notifyListeners();
    }
    _upateStatus();
  }

  /// Prepares the track for animation playback.
  ///
  /// Must be called before [tick]. Sets up the internal simulation with
  /// start/end values resolved from current progress and [reverseType].
  ///
  /// Respects reverse behavior:
  /// - `exclusive`: Track is dismissed immediately on forward — only drives reverse
  /// - `none`: Track is dismissed immediately on reverse — only drives forward
  /// - `mirror` (default): Drives both directions
  ///
  /// [forward] - Direction to animate
  /// [from] - Starting progress override (default: current progress)
  /// [target] - Target progress override (default: 1.0 forward, 0.0 reverse)
  /// [exteranlVelocity] - Initial velocity for spring handoff/momentum
  @override
  void prepare({required bool forward, double? from, double? target, double? exteranlVelocity}) {
    _needsPrepare = false;
    _forward = forward;

    if (forward && reverseType.isExclusive) {
      // this drive should only drive reverse animation
      _done = true;
      _upateStatus();
      return;
    }
    if (!forward && reverseType.isNone) {
      // this drive should not drive reverse animation
      _done = true;
      _upateStatus();
      return;
    }

    final active = forward ? motion : reverseMotion;

    if (from != null) {
      _progress = from;
    }

    _startProgress = _progress;
    _targetProgress = target ?? (forward ? 1.0 : 0.0);

    if (reverseType.isExclusive) {
      _value = 1.0;
      _phase = motion.totalPhases - 1;
    } else if (forward && reverseType.isNone) {
      _value = 0.0;
      _phase = 0;
    } else if (from != null || _activeSim == null) {
      final (value, phase) = _valueAtProgress(_startProgress, forward);
      _value = value;
      _phase = phase;
    } else if (_activeSim case final sim?) {
      _value = sim.x(_localT);
      _phase = sim.phase;
    }


    final (targetValue, targetPhase) = target == null ? (null, null) : _valueAtProgress(target, forward);
    _activeSim = active.build(
      SimulationBuildData(
        forward: forward,
        startValue: _value,
        endValue: targetValue,
        phase: _phase,
        endPhase: targetPhase,
        startProgress: _startProgress,
        velocity: exteranlVelocity ?? velocity,
      ),
    );
    _phase = _activeSim!.phase;

    _localT = 0.0;
    _done = false;
    _upateStatus();
  }

  void _upateStatus([AnimationStatus? newStatus]) {
    newStatus ??= switch ((_forward, _done)) {
      (true, true) => AnimationStatus.completed,
      (true, false) => AnimationStatus.forward,
      (false, true) => AnimationStatus.dismissed,
      (false, false) => AnimationStatus.reverse,
    };
    if (newStatus != _status) {
      _status = newStatus;
      notifyStatusListeners(_status);
    }
  }

  /// Advances animation by a time delta (in seconds).
  ///
  /// Called repeatedly by the timeline each frame. Updates progress, value,
  /// phase, and status. Once animation completes, further ticks are no-ops.
  /// [prepare] must be called before ticking after a [setProgress] call.
  @override
  void tick(double td) {
    assert(!_needsPrepare || _done, 'Tick() is called before prepare().');
    if (_done || _activeSim == null) return;
    _localT += td;

    final simDuration = _activeSim!.duration;
    final fraction = simDuration <= 0 ? 1.0 : (_localT / simDuration).clamp(0.0, 1.0);
    _progress = _startProgress + (_targetProgress - _startProgress) * fraction;

    if (_activeSim!.isDone(_localT)) {
      _value = _activeSim!.x(_localT);
      _phase = _activeSim!.phase;
      _done = true;
      _progress = _targetProgress;
      notifyListeners();
      _upateStatus(_forward ? .completed : .dismissed);
      return;
    }
    final newValue = _activeSim!.x(_localT);
    final newPhase = _activeSim!.phase;
    if (newValue != _value || newPhase != _phase) {
      _value = newValue;
      _phase = newPhase;
      notifyListeners();
    }
  }

  /// Whether animation has finished naturally or reached its boundary progress.
  @override
  bool get isDone => _done;

  /// Current animation velocity (rate of change of value).
  @override
  double get velocity {
    if (_activeSim == null) return 0.0;
    return _activeSim!.dx(_localT);
  }

  /// Current animation phase index (for multi-phase motions).
  @override
  int get phase => _phase;

  @override
  void didRegisterListener() => _listenres++;

  @override
  void didUnregisterListener() => _listenres--;

  bool get hasListeners => _listenres > 0;
}

abstract class CueTrack extends Animation<double> with AnimationLocalListenersMixin {
  /// Prepares the track for animation playback.
  /// Must be called before [tick] when resuming from a [setProgress] call.
  void prepare({required bool forward, double? from, double? target, double? exteranlVelocity});

  /// Track configuration with forward and reverse motion.
  TrackConfig get config;

  /// Reverse behavior type from config.
  ReverseBehaviorType get reverseType => config.reverseType;

  /// Forward motion from config.
  CueMotion get motion => config.motion;

  /// Reverse motion from config.
  CueMotion get reverseMotion => config.reverseMotion;

  /// Duration of forward animation (in seconds).
  double get forwardDuration;

  /// Duration of reverse animation (in seconds).
  double get reverseDuration;

  /// Advance animation by time delta (in seconds).
  void tick(double td);

  /// Set animation progress directly (0-1, normalized).
  void setProgress(double t, {bool forward = true, bool alwaysNotify = false, bool forceLinear = false});

  /// Whether animation has finished.
  bool get isDone;

  /// Current animation velocity (rate of change).
  double get velocity;

  /// Current progress (0-1, normalized).
  double get progress;

  /// Current phase index for multi-phase motions.
  int get phase;

  /// Whether track is in reverse or dismissed state.
  bool get isReverseOrDismissed => status == .reverse || status == .dismissed;
}
