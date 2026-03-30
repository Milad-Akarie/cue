import 'package:cue/cue.dart';
import 'package:cue/src/timeline/track/track.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:cue/src/acts/base/animatable_act.dart';
import 'package:cue/src/acts/base/tween_act.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  CueMotion createMotion() => CueMotion.linear(300.ms);

  ActContext createActContext() {
    final motion = createMotion();
    return ActContext(motion: motion, reverseMotion: motion);
  }

  CueTrackImpl createTrack() {
    final motion = createMotion();
    return CueTrackImpl(TrackConfig(motion: motion, reverseMotion: motion));
  }

  group('TranslateAct', () {
    group('key', () {
      test('has correct key name', () {
        final act = TranslateAct();
        expect(act.key.key, 'Translate');
      });
    });

    group('constructors', () {
      test('default constructor sets from and to', () {
        final act = TranslateAct(
          from: const Offset(10, 20),
          to: const Offset(30, 40),
        );
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        final ctx = createActContext();
        final (animtable, _) = animtableAct.buildTweens(ctx);

        final track = createTrack();
        track.setProgress(0);

        final animation = CueAnimationImpl<Offset>(
          parent: track,
          token: ReleaseToken(track.config),
          animtable: animtable,
        );

        expect(animation.value, const Offset(10, 20));
      });

      test('default constructor uses default values', () {
        final act = TranslateAct();
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        final ctx = createActContext();
        final (animtable, _) = animtableAct.buildTweens(ctx);

        final track = createTrack();
        track.setProgress(0);

        final animation = CueAnimationImpl<Offset>(
          parent: track,
          token: ReleaseToken(track.config),
          animtable: animtable,
        );

        expect(animation.value, Offset.zero);
      });

      test('keyframed constructor sets frames', () {
        final frames = FractionalKeyframes<Offset>([
          FractionalKeyframe(Offset.zero, at: 0),
          FractionalKeyframe(const Offset(50, 50), at: 1),
        ]);
        final act = TranslateAct.keyframed(frames: frames);
        final tweenAct = act as TweenActBase<Offset, Offset>;
        expect(tweenAct.frames, frames);
      });

      test('fromX constructor translates on X axis', () {
        final act = TranslateAct.fromX(from: -100, to: 0);
        final animtableAct = act as AnimtableAct<double, Offset>;
        final ctx = createActContext();
        final (animtable, _) = animtableAct.buildTweens(ctx);

        final track = createTrack();
        track.setProgress(0);

        final animation = CueAnimationImpl<Offset>(
          parent: track,
          token: ReleaseToken(track.config),
          animtable: animtable,
        );

        expect(animation.value, const Offset(-100, 0));

        track.setProgress(1);
        expect(animation.value, Offset.zero);
      });

      test('keyframedX constructor sets frames on X axis', () {
        final frames = FractionalKeyframes<double>([
          FractionalKeyframe(0.0, at: 0),
          FractionalKeyframe(100.0, at: 1),
        ]);
        final act = TranslateAct.keyframedX(frames: frames);
        final tweenAct = act as TweenActBase<double, Offset>;
        expect(tweenAct.frames, frames);
      });

      test('y constructor translates on Y axis', () {
        final act = TranslateAct.y(from: -50, to: 0);
        final animtableAct = act as AnimtableAct<double, Offset>;
        final ctx = createActContext();
        final (animtable, _) = animtableAct.buildTweens(ctx);

        final track = createTrack();
        track.setProgress(0);

        final animation = CueAnimationImpl<Offset>(
          parent: track,
          token: ReleaseToken(track.config),
          animtable: animtable,
        );

        expect(animation.value, const Offset(0, -50));

        track.setProgress(1);
        expect(animation.value, Offset.zero);
      });

      test('keyframedY constructor sets frames on Y axis', () {
        final frames = FractionalKeyframes<double>([
          FractionalKeyframe(0.0, at: 0),
          FractionalKeyframe(50.0, at: 1),
        ]);
        final act = TranslateAct.keyframedY(frames: frames);
        final tweenAct = act as TweenActBase<double, Offset>;
        expect(tweenAct.frames, frames);
      });

      test('fromGlobal constructor creates act', () {
        final act = TranslateAct.fromGlobal(
          offset: const Offset(100, 100),
          toLocal: Offset.zero,
        );
        expect(act.key.key, 'Translate');
      });

      test('fromGlobalRect constructor creates act', () {
        final act = TranslateAct.fromGlobalRect(
          const Rect.fromLTWH(0, 0, 100, 100),
          alignment: Alignment.center,
        );
        expect(act.key.key, 'Translate');
      });

      test('fromGlobalKey constructor creates act', () {
        final key = GlobalKey();
        final act = TranslateAct.fromGlobalKey(
          key,
          alignment: Alignment.topLeft,
        );
        expect(act.key.key, 'Translate');
      });

      test('constructor accepts delay', () {
        final act = TranslateAct(delay: 100.ms);
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        expect(animtableAct.delay, 100.ms);
      });
    });

    group('apply', () {
      testWidgets('wraps child in TranslateTransition', (tester) async {
        final act = TranslateAct(from: const Offset(-50, 0), to: Offset.zero);
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        final ctx = createActContext();
        final (animtable, _) = animtableAct.buildTweens(ctx);

        final track = createTrack();
        track.setProgress(0.5);

        final animation = CueAnimationImpl<Offset>(
          parent: track,
          token: ReleaseToken(track.config),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return animtableAct.apply(context, animation, const Text('Test'));
              },
            ),
          ),
        );

        expect(find.byType(TranslateTransition), findsOneWidget);
        expect(find.text('Test'), findsOneWidget);
      });
    });
  });

  group('TranslateTransition', () {
    testWidgets('applies translation via Transform.translate', (tester) async {
      final controller = AnimationController(
        vsync: tester,
        value: 0.5,
      );
      final animation = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(100, 50),
      ).animate(controller);

      await tester.pumpWidget(
        TranslateTransition(
          offset: animation,
          child: const SizedBox(width: 50, height: 50),
        ),
      );

      expect(find.byType(Transform), findsOneWidget);
      final transform = tester.widget<Transform>(find.byType(Transform));
      expect(transform.transform, isNotNull);
    });

    testWidgets('uses animation value for offset', (tester) async {
      final controller = AnimationController(
        vsync: tester,
        value: 0.5,
      );
      final animation = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(100, 50),
      ).animate(controller);

      await tester.pumpWidget(
        TranslateTransition(
          offset: animation,
          child: const SizedBox(width: 50, height: 50),
        ),
      );

      final translateTransition = tester.widget<TranslateTransition>(
        find.byType(TranslateTransition),
      );
      expect(translateTransition.offset, animation);
    });

    testWidgets('respects transformHitTests parameter', (tester) async {
      final controller = AnimationController(
        vsync: tester,
        value: 0.5,
      );
      final animation = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(100, 50),
      ).animate(controller);

      await tester.pumpWidget(
        TranslateTransition(
          offset: animation,
          transformHitTests: false,
          child: const SizedBox(width: 50, height: 50),
        ),
      );

      final transform = tester.widget<Transform>(find.byType(Transform));
      expect(transform.transformHitTests, false);
    });
  });
}
