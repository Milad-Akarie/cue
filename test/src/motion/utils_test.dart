import 'package:flutter_test/flutter_test.dart';
import 'package:cue/src/motion/utils.dart';

void main() {
  group('DurationExtension', () {
    test('ms returns Duration in milliseconds', () {
      expect(500.ms, const Duration(milliseconds: 500));
      expect(0.ms, const Duration(milliseconds: 0));
      expect((-100).ms, const Duration(milliseconds: -100));
    });
    test('s returns Duration in seconds', () {
      expect(2.s, const Duration(seconds: 2));
      expect(0.s, const Duration(seconds: 0));
      expect((-3).s, const Duration(seconds: -3));
    });
  });

  group('DoubleDurationExtension', () {
    test('s returns Duration in microseconds (rounded)', () {
      expect(1.0.s, const Duration(seconds: 1));
      expect(0.5.s, const Duration(milliseconds: 500));
      expect(0.000001.s, const Duration(microseconds: 1));
      expect(1.234567.s, Duration(microseconds: 1234567));
      expect((-2.0).s, const Duration(seconds: -2));
    });
  });
}
