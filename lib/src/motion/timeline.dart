import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

abstract class CueTimeline<Driver extends CueAnimationDriver> extends Simulation {
  CueAnimationDriver driverFor(DriverConfig config);
  void prepare({required bool forward, double? from});
  void setValue(double value);
  void release(Driver anim);

  final Map<DriverConfig, Driver> drivers;

  CueTimeline(this.drivers);

  Driver buildDriver(DriverConfig config);

  void reset(DriverConfig config) {
    drivers.clear();
    drivers[config] = buildDriver(config);
  }

  void addOnPrepareListener(ValueChanged<bool> listener);
  CueMotion get mainMotion;

  Driver get mainDriver;
}

abstract class CuePlaybackTimelineBase<Driver extends CueAnimationDriver> extends CueTimeline<Driver> {
  @override
  void addOnPrepareListener(ValueChanged<bool> listener) {
    _onPrapaerNotifier.addEventListener(listener);
  }

  final _onPrapaerNotifier = EventNotifier<bool>();

  CuePlaybackTimelineBase(Driver main)
    : super({
        DriverConfig(
          motion: main.motion,
          reverseMotion: main.reverseMotion,
        ): main,
      });

  double _lastT = 0.0;

  double get elapsedSeconds => _lastT;

  @override
  Driver get mainDriver => drivers.values.first;

  @override
  CueAnimationDriver driverFor(DriverConfig config) {
    final mergedConfig = drivers.keys.first.merge(config);
    final animation = drivers.putIfAbsent(mergedConfig, () => buildDriver(mergedConfig));
    // if already animating eagerly prepare the new animation to match the current progress and velocity
    if (mainDriver.isAnimating) {
      animation.prepare(
        forward: mainDriver.isForwardOrCompleted,
        from: mainDriver.value.clamp(0, 1),
        exteranlVelocity: mainDriver.velocity,
      );
      _onPrapaerNotifier.fireEvent(mainDriver.isForwardOrCompleted);
    }
    return animation;
  }

  @override
  void release(Driver anim) {}

  @override
  void setValue(double value) {
    for (final anim in drivers.values) {
      anim.setValue(value);
    }
  }

  @override
  void prepare({required bool forward, double? from}) {
    _onPrapaerNotifier.fireEvent(forward);
    _lastT = 0.0;
    for (final anim in drivers.values) {
      anim.prepare(forward: forward, from: from);
    }
  }

  @override
  double x(double time) {
    final dt = time - _lastT;
    _lastT = time;
    if (dt > 0) {
      for (final anim in drivers.values) {
        anim.tick(dt);
      }
    }
    return mainDriver.value;
  }

  @override
  double dx(double time) => mainDriver.velocity;

  @override
  bool isDone(double time) => drivers.values.every((anim) => anim.isDone);

  @override
  CueMotion get mainMotion => drivers.keys.first.motion;
}

abstract class CueAnimationDriver extends Animation<double> with AnimationLocalStatusListenersMixin {
  void prepare({required bool forward, double? from, double? exteranlVelocity});

  CueMotion get motion;
  CueMotion? get reverseMotion;
  Duration get delay;
  Duration get reverseDelay;

  void tick(double progress);
  void setValue(double value);

  bool get isDone;

  double get velocity;

  int get phase;

  @override
  void didRegisterListener() {}

  @override
  void didUnregisterListener() {}

  bool get isReverseOrDismissed => status == AnimationStatus.reverse || status == AnimationStatus.dismissed;
}

class CuePlaybackTimeline extends CuePlaybackTimelineBase<CuePlaypackDriver> {
  CuePlaybackTimeline(super.drivers);

  @override
  CuePlaypackDriver<CueMotion> buildDriver(DriverConfig config) {
    return CuePlaypackDriver(
      config.motion,
      reverseMotion: config.reverseMotion,
      delay: config.delay ?? Duration.zero,
      reverseDelay: config.reverseDelay ?? Duration.zero,
      reverseType: config.reverseType,
    );
  }
}

class CueSeekableTimeline extends CuePlaybackTimelineBase<CueSeekableAnimationsDriver> {
  CueSeekableTimeline(double initialProgress, {AnimationStatus status = AnimationStatus.forward})
    : super(
        CueSeekableAnimationsDriver(
          .linear(.zero),
          delay: Duration.zero,
          reverseDelay: Duration.zero,
        )..seek(initialProgress, status: status),
      );

  Duration get totalDuration {
    Duration maxDuration = Duration.zero;
    for (final animation in drivers.values) {
      final duration = Duration(
        microseconds: (animation.motion.durationSeconds * Duration.microsecondsPerSecond).round(),
      );
      if (duration > maxDuration) {
        maxDuration = duration;
      }
    }
    return maxDuration;
  }

  @override
  CueSeekableAnimationsDriver buildDriver(DriverConfig config) {
    return CueSeekableAnimationsDriver(
      config.motion,
      reverseMotion: config.reverseMotion,
      delay: config.delay ?? Duration.zero,
      reverseDelay: config.reverseDelay ?? Duration.zero,
    );
  }

  double get progress => _progress;
  double _progress = 0.0;

  void seek(double progress, {AnimationStatus status = AnimationStatus.forward}) {
    if (_progress == progress && mainDriver.status == status) return;
    _progress = progress;
    for (final driver in drivers.values) {
      driver.seek(progress, status: status);
    }
  }
}

