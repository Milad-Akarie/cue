import 'package:cue/cue.dart';
import 'package:cue/src/motion/simulation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'spring_motion.dart';

abstract class CueMotion {
  const CueMotion();

  int get totalPhases => 1;

  Duration get baseDuration;

  CueSimulation build(SimulationBuildData data);

  CueSimulation buildBase({bool forward = true, int? phase}) => switch (forward) {
    true => build(SimulationBuildData.forward(phase: phase ?? 0)),
    false => build(SimulationBuildData.reverse(phase: phase ?? totalPhases - 1)),
  };

  @internal
  CueMotion delayed(Duration delay) => DelayedMotion(this, delay);

  const factory CueMotion.linear(Duration duration) = TimedMotion;
  const factory CueMotion.threshold(Duration duration, {required double breakpoint}) = _ThresholdMotion;
  const factory CueMotion.curved(Duration duration, {required Curve curve}) = TimedMotion.curved;
  const factory CueMotion.easeIn(Duration duration) = TimedMotion.easeIn;
  const factory CueMotion.easeOut(Duration duration) = TimedMotion.easeOut;
  const factory CueMotion.easeInOut(Duration duration) = TimedMotion.easeInOut;
  const factory CueMotion.easeOutBack(Duration duration) = TimedMotion.easeOutBack;
  const factory CueMotion.easeInBack(Duration duration) = TimedMotion.easeInBack;
  const factory CueMotion.fastOutSlowIn(Duration duration) = TimedMotion.fastOutSlowIn;

  static const none = TimedMotion(Duration.zero);

  static const CueMotion defaultTime = TimedMotion(Duration(milliseconds: 300));

  factory CueMotion.spring({
    Duration duration,
    double bounce,
  }) = Spring;

  const factory CueMotion.smooth({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.smooth;

  const factory CueMotion.gentle({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.gentle;

  const factory CueMotion.bouncy({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.bouncy;

  const factory CueMotion.wobbly({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.wobbly;

  const factory CueMotion.snappy({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.snappy;

  const factory CueMotion.spatial({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.spatial;

  const factory CueMotion.spatialSlow({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.spatialSlow;

  const factory CueMotion.spatialFast({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.spatialFast;

  const factory CueMotion.effect({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.effect;

  const factory CueMotion.effectSlow({
    double mass,
    double stiffness,
    double dampingRatio,
    Tolerance tolerance,
    bool snapToEnd,
  }) = Spring.effectSlow;

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

class TimedMotion extends CueMotion {
  final Curve? curve;
  const TimedMotion(this.baseDuration) : curve = null;
  const TimedMotion.curved(this.baseDuration, {required Curve this.curve});
  const TimedMotion.easeIn(this.baseDuration) : curve = Curves.easeIn;
  const TimedMotion.easeOut(this.baseDuration) : curve = Curves.easeOut;
  const TimedMotion.easeInOut(this.baseDuration) : curve = Curves.easeInOut;
  const TimedMotion.easeOutBack(this.baseDuration) : curve = Curves.easeOutBack;
  const TimedMotion.easeInBack(this.baseDuration) : curve = Curves.easeInBack;
  const TimedMotion.fastOutSlowIn(this.baseDuration) : curve = Curves.fastOutSlowIn;
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
      baseDuration: baseDuration.inMilliseconds / 1000.0,
      curve: curve ?? Curves.linear,
      from: data.startValue,
      to: data.endValue,
    );
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

@visibleForTesting
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

class SimulationBuildData {
  final bool forward;
  final int phase;
  final int? endPhase;
  final double? _endValue;
  final double startValue;
  final double? startProgress;
  final double? velocity;

  double get endValue => _endValue ?? (forward ? 1.0 : 0.0);

  const SimulationBuildData({
    required this.forward,
    required this.startValue,
    this.phase = 0,
    this.endPhase,
    this.velocity,
    this.startProgress,

    double? endValue,
  }) : _endValue = endValue;

  const SimulationBuildData.forward({
    this.phase = 0,
    this.endPhase,
    this.startValue = 0.0,
    this.velocity,
    this.startProgress,
    double? endValue,
  }) : forward = true,
       _endValue = endValue;

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
