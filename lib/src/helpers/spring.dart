// holds default values for spring simulation
import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';

const double _kStandardIosStiffness = 522.35;
const double _kStandardIosDamping = 45.7099552;
const Tolerance _kStandardIosTolerance = Tolerance(velocity: 0.03);

class Spring {
  static SpringSimulation withDurationAndBounce({
    Duration duration = const Duration(milliseconds: 500),
    double bounce = 0,
  }) {
    return SpringSimulation(
      SpringDescription.withDurationAndBounce(
        duration: duration,
        bounce: bounce,
      ),
      0,
      1,
      0,
    );
  }

  static SpringSimulation buildIosStyle({
    double mass = 1,
    double stiffness = _kStandardIosStiffness,
    double damping = _kStandardIosDamping,
    bool forward = true,
    Tolerance tolerance = _kStandardIosTolerance,
    bool snapToEnd = true,
  }) {
    return SpringSimulation(
      SpringDescription(
        mass: mass,
        stiffness: stiffness,
        damping: damping,
      ),
      forward ? 0.0 : 1.0,
      forward ? 1.0 : 0.0,
      0,
      tolerance: tolerance,
      snapToEnd: snapToEnd,
    );
  }

  static SpringSimulation build({
    double mass = 1,
    double stiffness = 100,
    double damping = 10,
    double initialVelocity = 0,
    bool snapToEnd = false,
    Tolerance tolerance = Tolerance.defaultTolerance,
    double start = 0,
    double end = 1,
  }) {
    return SpringSimulation(
      SpringDescription(
        mass: mass,
        stiffness: stiffness,
        damping: damping,
      ),
      start,
      end,
      initialVelocity,
      tolerance: tolerance,
      snapToEnd: snapToEnd,
    );
  }

  static final SpringSimulation smooth = SpringSimulation(
    SpringDescription(
      mass: 1,
      stiffness: 100,
      damping: 10,
    ),
    0,
    1,
    0,
  );

  static final SpringSimulation bouncy = SpringSimulation(
    SpringDescription(
      mass: 1,
      stiffness: 100,
      damping: 7, // ζ ≈ 0.35 - balanced bounce
    ),
    0,
    1,
    0,
  );

  static final SpringSimulation snappy = SpringSimulation(
    SpringDescription(
      mass: 1,
      stiffness: 100,
      damping: 20,
    ),
    0,
    1,
    0,
  );
}

extension SpringSimulationAsCurve on SpringSimulation {
  Curve get curve => SpringCurve(this);
}

class SpringCurve extends Curve {
  final SpringSimulation simulation;

  const SpringCurve(this.simulation);

  @override
  double transform(double t) {
    return simulation.x(t) + t * (1 - simulation.x(1.0));
  }
}
