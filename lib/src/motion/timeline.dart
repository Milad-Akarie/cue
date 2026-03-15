import 'dart:ui';

import 'package:cue/src/acts/base/tween_act.dart';
import 'package:cue/src/motion/cue_motion.dart';
import 'package:flutter/material.dart';

abstract class CueTimeline {
  CueAnimationDriver driverFor(DriverConfig config);
  void prepare({required bool forward});
  void release(CueAnimationDriver anim);

  CueMotion get mainMotion;
}

class CueTimelineImpl extends Simulation implements CueTimeline {
  final Map<DriverConfig, CueAnimationDriver> _animations;

  CueTimelineImpl(CueAnimationDriverImpl main)
    : _animations = {
        DriverConfig(motion: main.motion, reverseMotion: main.reverseMotion): main,
      };

  double _lastT = 0.0;

  CueAnimationDriver get mainAnimation => _animations.values.first;

  @override
  CueAnimationDriver driverFor(DriverConfig config) {
    final mainConfig = _animations.keys.first;
    final forwardMotion = config.motion ?? mainConfig.motion!;
    final reverseMotion = config.reverseMotion ?? mainConfig.reverseMotion;
    final key = config.copyWith(motion: forwardMotion, reverseMotion: reverseMotion);
    final animation = _animations.putIfAbsent(
      key,
      () => CueAnimationDriverImpl(
        forwardMotion,
        reverseMotion: reverseMotion,
        delay: config.delay ?? Duration.zero,
        reverseDelay: config.reverseDelay ?? Duration.zero,
        reverseType: config.reverseType,
      ),
    );

    // if already animating eagerly prepare the new animation to match the current progress and velocity
    if (mainAnimation.isAnimating) {
      animation.prepare(
        forward: mainAnimation.isForwardOrCompleted,
        velocity: mainAnimation.velocity,
      );
    }
    return animation;
  }

  @override
  void release(CueAnimationDriver anim) {
    assert(_animations.values.first != anim, "Cannot remove main animation from ProxySimulation");
  }

  @override
  void prepare({required bool forward}) {
    _lastT = 0.0;
    for (final anim in _animations.values) {
      anim.prepare(forward: forward);
    }
  }

  @override
  double x(double time) {
    final dt = time - _lastT;
    _lastT = time;
    if (dt > 0) {
      for (final anim in _animations.values) {
        anim.advance(dt);
      }
    }
    return mainAnimation.value;
  }

  @override
  double dx(double time) => mainAnimation.velocity;

  @override
  bool isDone(double time) => _animations.values.every((anim) => anim.isDone);

  @override
  CueMotion get mainMotion => _animations.keys.first.motion!;
}

abstract class CueAnimationDriver extends Animation<double> with AnimationLocalStatusListenersMixin {
  void prepare({required bool forward, double? velocity});

  void advance(double progress);

  bool get isDone;

  double get velocity;

  int get phase;

  @override
  void didRegisterListener() {}

  @override
  void didUnregisterListener() {}

  bool get isReverseOrDismissed => status == AnimationStatus.reverse || status == AnimationStatus.dismissed;
}

class CueAnimationDriverImpl extends CueAnimationDriver with AnimationLocalListenersMixin {
  final CueMotion motion;
  final CueMotion? reverseMotion;
  final Duration delay;
  final Duration reverseDelay;
  final ReverseBehaviorType reverseType;

  CueSimulation? _sim;
  double _value = 0.0;
  double _localT = 0.0;
  double _delaySeconds = 0.0;
  bool _done = true; // idle until prepared

