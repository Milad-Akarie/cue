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

  CueTrackImpl createTrack() {
    final motion = CueMotion.linear(300.ms);
    final config = TrackConfig(motion: motion, reverseMotion: motion);
    return CueTrackImpl(config);
  }

  DeferredCueAnimation<Offset> createDeferredAnimation(CueTrackImpl track, ActContext ctx) {
    return DeferredCueAnimation<Offset>(
      parent: track,
      token: ReleaseToken(track.config),
      context: ctx,
    );
  }

  group('ParallaxAct', () {
    group('key', () {
      test('has correct key name', () {
        final act = ParallaxAct(slide: 0.5);
        expect(act.key.key, 'Parallax');
      });
    });

    group('constructors', () {
      test('requires slide', () {
        final act = ParallaxAct(slide: 0.5);
        expect(act.slide, 0.5);
      });

      test('default axis is horizontal', () {
        final act = ParallaxAct(slide: 0.5);
        expect(act.axis, Axis.horizontal);
      });

      test('constructor accepts axis', () {
        final act = ParallaxAct(slide: 0.5, axis: Axis.vertical);
        expect(act.axis, Axis.vertical);
      });

      test('constructor accepts motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = ParallaxAct(slide: 0.5, motion: motion);
        expect(act.motion, motion);
      });

      test('constructor accepts delay', () {
        final act = ParallaxAct(
          slide: 0.5,
          delay: const Duration(milliseconds: 100),
        );
        expect(act.delay, const Duration(milliseconds: 100));
      });

      test('constructor accepts reverse', () {
        const reverse = ReverseBehavior<double>.none();
        final act = ParallaxAct(slide: 0.5, reverse: reverse);
        expect(act, isNotNull);
      });
    });

    group('resolve', () {
      test('returns ActContext with motion and delay', () {
        final motion = CueMotion.linear(300.ms);
        final act = ParallaxAct(slide: 0.5, motion: motion);
        final ctx = createActContext();
        final resolved = act.resolve(ctx);
        expect(resolved.motion, isNotNull);
      });

      test('returns ActContext with delay', () {
        final act = ParallaxAct(slide: 0.5, delay: 100.ms);
        final ctx = createActContext();
        final resolved = act.resolve(ctx);
        expect(resolved, isA<ActContext>());
      });
    });

    group('apply', () {
      testWidgets('renders child widget', (tester) async {
        final act = ParallaxAct(slide: 0.5);
        final ctx = createActContext();
        final track = createTrack();
        track.setProgress(0.5);
        final animation = createDeferredAnimation(track, ctx);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const Text('Parallax'));
              },
            ),
          ),
        );

        expect(find.text('Parallax'), findsOneWidget);
      });

      testWidgets('renders with horizontal axis', (tester) async {
        final act = ParallaxAct(slide: 0.3, axis: Axis.horizontal);
        final ctx = createActContext();
        final track = createTrack();
        track.setProgress(0.5);
        final animation = createDeferredAnimation(track, ctx);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 400,
              height: 200,
              child: Builder(
                builder: (context) {
                  return act.apply(context, animation, const SizedBox(width: 300, height: 200));
                },
              ),
            ),
          ),
        );
      });

      testWidgets('renders with vertical axis', (tester) async {
        final act = ParallaxAct(slide: 0.3, axis: Axis.vertical);
        final ctx = createActContext();
        final track = createTrack();
        track.setProgress(0.5);
        final animation = createDeferredAnimation(track, ctx);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 200,
              height: 400,
              child: Builder(
                builder: (context) {
                  return act.apply(context, animation, const SizedBox(width: 200, height: 300));
                },
              ),
            ),
          ),
        );

        await tester.pump();
      });

      testWidgets('layout performs correctly with child', (tester) async {
        final act = ParallaxAct(slide: 0.5, axis: Axis.horizontal);
        final ctx = createActContext();
        final track = createTrack();
        track.setProgress(0);
        final animation = createDeferredAnimation(track, ctx);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: Builder(
                builder: (context) {
                  return act.apply(
                    context,
                    animation,
                    const SizedBox(width: 500, height: 100),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pump();
      });

      testWidgets('works with empty child', (tester) async {
        final act = ParallaxAct(slide: 0.5);
        final ctx = createActContext();
        final track = createTrack();
        track.setProgress(0.5);
        final animation = createDeferredAnimation(track, ctx);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const SizedBox.shrink());
              },
            ),
          ),
        );

        await tester.pump();
      });

      testWidgets('renders with different slide values', (tester) async {
        final act = ParallaxAct(slide: 1.0, axis: Axis.horizontal);
        final ctx = createActContext();
        final track = createTrack();
        track.setProgress(0);
        final animation = createDeferredAnimation(track, ctx);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 400,
              height: 100,
              child: Builder(
                builder: (context) {
                  return act.apply(
                    context,
                    animation,
                    const SizedBox(width: 800, height: 100),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pump();
      });
    });

    group('equality', () {
      test('equal acts have same hashCode', () {
        final act1 = ParallaxAct(slide: 0.5, axis: Axis.horizontal);
        final act2 = ParallaxAct(slide: 0.5, axis: Axis.horizontal);
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });

      test('different slide values are not equal', () {
        final act1 = ParallaxAct(slide: 0.5);
        final act2 = ParallaxAct(slide: 0.8);
        expect(act1, isNot(act2));
      });

      test('different axis values are not equal', () {
        final act1 = ParallaxAct(slide: 0.5, axis: Axis.horizontal);
        final act2 = ParallaxAct(slide: 0.5, axis: Axis.vertical);
        expect(act1, isNot(act2));
      });

      test('different motion values are not equal', () {
        final motion1 = CueMotion.linear(300.ms);
        final motion2 = CueMotion.linear(500.ms);
        final act1 = ParallaxAct(slide: 0.5, motion: motion1);
        final act2 = ParallaxAct(slide: 0.5, motion: motion2);
        expect(act1, isNot(act2));
      });

      test('different delay values are not equal', () {
        final act1 = ParallaxAct(slide: 0.5, delay: 100.ms);
        final act2 = ParallaxAct(slide: 0.5, delay: 200.ms);
        expect(act1, isNot(act2));
      });

      test('different reverse values are not equal', () {
        const act1 = ParallaxAct(slide: 0.5, reverse: ReverseBehavior<double>.none());
        const act2 = ParallaxAct(slide: 0.5, reverse: ReverseBehavior<double>.exclusive());
        expect(act1, isNot(act2));
      });

      test('identical act is equal to itself', () {
        final act = ParallaxAct(slide: 0.5);
        expect(act, same(act));
      });
    });
  });
}
