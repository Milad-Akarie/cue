import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/animation.dart';
import 'package:cue/src/core/curves.dart';

void main() {
  group('BoundedCurve', () {
    test('delegates to inner curve within bounds', () {
      final curve = BoundedCurve(curve: Curves.linear, min: 0.2, max: 0.8);
      // t in [0.2, 0.8] is passed as-is
      expect(curve.transform(0.5), Curves.linear.transform(0.5));
    });

    test('clamps t below min', () {
      final curve = BoundedCurve(curve: Curves.linear, min: 0.3, max: 0.7);
      // t < min is clamped to min
      expect(curve.transform(0.0), Curves.linear.transform(0.3));
      expect(curve.transform(-1.0), Curves.linear.transform(0.3));
    });

    test('clamps t above max', () {
      final curve = BoundedCurve(curve: Curves.linear, min: 0.1, max: 0.6);
      // t > max is clamped to max
      expect(curve.transform(1.0), Curves.linear.transform(0.6));
      expect(curve.transform(0.7), Curves.linear.transform(0.6));
    });

    test('works with non-linear curve', () {
      final curve = BoundedCurve(curve: Curves.easeIn, min: 0.2, max: 0.8);
      expect(curve.transform(0.2), Curves.easeIn.transform(0.2));
      expect(curve.transform(0.8), Curves.easeIn.transform(0.8));
      expect(curve.transform(0.0), Curves.easeIn.transform(0.2));
      expect(curve.transform(1.0), Curves.easeIn.transform(0.8));
    });

    test('default min/max are 0.0/1.0', () {
      final curve = BoundedCurve(curve: Curves.linear);
      expect(curve.transform(0.0), Curves.linear.transform(0.0));
      expect(curve.transform(1.0), Curves.linear.transform(1.0));
      expect(curve.transform(-1.0), Curves.linear.transform(0.0));
      expect(curve.transform(2.0), Curves.linear.transform(1.0));
    });
  });
}
