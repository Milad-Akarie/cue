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

      test('keyframed constructor sets frames', () {
        final frames = Keyframes<FractionalSize>([
          Keyframe(FractionalSize(widthFactor: 0.5), motion: CueMotion.linear(300.ms)),
          Keyframe(FractionalSize(widthFactor: 1.0), motion: CueMotion.linear(300.ms)),
        ]);
        final act = FractionalSizeAct.keyframed(frames: frames);
        expect(act.frames, frames);
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
          token:  ReleaseToken(track.config, timeline),
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
          token:  ReleaseToken(track.config, timeline),
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
          token:  ReleaseToken(track.config, timeline),
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
          token:  ReleaseToken(track.config, timeline),
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
          token:  ReleaseToken(track.config, timeline),
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
  });
}
