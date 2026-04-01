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
  group('DecoratedBoxAct', () {
    group('key', () {
      test('has correct key name', () {
        const act = DecoratedBoxAct();
        expect(act.key.key, 'DecoratedBox');
      });
    });

    group('constructors', () {
      test('default constructor creates act with null values', () {
        const act = DecoratedBoxAct();
        expect(act.color, isNull);
        expect(act.borderRadius, isNull);
        expect(act.border, isNull);
        expect(act.boxShadow, isNull);
        expect(act.gradient, isNull);
        expect(act.shape, BoxShape.rectangle);
        expect(act.position, DecorationPosition.background);
      });

      test('constructor accepts color', () {
        const act = DecoratedBoxAct(
          color: AnimatableValue(from: Colors.red, to: Colors.blue),
        );
        expect(act.color?.from, Colors.red);
        expect(act.color?.to, Colors.blue);
      });

      test('constructor accepts borderRadius', () {
        const act = DecoratedBoxAct(
          borderRadius: AnimatableValue(
            from: BorderRadius.zero,
            to: BorderRadius.all(Radius.circular(10)),
          ),
        );
        expect(act.borderRadius?.from, BorderRadius.zero);
        expect(act.borderRadius?.to, const BorderRadius.all(Radius.circular(10)));
      });

      test('constructor accepts border', () {
        const act = DecoratedBoxAct(
          border: AnimatableValue(
            from: Border(),
            to: Border.fromBorderSide(BorderSide(color: Colors.black)),
          ),
        );
        expect(act.border, isNotNull);
      });

      test('constructor accepts boxShadow', () {
        const act = DecoratedBoxAct(
          boxShadow: AnimatableValue(
            from: [],
            to: [BoxShadow(color: Colors.black)],
          ),
        );
        expect(act.boxShadow, isNotNull);
      });

      test('constructor accepts gradient', () {
        const act = DecoratedBoxAct(
          gradient: AnimatableValue(
            from: LinearGradient(colors: [Colors.red, Colors.blue]),
            to: LinearGradient(colors: [Colors.green, Colors.yellow]),
          ),
        );
        expect(act.gradient, isNotNull);
      });

      test('constructor accepts shape', () {
        const act = DecoratedBoxAct(shape: BoxShape.circle);
        expect(act.shape, BoxShape.circle);
      });

      test('constructor accepts position', () {
        const act = DecoratedBoxAct(position: DecorationPosition.foreground);
        expect(act.position, DecorationPosition.foreground);
      });

      test('constructor accepts motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = DecoratedBoxAct(motion: motion);
        expect(act.motion, motion);
      });

      test('constructor accepts delay', () {
        const act = DecoratedBoxAct(delay: Duration(milliseconds: 100));
        expect(act.delay, const Duration(milliseconds: 100));
      });

      test('keyframed constructor sets frames', () {
        final frames = Keyframes<Decoration>([
          Keyframe(BoxDecoration(color: Colors.red), motion: CueMotion.linear(300.ms)),
          Keyframe(BoxDecoration(color: Colors.blue), motion: CueMotion.linear(300.ms)),
        ]);
        final act = DecoratedBoxAct.keyframed(frames: frames);
        expect(act.frames, frames);
      });
    });

    group('buildTweens', () {
      test('creates animtable with color', () {
        const act = DecoratedBoxAct(
          color: AnimatableValue(from: Colors.red, to: Colors.blue),
        );
        
        final (animtable, _) = act.buildTweens(actContext);
        expect(animtable, isNotNull);
      });

      test('creates animtable with multiple properties', () {
        const act = DecoratedBoxAct(
          color: AnimatableValue(from: Colors.red, to: Colors.blue),
          borderRadius: AnimatableValue(
            from: BorderRadius.zero,
            to: BorderRadius.all(Radius.circular(10)),
          ),
        );
        
        final (animtable, _) = act.buildTweens(actContext);
        expect(animtable, isNotNull);
      });
    });

    group('apply', () {
      testWidgets('wraps child in DecoratedBoxTransition', (tester) async {
        const act = DecoratedBoxAct(
          color: AnimatableValue(from: Colors.red, to: Colors.blue),
        );
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0.5);

        final animation = CueAnimationImpl<Decoration>(
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

        expect(find.byType(DecoratedBoxTransition), findsOneWidget);
        expect(find.text('Child'), findsOneWidget);
      });

      testWidgets('uses animation for decoration', (tester) async {
        const act = DecoratedBoxAct(
          color: AnimatableValue(from: Colors.red, to: Colors.blue),
        );
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0.5);

        final animation = CueAnimationImpl<Decoration>(
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

        final transition = tester.widget<DecoratedBoxTransition>(find.byType(DecoratedBoxTransition));
        expect(transition.decoration, animation);
      });

      testWidgets('applies position correctly', (tester) async {
        const act = DecoratedBoxAct(
          color: AnimatableValue(from: Colors.red, to: Colors.blue),
          position: DecorationPosition.foreground,
        );
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0.5);

        final animation = CueAnimationImpl<Decoration>(
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

        final transition = tester.widget<DecoratedBoxTransition>(find.byType(DecoratedBoxTransition));
        expect(transition.position, DecorationPosition.foreground);
      });
    });

    group('equality', () {
      test('equal acts have same hashCode', () {
        const act1 = DecoratedBoxAct(
          color: AnimatableValue(from: Colors.red, to: Colors.blue),
        );
        const act2 = DecoratedBoxAct(
          color: AnimatableValue(from: Colors.red, to: Colors.blue),
        );
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });

      test('different color values are not equal', () {
        const act1 = DecoratedBoxAct(
          color: AnimatableValue(from: Colors.red, to: Colors.blue),
        );
        const act2 = DecoratedBoxAct(
          color: AnimatableValue(from: Colors.green, to: Colors.blue),
        );
        expect(act1, isNot(act2));
      });

      test('different shapes are not equal', () {
        const act1 = DecoratedBoxAct(shape: BoxShape.rectangle);
        const act2 = DecoratedBoxAct(shape: BoxShape.circle);
        expect(act1, isNot(act2));
      });

      test('different positions are not equal', () {
        const act1 = DecoratedBoxAct(position: DecorationPosition.background);
        const act2 = DecoratedBoxAct(position: DecorationPosition.foreground);
        expect(act1, isNot(act2));
      });
    });
  });

  group('DecoratedBoxActor', () {
    test('creates DecoratedBoxAct with correct values', () {
      const actor = DecoratedBoxActor(
        color: AnimatableValue(from: Colors.red, to: Colors.blue),
      );
      expect(actor.color?.from, Colors.red);
      expect(actor.color?.to, Colors.blue);
    });

    test('passes shape to act', () {
      const actor = DecoratedBoxActor(shape: BoxShape.circle);
      expect(actor.shape, BoxShape.circle);
    });

    test('passes position to act', () {
      const actor = DecoratedBoxActor(position: DecorationPosition.foreground);
      expect(actor.position, DecorationPosition.foreground);
    });

    test('wraps child in Actor with DecoratedBoxAct', () {
      const actor = DecoratedBoxActor(
        color: AnimatableValue(from: Colors.red, to: Colors.blue),
        child: SizedBox(),
      );

      expect(actor.color?.from, Colors.red);
      expect(actor.color?.to, Colors.blue);
    });
  });
}