  CueAnimationDriverImpl(
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
  void prepare({required bool forward, double? velocity}) {
    _forward = forward;

    if (forward && reverseType == ReverseBehaviorType.exclusive) {
      // this drive should only drive reverse animation
      return;
    }
    if (!forward && reverseType == ReverseBehaviorType.none) {
      // this drive should not drive reverse animation
      return;
    }

    final active = forward ? motion : (reverseMotion ?? motion);
    _sim = active.build(forward, _sim?.phase ?? 0, _sim?.progress ?? _value, velocity ?? this.velocity);
    _delaySeconds = (forward ? delay : (reverseDelay)).inMicroseconds / Duration.microsecondsPerSecond;
    _localT = 0.0;
    _done = false;
    notifyStatusListeners(status);
  }

  @override
  void advance(double progress) {
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

class CueProgressAnimations extends CueAnimationDriver with AnimationLocalListenersMixin implements CueTimeline {
  double _value;
  AnimationStatus _status;

  CueProgressAnimations(this._value, {AnimationStatus status = AnimationStatus.completed}) : _status = status;

  final Map<DriverConfig, BakedSimulationAnimation> _animations = {};

  final _linearMotion = const LinearSimulationMotion();

  @override
  CueAnimationDriver driverFor(DriverConfig config) {
    if (config.motion == null && config.reverseMotion == null) {
      return this;
    }
    final key = config.copyWith(
      motion: config.motion ?? _linearMotion,
      reverseMotion: config.reverseMotion ?? _linearMotion,
      // ignore delay for progress-based animations since the progress itself determines the timing
      delay: .zero,
      reverseDelay: .zero,
    );
    return _animations.putIfAbsent(
      key,
      () => BakedSimulationAnimation(key.motion!, reverseMotion: key.reverseMotion),
    );
  }

  @override
  double get value => _value;

  @override
  void prepare({required bool forward, double? velocity}) {
    // no-op
  }

  @override
  void release(CueAnimationDriver anim) {
    // TODO: implement release
  }

  @override
  AnimationStatus get status => _status;

  @override
  void advance(double value, {AnimationStatus status = AnimationStatus.forward}) {
    final valueChanged = _value != value;
    final statusChanged = _status != status;

    if (!valueChanged && !statusChanged) return;
    _value = value;
    _status = status;

    if (statusChanged) notifyStatusListeners(status);
    if (valueChanged) {
      for (final anim in _animations.values) {
        anim.advance(value, status: status);
      }
      notifyListeners();
    }
  }

  @override
  bool get isDone => _status.isCompleted || _status.isDismissed;

  @override
  double get velocity => 0.0;

  @override
  int get phase => 0;

  @override
  CueMotion get mainMotion => const LinearSimulationMotion();
}

class BakedSimulationAnimation extends CueAnimationDriver with AnimationLocalListenersMixin {
  final BakedMotion motion;
  final BakedMotion? reverseMotion;

  double _value = 0.0;

  BakedSimulationAnimation(CueMotion motion, {CueMotion? reverseMotion})
    : motion = motion.bake(),
      reverseMotion = reverseMotion?.bake();

  @override
  double get value => _value;

  AnimationStatus _status = AnimationStatus.completed;

  @override
  AnimationStatus get status => _status;

  @override
  void prepare({required bool forward, double? velocity}) {
    // no-op we're using pre-baked values
  }

  @override
  void advance(double progress, {AnimationStatus status = AnimationStatus.forward}) {
    final activeMotion = _status.isForwardOrCompleted ? motion : (reverseMotion ?? motion);
    final value = activeMotion.valueAt(progress);
    final valueChanged = _value != value;
    final statusChanged = _status != status;
    if (!valueChanged && !statusChanged) return;
    _value = value;
    _status = status;
    if (statusChanged) notifyStatusListeners(status);
    notifyListeners();
  }

  @override
  bool get isDone => false;

  @override
  double get velocity => 0.0;

  @override
  int get phase => 0;
}

class BakedMotion {
  final List<double> samples;
  final double durationSeconds;
  final CueMotion motion;
  final double Function(double progress, List<double> samples) valueGetter;

  const BakedMotion({
    required this.motion,
    required this.samples,
    required this.durationSeconds,
    this.valueGetter = _defaultValueGetter,
  });

  static double _defaultValueGetter(double progress, List<double> samples) {
    final scaled = progress * (samples.length - 1);
    final lo = samples[scaled.floor()];
    final hi = samples[scaled.ceil()];
    return lerpDouble(lo, hi, scaled - scaled.floor())!;
  }

  double valueAt(double progress) => valueGetter(progress, samples);
}

class DriverConfig {
  final CueMotion? motion;
  final CueMotion? reverseMotion;
  final Duration? delay;
  final Duration? reverseDelay;
  final ReverseBehaviorType reverseType;

  const DriverConfig({
    this.motion,
    this.reverseMotion,
    this.delay = Duration.zero,
    this.reverseDelay = Duration.zero,
    this.reverseType = ReverseBehaviorType.mirror,
  });

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
