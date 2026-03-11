import 'dart:ui';

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

class UnboundedInterval extends Curve {
  /// Creates an interval curve.
  const UnboundedInterval(this.begin, this.end);

  /// The largest value for which this interval is 0.0.
  ///
  /// From t=0.0 to t=[begin], the interval's value is 0.0.
  final double begin;

  /// The smallest value for which this interval is 1.0.
  ///
  /// From t=[end] to t=1.0, the interval's value is 1.0.
  final double end;

  @override
  double transformInternal(double t) {
    print(t);
     assert(begin >= 0.0);
    assert(begin <= 1.0);
    assert(end >= 0.0);
    assert(end <= 1.0);
    assert(end >= begin);
    t =  (t - begin) / (end - begin);
    if (t == 0.0 || t == 1.0) {
      return t;
    }
    return t;
  }

  @override
  double transform(double t) => transformInternal(t);
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
    return curve.transform(t);
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

class UnboundedLinearCurve extends Curve {
  const UnboundedLinearCurve();

  @override
  double transformInternal(double t) => t;

  @override
  double transform(double t) => t;
}
