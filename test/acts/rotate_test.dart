import 'dart:math' as math;
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

  group('RotateAct', () {
    group('key', () {
      test('has correct key name', () {
        const act = RotateAct();
        expect(act.key.key, 'Rotate');
      });
    });

    group('constructors', () {
      test('default constructor sets from and to', () {
        const act = RotateAct(from: 0, to: 90);
        expect(act.from, 0);
        expect(act.to, 90);
      });

      test('default constructor uses default values', () {
        const act = RotateAct();
        expect(act.from, 0);
        expect(act.to, 0);
        expect(act.unit, RotateUnit.degrees);
        expect(act.axis, RotateAxis.z);
        expect(act.alignment, Alignment.center);
      });

      test('radians constructor', () {
        const act = RotateAct.radians(from: 0, to: math.pi);
        expect(act.unit, RotateUnit.radians);
      });

      test('degrees constructor', () {
        const act = RotateAct.degrees(from: 0, to: 180);
        expect(act.unit, RotateUnit.degrees);
      });

      test('turns constructor', () {
        const act = RotateAct.turns(from: 0, to: 2);
        expect(act.unit, RotateUnit.quarterTurns);
      });

      test('flipX constructor', () {
        const act = RotateAct.flipX();
        expect(act.axis, RotateAxis.x);
        expect(act.unit, RotateUnit.radians);
        expect(act.from, 0);
        expect(act.to, math.pi);
      });

      test('flipY constructor', () {
        const act = RotateAct.flipY();
        expect(act.axis, RotateAxis.y);
        expect(act.unit, RotateUnit.radians);
        expect(act.from, 0);
        expect(act.to, math.pi);
      });

      test('constructor with alignment', () {
        const act = RotateAct(alignment: Alignment.topLeft);
        expect(act.alignment, Alignment.topLeft);
      });

      test('constructor with axis', () {
        const act = RotateAct(axis: RotateAxis.x);
        expect(act.axis, RotateAxis.x);
      });

      test('constructor with motion', () {
        final motion = CueMotion.linear(500.ms);
        final act = RotateAct(to: 90, motion: motion);
        expect(act.motion, motion);
      });

      test('constructor with reverse', () {
        const reverse = ReverseBehavior<double>.mirror();
        const act = RotateAct(to: 90, reverse: reverse);
        expect(act.reverse, reverse);
      });

      test('constructor with delay', () {
        const delay = Duration(milliseconds: 100);
        const act = RotateAct(to: 90, delay: delay);
        expect(act.delay, delay);
      });

      test('keyframed constructor sets frames', () {
        final frames = FractionalKeyframes<double>([
          FractionalKeyframe(0.0, at: 0.0),
          FractionalKeyframe(math.pi, at: 1.0),
        ]);
        final act = RotateAct.keyframed(frames: frames);
        expect(act.frames, frames);
      });
    });

    group('transform', () {
      test('transforms degrees to radians', () {
        const act = RotateAct(unit: RotateUnit.degrees);
        final ctx = createActContext();
        expect(act.transform(ctx, 180), math.pi);
        expect(act.transform(ctx, 90), math.pi / 2);
        expect(act.transform(ctx, 0), 0.0);
      });

      test('transforms quarter turns to radians', () {
        const act = RotateAct(unit: RotateUnit.quarterTurns);
        final ctx = createActContext();
        expect(act.transform(ctx, 2), math.pi);
        expect(act.transform(ctx, 1), math.pi / 2);
        expect(act.transform(ctx, 4), math.pi * 2);
      });

      test('returns radians unchanged', () {
        const act = RotateAct(unit: RotateUnit.radians);
        final ctx = createActContext();
        expect(act.transform(ctx, math.pi), math.pi);
        expect(act.transform(ctx, math.pi / 2), math.pi / 2);
      });
    });

    group('apply', () {
      testWidgets('wraps child in MatrixTransition', (tester) async {
        const act = RotateAct(from: 0, to: 90);
        final ctx = createActContext();
        final (animtable, _) = act.buildTweens(ctx);

        final track = createTrack();
        track.setProgress(0.5);

        final animation = CueAnimationImpl<double>(
          parent: track,
          token: ReleaseToken(track.config),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const SizedBox());
              },
            ),
          ),
        );

        expect(find.byType(MatrixTransition), findsOneWidget);
      });

      testWidgets('uses correct alignment', (tester) async {
        const act = RotateAct(from: 0, to: 90, alignment: Alignment.topLeft);
        final ctx = createActContext();
        final (animtable, _) = act.buildTweens(ctx);

        final track = createTrack();
        track.setProgress(0.5);

        final animation = CueAnimationImpl<double>(
          parent: track,
          token: ReleaseToken(track.config),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const SizedBox());
              },
            ),
          ),
        );

        final matrixTransition = tester.widget<MatrixTransition>(find.byType(MatrixTransition));
        expect(matrixTransition.alignment, Alignment.topLeft);
      });
    });

    group('equality', () {
      test('equal acts have same hashCode', () {
        const act1 = RotateAct(from: 0, to: 90, alignment: Alignment.topLeft);
        const act2 = RotateAct(from: 0, to: 90, alignment: Alignment.topLeft);
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });

      test('different from values are not equal', () {
        const act1 = RotateAct(from: 0, to: 90);
        const act2 = RotateAct(from: 45, to: 90);
        expect(act1, isNot(act2));
      });

      test('different to values are not equal', () {
        const act1 = RotateAct(from: 0, to: 90);
        const act2 = RotateAct(from: 0, to: 180);
        expect(act1, isNot(act2));
      });

      test('different alignment are not equal', () {
        const act1 = RotateAct(alignment: Alignment.topLeft);
        const act2 = RotateAct(alignment: Alignment.bottomRight);
        expect(act1, isNot(act2));
      });

      test('different unit are not equal', () {
        const act1 = RotateAct(unit: RotateUnit.degrees);
        const act2 = RotateAct(unit: RotateUnit.radians);
        expect(act1, isNot(act2));
      });

      test('different axis are not equal', () {
        const act1 = RotateAct(axis: RotateAxis.x);
        const act2 = RotateAct(axis: RotateAxis.y);
        expect(act1, isNot(act2));
      });
    });
  });

  group('Rotate3DAct', () {
    group('key', () {
      test('has correct key name', () {
        const act = Rotate3DAct();
        expect(act.key.key, 'Rotate3D');
      });
    });

    group('constructors', () {
      test('default constructor sets from and to', () {
        const from = Rotation3D(x: 0, y: 45, z: 0);
        const to = Rotation3D(x: 0, y: 180, z: 0);
        const act = Rotate3DAct(from: from, to: to);
        expect(act.from, from);
        expect(act.to, to);
      });

      test('default constructor uses default values', () {
        const act = Rotate3DAct();
        expect(act.from, Rotation3D.zero);
        expect(act.to, Rotation3D.zero);
        expect(act.alignment, Alignment.center);
        expect(act.perspective, 0.001);
        expect(act.unit, Rotate3DUnit.degrees);
      });

      test('constructor with alignment', () {
        const act = Rotate3DAct(alignment: Alignment.topLeft);
        expect(act.alignment, Alignment.topLeft);
      });

      test('constructor with perspective', () {
        const act = Rotate3DAct(perspective: 0.005);
        expect(act.perspective, 0.005);
      });

      test('constructor with motion', () {
        final motion = CueMotion.linear(500.ms);
        final act = Rotate3DAct(to: const Rotation3D(y: 180), motion: motion);
        expect(act.motion, motion);
      });

      test('constructor with reverse', () {
        const reverse = ReverseBehavior<Rotation3D>.mirror();
        const act = Rotate3DAct(to: Rotation3D(y: 180), reverse: reverse);
        expect(act.reverse, reverse);
      });

      test('constructor with delay', () {
        const delay = Duration(milliseconds: 100);
        const act = Rotate3DAct(to: Rotation3D(y: 180), delay: delay);
        expect(act.delay, delay);
      });

      test('keyframed constructor sets frames', () {
        final frames = FractionalKeyframes<Rotation3D>([
          FractionalKeyframe(Rotation3D.zero, at: 0.0),
          FractionalKeyframe(const Rotation3D(y: 180), at: 1.0),
        ]);
        final act = Rotate3DAct.keyframed(frames: frames);
        expect(act.frames, frames);
      });
    });

    group('transform', () {
      test('transforms degrees to radians', () {
        const act = Rotate3DAct(unit: Rotate3DUnit.degrees);
        final ctx = createActContext();
        final result = act.transform(ctx, const Rotation3D(x: 90, y: 180, z: 45));
        expect(result.x, math.pi / 2);
        expect(result.y, math.pi);
        expect(result.z, math.pi / 4);
      });

      test('returns radians unchanged', () {
        const act = Rotate3DAct(unit: Rotate3DUnit.radians);
        final ctx = createActContext();
        final result = act.transform(ctx, const Rotation3D(x: math.pi, y: math.pi / 2, z: 0));
        expect(result.x, math.pi);
        expect(result.y, math.pi / 2);
        expect(result.z, 0);
      });
    });

    group('createSingleTween', () {
      test('creates tween with correct type', () {
        const act = Rotate3DAct();
        final tween = act.createSingleTween(
          Rotation3D.zero,
          const Rotation3D(y: 180),
        );
        expect(tween, isA<Animatable<Rotation3D>>());
      });
    });

    group('apply', () {
      testWidgets('wraps child in Transform', (tester) async {
        const act = Rotate3DAct(from: Rotation3D.zero, to: Rotation3D(y: 180));
        final ctx = createActContext();
        final (animtable, _) = act.buildTweens(ctx);

        final track = createTrack();
        track.setProgress(0.5);

        final animation = CueAnimationImpl<Rotation3D>(
          parent: track,
          token: ReleaseToken(track.config),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const SizedBox());
              },
            ),
          ),
        );

        expect(find.byType(Transform), findsOneWidget);
      });

      testWidgets('uses correct alignment', (tester) async {
        const act = Rotate3DAct(
          from: Rotation3D.zero,
          to: Rotation3D(y: 180),
          alignment: Alignment.topLeft,
        );
        final ctx = createActContext();
        final (animtable, _) = act.buildTweens(ctx);

        final track = createTrack();
        track.setProgress(0.5);

        final animation = CueAnimationImpl<Rotation3D>(
          parent: track,
          token: ReleaseToken(track.config),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const SizedBox());
              },
            ),
          ),
        );

        final transform = tester.widget<Transform>(find.byType(Transform));
        expect(transform.alignment, Alignment.topLeft);
      });
    });

    group('equality', () {
      test('equal acts have same hashCode', () {
        const act1 = Rotate3DAct(
          from: Rotation3D.zero,
          to: Rotation3D(y: 180),
          alignment: Alignment.topLeft,
        );
        const act2 = Rotate3DAct(
          from: Rotation3D.zero,
          to: Rotation3D(y: 180),
          alignment: Alignment.topLeft,
        );
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });

      test('different from values are not equal', () {
        const act1 = Rotate3DAct(from: Rotation3D.zero, to: Rotation3D(y: 180));
        const act2 = Rotate3DAct(from: Rotation3D(x: 45), to: Rotation3D(y: 180));
        expect(act1, isNot(act2));
      });

      test('different to values are not equal', () {
        const act1 = Rotate3DAct(to: Rotation3D(y: 180));
        const act2 = Rotate3DAct(to: Rotation3D(y: 90));
        expect(act1, isNot(act2));
      });

      test('different alignment are not equal', () {
        const act1 = Rotate3DAct(alignment: Alignment.topLeft);
        const act2 = Rotate3DAct(alignment: Alignment.bottomRight);
        expect(act1, isNot(act2));
      });

      test('different perspective are not equal', () {
        const act1 = Rotate3DAct(perspective: 0.001);
        const act2 = Rotate3DAct(perspective: 0.005);
        expect(act1, isNot(act2));
      });

      test('different unit are not equal', () {
        const act1 = Rotate3DAct(unit: Rotate3DUnit.degrees);
        const act2 = Rotate3DAct(unit: Rotate3DUnit.radians);
        expect(act1, isNot(act2));
      });
    });
  });

  group('Rotation3D', () {
    test('default constructor', () {
      const rotation = Rotation3D();
      expect(rotation.x, 0);
      expect(rotation.y, 0);
      expect(rotation.z, 0);
    });

    test('custom values', () {
      const rotation = Rotation3D(x: 45, y: 90, z: 180);
      expect(rotation.x, 45);
      expect(rotation.y, 90);
      expect(rotation.z, 180);
    });

    test('zero constant', () {
      expect(Rotation3D.zero.x, 0);
      expect(Rotation3D.zero.y, 0);
      expect(Rotation3D.zero.z, 0);
    });

    test('toString', () {
      const rotation = Rotation3D(x: 1, y: 2, z: 3);
      expect(rotation.toString(), 'Rotation3D(x: 1.0, y: 2.0, z: 3.0)');
    });

    test('equality', () {
      const rotation1 = Rotation3D(x: 45, y: 90, z: 180);
      const rotation2 = Rotation3D(x: 45, y: 90, z: 180);
      const rotation3 = Rotation3D(x: 0, y: 90, z: 180);
      expect(rotation1, rotation2);
      expect(rotation1, isNot(rotation3));
    });

    test('hashCode consistency', () {
      const rotation1 = Rotation3D(x: 45, y: 90, z: 180);
      const rotation2 = Rotation3D(x: 45, y: 90, z: 180);
      expect(rotation1.hashCode, rotation2.hashCode);
    });

    test('lerpTo', () {
      const from = Rotation3D(x: 0, y: 0, z: 0);
      const to = Rotation3D(x: 90, y: 180, z: 45);
      final result = from.lerpTo(to, 0.5);
      expect(result.x, 45);
      expect(result.y, 90);
      expect(result.z, 22.5);
    });

    test('lerp static method', () {
      const a = Rotation3D(x: 0, y: 0, z: 0);
      const b = Rotation3D(x: 90, y: 180, z: 45);
      final result = Rotation3D.lerp(a, b, 0.5);
      expect(result!.x, 45);
      expect(result.y, 90);
      expect(result.z, 22.5);
    });

    test('lerp with null values', () {
      const b = Rotation3D(x: 90, y: 180, z: 45);
      final result = Rotation3D.lerp(null, b, 0.5);
      expect(result!.x, 45);
      expect(result.y, 90);
      expect(result.z, 22.5);
    });

    test('lerp both null returns null', () {
      final result = Rotation3D.lerp(null, null, 0.5);
      expect(result, isNull);
    });
  });

  group('RotateAxis', () {
    test('has all expected values', () {
      expect(RotateAxis.values, contains(RotateAxis.x));
      expect(RotateAxis.values, contains(RotateAxis.y));
      expect(RotateAxis.values, contains(RotateAxis.z));
    });
  });

  group('RotateUnit', () {
    test('has all expected values', () {
      expect(RotateUnit.values, contains(RotateUnit.degrees));
      expect(RotateUnit.values, contains(RotateUnit.radians));
      expect(RotateUnit.values, contains(RotateUnit.quarterTurns));
    });
  });

  group('Rotate3DUnit', () {
    test('has all expected values', () {
      expect(Rotate3DUnit.values, contains(Rotate3DUnit.degrees));
      expect(Rotate3DUnit.values, contains(Rotate3DUnit.radians));
    });
  });
}
