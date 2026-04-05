import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/src/core/keyframes.dart';
import 'package:cue/src/motion/cue_motion.dart';

void main() {
  group('Phase.resolveFractionalFrames', () {
    test('empty list returns empty', () {
      final phases = Phase.resolveFractionalFrames([], transform: (v) => v);
      expect(phases, isEmpty);
    });

    test('single fractional keyframe returns constant phase', () {
      final frames = [FractionalKeyframe.key(100.0, at: 0.0)];
      final phases = Phase.resolveFractionalFrames<double, double>(frames, transform: (v) => v);
      expect(phases, [const Phase(begin: 100.0, end: 100.0)]);
    });

    test('two fractional keyframes produce one phase', () {
      final frames = [
        FractionalKeyframe.key(0.0, at: 0.0),
        FractionalKeyframe.key(100.0, at: 1.0),
      ];
      final phases = Phase.resolveFractionalFrames<double, double>(frames, transform: (v) => v);
      expect(phases, [const Phase(begin: 0.0, end: 100.0)]);
    });

    test('duplicates at same time keep last value', () {
      final frames = [
        FractionalKeyframe.key(10.0, at: 0.0),
        FractionalKeyframe.key(20.0, at: 0.0),
        FractionalKeyframe.key(30.0, at: 1.0),
      ];
      final phases = Phase.resolveFractionalFrames<double, double>(frames, transform: (v) => v);
      // First time 0.0 should use last value 20.0 -> phase: 20 -> 30
      expect(phases, [const Phase(begin: 20.0, end: 30.0)]);
    });

  });

  group('Phase.resolveMotionFrames', () {
    test('empty list returns empty', () {
      final phases = Phase.resolveMotionFrames<double, double>([], transform: (v) => v);
      expect(phases, isEmpty);
    });

    test('motion keyframes produce phases preserving order', () {
      final frames = [
        Keyframe.key(0.0, motion: CueMotion.none),
        Keyframe.key(50.0, motion: CueMotion.linear(const Duration(milliseconds: 100))),
        Keyframe.key(100.0, motion: CueMotion.none),
      ];
      final phases = Phase.resolveMotionFrames<double, double>(frames, transform: (v) => v);
      expect(phases, [
        const Phase(begin: 0.0, end: 50.0),
        const Phase(begin: 50.0, end: 100.0),
      ]);
    });

    test('from value is respected when provided', () {
      final frames = [Keyframe.key(10.0, motion: CueMotion.none)];
      final phases = Phase.resolveMotionFrames<double, double>(frames, from: 0.0, transform: (v) => v);
      expect(phases, [const Phase(begin: 0.0, end: 10.0)]);
    });
  });

  group('Phase equality', () {
    test('identical begin/end are equal', () {
      const a = Phase(begin: 0.0, end: 100.0);
      const b = Phase(begin: 0.0, end: 100.0);
      expect(a, equals(b));
    });

    test('different begin or end are not equal', () {
      const a = Phase(begin: 0.0, end: 100.0);
      const b = Phase(begin: 10.0, end: 100.0);
      const c = Phase(begin: 0.0, end: 50.0);
      expect(a, isNot(equals(b)));
      expect(a, isNot(equals(c)));
    });
  });
  group('Keyframe equality', () {
    test('identical Keyframe are equal', () {
      const a = Keyframe.key(42, motion: CueMotion.none);
      const b = Keyframe.key(42, motion: CueMotion.none);
      expect(a, equals(b));
    });
    test('different value or motion are not equal', () {
      const a = Keyframe.key(42, motion: CueMotion.none);
      const b = Keyframe.key(43, motion: CueMotion.none);
      const c = Keyframe.key(42, motion: CueMotion.linear(Duration(milliseconds: 1)));
      expect(a, isNot(equals(b)));
      expect(a, isNot(equals(c)));
    });
  });

  group('FractionalKeyframe equality', () {
    test('identical FractionalKeyframe are equal', () {
      const a = FractionalKeyframe.key(42, at: 0.5);
      const b = FractionalKeyframe.key(42, at: 0.5);
      expect(a, equals(b));
    });
    test('different value or at or curve are not equal', () {
      const a = FractionalKeyframe.key(42, at: 0.5);
      const b = FractionalKeyframe.key(43, at: 0.5);
      const c = FractionalKeyframe.key(42, at: 0.6);
      const d = FractionalKeyframe.key(42, at: 0.5, curve: Curves.easeIn);
      expect(a, isNot(equals(b)));
      expect(a, isNot(equals(c)));
      expect(a, isNot(equals(d)));
    });
  });

  group('MotionKeyframes and FractionalKeyframes equality', () {
    test('identical MotionKeyframes are equal', () {
      final a = MotionKeyframes([Keyframe.key(1, motion: CueMotion.none), Keyframe.key(2, motion: CueMotion.none)]);
      final b = MotionKeyframes([Keyframe.key(1, motion: CueMotion.none), Keyframe.key(2, motion: CueMotion.none)]);
      expect(a, equals(b));
    });
    test('different MotionKeyframes are not equal', () {
      final a = MotionKeyframes([Keyframe.key(1, motion: CueMotion.none)]);
      final b = MotionKeyframes([Keyframe.key(2, motion: CueMotion.none)]);
      expect(a, isNot(equals(b)));
    });
    test('identical FractionalKeyframes are equal', () {
      final a = FractionalKeyframes([FractionalKeyframe.key(1, at: 0.1), FractionalKeyframe.key(2, at: 0.2)]);
      final b = FractionalKeyframes([FractionalKeyframe.key(1, at: 0.1), FractionalKeyframe.key(2, at: 0.2)]);
      expect(a, equals(b));
    });
    test('different FractionalKeyframes are not equal', () {
      final a = FractionalKeyframes([FractionalKeyframe.key(1, at: 0.1)]);
      final b = FractionalKeyframes([FractionalKeyframe.key(2, at: 0.1)]);
      expect(a, isNot(equals(b)));
    });
    test('FractionalKeyframes with different durations are not equal', () {
      final a = FractionalKeyframes([FractionalKeyframe.key(1, at: 0.1)], duration: Duration(seconds: 1));
      final b = FractionalKeyframes([FractionalKeyframe.key(1, at: 0.1)], duration: Duration(seconds: 2));
      expect(a, isNot(equals(b)));
    });

    test('Keyframes factory equality for MotionKeyframes', () {
      final a = Keyframes([Keyframe.key(1, motion: CueMotion.none)]);
      final b = MotionKeyframes([Keyframe.key(1, motion: CueMotion.none)]);
      expect(a, equals(b));
    });

    test('Keyframes.fractional factory equality for FractionalKeyframes', () {
      final a = Keyframes.fractional([FractionalKeyframe.key(1, at: 0.1)], duration: const Duration(milliseconds: 100));
      final b = FractionalKeyframes([FractionalKeyframe.key(1, at: 0.1)], duration: const Duration(milliseconds: 100));
      expect(a, equals(b));
    });

    test('MotionKeyframes.mapValues and reversed behavior', () {
      final original = MotionKeyframes<int>([
        Keyframe.key(1, motion: CueMotion.none),
        Keyframe.key(2, motion: CueMotion.none),
      ]);

      final mapped = original.mapValues((v) => 'x$v');
      expect(mapped.values, equals(['x1', 'x2']));

      final rev = original.reversed;
      expect(rev.values, equals([2, 1]));
    });

    test('FractionalKeyframes.mapValues and reversed behavior', () {
      final original = FractionalKeyframes<int>([
        FractionalKeyframe.key(10, at: 0.0),
        FractionalKeyframe.key(20, at: 0.5),
        FractionalKeyframe.key(30, at: 1.0),
      ], duration: const Duration(milliseconds: 1000));

      final mapped = original.mapValues((v) => v * 2);
      expect(mapped.values, equals([20, 40, 60]));

      final rev = original.reversed;
      // reversed should flip frames and adjust 'at' for each frame
      expect(rev.values, equals([30, 20, 10]));
      expect(rev.frames.first.at, equals(1.0 - original.frames.last.at));
    });
  });

  group('Additional Phase tests', () {
    test('Keyframe copyWith and toString', () {
      final k = Keyframe(5, motion: CueMotion.linear(const Duration(milliseconds: 10)));
      final k2 = k.copyWith(value: 6);
      expect(k2.value, equals(6));
      expect(k.toString(), contains('Keyframe'));
    });

    test('MotionKeyframes extractMotion edge cases', () {
      final single = MotionKeyframes([Keyframe(1, motion: CueMotion.none)]);
      // extractMotion without includeFirst and only one frame -> empty
      expect(single.extractMotion(), isEmpty);

      final frames = MotionKeyframes([
        Keyframe(1, motion: CueMotion.none),
        Keyframe(2, motion: CueMotion.linear(const Duration(milliseconds: 100))),
      ]);
      final motions = frames.extractMotion();
      expect(motions.length, equals(1));
    });

    test('FractionalKeyframes.extractMotion respects curves and dedup', () {
      final frames = FractionalKeyframes([
        FractionalKeyframe(1, at: 0.0, curve: Curves.easeIn),
        FractionalKeyframe(2, at: 0.5),
        FractionalKeyframe(3, at: 0.5, curve: Curves.easeOut),
        FractionalKeyframe(4, at: 1.0),
      ], duration: const Duration(milliseconds: 1000));

      final motions = frames.extractMotion(includeFirst: true, duration: const Duration(milliseconds: 1000));
      // includeFirst true should produce motions for first time + intervals
      expect(motions.isNotEmpty, isTrue);
    });

    test('resolveFractionalFrames with forReverse adds from at end', () {
      final frames = [
        FractionalKeyframe('x', at: 0.2),
        FractionalKeyframe('y', at: 0.8),
      ];
      final resolved = Phase.resolveFractionalFrames<String, String>(frames, from: 'from', forReverse: true, transform: (v) => v);
      // forReverse true with from provided inserts from at end, so phases count should be 2
      expect(resolved.length, equals(2));
    });

    test('resolveMotionFrames forReverse appends from correctly', () {
      final frames = [Keyframe(10, motion: CueMotion.none)];
      final phases = Phase.resolveMotionFrames<int, int>(frames, from: 0, forReverse: true, transform: (v) => v);
      // when forReverse true and from provided, function appends from at end producing one phase: 10 -> 0
      expect(phases.length, equals(1));
      expect(phases.first.begin, equals(10));
      expect(phases.first.end, equals(0));
    });
  });
}
