import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

abstract class CueTimeline extends Simulation {
  CueTrack trackFor(TrackConfig config);
  void prepare({required bool forward, double? from});
  void setProgress(double value, {bool forward = true});

  void release(CueTrack anim);

  AnimationStatus get status;

  double get progress => mainTrack.progress;

  final Map<TrackConfig, CueTrack> tracks;

  CueTimeline(this.tracks);

  CueTrack buildTrack(TrackConfig config);

  TrackConfig get mainTrackConfig => tracks.keys.first;

  CueTrack get mainTrack;

  void reset(TrackConfig config) {
    tracks.clear();
    tracks[config] = buildTrack(config);
  }

  void addOnPrepareListener(ValueChanged<bool> listener);
  void removeOnPrepareListener(ValueChanged<bool> listener);
  void addStatusListener(AnimationStatusListener listener);
  void removeStatusListener(AnimationStatusListener listener);
}

class CueTimelineImpl extends CueTimeline with AnimationLocalStatusListenersMixin {
  @override
  void addOnPrepareListener(ValueChanged<bool> listener) {
    _onPrepareNotifier.addEventListener(listener);
  }

  @override
  void removeOnPrepareListener(ValueChanged<bool> listener) {
    _onPrepareNotifier.removeEventListener(listener);
  }

  final _onPrepareNotifier = EventNotifier<bool>();

  CueTimelineImpl(CueTrack main)
    : super({
        TrackConfig(
          motion: main.motion,
          reverseMotion: main.reverseMotion,
        ): main,
      });

  double _lastT = 0.0;

  @override
  CueTrack get mainTrack => tracks.values.first;

  @override
  CueTrack trackFor(TrackConfig config) {
    if (config == mainTrackConfig) {
      return mainTrack;
    }
    final animation = tracks.putIfAbsent(config, () => buildTrack(config));
    if (mainTrack.isAnimating) {
      animation.prepare(
        forward: mainTrack.isForwardOrCompleted,
        from: mainTrack.progress,
        exteranlVelocity: mainTrack.velocity,
      );
      _onPrepareNotifier.fireEvent(mainTrack.isForwardOrCompleted);
    } else {
      animation.setProgress(mainTrack.progress);
    }
    return animation;
  }

  @override
  AnimationStatus get status => _status;

  AnimationStatus _status = AnimationStatus.dismissed;

  @override
  void release(CueTrack anim) {}

  @override
  void setProgress(double value, {bool forward = true}) {
    for (final anim in tracks.values) {
      anim.setProgress(value, forward: forward);
    }
    _updateStatus();
  }

  void _updateStatus() {
    bool allCompleted = true;
    bool allDismissed = true;

    AnimationStatus currentStatus = _status;

    for (final d in tracks.values) {
      final s = d.status;

      if (s != AnimationStatus.completed) {
        allCompleted = false;
      }
      if (s != AnimationStatus.dismissed) {
        allDismissed = false;
      }

      if (s == AnimationStatus.forward) {
        currentStatus = AnimationStatus.forward;
        break;
      }
      if (s == AnimationStatus.reverse) {
        currentStatus = AnimationStatus.reverse;
        break;
      }
    }

    if (allCompleted) currentStatus = AnimationStatus.completed;
    if (allDismissed) currentStatus = AnimationStatus.dismissed;

    if (currentStatus != _status) {
      _status = currentStatus;
      notifyStatusListeners(_status);
    }
  }

  @override
  void prepare({required bool forward, double? from}) {
    _onPrepareNotifier.fireEvent(forward);
    _lastT = 0.0;
    for (final anim in tracks.values) {
      anim.prepare(forward: forward, from: from);
    }
    _updateStatus();
  }

  @override
  double x(double time) {
    final dt = time - _lastT;
    _lastT = time;
    if (dt > 0) {
      for (final anim in tracks.values) {
        anim.tick(dt);
      }
    }
    _updateStatus();
    return mainTrack.progress;
  }

  @override
  double dx(double time) => mainTrack.velocity;

  @override
  bool isDone(double time) => tracks.values.every((anim) => anim.isDone);

  @override
  CueTrack buildTrack(TrackConfig config) {
    return CueTrackImpl(
      config.motion,
      reverseMotion: config.reverseMotion,
      delay: config.delay,
      reverseDelay: config.reverseDelay,
      reverseType: config.reverseType,
    );
  }

  @override
  void didRegisterListener() {
    // TODO: implement didRegisterListener
  }

  @override
  void didUnregisterListener() {
    // TODO: implement didUnregisterListener
  }
}

abstract class CueTrack extends Animation<double> with AnimationLocalListenersMixin {
  void prepare({required bool forward, double? from, double? exteranlVelocity});

  CueMotion get motion;
  CueMotion? get reverseMotion;

  Duration get delay;
  Duration get reverseDelay;

  void tick(double td);

  void setProgress(double t, {bool forward = true});

  bool get isDone;

  double get velocity;

  double get progress;

  int get phase;

  @override
  void didRegisterListener() {}

  @override
  void didUnregisterListener() {}

  bool get isReverseOrDismissed => status == AnimationStatus.reverse || status == AnimationStatus.dismissed;
}

class CueTrackImpl extends CueTrack with AnimationLocalStatusListenersMixin {
  @override
  final CueMotion motion;

  @override
  final CueMotion? reverseMotion;

  @override
  final Duration delay;

  @override
  final Duration reverseDelay;

  final ReverseBehaviorType reverseType;

