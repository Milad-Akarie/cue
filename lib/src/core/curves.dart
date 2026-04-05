

import 'package:flutter/material.dart';

/// A curve that constrains the input value [t] to a normalized range [min, max].
///
/// This ensures that the underlying [curve] receives only values within the
/// specified bounds, preventing non-normalized `t` values from causing
/// unexpected behavior.
class BoundedCurve extends Curve {
  /// The underlying curve to transform the bounded value.
  final Curve curve;

  /// The minimum bound for the input value (default: 0.0).
  final double min;

  /// The maximum bound for the input value (default: 1.0).
  final double max;

  const BoundedCurve({
    required this.curve,
    this.min = 0.0,
    this.max = 1.0,
  });

  @override
  double transform(double t) {
    /// Clamps [t] to the [min, max] range before applying the curve transformation.
    return curve.transform(t.clamp(min, max));
  }
}

 