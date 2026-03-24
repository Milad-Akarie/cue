import 'package:cue/src/motion/simulation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'spring_motion.dart';

abstract class CueMotion {
  const CueMotion();

  int get totalPhases => 1;

  Duration get baseDuration;

  CueSimulation build(SimulationBuildData data);

  CueSimulation buildBase([bool forward = true]) => build(SimulationBuildData.base(forward));

  bool get isTimed => this is TimedMotion;

  bool get isSimulation => this is SimulationMotion;

  CueMotion delayed(Duration delay) => DelayedMotion(this, delay);

  const factory CueMotion.curved(
    Duration duration, {
    required Curve curve,
  }) = TimedMotion.curved;

  const factory CueMotion.linear(Duration duration) = TimedMotion;

  static const none = TimedMotion(Duration.zero);

  static const CueMotion defaultTime = TimedMotion(Duration(milliseconds: 300));

  factory CueMotion.spring({
    Duration duration,
    double bounce,
  }) = Spring;

  const factory CueMotion.smooth({
    double mass,
    double stiffness,
    double damping,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.smooth;

  const factory CueMotion.gentle({
    double mass,
    double stiffness,
    double damping,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.gentle;

  const factory CueMotion.iosDefaultSpring({
    double mass,
    double stiffness,
    double damping,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.iosDefault;

  const factory CueMotion.bouncy({
    double mass,
    double stiffness,
    double damping,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.bouncy;

  const factory CueMotion.wobbly({
    double mass,
    double stiffness,
    double damping,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.wobbly;

  const factory CueMotion.stiff({
    double mass,
    double stiffness,
    double damping,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.stiff;
}

class TimedMotion extends CueMotion {
  final Curve? curve;
  const TimedMotion(this.baseDuration) : curve = null;
  const TimedMotion.curved(this.baseDuration, {required Curve this.curve});

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
      baseDuration: baseDuration,
      curve: curve ?? Curves.linear,
      from: data.startValue,
      to: data.endValue,
    );
  }

  @override
  String toString() {
    if (curve == null) {
      return 'TimedMotion(duration: $baseDuration)';
    } else {
      return 'TimedMotion(duration: $baseDuration, curve: $curve)'; 
    }
  }
}



abstract class SimulationMotion<S extends CueSimulation> extends CueMotion {
  const SimulationMotion();
}

class SegmentedMotion extends CueMotion {
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
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SegmentedMotion &&
          runtimeType == other.runtimeType &&
          listEquals(motions, other.motions);

  @override
  int get hashCode => Object.hashAll(motions);
}

class DelayedMotion extends CueMotion {
  final CueMotion base;
  final Duration delay;

  const DelayedMotion(this.base, this.delay);

  @override
  CueMotion delayed(Duration delay) => DelayedMotion(base, delay + this.delay);

  @override
  Duration get baseDuration => base.baseDuration + delay;

  @override
  CueSimulation build(SimulationBuildData data) {
    final baseSim = base.build(data);
    double delaySeconds = delay.inMicroseconds / Duration.microsecondsPerSecond;
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

 

  @override
  String toString() => 'DelayedMotion(base: $base, delay: $delay)';
}

class SimulationBuildData {
  final bool forward;
  final int phase;
  final double startValue;
  final double? startProgress;
  final double? velocity;

  double get endValue => forward ? 1.0 : 0.0;

  const SimulationBuildData({
    required this.forward,
    required this.startValue,
    this.phase = 0,
    this.velocity,
    this.startProgress,
  });

  const SimulationBuildData.forward({
    this.phase = 0,
    this.startValue = 0.0,
    this.velocity,
    this.startProgress,
  }) : forward = true;

  const SimulationBuildData.reverse({
    this.phase = 0,
    this.startValue = 1.0,
    this.velocity,
    this.startProgress,
  }) : forward = false;

  const SimulationBuildData.base([this.forward = true])
    : phase = 0,
      startValue = forward ? 0.0 : 1.0,
      velocity = null,
      startProgress = null;
}
