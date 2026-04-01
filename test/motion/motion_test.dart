import 'package:cue/cue.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimedMotion equality', () {
    test('equal instances with same duration', () {
      const a = TimedMotion(Duration(milliseconds: 300));
      const b = TimedMotion(Duration(milliseconds: 300));
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('unequal instances with different duration', () {
      const a = TimedMotion(Duration(milliseconds: 300));
      const b = TimedMotion(Duration(milliseconds: 500));
      expect(a, isNot(equals(b)));
    });

    test('equal instances with same curve', () {
      final a = TimedMotion.curved(Duration(milliseconds: 300), curve: Curves.easeIn);
      final b = TimedMotion.curved(Duration(milliseconds: 300), curve: Curves.easeIn);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('unequal instances with different curve', () {
      final a = TimedMotion.curved(Duration(milliseconds: 300), curve: Curves.easeIn);
      final b = TimedMotion.curved(Duration(milliseconds: 300), curve: Curves.easeOut);
      expect(a, isNot(equals(b)));
    });

    test('linear vs curved are not equal', () {
      const a = TimedMotion(Duration(milliseconds: 300));
      final b = TimedMotion.curved(Duration(milliseconds: 300), curve: Curves.linear);
      expect(a, isNot(equals(b)));
    });

    test('identical instances are equal', () {
      const a = TimedMotion(Duration(milliseconds: 300));
      expect(a, equals(a));
    });

    test('none is equal to zero duration linear', () {
      expect(CueMotion.none, equals(const TimedMotion(Duration.zero)));
    });
  });

  group('Spring equality', () {
    test('equal custom springs', () {
      const a = Spring.withDampingRatio(stiffness: 100, ratio: 0.5);
      const b = Spring.withDampingRatio(stiffness: 100, ratio: 0.5);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('unequal springs with different stiffness', () {
      const a = Spring.withDampingRatio(stiffness: 100, ratio: 0.5);
      const b = Spring.withDampingRatio(stiffness: 200, ratio: 0.5);
      expect(a, isNot(equals(b)));
    });

    test('unequal springs with different dampingRatio', () {
      const a = Spring.withDampingRatio(stiffness: 100, ratio: 0.5);
      const b = Spring.withDampingRatio(stiffness: 100, ratio: 0.8);
      expect(a, isNot(equals(b)));
    });

    test('unequal springs with different mass', () {
      const a = Spring.withDampingRatio(mass: 1.0, stiffness: 100, ratio: 0.5);
      const b = Spring.withDampingRatio(mass: 2.0, stiffness: 100, ratio: 0.5);
      expect(a, isNot(equals(b)));
    });

    test('unequal springs with different snapToEnd', () {
      const a = Spring.withDampingRatio(stiffness: 100, ratio: 0.5, snapToEnd: true);
      const b = Spring.withDampingRatio(stiffness: 100, ratio: 0.5, snapToEnd: false);
      expect(a, isNot(equals(b)));
    });

    test('unequal springs with different tolerance', () {
      const a = Spring.withDampingRatio(
        stiffness: 100,
        ratio: 0.5,
        tolerance: Tolerance(distance: 0.01),
      );
      const b = Spring.withDampingRatio(
        stiffness: 100,
        ratio: 0.5,
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
      expect(const Spring.smooth(), isNot(equals(const Spring.snappy())));
      expect(const Spring.bouncy(), isNot(equals(const Spring.wobbly())));
      expect(const Spring.spatialSlow(), isNot(equals(const Spring.interactive())));
    });

    test('identical spring is equal', () {
      const a = Spring.smooth();
      expect(a, equals(a));
    });
  });

  group('SegmentedMotion equality', () {
    test('equal segmented motions with same list', () {
      const a = SegmentedMotion([
        TimedMotion(Duration(milliseconds: 200)),
        TimedMotion(Duration(milliseconds: 300)),
      ]);
      const b = SegmentedMotion([
        TimedMotion(Duration(milliseconds: 200)),
        TimedMotion(Duration(milliseconds: 300)),
      ]);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('unequal segmented motions with different list', () {
      const a = SegmentedMotion([
        TimedMotion(Duration(milliseconds: 200)),
        TimedMotion(Duration(milliseconds: 300)),
      ]);
      const b = SegmentedMotion([
        TimedMotion(Duration(milliseconds: 200)),
        TimedMotion(Duration(milliseconds: 400)),
      ]);
      expect(a, isNot(equals(b)));
    });

    test('unequal segmented motions with different length', () {
      const a = SegmentedMotion([
        TimedMotion(Duration(milliseconds: 200)),
      ]);
      const b = SegmentedMotion([
        TimedMotion(Duration(milliseconds: 200)),
        TimedMotion(Duration(milliseconds: 300)),
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
          TimedMotion(Duration(milliseconds: 100)),
          TimedMotion(Duration(milliseconds: 200)),
        ]),
      ]);
      const b = SegmentedMotion([
        SegmentedMotion([
          TimedMotion(Duration(milliseconds: 100)),
          TimedMotion(Duration(milliseconds: 200)),
        ]),
      ]);
      expect(a, equals(b));
    });

    test('identical segmented motion is equal', () {
      const a = SegmentedMotion([TimedMotion(Duration(milliseconds: 200))]);
      expect(a, equals(a));
    });
  });

  group('DelayedMotion equality', () {
    test('equal delayed motions', () {
      const a = DelayedMotion(TimedMotion(Duration(milliseconds: 300)), Duration(milliseconds: 100));
      const b = DelayedMotion(TimedMotion(Duration(milliseconds: 300)), Duration(milliseconds: 100));
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('unequal delayed motions with different base', () {
      const a = DelayedMotion(TimedMotion(Duration(milliseconds: 300)), Duration(milliseconds: 100));
      const b = DelayedMotion(TimedMotion(Duration(milliseconds: 500)), Duration(milliseconds: 100));
      expect(a, isNot(equals(b)));
    });

    test('unequal delayed motions with different delay', () {
      const a = DelayedMotion(TimedMotion(Duration(milliseconds: 300)), Duration(milliseconds: 100));
      const b = DelayedMotion(TimedMotion(Duration(milliseconds: 300)), Duration(milliseconds: 200));
      expect(a, isNot(equals(b)));
    });

    test('delayed spring vs delayed timed are not equal', () {
      const a = DelayedMotion(TimedMotion(Duration(milliseconds: 300)), Duration(milliseconds: 100));
      const b = DelayedMotion(Spring.smooth(), Duration(milliseconds: 100));
      expect(a, isNot(equals(b)));
    });

    test('identical delayed motion is equal', () {
      const a = DelayedMotion(TimedMotion(Duration(milliseconds: 300)), Duration(milliseconds: 100));
      expect(a, equals(a));
    });
  });

  group('Cross-type inequality', () {
    test('TimedMotion is not equal to Spring', () {
      const a = TimedMotion(Duration(milliseconds: 300));
      const b = Spring.smooth();
      expect(a, isNot(equals(b)));
    });

    test('TimedMotion is not equal to SegmentedMotion', () {
      const a = TimedMotion(Duration(milliseconds: 300));
      const b = SegmentedMotion([TimedMotion(Duration(milliseconds: 300))]);
      expect(a, isNot(equals(b)));
    });

    test('TimedMotion is not equal to DelayedMotion', () {
      const a = TimedMotion(Duration(milliseconds: 300));
      const b = DelayedMotion(TimedMotion(Duration(milliseconds: 300)), Duration.zero);
      expect(a, isNot(equals(b)));
    });

    test('Spring is not equal to SegmentedMotion', () {
      const a = Spring.smooth();
      const b = SegmentedMotion([Spring.smooth()]);
      expect(a, isNot(equals(b)));
    });
  });

  group('SegmentedMotion baseDuration', () {
    test('sums durations of all motions', () {
      const motion = SegmentedMotion([
        TimedMotion(Duration(milliseconds: 200)),
        TimedMotion(Duration(milliseconds: 300)),
        TimedMotion(Duration(milliseconds: 100)),
      ]);
      expect(motion.baseDuration, equals(Duration(milliseconds: 600)));
    });

    test('returns zero for empty list', () {
      const motion = SegmentedMotion([]);
      expect(motion.baseDuration, equals(Duration.zero));
    });

    test('handles single motion', () {
      const motion = SegmentedMotion([
        TimedMotion(Duration(milliseconds: 500)),
      ]);
      expect(motion.baseDuration, equals(Duration(milliseconds: 500)));
    });
  });

  group('DelayedMotion baseDuration', () {
    test('sums base duration and delay', () {
      const motion = DelayedMotion(
        TimedMotion(Duration(milliseconds: 300)),
        Duration(milliseconds: 100),
      );
      expect(motion.baseDuration, equals(Duration(milliseconds: 400)));
    });

    test('handles zero delay', () {
      const motion = DelayedMotion(
        TimedMotion(Duration(milliseconds: 300)),
        Duration.zero,
      );
      expect(motion.baseDuration, equals(Duration(milliseconds: 300)));
    });

    test('handles zero base duration', () {
      const motion = DelayedMotion(
        TimedMotion(Duration.zero),
        Duration(milliseconds: 100),
      );
      expect(motion.baseDuration, equals(Duration(milliseconds: 100)));
    });
  });

  group('DelayedMotion build with startProgress', () {
    test('builds simulation with forward startProgress', () {
      const motion = DelayedMotion(
        TimedMotion(Duration(milliseconds: 300)),
        Duration(milliseconds: 100),
      );
      final sim = motion.build(
        SimulationBuildData.forward(
          startValue: 0.0,
          startProgress: 0.5,
        ),
      );
      expect(sim, isNotNull);
      expect(sim.duration, greaterThan(0));
    });

    test('builds simulation with reverse startProgress', () {
      const motion = DelayedMotion(
        TimedMotion(Duration(milliseconds: 300)),
        Duration(milliseconds: 100),
      );
      final sim = motion.build(
        SimulationBuildData.reverse(
          startValue: 1.0,
          startProgress: 0.5,
        ),
      );
      expect(sim, isNotNull);
      expect(sim.duration, greaterThan(0));
    });

    test('builds simulation with high startProgress clamps delay', () {
      const motion = DelayedMotion(
        TimedMotion(Duration(milliseconds: 100)),
        Duration(milliseconds: 100),
      );
      final sim = motion.build(
        SimulationBuildData.forward(
          startValue: 0.0,
          startProgress: 0.9,
        ),
      );
      expect(sim, isNotNull);
    });
  });

  group('Spring constructors', () {
    test('withDampingRatio creates valid spring', () {
      final spring = Spring.withDampingRatio(stiffness: 100, ratio: 0.5);
      final desc = spring.springDescription;
      expect(desc.stiffness, equals(100));
      expect(desc.mass, equals(1.0));
    });

    test('spatialFast creates valid spring', () {
      final spring = Spring.spatialFast();
      final desc = spring.springDescription;
      expect(desc.stiffness, equals(1400.0));
      expect(desc.mass, equals(1.0));
    });

    test('spatial creates valid spring', () {
      final spring = Spring.spatial();
      final desc = spring.springDescription;
      expect(desc.stiffness, equals(700.0));
      expect(desc.mass, equals(1.0));
      expect(spring.snapToEnd, isFalse);
    });

    test('spatialSlow creates valid spring', () {
      final spring = Spring.spatialSlow();
      final desc = spring.springDescription;
      expect(desc.stiffness, equals(300.0));
      expect(desc.mass, equals(1.0));
    });

    test('effectFast creates valid spring', () {
      final spring = Spring.effectFast();
      final desc = spring.springDescription;
      expect(desc.stiffness, equals(1400.0));
      expect(desc.mass, equals(1.0));
    });

    test('effect creates valid spring', () {
      final spring = Spring.effect();
      final desc = spring.springDescription;
      expect(desc.stiffness, equals(700.0));
      expect(desc.mass, equals(1.0));
    });

    test('effectSlow creates valid spring', () {
      final spring = Spring.effectSlow();
      final desc = spring.springDescription;
      expect(desc.stiffness, equals(300.0));
      expect(desc.mass, equals(1.0));
    });
  });
}