  double _progress = 0.0;

  @override
  double get progress => _progress;

  CueSimulation? _activeSim;

  bool _needsPrepare = false;

  late final CueSimulation _seekableSim = motion.build(true, 0, 0, 0);
  late final CueSimulation _seekableReverseSim = reverseMotion?.build(false, 0, 0, 0) ?? _seekableSim;

  double _value = 0.0;
  double _localT = 0.0;
  double _startProgress = 0.0;
  double _delaySeconds = 0.0;
  bool _done = true; 

  AnimationStatus _status = AnimationStatus.dismissed;

  CueTrackImpl(
    this.motion, {
    this.reverseMotion,
    this.delay = Duration.zero,
    this.reverseDelay = Duration.zero,
    this.reverseType = ReverseBehaviorType.mirror,
  });

  @override
  double get value => _value;

  @override
  AnimationStatus get status => _status;

  bool _forward = true;

  double _valueAtProgress(double progress, bool forward) {
    final sim = forward ? _seekableSim : _seekableReverseSim;
    final delaySeconds = (forward ? delay : reverseDelay).inMicroseconds / Duration.microsecondsPerSecond;
    final simDuration = sim.duration;
    final totalDuration = delaySeconds + simDuration;
    final simT = (progress * totalDuration - delaySeconds).clamp(0.0, simDuration);
    return sim.x(simT);
  }

  @override
  void setProgress(double t, {bool forward = true}) {
    assert(t >= 0.0 && t <= 1.0, 'Progress value must be between 0.0 and 1.0. Received: $t');
    _forward = forward;
    _needsPrepare = true;
    _progress = t;
    double newValue = _value;
    if (forward && !reverseType.isExclusive) {
      newValue = _valueAtProgress(t, true);
      _done = t >= 1.0;
    } else if (!forward && !reverseType.isNone) {
      newValue = _valueAtProgress(t, false);
      _done = t <= 0.0;
    } else {
      _done = true;
    }
    _localT = 0.0;
    _activeSim = null;
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
    _upateStatus();
  }

  @override
  void prepare({required bool forward, double? from, double? exteranlVelocity}) {
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

    final active = forward ? motion : (reverseMotion ?? motion);

    int phase = _activeSim?.phase ?? 0;
    _startProgress = from ?? _progress;

    _value = _activeSim?.lastX ??  _valueAtProgress(_startProgress, forward);


    if (reverseType.isExclusive) {
      _value = 1.0;
      phase = motion.totalPhases - 1;
    } else if (forward && reverseType.isNone) {
      _value = 0.0;
      phase = 0;
    }

    _activeSim = active.build(forward, phase, _value, exteranlVelocity ?? velocity);

    final rawDelaySeconds = (forward ? delay : reverseDelay).inMicroseconds / Duration.microsecondsPerSecond;
    final fullSimDuration = (forward ? _seekableSim : _seekableReverseSim).duration;
    final totalDuration = rawDelaySeconds + fullSimDuration;
    final elapsedTime = forward ? _startProgress * totalDuration : (1.0 - _startProgress) * totalDuration;
    _delaySeconds = (rawDelaySeconds - elapsedTime).clamp(0.0, double.infinity);

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

    final t = (_localT - _delaySeconds);
    final target = _forward ? 1.0 : 0.0;

    final simT = (_localT - _delaySeconds).clamp(0.0, double.infinity);
    final simDuration = _activeSim!.duration;
    final fraction = simDuration <= 0 ? 1.0 : (simT / simDuration).clamp(0.0, 1.0);
    _progress = _startProgress + (target - _startProgress) * fraction;

    if (_localT < _delaySeconds) return;

    if (_activeSim!.isDone(t)) {
      _value = _activeSim!.x(t);
      _done = true;
      _progress = target;
      notifyListeners();
      _upateStatus(_forward ? .completed : .dismissed);
      return;
    }
    _value = _activeSim!.x(t);
    notifyListeners();
  }

  @override
  bool get isDone => _done;

  @override
  double get velocity {
    if (_activeSim == null) return 0.0;
    final t = (_localT - _delaySeconds).clamp(0.0, double.infinity);
    return _activeSim!.dx(t);
  }

  @override
  int get phase => _activeSim?.phase ?? 0;
}

class TrackConfig {
  final CueMotion motion;
  final CueMotion? reverseMotion;
  final Duration delay;
  final Duration reverseDelay;
  final ReverseBehaviorType reverseType;

  const TrackConfig({
    required this.motion,
    this.reverseMotion,
    this.delay = Duration.zero,
    this.reverseDelay = Duration.zero,
    this.reverseType = ReverseBehaviorType.mirror,
  });

  TrackConfig copyWith({
    CueMotion? motion,
    CueMotion? reverseMotion,
    Duration? delay,
    Duration? reverseDelay,
    ReverseBehaviorType? reverseType,
  }) {
    return TrackConfig(
      motion: motion ?? this.motion,
      reverseMotion: reverseMotion ?? this.reverseMotion,
      delay: delay ?? this.delay,
      reverseDelay: reverseDelay ?? this.reverseDelay,
      reverseType: reverseType ?? this.reverseType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrackConfig &&
        other.motion == motion &&
        other.reverseMotion == reverseMotion &&
        other.delay == delay &&
        other.reverseType == reverseType &&
        other.reverseDelay == reverseDelay;
  }

  @override
  int get hashCode => Object.hash(motion, reverseMotion, delay, reverseDelay, reverseType);
}
