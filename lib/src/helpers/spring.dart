// holds default values for spring simulation
import 'package:flutter/cupertino.dart';
import 'package:flutter/physics.dart';

const double _kStandardIosStiffness = 522.35;
const double _kStandardIosDamping = 45.7099552;
const Tolerance _kStandardIosTolerance = Tolerance(velocity: 0.03);

class Spring extends SpringSimulation {
  final SpringDescription _springDesc;
  final double _start;
  final double _end;
  final double _velocity;
  final bool _snapToEnd;

  Spring(
    super.spring,
    super.start,
    super.end,
    super.velocity, {
    super.tolerance,
    super.snapToEnd,
  }) : _springDesc = spring,
       _start = start,
       _end = end,
       _velocity = velocity,
       _snapToEnd = snapToEnd;

  Spring copyWith({
    SpringDescription? spring,
    double? start,
    double? end,
    double? velocity,
    Tolerance? tolerance,
    bool? snapToEnd,
  }) {
    return Spring(
      spring ?? _springDesc,
      start ?? _start,
      end ?? _end,
      velocity ?? _velocity,
      snapToEnd: snapToEnd ?? _snapToEnd,
      tolerance: tolerance ?? this.tolerance,
    );
  }

  Curve get curve => SpringCurve(this);

  Spring withDirection(bool forward) {
    final start = forward ? 0.0 : 1.0;
    if (start == _start) return this;
    return copyWith(
      start: start,
      end: forward ? 1.0 : 0.0,
    );
  }

  factory Spring.iosDefault([bool forward = true]) => Spring(
    SpringDescription(
      mass: 1.0,
      stiffness: _kStandardIosStiffness,
      damping: _kStandardIosDamping,
    ),
    forward ? 0.0 : 1.0,
    forward ? 1.0 : 0.0,
    0.0,
    tolerance: _kStandardIosTolerance,
    snapToEnd: true,
  );

  factory Spring.smooth([bool forward = true]) => Spring(
    SpringDescription(
      mass: 1.0,
      stiffness: 157.91,
      damping: 25.13,
    ),
    forward ? 0.0 : 1.0,
    forward ? 1.0 : 0.0,
    0.0,
    tolerance: Tolerance(distance: 0.01, velocity: 0.03),
    snapToEnd: true,
  );

  factory Spring.snappy([bool forward = true]) => Spring(
    SpringDescription(
      mass: 1.0,
      stiffness: 246.74,
      damping: 26.70,
    ),
    forward ? 0.0 : 1.0,
    forward ? 1.0 : 0.0,
    0.0,
    tolerance: Tolerance(distance: 0.01, velocity: 0.03),
    snapToEnd: true,
  );

  factory Spring.bouncy([bool forward = true]) => Spring(
    SpringDescription(
      mass: 1.0,
      stiffness: 157.91,
      damping: 15.08,
    ),
    forward ? 0.0 : 1.0,
    forward ? 1.0 : 0.0,
    0.0,
    tolerance: Tolerance(distance: 0.01, velocity: 0.03),
    snapToEnd: true,
  );

  factory Spring.interactive([bool forward = true]) => Spring(
    SpringDescription(
      mass: 1.0,
      stiffness: 1754.17,
      damping: 72.11,
    ),
    forward ? 0.0 : 1.0,
    forward ? 1.0 : 0.0,
    0.0,
    tolerance: Tolerance(distance: 0.01, velocity: 0.03),
    snapToEnd: true,
  );

  factory Spring.gentle([bool forward = true]) => Spring(
    SpringDescription(
      mass: 1.0,
      stiffness: 61.69,
      damping: 15.71,
    ),
    forward ? 0.0 : 1.0,
    forward ? 1.0 : 0.0,
    0.0,
    tolerance: Tolerance(distance: 0.01, velocity: 0.03),
    snapToEnd: true,
  );

  factory Spring.stiff([bool forward = true]) => Spring(
    SpringDescription(
      mass: 1.0,
      stiffness: 438.65,
      damping: 41.89,
    ),
    forward ? 0.0 : 1.0,
    forward ? 1.0 : 0.0,
    0.0,
    tolerance: Tolerance(distance: 0.01, velocity: 0.03),
    snapToEnd: true,
  );

  factory Spring.withDurationAndBounce({
    Duration duration = const Duration(milliseconds: 500),
    double bounce = 0,
    bool forward = true,
  }) {
    return Spring(
      SpringDescription.withDurationAndBounce(
        duration: duration,
        bounce: bounce,
      ),
      forward ? 0.0 : 1.0,
      forward ? 1.0 : 0.0,
      0,
      tolerance: Tolerance(distance: 0.01, velocity: 0.03),
      snapToEnd: true,
    );
  }
}

class SpringCurve extends Curve {
  final SpringSimulation simulation;

  const SpringCurve(this.simulation);

  @override
  double transform(double t) {
    return simulation.x(t) + t * (1 - simulation.x(1.0));
  }
}
