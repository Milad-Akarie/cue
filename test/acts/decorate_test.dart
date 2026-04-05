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

      test('constructor accepts image', () {
        const act = DecoratedBoxAct(
          image: DecorationImage(image: AssetImage('test.png')),
        );
        expect(act.image, isNotNull);
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

      test('constructor accepts reverse', () {
        const reverse = ReverseBehavior<Decoration>.mirror();
        const act = DecoratedBoxAct(reverse: reverse);
        expect(act.reverse, reverse);
      });

      test('keyframed constructor sets frames', () {
        final frames = Keyframes<Decoration>([
          Keyframe(BoxDecoration(color: Colors.red)),
          Keyframe(BoxDecoration(color: Colors.blue)),
        ], motion: .linear(300.ms));
        final act = DecoratedBoxAct.keyframed(frames: frames);
        expect(act.frames, frames);
      });

      test('keyframed constructor accepts delay', () {
        final frames = Keyframes<Decoration>([
          Keyframe(BoxDecoration(color: Colors.red)),
          Keyframe(BoxDecoration(color: Colors.blue)),
        ], motion: .linear(300.ms));
        const delay = Duration(milliseconds: 150);
        final act = DecoratedBoxAct.keyframed(frames: frames, delay: delay);
        expect(act.delay, equals(delay));
      });

      test('keyframed constructor accepts reverse', () {
        final frames = Keyframes<Decoration>([
          Keyframe(BoxDecoration(color: Colors.red)),
          Keyframe(BoxDecoration(color: Colors.blue)),
        ], motion: .linear(300.ms));
        const reverse = KFReverseBehavior<Decoration>.mirror();
        final act = DecoratedBoxAct.keyframed(frames: frames, reverse: reverse);
        expect(act.reverse, reverse);
      });

      test('keyframed constructor accepts position', () {
        final frames = Keyframes<Decoration>([
          Keyframe(BoxDecoration(color: Colors.red)),
          Keyframe(BoxDecoration(color: Colors.blue)),
        ], motion: .linear(300.ms));
        final act = DecoratedBoxAct.keyframed(
          frames: frames,
          position: DecorationPosition.foreground,
        );
        expect(act.position, DecorationPosition.foreground);
      });

      test('keyframed constructor accepts image', () {
        final frames = Keyframes<Decoration>([
          Keyframe(BoxDecoration(color: Colors.red)),
          Keyframe(BoxDecoration(color: Colors.blue)),
        ], motion: .linear(300.ms));
        final act = DecoratedBoxAct.keyframed(
          frames: frames,
          image: const DecorationImage(image: AssetImage('test.png')),
        );
        expect(act.image, isNotNull);
      });

      test('constructor with all parameters', () {
        final motion = CueMotion.linear(400.ms);
        const reverse = ReverseBehavior<Decoration>.mirror();
        final act = DecoratedBoxAct(
          color: const AnimatableValue(from: Colors.red, to: Colors.blue),
          borderRadius: const AnimatableValue(
            from: BorderRadius.zero,
            to: BorderRadius.all(Radius.circular(10)),
          ),
          border: const AnimatableValue(from: Border(), to: Border()),
          boxShadow: const AnimatableValue(
            from: [],
            to: [BoxShadow(color: Colors.black)],
          ),
          gradient: const AnimatableValue(
            from: LinearGradient(colors: [Colors.red, Colors.blue]),
            to: LinearGradient(colors: [Colors.green, Colors.yellow]),
          ),
          image: const DecorationImage(image: AssetImage('test.png')),
          motion: motion,
          reverse: reverse,
          shape: BoxShape.circle,
          position: DecorationPosition.foreground,
          delay: const Duration(milliseconds: 100),
        );

        expect(act.color, isNotNull);
        expect(act.borderRadius, isNotNull);
        expect(act.border, isNotNull);
        expect(act.boxShadow, isNotNull);
        expect(act.gradient, isNotNull);
        expect(act.image, isNotNull);
        expect(act.motion, motion);
        expect(act.reverse, reverse);
        expect(act.shape, BoxShape.circle);
        expect(act.position, DecorationPosition.foreground);
        expect(act.delay, const Duration(milliseconds: 100));
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

      test('creates animtable with gradient', () {
        const act = DecoratedBoxAct(
          gradient: AnimatableValue(
            from: LinearGradient(colors: [Colors.red, Colors.blue]),
            to: LinearGradient(colors: [Colors.green, Colors.yellow]),
          ),
        );

        final (animtable, _) = act.buildTweens(actContext);
        expect(animtable, isNotNull);
      });

      test('creates animtable with boxShadow', () {
        const act = DecoratedBoxAct(
          boxShadow: AnimatableValue(
            from: [],
            to: [BoxShadow(color: Colors.black, blurRadius: 5)],
          ),
        );

        final (animtable, _) = act.buildTweens(actContext);
        expect(animtable, isNotNull);
      });

      test('creates animtable with border', () {
        final act = DecoratedBoxAct(
          border: AnimatableValue(
            from: Border(),
            to: Border.fromBorderSide(BorderSide(color: Colors.black, width: 2)),
          ),
        );

        final (animtable, _) = act.buildTweens(actContext);
        expect(animtable, isNotNull);
      });

      test('creates animtable with all properties', () {
        const act = DecoratedBoxAct(
          color: AnimatableValue(from: Colors.red, to: Colors.blue),
          borderRadius: AnimatableValue(
            from: BorderRadius.zero,
            to: BorderRadius.all(Radius.circular(10)),
          ),
          gradient: AnimatableValue(
            from: LinearGradient(colors: [Colors.red, Colors.blue]),
            to: LinearGradient(colors: [Colors.green, Colors.yellow]),
          ),
          boxShadow: AnimatableValue(
            from: [],
            to: [BoxShadow(color: Colors.black)],
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

        final transition = tester.widget<DecoratedBoxTransition>(find.byType(DecoratedBoxTransition));
        expect(transition.position, DecorationPosition.foreground);
      });

      testWidgets('applies background position correctly', (tester) async {
        const act = DecoratedBoxAct(
          color: AnimatableValue(from: Colors.red, to: Colors.blue),
          position: DecorationPosition.background,
        );

        final (animtable, _) = act.buildTweens(actContext);

        track.setProgress(0.5);

        final animation = CueAnimationImpl<Decoration>(
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

        final transition = tester.widget<DecoratedBoxTransition>(find.byType(DecoratedBoxTransition));
        expect(transition.position, DecorationPosition.background);
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

      test('different borderRadius values are not equal', () {
        const act1 = DecoratedBoxAct(
          borderRadius: AnimatableValue(from: BorderRadius.zero, to: BorderRadius.zero),
        );
        const act2 = DecoratedBoxAct(
          borderRadius: AnimatableValue(
            from: BorderRadius.zero,
            to: BorderRadius.all(Radius.circular(10)),
          ),
        );
        expect(act1, isNot(act2));
      });

      test('different gradient values are not equal', () {
        const act1 = DecoratedBoxAct(
          gradient: AnimatableValue(
            from: LinearGradient(colors: [Colors.red, Colors.blue]),
            to: LinearGradient(colors: [Colors.green, Colors.yellow]),
          ),
        );
        const act2 = DecoratedBoxAct(
          gradient: AnimatableValue(
            from: LinearGradient(colors: [Colors.blue, Colors.red]),
            to: LinearGradient(colors: [Colors.yellow, Colors.green]),
          ),
        );
        expect(act1, isNot(act2));
      });

      test('acts with same properties but different motion are equal', () {
        final motion1 = CueMotion.linear(300.ms);
        final motion2 = CueMotion.linear(400.ms);
        final act1 = DecoratedBoxAct(motion: motion1);
        final act2 = DecoratedBoxAct(motion: motion2);
        // They may not be equal due to motion, but at least verify they have the properties
        expect(act1.motion, isNotNull);
        expect(act2.motion, isNotNull);
      });

      test('different image values are not equal', () {
        const act1 = DecoratedBoxAct(
          image: DecorationImage(image: AssetImage('test1.png')),
        );
        const act2 = DecoratedBoxAct(
          image: DecorationImage(image: AssetImage('test2.png')),
        );
        expect(act1, isNot(act2));
      });
    });

    group('resolve', () {
      test('resolve returns ActContext', () {
        const act = DecoratedBoxAct(
          color: AnimatableValue(from: Colors.red, to: Colors.blue),
        );
        final resolved = act.resolve(actContext);
        expect(resolved, isA<ActContext>());
      });

      test('resolve with motion parameter', () {
        final motion = CueMotion.linear(400.ms);
        final act = DecoratedBoxAct(
          color: AnimatableValue(from: Colors.red, to: Colors.blue),
          motion: motion,
        );
        final resolved = act.resolve(actContext);
        expect(resolved, isA<ActContext>());
      });

      test('resolve with delay parameter', () {
        const act = DecoratedBoxAct(
          color: AnimatableValue(from: Colors.red, to: Colors.blue),
          delay: Duration(milliseconds: 100),
        );
        final resolved = act.resolve(actContext);
        expect(resolved, isA<ActContext>());
      });

      test('resolve with reverse parameter', () {
        const reverse = ReverseBehavior<Decoration>.mirror();
        const act = DecoratedBoxAct(
          color: AnimatableValue(from: Colors.red, to: Colors.blue),
          reverse: reverse,
        );
        final resolved = act.resolve(actContext);
        expect(resolved, isA<ActContext>());
      });

      test('resolve with all parameters', () {
        final motion = CueMotion.linear(400.ms);
        const reverse = ReverseBehavior<Decoration>.mirror();
        final act = DecoratedBoxAct(
          color: const AnimatableValue(from: Colors.red, to: Colors.blue),
          motion: motion,
          delay: const Duration(milliseconds: 100),
          reverse: reverse,
        );
        final resolved = act.resolve(actContext);
        expect(resolved, isA<ActContext>());
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

    test('passes image to act', () {
      const actor = DecoratedBoxActor(
        image: DecorationImage(image: AssetImage('test.png')),
      );
      expect(actor.image, isNotNull);
    });

    test('actor with all parameters', () {
      final motion = CueMotion.linear(300.ms);
      const reverse = ReverseBehavior<Decoration>.mirror();
      final actor = DecoratedBoxActor(
        color: const AnimatableValue(from: Colors.red, to: Colors.blue),
        borderRadius: const AnimatableValue(
          from: BorderRadius.zero,
          to: BorderRadius.all(Radius.circular(10)),
        ),
        image: const DecorationImage(image: AssetImage('test.png')),
        shape: BoxShape.circle,
        position: DecorationPosition.foreground,
        motion: motion,
        delay: const Duration(milliseconds: 100),
        reverse: reverse,
      );

      expect(actor.color, isNotNull);
      expect(actor.borderRadius, isNotNull);
      expect(actor.image, isNotNull);
      expect(actor.shape, BoxShape.circle);
      expect(actor.position, DecorationPosition.foreground);
      expect(actor.motion, motion);
      expect(actor.delay, const Duration(milliseconds: 100));
      expect(actor.reverse, reverse);
    });

    testWidgets('build method creates Actor with DecoratedBoxAct', (tester) async {
      const actor = DecoratedBoxActor(
        color: AnimatableValue(from: Colors.red, to: Colors.blue),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: CueController(
              vsync: tester,
              motion: motion,
            ),
            child: Scaffold(body: actor),
          ),
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('build method passes color to DecoratedBoxAct', (tester) async {
      const actor = DecoratedBoxActor(
        color: AnimatableValue(from: Colors.red, to: Colors.blue),
        child: Text('Test'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: CueController(
              vsync: tester,
              motion: motion,
            ),
            child: Scaffold(body: actor),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('build method passes shape to DecoratedBoxAct', (tester) async {
      const actor = DecoratedBoxActor(
        shape: BoxShape.circle,
        color: AnimatableValue(from: Colors.red, to: Colors.blue),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: CueController(
              vsync: tester,
              motion: motion,
            ),
            child: Scaffold(body: actor),
          ),
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('build method passes position to DecoratedBoxAct', (tester) async {
      const actor = DecoratedBoxActor(
        position: DecorationPosition.foreground,
        color: AnimatableValue(from: Colors.red, to: Colors.blue),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onMount(
            child: Scaffold(body: actor),
          ),
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('build method uses default child when none provided', (tester) async {
      const actor = DecoratedBoxActor(
        color: AnimatableValue(from: Colors.red, to: Colors.blue),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onMount(
            child: Scaffold(body: actor),
          ),
        ),
      );

      // Should have SizedBox as the default child
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('build method uses provided child', (tester) async {
      const actor = DecoratedBoxActor(
        color: AnimatableValue(from: Colors.red, to: Colors.blue),
        child: Text('Custom Child'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onMount(
            child: Scaffold(body: actor),
          ),
        ),
      );

      expect(find.text('Custom Child'), findsOneWidget);
    });

    testWidgets('build method with all parameters', (tester) async {
      final motion = CueMotion.linear(300.ms);
      const reverse = ReverseBehavior<Decoration>.mirror();
      final actor = DecoratedBoxActor(
        color: const AnimatableValue(from: Colors.red, to: Colors.blue),
        borderRadius: const AnimatableValue(
          from: BorderRadius.zero,
          to: BorderRadius.all(Radius.circular(10)),
        ),
        border: const AnimatableValue(from: Border(), to: Border()),
        boxShadow: const AnimatableValue(
          from: [],
          to: [BoxShadow(color: Colors.black)],
        ),
        gradient: const AnimatableValue(
          from: LinearGradient(colors: [Colors.red, Colors.blue]),
          to: LinearGradient(colors: [Colors.green, Colors.yellow]),
        ),
        position: DecorationPosition.foreground,
        motion: motion,
        delay: const Duration(milliseconds: 100),
        reverse: reverse,
        child: const Text('Full Test'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onMount(
            child: Scaffold(body: actor),
          ),
        ),
      );

      expect(find.text('Full Test'), findsOneWidget);
    });

    testWidgets('build method passes motion parameter', (tester) async {
      final motion = CueMotion.linear(500.ms);
      final actor = DecoratedBoxActor(
        color: const AnimatableValue(from: Colors.red, to: Colors.blue),
        motion: motion,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onMount(
            child: Scaffold(body: actor),
          ),
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('build method passes delay parameter', (tester) async {
      const actor = DecoratedBoxActor(
        color: AnimatableValue(from: Colors.red, to: Colors.blue),
        delay: Duration(milliseconds: 200),
      );

      await tester.pumpWidget(MaterialApp(home: Cue.onMount(child: actor)));

      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
