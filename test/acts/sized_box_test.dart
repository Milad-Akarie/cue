import 'package:cue/cue.dart';
import 'package:cue/src/timeline/track/track.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final motion = CueMotion.linear(300.ms);
  final actContext = ActContext(motion: motion, reverseMotion: motion);
  final track = CueTrackImpl(TrackConfig(motion: motion, reverseMotion: motion));
  final timeline = CueTimelineImpl.fromMotion(motion);

  DeferredCueAnimation<Size> createDeferredAnimation(CueTrackImpl track, ActContext ctx) {
    return DeferredCueAnimation<Size>(
      parent: track,
      token: ReleaseToken(track.config, timeline),
      context: ctx,
    );
  }

  group('SizedBoxAct', () {
    group('key', () {
      test('has correct key name', () {
        final act = SizedBoxAct();
        expect(act.key.key, 'SizedBox');
      });
    });

    group('default constructor', () {
      test('accepts width', () {
        final width = AnimatableValue(from: 100.0, to: 200.0);
        final act = SizedBoxAct(width: width);
        expect(act.width, width);
      });

      test('accepts height', () {
        final height = AnimatableValue(from: 100.0, to: 200.0);
        final act = SizedBoxAct(height: height);
        expect(act.height, height);
      });

      test('accepts both width and height', () {
        final width = AnimatableValue(from: 100.0, to: 200.0);
        final height = AnimatableValue(from: 50.0, to: 100.0);
        final act = SizedBoxAct(width: width, height: height);
        expect(act.width, width);
        expect(act.height, height);
      });

      test('default alignment is center', () {
        final act = SizedBoxAct();
        expect(act.alignment, Alignment.center);
      });

      test('accepts alignment', () {
        final act = SizedBoxAct(alignment: Alignment.topLeft);
        expect(act.alignment, Alignment.topLeft);
      });

      test('accepts motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = SizedBoxAct(motion: motion);
        expect(act.motion, motion);
      });

      test('accepts delay', () {
        final act = SizedBoxAct(delay: const Duration(milliseconds: 100));
        expect(act.delay, const Duration(milliseconds: 100));
      });

      test('accepts reverse', () {
        const reverse = ReverseBehavior<Size>.none();
        final act = SizedBoxAct(reverse: reverse);
        expect(act.reverse, reverse);
      });
    });

    group('keyframed constructor', () {
      test('accepts frames', () {
        final frames = Keyframes<Size>([
          Keyframe(const Size(100, 100), motion: CueMotion.linear(100.ms)),
          Keyframe(const Size(200, 200), motion: CueMotion.linear(100.ms)),
        ]);
        final act = SizedBoxAct.keyframed(frames: frames);
        expect(act.frames, frames);
      });

      test('accepts alignment', () {
        final frames = Keyframes<Size>([
          Keyframe(const Size(100, 100), motion: CueMotion.linear(100.ms)),
        ]);
        final act = SizedBoxAct.keyframed(frames: frames, alignment: Alignment.bottomRight);
        expect(act.alignment, Alignment.bottomRight);
      });

      test('accepts delay', () {
        final frames = Keyframes<Size>([
          Keyframe(const Size(100, 100), motion: CueMotion.linear(100.ms)),
        ]);
        final act = SizedBoxAct.keyframed(frames: frames, delay: 100.ms);
        expect(act.delay, 100.ms);
      });
    });

    group('resolve', () {
      test('returns ActContext with motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = SizedBoxAct(motion: motion);

        final resolved = act.resolve(actContext);
        expect(resolved.motion, isNotNull);
      });
    });

    group('apply', () {
      testWidgets('renders with width animation', (tester) async {
        final width = AnimatableValue(from: 100.0, to: 200.0);
        final act = SizedBoxAct(width: width);

        track.setProgress(0);
        final animation = createDeferredAnimation(track, actContext);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: Builder(
                builder: (context) {
                  return act.apply(context, animation, const Text('Width Test'));
                },
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.text('Width Test'), findsOneWidget);
      });

      testWidgets('renders with height animation', (tester) async {
        final height = AnimatableValue(from: 50.0, to: 150.0);
        final act = SizedBoxAct(height: height);

        track.setProgress(0.5);
        final animation = createDeferredAnimation(track, actContext);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: Builder(
                builder: (context) {
                  return act.apply(context, animation, const Text('Height Test'));
                },
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.text('Height Test'), findsOneWidget);
      });

      testWidgets('renders with both width and height', (tester) async {
        final width = AnimatableValue(from: 100.0, to: 200.0);
        final height = AnimatableValue(from: 50.0, to: 150.0);
        final act = SizedBoxAct(width: width, height: height);

        track.setProgress(0.5);
        final animation = createDeferredAnimation(track, actContext);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: Builder(
                builder: (context) {
                  return act.apply(context, animation, const Text('Both'));
                },
              ),
            ),
          ),
        );

        await tester.pump();
        expect(find.text('Both'), findsOneWidget);
      });

      testWidgets('renders with alignment', (tester) async {
        final width = AnimatableValue(from: 100.0, to: 200.0);
        final act = SizedBoxAct(width: width, alignment: Alignment.topLeft);

        track.setProgress(0.5);
        final animation = createDeferredAnimation(track, actContext);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const Text('Aligned'));
              },
            ),
          ),
        );

        await tester.pump();
        expect(find.text('Aligned'), findsOneWidget);
      });

      testWidgets('renders with progress at 0', (tester) async {
        final width = AnimatableValue(from: 100.0, to: 200.0);
        final act = SizedBoxAct(width: width);

        track.setProgress(0);
        final animation = createDeferredAnimation(track, actContext);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const Text('At Zero'));
              },
            ),
          ),
        );

        await tester.pump();
        expect(find.text('At Zero'), findsOneWidget);
      });

      testWidgets('renders with progress at 1', (tester) async {
        final width = AnimatableValue(from: 100.0, to: 200.0);
        final act = SizedBoxAct(width: width);

        track.setProgress(1);
        final animation = createDeferredAnimation(track, actContext);

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const Text('At One'));
              },
            ),
          ),
        );

        await tester.pump();
        expect(find.text('At One'), findsOneWidget);
      });
    });

    group('equality', () {
      test('equal acts have same hashCode', () {
        final width = AnimatableValue(from: 100.0, to: 200.0);
        final act1 = SizedBoxAct(width: width);
        final act2 = SizedBoxAct(width: width);
        expect(act1, act2);
        expect(act1.hashCode, equals(act2.hashCode));
      });

      test('different widths are not equal', () {
        final act1 = SizedBoxAct(width: AnimatableValue(from: 100.0, to: 200.0));
        final act2 = SizedBoxAct(width: AnimatableValue(from: 150.0, to: 250.0));
        expect(act1, isNot(act2));
      });

      test('different heights are not equal', () {
        final act1 = SizedBoxAct(height: AnimatableValue(from: 100.0, to: 200.0));
        final act2 = SizedBoxAct(height: AnimatableValue(from: 150.0, to: 250.0));
        expect(act1, isNot(act2));
      });

      test('different alignments are not equal', () {
        final act1 = SizedBoxAct(alignment: Alignment.center);
        final act2 = SizedBoxAct(alignment: Alignment.topLeft);
        expect(act1, isNot(act2));
      });

      test('different motion values are not equal', () {
        final motion1 = CueMotion.linear(300.ms);
        final motion2 = CueMotion.linear(500.ms);
        final act1 = SizedBoxAct(motion: motion1);
        final act2 = SizedBoxAct(motion: motion2);
        expect(act1, isNot(act2));
      });

      test('different delay values are not equal', () {
        final act1 = SizedBoxAct(delay: 100.ms);
        final act2 = SizedBoxAct(delay: 200.ms);
        expect(act1, isNot(act2));
      });

      test('different reverse values are not equal', () {
        const act1 = SizedBoxAct(reverse: ReverseBehavior<Size>.none());
        const act2 = SizedBoxAct(reverse: ReverseBehavior<Size>.exclusive());
        expect(act1, isNot(act2));
      });

      test('identical act is equal to itself', () {
        final act = SizedBoxAct();
        expect(act, same(act));
      });
    });
  });
}
