import 'dart:math' show pi;

import 'package:cue/cue.dart';
import 'package:cue/src/timeline/track/track.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ActContext createActContext() {
    final motion = CueMotion.linear(300.ms);
    return ActContext(motion: motion, reverseMotion: motion);
  }

  CueTrack createTrack() {
    final motion = CueMotion.linear(300.ms);
    final config = TrackConfig(motion: motion, reverseMotion: motion);
    return CueTrackImpl(config);
  }

  group('RotateLayoutAct', () {
    group('key', () {
      test('has correct key name', () {
        final act = RotateLayoutAct(from: 0, to: 90);
        expect(act.key.key, 'RotateLayout');
      });
    });

    group('default constructor', () {
      test('accepts from and to', () {
        final act = RotateLayoutAct(from: 45, to: 90);
        expect(act.from, 45);
        expect(act.to, 90);
      });

      test('default from and to are 0', () {
        final act = RotateLayoutAct();
        expect(act.from, 0);
        expect(act.to, 0);
      });

      test('default unit is degrees', () {
        final act = RotateLayoutAct(from: 0, to: 90);
        expect(act.unit, RotateUnit.degrees);
      });

      test('accepts unit', () {
        final act = RotateLayoutAct(
          from: 0,
          to: 1.57,
          unit: RotateUnit.radians,
        );
        expect(act.unit, RotateUnit.radians);
      });

      test('accepts motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = RotateLayoutAct(from: 0, to: 90, motion: motion);
        expect(act.motion, motion);
      });

      test('accepts delay', () {
        final act = RotateLayoutAct(
          from: 0,
          to: 90,
          delay: const Duration(milliseconds: 100),
        );
        expect(act.delay, const Duration(milliseconds: 100));
      });
    });

    group('degrees constructor', () {
      test('creates act with degrees unit', () {
        final act = RotateLayoutAct.degrees(from: 0, to: 180);
        expect(act.unit, RotateUnit.degrees);
        expect(act.from, 0);
        expect(act.to, 180);
      });

      test('accepts motion and delay', () {
        final motion = CueMotion.linear(300.ms);
        final act = RotateLayoutAct.degrees(
          from: 0,
          to: 180,
          motion: motion,
          delay: const Duration(milliseconds: 50),
        );
        expect(act.motion, motion);
        expect(act.delay, const Duration(milliseconds: 50));
      });
    });

    group('turns constructor', () {
      test('creates act with quarterTurns unit', () {
        final act = RotateLayoutAct.turns(from: 0, to: 1);
        expect(act.unit, RotateUnit.quarterTurns);
        expect(act.from, 0);
        expect(act.to, 1);
      });

      test('accepts motion and delay', () {
        final motion = CueMotion.linear(300.ms);
        final act = RotateLayoutAct.turns(
          from: 0,
          to: 2,
          motion: motion,
          delay: const Duration(milliseconds: 50),
        );
        expect(act.motion, motion);
        expect(act.delay, const Duration(milliseconds: 50));
      });
    });

    group('keyframed constructor', () {
      test('accepts frames', () {
        final frames = Keyframes<double>([
          Keyframe(0, motion: CueMotion.linear(100.ms)),
          Keyframe(90, motion: CueMotion.linear(100.ms)),
        ]);
        final act = RotateLayoutAct.keyframed(frames: frames);
        expect(act.frames, frames);
      });

      test('default unit is radians for keyframed', () {
        final frames = Keyframes<double>([
          Keyframe(0, motion: CueMotion.linear(100.ms)),
        ]);
        final act = RotateLayoutAct.keyframed(frames: frames);
        expect(act.unit, RotateUnit.radians);
      });
    });

    group('transform', () {
      test('converts degrees to radians', () {
        final act = RotateLayoutAct.degrees(from: 0, to: 180);
        final ctx = createActContext();
        final radians = act.transform(ctx, 180);
        expect(radians, closeTo(pi, 0.0001));
      });

      test('converts quarterTurns to radians', () {
        final act = RotateLayoutAct.turns(from: 0, to: 2);
        final ctx = createActContext();
        final radians = act.transform(ctx, 2);
        expect(radians, closeTo(pi, 0.0001));
      });

      test('leaves radians unchanged', () {
        final act = RotateLayoutAct(
          from: 0,
          to: pi,
          unit: RotateUnit.radians,
        );
        final ctx = createActContext();
        final radians = act.transform(ctx, pi);
        expect(radians, closeTo(pi, 0.0001));
      });
    });

    group('resolve', () {
      test('returns ActContext with motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = RotateLayoutAct(from: 0, to: 90, motion: motion);
        final ctx = createActContext();
        final resolved = act.resolve(ctx);
        expect(resolved.motion, isNotNull);
      });
    });

    group('equality', () {
      test('equal acts have same hashCode', () {
        final act1 = RotateLayoutAct(from: 0, to: 90);
        final act2 = RotateLayoutAct(from: 0, to: 90);
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });

      test('different from values are not equal', () {
        final act1 = RotateLayoutAct(from: 0, to: 90);
        final act2 = RotateLayoutAct(from: 45, to: 90);
        expect(act1, isNot(act2));
      });

      test('different to values are not equal', () {
        final act1 = RotateLayoutAct(from: 0, to: 90);
        final act2 = RotateLayoutAct(from: 0, to: 180);
        expect(act1, isNot(act2));
      });

      test('different units are not equal', () {
        final act1 = RotateLayoutAct(from: 0, to: 90, unit: RotateUnit.degrees);
        final act2 = RotateLayoutAct(from: 0, to: 90, unit: RotateUnit.radians);
        expect(act1, isNot(act2));
      });
    });
  });
}
