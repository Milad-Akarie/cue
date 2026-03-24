import 'package:cue/src/motion/cue_motion.dart';
import 'package:cue/src/motion/simulation.dart';
import 'package:flutter/widgets.dart';

// holds default values for spring simulation
const double _kStandardIosStiffness = 522.35;
const double _kStandardIosDamping = 45.7099552;
const Tolerance _kStandardIosTolerance = Tolerance(velocity: 0.03);
const Tolerance _kDefaultTolerance = Tolerance(distance: 0.01, velocity: 0.03);

final class Spring extends SimulationMotion<CueSpringSimulation> {
  final double mass;
  final double stiffness;
  final double damping;
  final Tolerance tolerance;
  final bool snapToEnd;

  const Spring.custom({
    this.mass = 1.0,
    required this.stiffness,
    required this.damping,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  });

  SpringDescription get springDescription => SpringDescription(
    mass: mass,
    stiffness: stiffness,
    damping: damping,
  );

  @override
  CueSpringSimulation build(SimulationBuildData data) {
    final view = WidgetsBinding.instance.platformDispatcher.views.firstOrNull;
    final refreshRate = view?.display.refreshRate ?? 60.0;
    return CueSpringSimulation(
      springDescription,
      data.startValue,
      data.endValue,
      data.velocity ?? 0.0,
      tolerance: tolerance,
      snapToEnd: snapToEnd,
      samplingStepSize: 1 / refreshRate,
    );
  }


  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Spring &&
        other.mass == mass &&
        other.stiffness == stiffness &&
        other.damping == damping &&
        other.tolerance == tolerance &&
        other.snapToEnd == snapToEnd;
  }

  @override
  int get hashCode {
    return Object.hash(mass, stiffness, damping, tolerance, snapToEnd);
  }

  @override
  String toString() {
    return 'Spring(mass: $mass, stiffness: $stiffness, damping: $damping, tolerance: $tolerance, snapToEnd: $snapToEnd)';
  }

  const Spring.iosDefault({
    this.mass = 1.0,
    this.stiffness = _kStandardIosStiffness,
    this.damping = _kStandardIosDamping,
    this.tolerance = _kStandardIosTolerance,
    this.snapToEnd = true,
  });

  const Spring.smooth({
    this.mass = 1.0,
    this.stiffness = 157.91,
    this.damping = 25.13,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  });

  const Spring.stiff({
    this.mass = 1.0,
    this.stiffness = 438.65,
    this.damping = 41.89,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  });

  const Spring.soft({
    this.mass = 1.0,
    this.stiffness = 100.0,
    this.damping = 10.0,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  });

  const Spring.interactive({
    this.mass = 1.0,
    this.stiffness = 1754.17,
    this.damping = 72.11,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  });

  const Spring.bouncy({
    this.mass = 1.0,
    this.stiffness = 157.91,
    this.damping = 15.08,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  });

  const Spring.wobbly({
    this.mass = 1.0,
    this.stiffness = 180.0,
    this.damping = 12.0,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  });

  const Spring.gentle({
    this.mass = 1.0,
    this.stiffness = 61.69,
    this.damping = 15.71,
    this.tolerance = _kDefaultTolerance,
    this.snapToEnd = true,
  });

  factory Spring({
    Duration duration = const Duration(milliseconds: 500),
    double bounce = 0,
  }) {
    final desc = SpringDescription.withDurationAndBounce(
      duration: duration,
      bounce: bounce,
    );
    return Spring.custom(
      mass: desc.mass,
      stiffness: desc.stiffness,
      damping: desc.damping,
    );
  }

  @override
  Duration get baseDuration {
    final sim = build(SimulationBuildData.base(true));
    return Duration(milliseconds: (sim.duration * 1000).round());
  }
}

