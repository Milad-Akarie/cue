import 'package:flutter/physics.dart';

import 'cue_simulation.dart';

// holds default values for spring simulation
const double _kStandardIosStiffness = 522.35;
const double _kStandardIosDamping = 45.7099552;
const Tolerance _kStandardIosTolerance = Tolerance(velocity: 0.03);
const Tolerance _kDefaultTolerance = Tolerance(distance: 0.01, velocity: 0.03);

class Spring extends CueSimulation {
  final double mass;
  final double stiffness;
  final double damping;
  final Tolerance tolerance;
  final bool snapToEnd;

  const Spring({
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
  Simulation build(SimulationBuildData data) {
    return SpringSimulation(
      springDescription,
      data.progress,
      data.end,
      data.velocity ?? 0.0,
      tolerance: tolerance,
      snapToEnd: snapToEnd,
    );
  }

  Spring copyWith({
    double? mass,
    double? stiffness,
    double? damping,
    Tolerance? tolerance,
    bool? snapToEnd,
  }) {
    return Spring(
      mass: mass ?? this.mass,
      stiffness: stiffness ?? this.stiffness,
      damping: damping ?? this.damping,
      tolerance: tolerance ?? this.tolerance,
      snapToEnd: snapToEnd ?? this.snapToEnd,
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

  factory Spring.withDurationAndBounce({
    Duration duration = const Duration(milliseconds: 500),
    double bounce = 0,
  }) {
    final desc = SpringDescription.withDurationAndBounce(
      duration: duration,
      bounce: bounce,
    );
    return Spring(
      mass: desc.mass,
      stiffness: desc.stiffness,
      damping: desc.damping,
    );
  }
}
