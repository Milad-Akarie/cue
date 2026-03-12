import 'dart:ui';

import 'package:cue/src/motion/cue_motion.dart';
import 'package:flutter/material.dart';

abstract class Timeline {
  SimulationAnimation animationFor(AnimationConfig config);
  void prepare({required bool forward, double velocity = 0.0});
  void release(SimulationAnimation anim);
}

class AnimationsSetImpl extends Simulation implements Timeline {
  final Map<AnimationConfig, SimulationAnimation> _animations;

  AnimationsSetImpl(SimulationAnimationImpl main)
    : _animations = {
        AnimationConfig(motion: main.motion, reverseMotion: main.reverseMotion): main,
      };

  double _lastT = 0.0;

  SimulationAnimation get _mainAnim => _animations.values.first;

  @override
  SimulationAnimation animationFor(AnimationConfig config) {
    final mainConfig = _animations.keys.first;
    final forwardMotion = config.motion ?? mainConfig.motion!;
    final reverseMotion = config.reverseMotion ?? mainConfig.reverseMotion;
    final key = config.copyWith(motion: forwardMotion, reverseMotion: reverseMotion);
    return _animations.putIfAbsent(
      key,
      () => SimulationAnimationImpl(
        forwardMotion,
        reverseMotion: reverseMotion,
        delay: config.delay ?? Duration.zero,
        reverseDelay: config.reverseDelay ?? Duration.zero,
      ),
    );
  }

  @override
  void release(SimulationAnimation anim) {
    assert(_animations.values.first != anim, "Cannot remove main animation from ProxySimulation");
  }

  @override
  void prepare({required bool forward, double velocity = 0.0}) {
    _lastT = 0.0;
    for (final anim in _animations.values) {
      anim.prepare(forward: forward, velocity: velocity);
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
    return _mainAnim.value;
  }

  @override
  double dx(double time) => _mainAnim.velocity;

  @override
  bool isDone(double time) => _animations.values.every((anim) => anim.isDone);
}

abstract class SimulationAnimation extends Animation<double> with AnimationLocalStatusListenersMixin {
  void prepare({required bool forward, double velocity = 0.0});

  void advance(double progress);

  bool get isDone;

  double get velocity;

  @override
  void didRegisterListener() {}

  @override
  void didUnregisterListener() {}
}

class SimulationAnimationImpl extends SimulationAnimation with AnimationLocalListenersMixin {
  final CueMotion motion;
  final CueMotion? reverseMotion;
  final Duration delay;
  final Duration reverseDelay;

  Simulation? _sim;
  double _value = 0.0;
  double _localT = 0.0;
  double _delaySeconds = 0.0;
  bool _done = true; // idle until prepared

  SimulationAnimationImpl(
    this.motion, {
    this.reverseMotion,
    this.delay = Duration.zero,
    this.reverseDelay = Duration.zero,
  });

  // ── public ─────────────────────────────────────────────────────────────────

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

  // ── lifecycle ──────────────────────────────────────────────────────────────

  @override
  void prepare({required bool forward, double velocity = 0.0}) {
    _forward = forward;
    final active = forward ? motion : (reverseMotion ?? motion);
    _sim = active.build(forward, _value, velocity);
    _delaySeconds = (forward ? delay : (reverseDelay ?? delay)).inMicroseconds / Duration.microsecondsPerSecond;
    _localT = 0.0;
    _done = false;
  }

  // ── tick ───────────────────────────────────────────────────────────────────

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
}

class ProgressAnimationsSet extends SimulationAnimation with AnimationLocalListenersMixin implements Timeline {
  double _value;
  AnimationStatus _status;

  ProgressAnimationsSet(this._value, {AnimationStatus status = AnimationStatus.completed}) : _status = status;

  final Map<AnimationConfig, SimulationAnimation> _animations = {};

  final _linearMotion = const LinearSimulationMotion();

  @override
  SimulationAnimation animationFor(AnimationConfig config) {
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
  void prepare({required bool forward, double velocity = 0.0}) {
    // no-op
  }

  @override
  void release(SimulationAnimation anim) {
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
    if (valueChanged) notifyListeners();
  }

  @override
  bool get isDone => _status.isCompleted || _status.isDismissed;

  @override
  double get velocity => 0.0;
}

class BakedSimulationAnimation extends SimulationAnimation with AnimationLocalListenersMixin {
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
  void prepare({required bool forward, double velocity = 0.0}) {
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

class AnimationConfig {
  final CueMotion? motion;
  final CueMotion? reverseMotion;
  final Duration? delay;
  final Duration? reverseDelay;

  const AnimationConfig({
    this.motion,
    this.reverseMotion,
    this.delay = Duration.zero,
    this.reverseDelay = Duration.zero,
  });

  AnimationConfig copyWith({
    CueMotion? motion,
    CueMotion? reverseMotion,
    Duration? delay,
    Duration? reverseDelay,
  }) {
    return AnimationConfig(
      motion: motion ?? this.motion,
      reverseMotion: reverseMotion ?? this.reverseMotion,
      delay: delay ?? this.delay,
      reverseDelay: reverseDelay ?? this.reverseDelay,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnimationConfig &&
        other.motion == motion &&
        other.reverseMotion == reverseMotion &&
        other.delay == delay &&
        other.reverseDelay == reverseDelay;
  }

  @override
  int get hashCode => Object.hash(motion, reverseMotion, delay, reverseDelay);
}
