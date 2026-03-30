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

  group('ScaleAct', () {
    group('key', () {
      test('has correct key name', () {
        const act = ScaleAct();
        expect(act.key.key, 'Scale');
      });
    });

    group('constructors', () {
      test('default constructor sets from and to', () {
        const act = ScaleAct(from: 0.5, to: 1.5);
        expect(act.from, 0.5);
        expect(act.to, 1.5);
      });

      test('default constructor uses default values', () {
        const act = ScaleAct();
        expect(act.from, 1.0);
        expect(act.to, 1.0);
      });

      test('default constructor with alignment', () {
        const act = ScaleAct(alignment: Alignment.topLeft);
        expect(act.alignment, Alignment.topLeft);
      });

      test('zoomIn constructor', () {
        const act = ScaleAct.zoomIn();
        expect(act.from, 0.0);
        expect(act.to, 1.0);
      });

      test('zoomIn constructor with alignment', () {
        const act = ScaleAct.zoomIn(alignment: Alignment.bottomRight);
        expect(act.alignment, Alignment.bottomRight);
      });

      test('zoomOut constructor', () {
        const act = ScaleAct.zoomOut();
        expect(act.from, 1.0);
        expect(act.to, 0.0);
      });

      test('zoomOut constructor with alignment', () {
        const act = ScaleAct.zoomOut(alignment: Alignment.topCenter);
        expect(act.alignment, Alignment.topCenter);
      });

      test('constructor with motion', () {
        final motion = CueMotion.linear(500.ms);
        final act = ScaleAct(to: 0.5, motion: motion);
        expect(act.motion, motion);
      });

      test('constructor with reverse', () {
        const reverse = ReverseBehavior<double>.mirror();
        const act = ScaleAct(to: 0.5, reverse: reverse);
        expect(act.reverse, reverse);
      });

      test('constructor with delay', () {
        const delay = Duration(milliseconds: 100);
        const act = ScaleAct(to: 0.5, delay: delay);
        expect(act.delay, delay);
      });

      test('keyframed constructor sets frames', () {
        final frames = FractionalKeyframes<double>([
          FractionalKeyframe(1.0, at: 0.0),
          FractionalKeyframe(0.5, at: 0.5),
          FractionalKeyframe(1.0, at: 1.0),
        ]);
        final act = ScaleAct.keyframed(frames: frames);
        expect(act.frames, frames);
      });
    });

    group('apply', () {
      testWidgets('wraps child in ScaleTransition', (tester) async {
        const act = ScaleAct(from: 1.0, to: 0.5);
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
                return act.apply(context, animation, const Text('Child'));
              },
            ),
          ),
        );

        expect(find.byType(ScaleTransition), findsOneWidget);
        expect(find.text('Child'), findsOneWidget);
      });

      testWidgets('ScaleTransition uses animation', (tester) async {
        const act = ScaleAct(from: 1.0, to: 0.5);
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

        final scaleTransition = tester.widget<ScaleTransition>(find.byType(ScaleTransition));
        expect(scaleTransition.scale, animation);
      });

      testWidgets('uses default alignment when not specified', (tester) async {
        const act = ScaleAct(from: 1.0, to: 0.5);
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

        final scaleTransition = tester.widget<ScaleTransition>(find.byType(ScaleTransition));
        expect(scaleTransition.alignment, Alignment.center);
      });

      testWidgets('uses specified alignment', (tester) async {
        const act = ScaleAct(from: 1.0, to: 0.5, alignment: Alignment.topLeft);
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

        final scaleTransition = tester.widget<ScaleTransition>(find.byType(ScaleTransition));
        expect(scaleTransition.alignment, Alignment.topLeft);
      });

      testWidgets('resolves AlignmentDirectional', (tester) async {
        const act = ScaleAct(
          from: 1.0,
          to: 0.5,
          alignment: AlignmentDirectional.centerStart,
        );
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
            textDirection: TextDirection.rtl,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const SizedBox());
              },
            ),
          ),
        );

        final scaleTransition = tester.widget<ScaleTransition>(find.byType(ScaleTransition));
        expect(scaleTransition.alignment, Alignment.centerRight);
      });

      testWidgets('animation value affects scale at start', (tester) async {
        const act = ScaleAct(from: 1.0, to: 0.5);
        final ctx = createActContext();
        final (animtable, _) = act.buildTweens(ctx);

        final track = createTrack();
        track.setProgress(0.0);

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

        expect(animation.value, 1.0);
      });

      testWidgets('animation value affects scale at end', (tester) async {
        const act = ScaleAct(from: 1.0, to: 0.5);
        final ctx = createActContext();
        final (animtable, _) = act.buildTweens(ctx);

        final track = createTrack();
        track.setProgress(1.0);

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

        expect(animation.value, 0.5);
      });
    });

    group('equality', () {
      test('equal acts have same hashCode', () {
        const act1 = ScaleAct(from: 0.5, to: 1.5, alignment: Alignment.topLeft);
        const act2 = ScaleAct(from: 0.5, to: 1.5, alignment: Alignment.topLeft);
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });

      test('different from values are not equal', () {
        const act1 = ScaleAct(from: 0.5, to: 1.5);
        const act2 = ScaleAct(from: 0.8, to: 1.5);
        expect(act1, isNot(act2));
      });

      test('different to values are not equal', () {
        const act1 = ScaleAct(from: 0.5, to: 1.5);
        const act2 = ScaleAct(from: 0.5, to: 2.0);
        expect(act1, isNot(act2));
      });

      test('different alignment are not equal', () {
        const act1 = ScaleAct(alignment: Alignment.topLeft);
        const act2 = ScaleAct(alignment: Alignment.bottomRight);
        expect(act1, isNot(act2));
      });

      test('different motion values are not equal', () {
        final motion1 = CueMotion.linear(300.ms);
        final motion2 = CueMotion.linear(500.ms);
        final act1 = ScaleAct(motion: motion1);
        final act2 = ScaleAct(motion: motion2);
        expect(act1, isNot(act2));
      });

      test('different delay values are not equal', () {
        const act1 = ScaleAct(delay: Duration(milliseconds: 100));
        const act2 = ScaleAct(delay: Duration(milliseconds: 200));
        expect(act1, isNot(act2));
      });
    });

    group('isConstant', () {
      test('isConstant when from equals to', () {
        const act = ScaleAct(from: 1.0, to: 1.0);
        expect(act.isConstant, isTrue);
      });

      test('isConstant is false when from and to differ', () {
        const act = ScaleAct(from: 1.0, to: 0.5);
        expect(act.isConstant, isFalse);
      });
    });
  });

  group('StretchAct', () {
    group('key', () {
      test('has correct key name', () {
        const act = StretchAct();
        expect(act.key.key, 'Stretch');
      });
    });

    group('constructors', () {
      test('default constructor sets from and to', () {
        const act = StretchAct(from: Stretch(x: 0.5, y: 1.0), to: Stretch(x: 1.0, y: 0.5));
        expect(act.from, Stretch(x: 0.5, y: 1.0));
        expect(act.to, Stretch(x: 1.0, y: 0.5));
      });

      test('default constructor uses default values', () {
        const act = StretchAct();
        expect(act.from, Stretch.none);
        expect(act.to, Stretch.none);
      });

      test('constructor with motion', () {
        final motion = CueMotion.linear(500.ms);
        final act = StretchAct(to: Stretch(x: 2.0, y: 1.0), motion: motion);
        expect(act.motion, motion);
      });

      test('constructor with reverse', () {
        const reverse = ReverseBehavior<Stretch>.mirror();
        const act = StretchAct(to: Stretch(x: 2.0, y: 1.0), reverse: reverse);
        expect(act.reverse, reverse);
      });

      test('constructor with delay', () {
        const delay = Duration(milliseconds: 100);
        const act = StretchAct(to: Stretch(x: 2.0, y: 1.0), delay: delay);
        expect(act.delay, delay);
      });

      test('keyframed constructor sets frames', () {
        final frames = FractionalKeyframes<Stretch>([
          FractionalKeyframe(Stretch.none, at: 0.0),
          FractionalKeyframe(Stretch(x: 2.0, y: 1.0), at: 1.0),
        ]);
        final act = StretchAct.keyframed(frames: frames);
        expect(act.frames, frames);
      });
    });

    group('transform', () {
      test('transforms Stretch to Matrix4', () {
        const act = StretchAct();
        final ctx = createActContext();

        final result = act.transform(ctx, const Stretch(x: 2.0, y: 0.5));
        expect(result, isA<Matrix4>());
        expect(result.storage[0], closeTo(2.0, 0.001));
        expect(result.storage[5], closeTo(0.5, 0.001));
      });

      test('transforms Stretch.none to identity-like matrix', () {
        const act = StretchAct();
        final ctx = createActContext();

        final result = act.transform(ctx, Stretch.none);
        expect(result, isA<Matrix4>());
        expect(result.storage[0], closeTo(1.0, 0.001));
        expect(result.storage[5], closeTo(1.0, 0.001));
      });
    });

    group('createSingleTween', () {
      test('creates Matrix4Tween with correct values', () {
        const act = StretchAct();
        final from = Matrix4.diagonal3Values(1.0, 1.0, 1.0);
        final to = Matrix4.diagonal3Values(2.0, 0.5, 1.0);
        final tween = act.createSingleTween(from, to);
        expect(tween, isA<Matrix4Tween>());
        final matrix4Tween = tween as Matrix4Tween;
        expect(matrix4Tween.begin, from);
        expect(matrix4Tween.end, to);
      });
    });

    group('apply', () {
      testWidgets('wraps child in Transform', (tester) async {
        const act = StretchAct(from: Stretch.none, to: Stretch(x: 2.0, y: 1.0));
        final ctx = createActContext();
        final (animtable, _) = act.buildTweens(ctx);

        final track = createTrack();
        track.setProgress(0.5);

        final animation = CueAnimationImpl<Matrix4>(
          parent: track,
          token: ReleaseToken(track.config),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Builder(
            builder: (context) {
              return act.apply(context, animation, const SizedBox());
            },
          ),
        );

        expect(find.byType(Transform), findsOneWidget);
      });

      testWidgets('Transform uses animation value', (tester) async {
        const act = StretchAct(from: Stretch.none, to: Stretch(x: 2.0, y: 1.0));
        final ctx = createActContext();
        final (animtable, _) = act.buildTweens(ctx);

        final track = createTrack();
        track.setProgress(0.0);

        final animation = CueAnimationImpl<Matrix4>(
          parent: track,
          token: ReleaseToken(track.config),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Builder(
            builder: (context) {
              return act.apply(context, animation, const SizedBox());
            },
          ),
        );

        final transform = tester.widget<Transform>(find.byType(Transform));
        expect(transform.transform, isA<Matrix4>());
      });
    });

    group('equality', () {
      test('equal acts have same hashCode', () {
        const act1 = StretchAct(from: Stretch(x: 0.5, y: 1.0), to: Stretch(x: 2.0, y: 1.0));
        const act2 = StretchAct(from: Stretch(x: 0.5, y: 1.0), to: Stretch(x: 2.0, y: 1.0));
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });

      test('different from values are not equal', () {
        const act1 = StretchAct(from: Stretch(x: 0.5, y: 1.0), to: Stretch.none);
        const act2 = StretchAct(from: Stretch(x: 0.8, y: 1.0), to: Stretch.none);
        expect(act1, isNot(act2));
      });

      test('different to values are not equal', () {
        const act1 = StretchAct(from: Stretch.none, to: Stretch(x: 2.0, y: 1.0));
        const act2 = StretchAct(from: Stretch.none, to: Stretch(x: 1.5, y: 1.0));
        expect(act1, isNot(act2));
      });
    });
  });

  group('Stretch', () {
    test('default constructor', () {
      const stretch = Stretch();
      expect(stretch.x, 1.0);
      expect(stretch.y, 1.0);
    });

    test('custom values', () {
      const stretch = Stretch(x: 2.0, y: 0.5);
      expect(stretch.x, 2.0);
      expect(stretch.y, 0.5);
    });

    test('none constant', () {
      expect(Stretch.none.x, 1.0);
      expect(Stretch.none.y, 1.0);
    });

    test('toString', () {
      const stretch = Stretch(x: 2.0, y: 0.5);
      expect(stretch.toString(), 'Stretch(x: 2.0, y: 0.5)');
    });

    test('equality', () {
      const stretch1 = Stretch(x: 2.0, y: 0.5);
      const stretch2 = Stretch(x: 2.0, y: 0.5);
      const stretch3 = Stretch(x: 1.0, y: 0.5);
      expect(stretch1, stretch2);
      expect(stretch1, isNot(stretch3));
    });

    test('hashCode consistency', () {
      const stretch1 = Stretch(x: 2.0, y: 0.5);
      const stretch2 = Stretch(x: 2.0, y: 0.5);
      expect(stretch1.hashCode, stretch2.hashCode);
    });
  });
}