class CuePlaypackDriver<Motion extends CueMotion> extends CueAnimationDriver with AnimationLocalListenersMixin {
  @override
  final Motion motion;
  @override
  final Motion? reverseMotion;
  @override
  final Duration delay;
  @override
  final Duration reverseDelay;
  final ReverseBehaviorType reverseType;

  CueSimulation? _sim;
  double _value = 0.0;
  double _localT = 0.0;
  double _delaySeconds = 0.0;
  bool _done = true; // idle until prepared

  CuePlaypackDriver(
    this.motion, {
    this.reverseMotion,
    this.delay = Duration.zero,
    this.reverseDelay = Duration.zero,
    this.reverseType = ReverseBehaviorType.mirror,
  });

  @override
  double get value => _value;

  @override
  AnimationStatus get status {
    return switch ((_forward, _done)) {
      (true, true) => AnimationStatus.completed,
      (true, false) => AnimationStatus.forward,
      (false, true) => AnimationStatus.dismissed,
      (false, false) => AnimationStatus.reverse,
    };
  }

  bool _forward = true;

  @override
  void setValue(double value) {
    if(value == _value) return; 
    _value = value;
    notifyListeners();
  }

  @override
  void prepare({required bool forward, double? from, double? exteranlVelocity}) {
    _forward = forward;

    if (forward && reverseType.isExclusive) {
      // this drive should only drive reverse animation
      _done = true;
      return;
    }
    if (!forward && reverseType.isNone) {
      // this drive should not drive reverse animation
      _done = true;
      return;
    }

    final active = forward ? motion : (reverseMotion ?? motion);

    int phase = _sim?.phase ?? 0;
    double progress = from ?? _sim?.progress ?? _value;

    if (reverseType.isExclusive) {
      _value = 1.0;
      progress = 1.0;
      phase = motion.totalPhases - 1;
    } else if (forward && reverseType.isNone) {
      _value = 0.0;
      progress = 0.0;
      phase = 0;
    }
    _sim = active.build(forward, phase, progress, exteranlVelocity ?? velocity);
    _value = progress;
    _delaySeconds = (forward ? delay : (reverseDelay)).inMicroseconds / Duration.microsecondsPerSecond;
    _localT = 0.0;
    _done = false;
    notifyStatusListeners(status);
  }

  @override
  void tick(double progress) {
    if (_done || _sim == null) return;
    _localT += progress;
    final t = _localT - _delaySeconds;
    if (t < 0) return; // still in delay

    if (_sim!.isDone(t)) {
      _value = _sim!.x(t);
      _done = true;
      notifyListeners();
      notifyStatusListeners(_forward ? AnimationStatus.completed : AnimationStatus.dismissed);
      return;
    }
    _value = _sim!.x(t);
    // print('Ticking ${status} animation at progress ${_value.toStringAsFixed(4)}');
    notifyListeners();
  }

  @override
  bool get isDone => _done;

  @override
  double get velocity {
    if (_sim == null) return 0.0;
    final t = (_localT - _delaySeconds).clamp(0.0, double.infinity);
    return _sim!.dx(t);
  }

  @override
  int get phase => _sim?.phase ?? 0;
}

class CueSeekableAnimationsDriver extends CuePlaypackDriver<BakedMotion> {
  CueSeekableAnimationsDriver(
    CueMotion motion, {
    CueMotion? reverseMotion,
    Duration delay = Duration.zero,
    Duration reverseDelay = Duration.zero,
  }) : super(
         motion.bake(),
         reverseMotion: reverseMotion?.bake(),
         delay: delay,
         reverseDelay: reverseDelay,
       );

  void seek(double progress, {AnimationStatus status = AnimationStatus.forward}) {
    final activeMotion = status.isForwardOrCompleted ? motion : (reverseMotion ?? motion);
    final value = activeMotion.valueAt(progress);
    final valueChanged = _value != value;
    final statusChanged = status != this.status;
    if (!valueChanged && !statusChanged) return;
    _value = value;
    _forward = status.isForwardOrCompleted;
    _done = status.isCompleted || status.isDismissed;
    if (statusChanged) notifyStatusListeners(status);
    notifyListeners();
  }
}

class DriverConfig {
  final CueMotion motion;
  final CueMotion? reverseMotion;
  final Duration? delay;
  final Duration? reverseDelay;
  final ReverseBehaviorType reverseType;

  const DriverConfig({
    required this.motion,
    this.reverseMotion,
    this.delay = Duration.zero,
    this.reverseDelay = Duration.zero,
    this.reverseType = ReverseBehaviorType.mirror,
  });

  DriverConfig merge(DriverConfig other) {
    return copyWith(
      motion: other.motion,
      reverseMotion: other.reverseMotion,
      delay: other.delay,
      reverseDelay: other.reverseDelay,
      reverseType: other.reverseType,
    );
  }

  DriverConfig copyWith({
    CueMotion? motion,
    CueMotion? reverseMotion,
    Duration? delay,
    Duration? reverseDelay,
    ReverseBehaviorType? reverseType,
  }) {
    return DriverConfig(
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
    return other is DriverConfig &&
        other.motion == motion &&
        other.reverseMotion == reverseMotion &&
        other.delay == delay &&
        other.reverseType == reverseType &&
        other.reverseDelay == reverseDelay;
  }

  @override
  int get hashCode => Object.hash(motion, reverseMotion, delay, reverseDelay, reverseType);
}
