import 'package:cue/cue.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimedMotion equality', () {
    test('equal instances with same duration', () {
      const a = TimedMotion(0.3);
      const b = TimedMotion(0.3);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('unequal instances with different duration', () {
      const a = TimedMotion(0.3);
      const b = TimedMotion(0.5);
      expect(a, isNot(equals(b)));
    });

    test('equal instances with same curve', () {
      final a = TimedMotion.curved(0.3, curve: Curves.easeIn);
      final b = TimedMotion.curved(0.3, curve: Curves.easeIn);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('unequal instances with different curve', () {
      final a = TimedMotion.curved(0.3, curve: Curves.easeIn);
      final b = TimedMotion.curved(0.3, curve: Curves.easeOut);
      expect(a, isNot(equals(b)));
    });

    test('linear vs curved are not equal', () {
      const a = TimedMotion(0.3);
      final b = TimedMotion.curved(0.3, curve: Curves.linear);
      expect(a, isNot(equals(b)));
    });

    test('identical instances are equal', () {
      const a = TimedMotion(0.3);
      expect(a, equals(a));
    });

    test('none is equal to zero duration linear', () {
      expect(CueMotion.none, equals(const TimedMotion(0.0)));
    });
  });

  group('Spring equality', () {
    test('equal custom springs', () {
      const a = Spring.custom(stiffness: 100, damping: 10);
      const b = Spring.custom(stiffness: 100, damping: 10);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('unequal springs with different stiffness', () {
      const a = Spring.custom(stiffness: 100, damping: 10);
      const b = Spring.custom(stiffness: 200, damping: 10);
      expect(a, isNot(equals(b)));
    });

    test('unequal springs with different damping', () {
      const a = Spring.custom(stiffness: 100, damping: 10);
      const b = Spring.custom(stiffness: 100, damping: 20);
      expect(a, isNot(equals(b)));
    });

    test('unequal springs with different mass', () {
      const a = Spring.custom(mass: 1.0, stiffness: 100, damping: 10);
      const b = Spring.custom(mass: 2.0, stiffness: 100, damping: 10);
      expect(a, isNot(equals(b)));
    });

    test('unequal springs with different snapToEnd', () {
      const a = Spring.custom(stiffness: 100, damping: 10, snapToEnd: true);
      const b = Spring.custom(stiffness: 100, damping: 10, snapToEnd: false);
      expect(a, isNot(equals(b)));
    });

    test('unequal springs with different tolerance', () {
      const a = Spring.custom(
        stiffness: 100,
        damping: 10,
        tolerance: Tolerance(distance: 0.01),
      );
      const b = Spring.custom(
        stiffness: 100,
        damping: 10,
        tolerance: Tolerance(distance: 0.02),
      );
      expect(a, isNot(equals(b)));
    });

    test('preset springs with same values are equal', () {
      const a = Spring.smooth();
      const b = Spring.smooth();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different presets are not equal', () {
      expect(const Spring.smooth(), isNot(equals(const Spring.gentle())));
      expect(const Spring.smooth(), isNot(equals(const Spring.stiff())));
      expect(const Spring.bouncy(), isNot(equals(const Spring.wobbly())));
      expect(const Spring.iosDefault(), isNot(equals(const Spring.interactive())));
    });

    test('identical spring is equal', () {
      const a = Spring.smooth();
      expect(a, equals(a));
    });
  });

  group('SegmentedMotion equality', () {
    test('equal segmented motions with same list', () {
      const a = SegmentedMotion([
        TimedMotion(0.2),
        TimedMotion(0.3),
      ]);
      const b = SegmentedMotion([
        TimedMotion(0.2),
        TimedMotion(0.3),
      ]);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('unequal segmented motions with different list', () {
      const a = SegmentedMotion([
        TimedMotion(0.2),
        TimedMotion(0.3),
      ]);
      const b = SegmentedMotion([
        TimedMotion(0.2),
        TimedMotion(0.4),
      ]);
      expect(a, isNot(equals(b)));
    });

    test('unequal segmented motions with different length', () {
      const a = SegmentedMotion([
        TimedMotion(0.2),
      ]);
      const b = SegmentedMotion([
        TimedMotion(0.2),
        TimedMotion(0.3),
      ]);
      expect(a, isNot(equals(b)));
    });

    test('empty segmented motions are equal', () {
      const a = SegmentedMotion([]);
      const b = SegmentedMotion([]);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('nested segmented motions compare deeply', () {
      const a = SegmentedMotion([
        SegmentedMotion([
          TimedMotion(0.1),
          TimedMotion(0.2),
        ]),
      ]);
      const b = SegmentedMotion([
        SegmentedMotion([
          TimedMotion(0.1),
          TimedMotion(0.2),
        ]),
      ]);
      expect(a, equals(b));
    });

    test('identical segmented motion is equal', () {
      const a = SegmentedMotion([TimedMotion(0.2)]);
      expect(a, equals(a));
    });
  });

  group('DelayedMotion equality', () {
    test('equal delayed motions', () {
      const a = DelayedMotion(TimedMotion(0.3), 0.1);
      const b = DelayedMotion(TimedMotion(0.3), 0.1);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('unequal delayed motions with different base', () {
      const a = DelayedMotion(TimedMotion(0.3), 0.1);
      const b = DelayedMotion(TimedMotion(0.5), 0.1);
      expect(a, isNot(equals(b)));
    });

    test('unequal delayed motions with different delay', () {
      const a = DelayedMotion(TimedMotion(0.3), 0.1);
      const b = DelayedMotion(TimedMotion(0.3), 0.2);
      expect(a, isNot(equals(b)));
    });

    test('delayed spring vs delayed timed are not equal', () {
      const a = DelayedMotion(TimedMotion(0.3), 0.1);
      const b = DelayedMotion(Spring.smooth(), 0.1);
      expect(a, isNot(equals(b)));
    });

    test('identical delayed motion is equal', () {
      const a = DelayedMotion(TimedMotion(0.3), 0.1);
      expect(a, equals(a));
    });
  });

  group('Cross-type inequality', () {
    test('TimedMotion is not equal to Spring', () {
      const a = TimedMotion(0.3);
      const b = Spring.smooth();
      expect(a, isNot(equals(b)));
    });

    test('TimedMotion is not equal to SegmentedMotion', () {
      const a = TimedMotion(0.3);
      const b = SegmentedMotion([TimedMotion(0.3)]);
      expect(a, isNot(equals(b)));
    });

    test('TimedMotion is not equal to DelayedMotion', () {
      const a = TimedMotion(0.3);
      const b = DelayedMotion(TimedMotion(0.3), 0.0);
      expect(a, isNot(equals(b)));
    });

    test('Spring is not equal to SegmentedMotion', () {
      const a = Spring.smooth();
      const b = SegmentedMotion([Spring.smooth()]);
      expect(a, isNot(equals(b)));
    });
  });
}
