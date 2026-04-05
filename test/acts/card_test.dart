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
  group('CardProps', () {
    test('default values', () {
      const props = CardProps();
      expect(props.elevation, equals(0));
      expect(props.color, isNull);
      expect(props.shadowColor, equals(const Color(0xFF000000)));
      expect(props.surfaceTintColor, isNull);
      expect(props.borderRadius, isNull);
      expect(props.shape, isNull);
      expect(props.margin, isNull);
    });

    test('constructor with all values', () {
      const props = CardProps(
        elevation: 8.0,
        color: Colors.white,
        shadowColor: Colors.black,
        surfaceTintColor: Colors.blue,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        margin: EdgeInsets.all(16),
      );
      expect(props.elevation, equals(8.0));
      expect(props.color, equals(Colors.white));
      expect(props.shadowColor, equals(Colors.black));
      expect(props.surfaceTintColor, equals(Colors.blue));
      expect(props.borderRadius, equals(const BorderRadius.all(Radius.circular(12))));
      expect(props.margin, equals(const EdgeInsets.all(16)));
    });

    test('equality', () {
      const props1 = CardProps(elevation: 4.0, color: Colors.white);
      const props2 = CardProps(elevation: 4.0, color: Colors.white);
      const props3 = CardProps(elevation: 8.0, color: Colors.white);

      expect(props1, equals(props2));
      expect(props1, isNot(equals(props3)));
    });

    test('hashCode consistency', () {
      const props1 = CardProps(elevation: 4.0);
      const props2 = CardProps(elevation: 4.0);

      expect(props1.hashCode, equals(props2.hashCode));
    });

    test('lerp interpolates between two CardProps', () {
      const a = CardProps(elevation: 0.0, color: Colors.white);
      const b = CardProps(elevation: 10.0, color: Colors.black);

      final result0 = CardProps.lerp(a, b, 0.0);
      expect(result0.elevation, equals(0.0));

      final result1 = CardProps.lerp(a, b, 1.0);
      expect(result1.elevation, equals(10.0));

      final result05 = CardProps.lerp(a, b, 0.5);
      expect(result05.elevation, equals(5.0));
    });

    test('lerp with null values', () {
      const a = CardProps();
      const b = CardProps(elevation: 10.0);

      final result = CardProps.lerp(a, b, 0.5);
      expect(result.elevation, equals(5.0));
    });

    test('assert fails when both shape and borderRadius are provided', () {
      expect(
        () => CardProps(
          shape: const RoundedRectangleBorder(),
          borderRadius: BorderRadius.circular(12),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('CardAct', () {
    test('key is "Card"', () {
      const act = CardAct();
      expect(act.key.key, equals('Card'));
    });

    test('default values', () {
      const act = CardAct();
      expect(act.clipBehavior, equals(Clip.none));
      expect(act.borderOnForeground, isTrue);
      expect(act.semanticContainer, isTrue);
      expect(act.shadowColor, equals(const AnimatableValue.fixed(Color(0xFF000000))));
    });

    test('constructor with elevation', () {
      const act = CardAct(
        elevation: AnimatableValue(from: 0.0, to: 8.0),
      );
      expect(act.elevation?.from, equals(0.0));
      expect(act.elevation?.to, equals(8.0));
    });

    test('constructor with color', () {
      const act = CardAct(
        color: AnimatableValue(from: Colors.white, to: Colors.grey),
      );
      expect(act.color?.from, equals(Colors.white));
      expect(act.color?.to, equals(Colors.grey));
    });

    test('constructor with borderRadius', () {
      const act = CardAct(
        borderRadius: AnimatableValue(
          from: BorderRadius.zero,
          to: BorderRadius.all(Radius.circular(12)),
        ),
      );
      expect(act.borderRadius?.from, equals(BorderRadius.zero));
    });

    test('constructor with margin', () {
      const act = CardAct(
        margin: AnimatableValue(from: EdgeInsets.zero, to: EdgeInsets.all(16)),
      );
      expect(act.margin?.from, equals(EdgeInsets.zero));
      expect(act.margin?.to, equals(const EdgeInsets.all(16)));
    });

    test('constructor with clipBehavior', () {
      const act = CardAct(clipBehavior: Clip.hardEdge);
      expect(act.clipBehavior, equals(Clip.hardEdge));
    });

    test('constructor with motion', () {
      final motion = CueMotion.linear(500.ms);
      final act = CardAct(motion: motion);
      expect(act.motion, equals(motion));
    });

    test('constructor with delay', () {
      const act = CardAct(delay: Duration(milliseconds: 200));
      expect(act.delay, equals(const Duration(milliseconds: 200)));
    });

    test('constructor with surfaceTintColor', () {
      const act = CardAct(
        surfaceTintColor: AnimatableValue(from: Colors.blue, to: Colors.green),
      );
      expect(act.surfaceTintColor?.from, equals(Colors.blue));
      expect(act.surfaceTintColor?.to, equals(Colors.green));
    });

    test('constructor with shadowColor', () {
      const act = CardAct(
        shadowColor: AnimatableValue.fixed(Colors.red),
      );
      expect(act.shadowColor.from, equals(Colors.red));
    });

    test('constructor with shape', () {
      const act = CardAct(
        shape: AnimatableValue.fixed(RoundedRectangleBorder()),
      );
      expect(act.shape, isNotNull);
    });

    test('constructor with borderOnForeground', () {
      const act = CardAct(borderOnForeground: false);
      expect(act.borderOnForeground, isFalse);
    });

    test('constructor with semanticContainer', () {
      const act = CardAct(semanticContainer: false);
      expect(act.semanticContainer, isFalse);
    });

    test('constructor with reverse', () {
      const reverse = ReverseBehavior<CardProps>.mirror();
      const act = CardAct(reverse: reverse);
      expect(act.reverse, reverse);
    });

    test('constructor with all parameters', () {
      final motion = CueMotion.linear(400.ms);
      const elevation = AnimatableValue(from: 0.0, to: 8.0);
      const color = AnimatableValue(from: Colors.white, to: Colors.grey);
      const borderRadius = AnimatableValue(
        from: BorderRadius.zero,
        to: BorderRadius.all(Radius.circular(12)),
      );
      const delay = Duration(milliseconds: 100);
      final act = CardAct(
        motion: motion,
        elevation: elevation,
        color: color,
        borderRadius: borderRadius,
        delay: delay,
        clipBehavior: Clip.antiAlias,
        borderOnForeground: false,
        semanticContainer: false,
      );
      
      expect(act.motion, equals(motion));
      expect(act.elevation, equals(elevation));
      expect(act.color, equals(color));
      expect(act.borderRadius, equals(borderRadius));
      expect(act.delay, equals(delay));
      expect(act.clipBehavior, equals(Clip.antiAlias));
      expect(act.borderOnForeground, isFalse);
      expect(act.semanticContainer, isFalse);
    });

    test('keyframed constructor', () {
      final frames = FractionalKeyframes<CardProps>([
        FKeyframe(const CardProps(elevation: 0), at: 0.0),
        FKeyframe(const CardProps(elevation: 8), at: 1.0),
      ]);
      final act = CardAct.keyframed(frames: frames);
      expect(act.frames, equals(frames));
    });

    test('keyframed constructor with delay', () {
      final frames = FractionalKeyframes<CardProps>([
        FKeyframe(const CardProps(elevation: 0), at: 0.0),
        FKeyframe(const CardProps(elevation: 8), at: 1.0),
      ]);
      const delay = Duration(milliseconds: 150);
      final act = CardAct.keyframed(frames: frames, delay: delay);
      expect(act.frames, equals(frames));
      expect(act.delay, equals(delay));
    });

    test('keyframed constructor with reverse', () {
      final frames = FractionalKeyframes<CardProps>([
        FKeyframe(const CardProps(elevation: 0), at: 0.0),
        FKeyframe(const CardProps(elevation: 8), at: 1.0),
      ]);
      const reverse = KFReverseBehavior<CardProps>.mirror();
      final act = CardAct.keyframed(frames: frames, reverse: reverse);
      expect(act.frames, equals(frames));
      expect(act.reverse, reverse);
    });

    test('assert fails when both shape and borderRadius are provided', () {
      expect(
        () => CardAct(
          shape: const AnimatableValue.fixed(RoundedRectangleBorder()),
          borderRadius: const AnimatableValue.fixed(BorderRadius.zero),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('buildTweens returns CueAnimtable', () {
      const act = CardAct(
        elevation: AnimatableValue(from: 0.0, to: 8.0),
      );
      
      final (animtable, reverseAnimtable) = act.buildTweens(actContext);

      expect(animtable, isA<CueAnimtable<CardProps>>());
      expect(reverseAnimtable, isNull);
    });

    test('resolve returns ActContext', () {
      const act = CardAct(
        elevation: AnimatableValue(from: 0.0, to: 8.0),
      );
      
      final resolved = act.resolve(actContext);

      expect(resolved, isA<ActContext>());
    });

    test('resolve with keyframed', () {
      final frames = FractionalKeyframes<CardProps>([
        FKeyframe(const CardProps(elevation: 0), at: 0.0),
        FKeyframe(const CardProps(elevation: 8), at: 1.0),
      ]);
      final act = CardAct.keyframed(frames: frames);
      
      final resolved = act.resolve(actContext);

      expect(resolved, isA<ActContext>());
    });

    test('equality', () {
      const act1 = CardAct(
        elevation: AnimatableValue(from: 0.0, to: 8.0),
        delay: Duration(milliseconds: 100),
      );
      const act2 = CardAct(
        elevation: AnimatableValue(from: 0.0, to: 8.0),
        delay: Duration(milliseconds: 100),
      );
      const act3 = CardAct(
        elevation: AnimatableValue(from: 0.0, to: 4.0),
      );

      expect(act1, equals(act2));
      expect(act1, isNot(equals(act3)));
    });

    test('equality with different properties', () {
      const act1 = CardAct(
        clipBehavior: Clip.hardEdge,
        borderOnForeground: false,
      );
      const act2 = CardAct(
        clipBehavior: Clip.hardEdge,
        borderOnForeground: false,
      );
      const act3 = CardAct(
        clipBehavior: Clip.antiAlias,
      );

      expect(act1, equals(act2));
      expect(act1, isNot(equals(act3)));
    });

    test('hashCode consistency', () {
      const act1 = CardAct(elevation: AnimatableValue(from: 0.0, to: 8.0));
      const act2 = CardAct(elevation: AnimatableValue(from: 0.0, to: 8.0));

      expect(act1.hashCode, equals(act2.hashCode));
    });

    testWidgets('apply wraps child in PhysicalShape', (tester) async {
      const act = CardAct(
        elevation: AnimatableValue(from: 0.0, to: 8.0),
      );
      
      final (animtable, _) = act.buildTweens(actContext);

      
      track.setProgress(0.5);

      final animation = CueAnimationImpl<CardProps>(
        parent: track,
        token:  ReleaseToken(track.config, timeline),
        animtable: animtable,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => act.apply(context, animation, const SizedBox()),
            ),
          ),
        ),
      );

      expect(find.byType(PhysicalShape), findsOneWidget);
    });

    testWidgets('apply uses animation value for elevation', (tester) async {
      const act = CardAct(
        elevation: AnimatableValue(from: 0.0, to: 8.0),
      );
      
      final (animtable, _) = act.buildTweens(actContext);

      
      track.setProgress(0.5);

      final animation = CueAnimationImpl<CardProps>(
        parent: track,
        token:  ReleaseToken(track.config, timeline),
        animtable: animtable,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => act.apply(context, animation, const SizedBox()),
            ),
          ),
        ),
      );

      final physicalShape = tester.widget<PhysicalShape>(find.byType(PhysicalShape));
      expect(physicalShape.elevation, equals(4.0));
    });

    testWidgets('apply with borderRadius', (tester) async {
      const act = CardAct(
        borderRadius: AnimatableValue(
          from: BorderRadius.zero,
          to: BorderRadius.all(Radius.circular(12)),
        ),
      );
      
      final (animtable, _) = act.buildTweens(actContext);

      
      track.setProgress(0.0);

      final animation = CueAnimationImpl<CardProps>(
        parent: track,
        token:  ReleaseToken(track.config, timeline),
        animtable: animtable,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => act.apply(context, animation, const SizedBox()),
            ),
          ),
        ),
      );

      expect(find.byType(PhysicalShape), findsOneWidget);
    });

    testWidgets('apply with margin', (tester) async {
      const act = CardAct(
        margin: AnimatableValue(from: EdgeInsets.zero, to: EdgeInsets.all(16)),
      );
      
      final (animtable, _) = act.buildTweens(actContext);

      
      track.setProgress(0.0);

      final animation = CueAnimationImpl<CardProps>(
        parent: track,
        token:  ReleaseToken(track.config, timeline),
        animtable: animtable,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => act.apply(context, animation, const SizedBox()),
            ),
          ),
        ),
      );

      expect(find.byType(Padding), findsOneWidget);
    });

    testWidgets('apply with hasBorderStroke renders CustomPaint', (tester) async {
      const act = CardAct(
        shape: AnimatableValue.fixed(BeveledRectangleBorder()),
      );
      
      final (animtable, _) = act.buildTweens(actContext);

      track.setProgress(0.0);

      final animation = CueAnimationImpl<CardProps>(
        parent: track,
        token:  ReleaseToken(track.config, timeline),
        animtable: animtable,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => act.apply(context, animation, const SizedBox()),
            ),
          ),
        ),
      );

      // BeveledRectangleBorder has preferPaintInterior = false, so hasBorderStroke = true
      // There should be CustomPaint for the PhysicalShape
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('apply with hasBorderStroke and borderOnForeground true uses foregroundPainter', (tester) async {
      const act = CardAct(
        shape: AnimatableValue.fixed(BeveledRectangleBorder()),
        borderOnForeground: true,
      );
      
      final (animtable, _) = act.buildTweens(actContext);

      track.setProgress(0.0);

      final animation = CueAnimationImpl<CardProps>(
        parent: track,
        token:  ReleaseToken(track.config, timeline),
        animtable: animtable,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => act.apply(context, animation, const SizedBox()),
            ),
          ),
        ),
      );

      // Should have at least one CustomPaint (the one we created for the border)
      final customPaints = find.byType(CustomPaint);
      expect(customPaints, findsWidgets);
      
      // The CustomPaint should have the painter as foregroundPainter
      final widgets = tester.widgetList<CustomPaint>(customPaints);
      final hasCustomPaintWithForeground = widgets.any(
        (widget) => widget.foregroundPainter != null && widget.painter == null,
      );
      expect(hasCustomPaintWithForeground, isTrue);
    });

    testWidgets('apply with hasBorderStroke and borderOnForeground false uses painter', (tester) async {
      const act = CardAct(
        shape: AnimatableValue.fixed(BeveledRectangleBorder()),
        borderOnForeground: false,
      );
      
      final (animtable, _) = act.buildTweens(actContext);

      track.setProgress(0.0);

      final animation = CueAnimationImpl<CardProps>(
        parent: track,
        token:  ReleaseToken(track.config, timeline),
        animtable: animtable,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => act.apply(context, animation, const SizedBox()),
            ),
          ),
        ),
      );

      // Should have at least one CustomPaint (the one we created for the border)
      final customPaints = find.byType(CustomPaint);
      expect(customPaints, findsWidgets);
      
      // The CustomPaint should have the painter as painter (not foregroundPainter)
      final widgets = tester.widgetList<CustomPaint>(customPaints);
      final hasCustomPaintWithPainter = widgets.any(
        (widget) => widget.painter != null && widget.foregroundPainter == null,
      );
      expect(hasCustomPaintWithPainter, isTrue);
    });

    testWidgets('apply with constant borderRadius uses cached shape', (tester) async {
      const act = CardAct(
        borderRadius: AnimatableValue.fixed(BorderRadius.all(Radius.circular(12))),
      );
      
      final (animtable, _) = act.buildTweens(actContext);

      track.setProgress(0.0);

      final animation = CueAnimationImpl<CardProps>(
        parent: track,
        token:  ReleaseToken(track.config, timeline),
        animtable: animtable,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => act.apply(context, animation, const SizedBox()),
            ),
          ),
        ),
      );

      // Constant shape should be cached and still render properly
      expect(find.byType(PhysicalShape), findsOneWidget);
    });

    testWidgets('apply with animated shape updates shape each frame', (tester) async {
      const act = CardAct(
        shape: AnimatableValue(
          from: RoundedRectangleBorder(),
          to: BeveledRectangleBorder(),
        ),
      );
      
      final (animtable, _) = act.buildTweens(actContext);

      track.setProgress(0.5);

      final animation = CueAnimationImpl<CardProps>(
        parent: track,
        token:  ReleaseToken(track.config, timeline),
        animtable: animtable,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => act.apply(context, animation, const SizedBox()),
            ),
          ),
        ),
      );

      // Animated shape should still render PhysicalShape
      expect(find.byType(PhysicalShape), findsOneWidget);
    });
  });

  group('CardActor', () {
    test('wraps child in Actor with CardAct', () {
      const actor = CardActor(
        elevation: AnimatableValue(from: 0.0, to: 8.0),
        child: SizedBox(),
      );

      expect(actor.elevation?.from, equals(0.0));
      expect(actor.elevation?.to, equals(8.0));
    });

    test('passes all properties to CardAct', () {
      const actor = CardActor(
        color: AnimatableValue(from: Colors.white, to: Colors.grey),
        shadowColor: AnimatableValue.fixed(Colors.black),
        elevation: AnimatableValue(from: 0.0, to: 8.0),
        clipBehavior: Clip.hardEdge,
        borderOnForeground: false,
      );

      expect(actor.color?.from, equals(Colors.white));
      expect(actor.shadowColor.from, equals(Colors.black));
      expect(actor.elevation?.from, equals(0.0));
      expect(actor.clipBehavior, equals(Clip.hardEdge));
      expect(actor.borderOnForeground, isFalse);
    });

    test('assert fails when both shape and borderRadius are provided', () {
      expect(
        () => CardActor(
          shape: const AnimatableValue.fixed(RoundedRectangleBorder()),
          borderRadius: const AnimatableValue.fixed(BorderRadius.zero),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('build method creates Actor with CardAct', (tester) async {
      const actor = CardActor(
        elevation: AnimatableValue(from: 0.0, to: 8.0),
        color: AnimatableValue(from: Colors.white, to: Colors.grey),
        child: Text('Card Content'),
      );

      final motion = CueMotion.linear(300.ms);

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

      // Verify child widget is rendered
      expect(find.text('Card Content'), findsOneWidget);
      // Verify PhysicalShape from CardAct is applied
      expect(find.byType(PhysicalShape), findsOneWidget);
    });
  });
}
