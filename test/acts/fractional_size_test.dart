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

  group('FractionalSizeAct', () {
    group('key', () {
      test('has correct key name', () {
        const act = FractionalSizeAct();
        expect(act.key.key, 'FractionalSize');
      });
    });

    group('constructors', () {
      test('default constructor creates act with null values', () {
        const act = FractionalSizeAct();
        expect(act.widthFactor, isNull);
        expect(act.heightFactor, isNull);
        expect(act.alignment?.from, Alignment.center);
      });

      test('constructor accepts widthFactor', () {
        const act = FractionalSizeAct(
          widthFactor: AnimatableValue(from: 0.5, to: 1.0),
        );
        expect(act.widthFactor?.from, 0.5);
        expect(act.widthFactor?.to, 1.0);
      });

      test('constructor accepts heightFactor', () {
        const act = FractionalSizeAct(
          heightFactor: AnimatableValue(from: 0.5, to: 1.0),
        );
        expect(act.heightFactor?.from, 0.5);
        expect(act.heightFactor?.to, 1.0);
      });

      test('constructor accepts alignment', () {
        const act = FractionalSizeAct(
          alignment: AnimatableValue(from: Alignment.topLeft, to: Alignment.bottomRight),
        );
        expect(act.alignment?.from, Alignment.topLeft);
        expect(act.alignment?.to, Alignment.bottomRight);
      });

      test('constructor accepts motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = FractionalSizeAct(motion: motion);
        expect(act.motion, motion);
      });

      test('constructor accepts delay', () {
        const act = FractionalSizeAct(delay: Duration(milliseconds: 100));
        expect(act.delay, const Duration(milliseconds: 100));
      });

      test('constructor accepts reverse', () {
        const reverse = ReverseBehavior<FractionalSize>.mirror();
        const act = FractionalSizeAct(reverse: reverse);
        expect(act.reverse, reverse);
      });

      test('constructor accepts all parameters', () {
        final motion = CueMotion.linear(300.ms);
        const reverse = ReverseBehavior<FractionalSize>.none();
        final act = FractionalSizeAct(
          motion: motion,
          delay: Duration(milliseconds: 100),
          widthFactor: AnimatableValue(from: 0.5, to: 1.0),
          heightFactor: AnimatableValue(from: 0.3, to: 0.8),
          alignment: AnimatableValue(from: Alignment.topLeft, to: Alignment.bottomRight),
          reverse: reverse,
        );
        expect(act.motion, motion);
        expect(act.delay, const Duration(milliseconds: 100));
        expect(act.widthFactor?.from, 0.5);
        expect(act.heightFactor?.from, 0.3);
        expect(act.alignment?.from, Alignment.topLeft);
        expect(act.reverse, reverse);
      });

      test('keyframed constructor sets frames', () {
        final frames = Keyframes<FractionalSize>([
          Keyframe(FractionalSize(widthFactor: 0.5)),
          Keyframe(FractionalSize(widthFactor: 1.0)),
        ], motion: .linear(300.ms));
        final act = FractionalSizeAct.keyframed(frames: frames);
        expect(act.frames, frames);
      });

      test('keyframed constructor with delay', () {
        final frames = Keyframes<FractionalSize>([
          Keyframe(FractionalSize(widthFactor: 0.5)),
          Keyframe(FractionalSize(widthFactor: 1.0)),
        ], motion: .linear(300.ms));
        final act = FractionalSizeAct.keyframed(
          frames: frames,
          delay: Duration(milliseconds: 100),
        );
        expect(act.delay, const Duration(milliseconds: 100));
        expect(act.frames, frames);
      });

      test('keyframed constructor with reverse', () {
        final frames = Keyframes<FractionalSize>([
          Keyframe(FractionalSize(widthFactor: 0.5)),
          Keyframe(FractionalSize(widthFactor: 1.0)),
        ], motion: .linear(300.ms));
        const reverse = ReverseBehavior<FractionalSize>.mirror();
        final act = FractionalSizeAct.keyframed(
          frames: frames,
          reverse: reverse,
        );
        expect(act.reverse, reverse);
        expect(act.frames, frames);
      });

      test('keyframed constructor with all parameters', () {
        final frames = Keyframes<FractionalSize>([
          Keyframe(FractionalSize(widthFactor: 0.5)),
          Keyframe(FractionalSize(widthFactor: 1.0)),
        ], motion: .linear(300.ms));
        const reverse = ReverseBehavior<FractionalSize>.none();
        final act = FractionalSizeAct.keyframed(
          frames: frames,
          delay: Duration(milliseconds: 100),
          reverse: reverse,
        );
        expect(act.frames, frames);
        expect(act.delay, const Duration(milliseconds: 100));
        expect(act.reverse, reverse);
      });
    });

    group('buildTweens', () {
      test('creates animtable with widthFactor', () {
        const act = FractionalSizeAct(
          widthFactor: AnimatableValue(from: 0.5, to: 1.0),
        );

        final (animtable, _) = act.buildTweens(actContext);
        expect(animtable, isNotNull);
      });

      test('creates animtable with multiple properties', () {
        const act = FractionalSizeAct(
          widthFactor: AnimatableValue(from: 0.5, to: 1.0),
          heightFactor: AnimatableValue(from: 0.5, to: 1.0),
        );

        final (animtable, _) = act.buildTweens(actContext);
        expect(animtable, isNotNull);
      });

      test('creates animtable with alignment', () {
        const act = FractionalSizeAct(
          widthFactor: AnimatableValue(from: 0.5, to: 1.0),
          alignment: AnimatableValue(from: Alignment.topLeft, to: Alignment.bottomRight),
        );

        final (animtable, _) = act.buildTweens(actContext);
        expect(animtable, isNotNull);
      });

      test('creates animtable with all properties', () {
        const act = FractionalSizeAct(
          widthFactor: AnimatableValue(from: 0.5, to: 1.0),
          heightFactor: AnimatableValue(from: 0.3, to: 0.8),
          alignment: AnimatableValue(from: Alignment.topLeft, to: Alignment.bottomRight),
        );

        final (animtable, _) = act.buildTweens(actContext);
        expect(animtable, isNotNull);
      });

      test('creates animtable from keyframed constructor', () {
        final frames = Keyframes<FractionalSize>([
          Keyframe(FractionalSize(widthFactor: 0.5)),
          Keyframe(FractionalSize(widthFactor: 1.0)),
        ], motion: .linear(300.ms));
        final act = FractionalSizeAct.keyframed(frames: frames);

        final (animtable, _) = act.buildTweens(actContext);
        expect(animtable, isNotNull);
      });
    });

    group('apply', () {
      testWidgets('wraps child in FractionallySizedBox', (tester) async {
        const act = FractionalSizeAct(
          widthFactor: AnimatableValue(from: 0.5, to: 1.0),
        );

        final (animtable, _) = act.buildTweens(actContext);

        track.setProgress(0.5);

        final animation = CueAnimationImpl<FractionalSize>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
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

        expect(find.byType(FractionallySizedBox), findsOneWidget);
        expect(find.text('Child'), findsOneWidget);
      });

      testWidgets('applies widthFactor at progress 0', (tester) async {
        const act = FractionalSizeAct(
          widthFactor: AnimatableValue(from: 0.5, to: 1.0),
        );

        final (animtable, _) = act.buildTweens(actContext);

        track.setProgress(0.0);

        final animation = CueAnimationImpl<FractionalSize>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
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

        final sizedBox = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
        expect(sizedBox.widthFactor, 0.5);
      });

      testWidgets('applies widthFactor at progress 1', (tester) async {
        const act = FractionalSizeAct(
          widthFactor: AnimatableValue(from: 0.5, to: 1.0),
        );

        final (animtable, _) = act.buildTweens(actContext);

        track.setProgress(1.0);

        final animation = CueAnimationImpl<FractionalSize>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
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

        final sizedBox = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
        expect(sizedBox.widthFactor, 1.0);
      });

      testWidgets('interpolates widthFactor at progress 0.5', (tester) async {
        const act = FractionalSizeAct(
          widthFactor: AnimatableValue(from: 0.0, to: 1.0),
        );

        final (animtable, _) = act.buildTweens(actContext);

        track.setProgress(0.5);

        final animation = CueAnimationImpl<FractionalSize>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
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

        final sizedBox = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
        expect(sizedBox.widthFactor, 0.5);
      });

      testWidgets('applies both widthFactor and heightFactor', (tester) async {
        const act = FractionalSizeAct(
          widthFactor: AnimatableValue(from: 0.5, to: 1.0),
          heightFactor: AnimatableValue(from: 0.5, to: 1.0),
        );

        final (animtable, _) = act.buildTweens(actContext);

        track.setProgress(0.5);

        final animation = CueAnimationImpl<FractionalSize>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
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

        final sizedBox = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
        expect(sizedBox.widthFactor, 0.75);
        expect(sizedBox.heightFactor, 0.75);
      });

      testWidgets('default alignment is center', (tester) async {
        const act = FractionalSizeAct(
          widthFactor: AnimatableValue(from: 0.5, to: 1.0),
        );

        final (animtable, _) = act.buildTweens(actContext);

        track.setProgress(0.5);

        final animation = CueAnimationImpl<FractionalSize>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
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

        final sizedBox = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
        expect(sizedBox.alignment, Alignment.center);
      });

      testWidgets('applies heightFactor at progress 0', (tester) async {
        const act = FractionalSizeAct(
          heightFactor: AnimatableValue(from: 0.5, to: 1.0),
        );

        final (animtable, _) = act.buildTweens(actContext);

        track.setProgress(0.0);

        final animation = CueAnimationImpl<FractionalSize>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
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

        final sizedBox = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
        expect(sizedBox.heightFactor, 0.5);
      });

      testWidgets('applies heightFactor at progress 1', (tester) async {
        const act = FractionalSizeAct(
          heightFactor: AnimatableValue(from: 0.5, to: 1.0),
        );

        final (animtable, _) = act.buildTweens(actContext);

        track.setProgress(1.0);

        final animation = CueAnimationImpl<FractionalSize>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
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

        final sizedBox = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
        expect(sizedBox.heightFactor, 1.0);
      });

      testWidgets('applies alignment at progress 0', (tester) async {
        const act = FractionalSizeAct(
          widthFactor: AnimatableValue(from: 0.5, to: 1.0),
          alignment: AnimatableValue(from: Alignment.topLeft, to: Alignment.bottomRight),
        );

        final (animtable, _) = act.buildTweens(actContext);

        track.setProgress(0.0);

        final animation = CueAnimationImpl<FractionalSize>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
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

        final sizedBox = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
        expect(sizedBox.alignment, Alignment.topLeft);
      });

      testWidgets('applies alignment at progress 1', (tester) async {
        const act = FractionalSizeAct(
          widthFactor: AnimatableValue(from: 0.5, to: 1.0),
          alignment: AnimatableValue(from: Alignment.topLeft, to: Alignment.bottomRight),
        );

        final (animtable, _) = act.buildTweens(actContext);

        track.setProgress(1.0);

        final animation = CueAnimationImpl<FractionalSize>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
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

        final sizedBox = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
        expect(sizedBox.alignment, Alignment.bottomRight);
      });
    });

    group('resolve', () {
      test('resolve returns ActContext with motion', () {
        final motion = CueMotion.linear(500.ms);
        final act = FractionalSizeAct(motion: motion);
        final context = ActContext(motion: CueMotion.linear(300.ms), reverseMotion: CueMotion.linear(300.ms));

        final resolved = act.resolve(context);
        expect(resolved, isNotNull);
      });

      test('resolve returns ActContext with delay', () {
        final act = FractionalSizeAct(delay: Duration(milliseconds: 100));
        final context = ActContext(motion: CueMotion.linear(300.ms), reverseMotion: CueMotion.linear(300.ms));

        final resolved = act.resolve(context);
        expect(resolved, isNotNull);
      });

      test('resolve with keyframed constructor', () {
        final frames = Keyframes<FractionalSize>([
          Keyframe(FractionalSize(widthFactor: 0.5)),
          Keyframe(FractionalSize(widthFactor: 1.0)),
        ], motion: .linear(300.ms));
        final act = FractionalSizeAct.keyframed(frames: frames);
        final context = ActContext(motion: CueMotion.linear(300.ms), reverseMotion: CueMotion.linear(300.ms));

        final resolved = act.resolve(context);
        expect(resolved, isNotNull);
      });
    });

    group('equality', () {
      test('equal acts have same hashCode', () {
        const act1 = FractionalSizeAct(
          widthFactor: AnimatableValue(from: 0.5, to: 1.0),
        );
        const act2 = FractionalSizeAct(
          widthFactor: AnimatableValue(from: 0.5, to: 1.0),
        );
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });

      test('different widthFactor values are not equal', () {
        const act1 = FractionalSizeAct(
          widthFactor: AnimatableValue(from: 0.5, to: 1.0),
        );
        const act2 = FractionalSizeAct(
          widthFactor: AnimatableValue(from: 0.3, to: 1.0),
        );
        expect(act1, isNot(act2));
      });

      test('different heightFactor values are not equal', () {
        const act1 = FractionalSizeAct(
          heightFactor: AnimatableValue(from: 0.5, to: 1.0),
        );
        const act2 = FractionalSizeAct(
          heightFactor: AnimatableValue(from: 0.3, to: 1.0),
        );
        expect(act1, isNot(act2));
      });

      test('different alignment values are not equal', () {
        const act1 = FractionalSizeAct(
          alignment: AnimatableValue(from: Alignment.topLeft, to: Alignment.center),
        );
        const act2 = FractionalSizeAct(
          alignment: AnimatableValue(from: Alignment.bottomRight, to: Alignment.center),
        );
        expect(act1, isNot(act2));
      });

      test('different reverse values are not equal', () {
        const act1 = FractionalSizeAct(
          reverse: ReverseBehavior<FractionalSize>.mirror(),
        );
        const act2 = FractionalSizeAct(
          reverse: ReverseBehavior<FractionalSize>.none(),
        );
        expect(act1, isNot(act2));
      });

      test('keyframed acts with different frames are not equal', () {
        final frames1 = Keyframes<FractionalSize>([
          Keyframe(FractionalSize(widthFactor: 0.5)),
          Keyframe(FractionalSize(widthFactor: 1.0)),
        ], motion: .linear(300.ms));
        final frames2 = Keyframes<FractionalSize>([
          Keyframe(FractionalSize(widthFactor: 0.3)),
          Keyframe(FractionalSize(widthFactor: 0.9)),
        ], motion: .linear(300.ms));
        final act1 = FractionalSizeAct.keyframed(frames: frames1);
        final act2 = FractionalSizeAct.keyframed(frames: frames2);
        expect(act1, isNot(act2));
      });

      test('keyframed acts with same frames are equal', () {
        final frames = Keyframes<FractionalSize>([
          Keyframe(FractionalSize(widthFactor: 0.5)),
          Keyframe(FractionalSize(widthFactor: 1.0)),
        ], motion: .linear(300.ms));
        final act1 = FractionalSizeAct.keyframed(frames: frames);
        final act2 = FractionalSizeAct.keyframed(frames: frames);
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });
    });

    group('FractionalSize', () {
      test('creates with widthFactor', () {
        final size = FractionalSize(widthFactor: 0.5);
        expect(size.widthFactor, 0.5);
        expect(size.heightFactor, isNull);
        expect(size.alignment, isNull);
      });

      test('creates with all properties', () {
        final size = FractionalSize(
          widthFactor: 0.5,
          heightFactor: 0.8,
          alignment: Alignment.center,
        );
        expect(size.widthFactor, 0.5);
        expect(size.heightFactor, 0.8);
        expect(size.alignment, Alignment.center);
      });

      test('lerp interpolates values', () {
        final a = FractionalSize(widthFactor: 0.0, heightFactor: 0.0);
        final b = FractionalSize(widthFactor: 1.0, heightFactor: 1.0);
        final result = FractionalSize.lerp(a, b, 0.5);
        expect(result.widthFactor, 0.5);
        expect(result.heightFactor, 0.5);
      });

      test('lerp handles null values', () {
        final a = FractionalSize(widthFactor: null, heightFactor: null);
        final b = FractionalSize(widthFactor: 1.0, heightFactor: 1.0);
        final result = FractionalSize.lerp(a, b, 0.5);
        expect(result.widthFactor, 0.5);
        expect(result.heightFactor, 0.5);
      });

      test('lerp with alignment', () {
        final a = FractionalSize(
          widthFactor: 0.0,
          alignment: Alignment.topLeft,
        );
        final b = FractionalSize(
          widthFactor: 1.0,
          alignment: Alignment.bottomRight,
        );
        final result = FractionalSize.lerp(a, b, 0.5);
        expect(result.widthFactor, 0.5);
        expect(result.alignment, isNotNull);
      });

      test('lerp at t=0 returns start value', () {
        final a = FractionalSize(widthFactor: 0.2, heightFactor: 0.3);
        final b = FractionalSize(widthFactor: 1.0, heightFactor: 1.0);
        final result = FractionalSize.lerp(a, b, 0.0);
        expect(result.widthFactor, 0.2);
        expect(result.heightFactor, 0.3);
      });

      test('lerp at t=1 returns end value', () {
        final a = FractionalSize(widthFactor: 0.0, heightFactor: 0.0);
        final b = FractionalSize(widthFactor: 0.8, heightFactor: 0.9);
        final result = FractionalSize.lerp(a, b, 1.0);
        expect(result.widthFactor, 0.8);
        expect(result.heightFactor, 0.9);
      });

      test('equality works correctly', () {
        final size1 = FractionalSize(widthFactor: 0.5, heightFactor: 0.5);
        final size2 = FractionalSize(widthFactor: 0.5, heightFactor: 0.5);
        expect(size1, equals(size2));
        expect(size1.hashCode, equals(size2.hashCode));
      });

      test('different values are not equal', () {
        final size1 = FractionalSize(widthFactor: 0.5);
        final size2 = FractionalSize(widthFactor: 0.8);
        expect(size1, isNot(equals(size2)));
      });

      test('hashCode is consistent', () {
        final size1 = FractionalSize(
          widthFactor: 0.5,
          heightFactor: 0.8,
          alignment: Alignment.center,
        );
        final size2 = FractionalSize(
          widthFactor: 0.5,
          heightFactor: 0.8,
          alignment: Alignment.center,
        );
        expect(size1.hashCode, size2.hashCode);
      });

      test('equal when all properties are null', () {
        final size1 = FractionalSize();
        final size2 = FractionalSize();
        expect(size1, equals(size2));
        expect(size1.hashCode, equals(size2.hashCode));
      });

      test('different alignment values are not equal', () {
        final size1 = FractionalSize(
          widthFactor: 0.5,
          alignment: Alignment.topLeft,
        );
        final size2 = FractionalSize(
          widthFactor: 0.5,
          alignment: Alignment.bottomRight,
        );
        expect(size1, isNot(equals(size2)));
      });
    });
  });
}
