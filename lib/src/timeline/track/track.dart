import 'package:cue/cue.dart';
import 'package:cue/src/motion/simulation.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/material.dart';

class CueTrackImpl extends CueTrack with AnimationLocalStatusListenersMixin {
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

  @override
  double get forwardDuration => _seekableSim.duration;

  @override
  double get reverseDuration => _seekableReverseSim.duration;

  double _value = 0.0;
  double _localT = 0.0;
  double _startProgress = 0.0;
  double _targetProgress = 1.0;
  bool _done = true;

  AnimationStatus _status = AnimationStatus.dismissed;

  CueTrackImpl(this.config);

  @override
  double get value => _value;

  @override
  AnimationStatus get status => _status;

  bool _forward = true;

  (double, int) _valueAtProgress(double progress, bool forward) {
    final sim = forward ? _seekableSim : _seekableReverseSim;
    progress = forward ? progress : (1.0 - progress);
    return sim.valueAtProgress(progress);
  }

  @override
  void setProgress(double t, {bool forward = true, bool alwaysNotify = false}) {
    assert(t >= 0.0 && t <= 1.0, 'Progress value must be between 0.0 and 1.0. Received: $t');
    _forward = forward;
    _needsPrepare = true;
    _progress = t;
    double value = _value;
    int phase = _phase;
    if (forward && !reverseType.isExclusive) {
      (value, phase) = _valueAtProgress(t, true);
      _done = t >= 1.0;
    } else if (!forward && !reverseType.isNone) {
      (value, phase) = _valueAtProgress(t, false);
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

  @override
  bool get isDone => _done;

  @override
  double get velocity {
    if (_activeSim == null) return 0.0;
    return _activeSim!.dx(_localT);
  }

  @override
  int get phase => _phase;

  @override
  void didRegisterListener() => _listenres++;

  @override
  void didUnregisterListener() => _listenres--;

  bool get hasListeners => _listenres > 0;
}

abstract class CueTrack extends Animation<double> with AnimationLocalListenersMixin {
  void prepare({required bool forward, double? from, double? target, double? exteranlVelocity});

  TrackConfig get config;

  ReverseBehaviorType get reverseType => config.reverseType;

  CueMotion get motion => config.motion;

  CueMotion get reverseMotion => config.reverseMotion;

  double get forwardDuration;

  double get reverseDuration;

  void tick(double td);

  void setProgress(double t, {bool forward = true, bool alwaysNotify = false});

  bool get isDone;

  double get velocity;

  double get progress;

  int get phase;

  bool get isReverseOrDismissed => status == .reverse || status == .dismissed;
}
