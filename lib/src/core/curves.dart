import 'package:flutter/animation.dart';

class BoundedTweenSequence<T> extends TweenSequence<T> {
  BoundedTweenSequence(super.items, {this.min = 0.0, this.max = 1.0});
  final double min;
  final double max;

  @override
  T transform(double t) {
    return super.transform(t.clamp(min, max));
  }
}

class BoundedInterval extends Interval {
  const BoundedInterval(
    super.begin,
    super.end, {
    super.curve,
    this.min = 0.0,
    this.max = 1.0,
  });
  final double min;
  final double max;

  @override
  double transform(double t) {
    return super.transform(t.clamp(min, max));
  }
}

class BoundedCurveTween extends CurveTween {
  final bool applyBounds;
  BoundedCurveTween({
    required super.curve,
    this.min = 0.0,
    this.max = 1.0,
    this.applyBounds = true,
  });

  final double min;
  final double max;

  @override
  double transform(double t) {
    if (applyBounds) {
      t = t.clamp(min, max);
    }
    return super.transform(t);
  }
}

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
