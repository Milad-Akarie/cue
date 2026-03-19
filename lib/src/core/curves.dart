

import 'package:flutter/material.dart';

class BoundedCurve extends Curve {
  final Curve curve;
  final double min;
  final double max;

  const BoundedCurve({
    required this.curve,
    this.min = 0.0,
    this.max = 1.0,
  });

  @override
  double transform(double t) {
    return curve.transform(t.clamp(min, max));
  }
}

 