import 'package:cue/cue.dart';
import 'package:cue/src/timeline/track/track.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final motion = CueMotion.linear(300.ms);
  final actContext = ActContext(motion: motion, reverseMotion: motion);
  final track = CueTrackImpl(TrackConfig(motion: motion, reverseMotion: motion));
  final timeline = CueTimelineImpl.fromMotion(motion);

  group('PathMotionAct', () {
    group('key', () {
      test('has correct key name', () {
        final path = Path()..lineTo(100, 0);
        final act = PathMotionAct(path: path);
        expect(act.key.key, 'PathMotionAct');
      });
    });

    group('default constructor', () {
      test('requires path', () {
        final path = Path()..lineTo(100, 0);
        final act = PathMotionAct(path: path);
        expect(act.path, path);
      });

      test('default autoRotate is false', () {
        final path = Path()..lineTo(100, 0);
        final act = PathMotionAct(path: path);
        expect(act.autoRotate, false);
      });

      test('accepts autoRotate', () {
        final path = Path()..lineTo(100, 0);
        final act = PathMotionAct(path: path, autoRotate: true);
        expect(act.autoRotate, true);
      });

      test('default alignment is center', () {
        final path = Path()..lineTo(100, 0);
        final act = PathMotionAct(path: path);
        expect(act.alignment, Alignment.center);
      });

      test('accepts alignment', () {
        final path = Path()..lineTo(100, 0);
        final act = PathMotionAct(path: path, alignment: Alignment.topLeft);
        expect(act.alignment, Alignment.topLeft);
      });

      test('accepts motion', () {
        final path = Path()..lineTo(100, 0);
        final motion = CueMotion.linear(300.ms);
        final act = PathMotionAct(path: path, motion: motion);
        expect(act.motion, motion);
      });

      test('accepts delay', () {
        final path = Path()..lineTo(100, 0);
        final act = PathMotionAct(
          path: path,
          delay: const Duration(milliseconds: 100),
        );
        expect(act.delay, const Duration(milliseconds: 100));
      });
    });

    group('circular constructor', () {
      test('creates circular path with radius', () {
        final act = PathMotionAct.circular(radius: 50);
        expect(act.path, isNotNull);
      });

      test('accepts center offset', () {
        final act = PathMotionAct.circular(
          radius: 50,
          center: const Offset(100, 100),
        );
        expect(act.path, isNotNull);
      });

      test('accepts startAngle', () {
        final act = PathMotionAct.circular(
          radius: 50,
          startAngle: 90,
        );
        expect(act.path, isNotNull);
      });

      test('accepts autoRotate', () {
        final act = PathMotionAct.circular(radius: 50, autoRotate: true);
        expect(act.autoRotate, true);
      });

      test('accepts alignment', () {
        final act = PathMotionAct.circular(
          radius: 50,
          alignment: Alignment.bottomRight,
        );
        expect(act.alignment, Alignment.bottomRight);
      });
    });

    group('arc constructor', () {
      test('requires radius and sweepAngle', () {
        final act = PathMotionAct.arc(
          radius: 50,
          sweepAngle: 90,
        );
        expect(act.path, isNotNull);
      });

      test('accepts center offset', () {
        final act = PathMotionAct.arc(
          radius: 50,
          sweepAngle: 90,
          center: const Offset(100, 100),
        );
        expect(act.path, isNotNull);
      });

      test('accepts startAngle', () {
        final act = PathMotionAct.arc(
          radius: 50,
          sweepAngle: 90,
          startAngle: 45,
        );
        expect(act.path, isNotNull);
      });

      test('accepts startOffset', () {
        final act = PathMotionAct.arc(
          radius: 50,
          sweepAngle: 90,
          startOffset: 30,
        );
        expect(act.path, isNotNull);
      });

      test('accepts autoRotate', () {
        final act = PathMotionAct.arc(
          radius: 50,
          sweepAngle: 90,
          autoRotate: true,
        );
        expect(act.autoRotate, true);
      });
    });

    group('resolve', () {
      test('returns ActContext with motion', () {
        final path = Path()..lineTo(100, 0);
        final motion = CueMotion.linear(300.ms);
        final act = PathMotionAct(path: path, motion: motion);

        final resolved = act.resolve(actContext);
        expect(resolved.motion, isNotNull);
      });
    });

    group('equality', () {
      test('equal acts have same hashCode', () {
        final path = Path()..lineTo(100, 0);
        final act1 = PathMotionAct(path: path, autoRotate: true);
        final act2 = PathMotionAct(path: path, autoRotate: true);
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });

      test('different paths are not equal', () {
        final path1 = Path()..lineTo(100, 0);
        final path2 = Path()..lineTo(200, 0);
        final act1 = PathMotionAct(path: path1);
        final act2 = PathMotionAct(path: path2);
        expect(act1, isNot(act2));
      });

      test('different autoRotate values are not equal', () {
        final path = Path()..lineTo(100, 0);
        final act1 = PathMotionAct(path: path, autoRotate: true);
        final act2 = PathMotionAct(path: path, autoRotate: false);
        expect(act1, isNot(act2));
      });

      test('different alignment values are not equal', () {
        final path = Path()..lineTo(100, 0);
        final act1 = PathMotionAct(path: path, alignment: Alignment.center);
        final act2 = PathMotionAct(path: path, alignment: Alignment.topLeft);
        expect(act1, isNot(act2));
      });
    });

    group('buildTweens', () {
      test('throws error on empty path', () {
        final emptyPath = Path();
        final act = PathMotionAct(path: emptyPath);

        expect(
          () => act.buildTweens(actContext),
          throwsException,
        );
      });

      test('throws error on path with multiple metrics', () {
        final multiPath = Path()
          ..lineTo(100, 0)
          ..moveTo(200, 0)
          ..lineTo(300, 0);
        final act = PathMotionAct(path: multiPath);

        expect(
          () => act.buildTweens(actContext),
          throwsException,
        );
      });

      test('creates tween for valid linear path', () {
        final path = Path()..lineTo(100, 0);
        final act = PathMotionAct(path: path);

        final (animatable, reverseAnimatable) = act.buildTweens(actContext);
        expect(animatable, isNotNull);
        expect(reverseAnimatable, isNull);
      });

      test('creates tween for circular path', () {
        final act = PathMotionAct.circular(radius: 50);
        final (animatable, reverseAnimatable) = act.buildTweens(actContext);
        expect(animatable, isNotNull);
        expect(reverseAnimatable, isNull);
      });

      test('creates tween for arc path', () {
        final act = PathMotionAct.arc(
          radius: 50,
          sweepAngle: 180,
        );
        final (animatable, reverseAnimatable) = act.buildTweens(actContext);
        expect(animatable, isNotNull);
        expect(reverseAnimatable, isNull);
      });
    });

    group('apply', () {
      testWidgets('renders child widget on linear path', (tester) async {
        final path = Path()..lineTo(100, 0);
        final act = PathMotionAct(path: path);

        final (animatable, _) = act.buildTweens(actContext);
        track.setProgress(0.5);
        final animation = CueAnimationImpl<Matrix4>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animatable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const Text('Path Motion'));
              },
            ),
          ),
        );

        expect(find.text('Path Motion'), findsOneWidget);
      });

      testWidgets('renders with autoRotate enabled', (tester) async {
        final act = PathMotionAct.circular(
          radius: 50,
          autoRotate: true,
        );

        final (animatable, _) = act.buildTweens(actContext);
        track.setProgress(0.5);
        final animation = CueAnimationImpl<Matrix4>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animatable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(
                  context,
                  animation,
                  const SizedBox(width: 50, height: 50),
                );
              },
            ),
          ),
        );

        await tester.pump();
      });

      testWidgets('renders with custom alignment', (tester) async {
        final path = Path()..lineTo(100, 0);
        final act = PathMotionAct(
          path: path,
          alignment: Alignment.topLeft,
        );

        final (animatable, _) = act.buildTweens(actContext);
        track.setProgress(0.5);
        final animation = CueAnimationImpl<Matrix4>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animatable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(
                  context,
                  animation,
                  const SizedBox(width: 50, height: 50),
                );
              },
            ),
          ),
        );

        await tester.pump();
      });

      testWidgets('renders arc path animation', (tester) async {
        final act = PathMotionAct.arc(
          radius: 50,
          sweepAngle: 180,
          autoRotate: true,
        );

        final (animatable, _) = act.buildTweens(actContext);
        track.setProgress(0.5);
        final animation = CueAnimationImpl<Matrix4>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animatable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(
                  context,
                  animation,
                  const SizedBox(width: 50, height: 50),
                );
              },
            ),
          ),
        );

        await tester.pump();
      });
    });

    group('path transform evaluation', () {
      test('circular path at different progress values', () {
        final act = PathMotionAct.circular(
          radius: 50,
          autoRotate: true,
          startAngle: 45,
        );

        final (animatable, _) = act.buildTweens(actContext);

        // Test at different progress values
        track.setProgress(0);
        final animation0 = CueAnimationImpl<Matrix4>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animatable,
        );
        expect(animation0.value, isA<Matrix4>());

        track.setProgress(0.25);
        final animation25 = CueAnimationImpl<Matrix4>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animatable,
        );
        expect(animation25.value, isA<Matrix4>());

        track.setProgress(0.5);
        final animation50 = CueAnimationImpl<Matrix4>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animatable,
        );
        expect(animation50.value, isA<Matrix4>());

        track.setProgress(1.0);
        final animation100 = CueAnimationImpl<Matrix4>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animatable,
        );
        expect(animation100.value, isA<Matrix4>());
      });

      test('linear path motion without autoRotate', () {
        final path = Path()..lineTo(100, 0);
        final act = PathMotionAct(path: path, autoRotate: false);

        final (animatable, _) = act.buildTweens(actContext);

        track.setProgress(0.5);
        final animation = CueAnimationImpl<Matrix4>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animatable,
        );
        expect(animation.value, isA<Matrix4>());
      });

      test('arc path with start offset', () {
        final act = PathMotionAct.arc(
          radius: 50,
          sweepAngle: 360,
          startOffset: 90,
        );

        final (animatable, _) = act.buildTweens(actContext);
        track.setProgress(0.5);
        final animation = CueAnimationImpl<Matrix4>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animatable,
        );
        expect(animation.value, isA<Matrix4>());
      });
    });
  });
}
