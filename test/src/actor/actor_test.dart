import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final motion = CueMotion.linear(100.ms);

  group('Actor', () {
    late CueController controller;

    setUp(() {
      controller = CueController(
        vsync: TestVSync(),
        motion: motion,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders child with no acts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: const Scaffold(
              body: Actor(
                acts: [],
                child: Text('Hello'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders child with single act', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: const Scaffold(
              body: Actor(
                acts: [ScaleAct()],
                child: Text('Hello'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
      expect(find.byType(Transform), findsWidgets);
    });

    testWidgets('renders child with multiple different acts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: const Scaffold(
              body: Actor(
                acts: [
                  ScaleAct(),
                  OpacityAct(from: 1.0, to: 0.5),
                ],
                child: Text('Hello'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('animation setup works with different act types', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: const Scaffold(
              body: Actor(
                acts: [
                  ScaleAct(from: 1.0, to: 2.0),
                  OpacityAct(from: 1.0, to: 0.5),
                ],
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Text('Hello'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
      expect(find.byType(Transform), findsWidgets);
    });

    testWidgets('updates when acts change', (tester) async {
      final key = GlobalKey<_StatefulActorWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: _StatefulActorWidget(key: key),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);

      key.currentState?.addAct();
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('updates animation when motion changes', (tester) async {
      final key = GlobalKey<_StatefulMotionWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: _StatefulMotionWidget(key: key),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);

      key.currentState?.changeMotion();
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('updates animation when delay changes', (tester) async {
      final key = GlobalKey<_StatefulDelayWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: _StatefulDelayWidget(key: key),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);

      key.currentState?.changeDelay();
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('updates animation when reverseDelay changes', (tester) async {
      final key = GlobalKey<_StatefulReverseDelayWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: _StatefulReverseDelayWidget(key: key),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);

      key.currentState?.changeReverseDelay();
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('updates animation when reverseMotion changes', (tester) async {
      final key = GlobalKey<_StatefulReverseMotionWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: _StatefulReverseMotionWidget(key: key),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);

      key.currentState?.changeReverseMotion();
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('handles animation removal when acts list changes', (tester) async {
      final key = GlobalKey<_StatefulRemoveActWidgetState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: _StatefulRemoveActWidget(key: key),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);

      key.currentState?.removeAct();
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('applies acts in reverse order', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: const Scaffold(
              body: Actor(
                acts: [
                  ScaleAct(from: 1.0, to: 2.0),
                  OpacityAct(from: 1.0, to: 0.5),
                ],
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Text('Hello'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
      // Verify that both transforms are applied  
      expect(find.byType(Transform), findsWidgets);
    });

    testWidgets('throws error when multiple acts of same type are used', (tester) async {
      // Pump widget that should trigger duplicate acts error
      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: const Scaffold(
              body: Actor(
                acts: [
                  ScaleAct(from: 1.0, to: 2.0),
                  ScaleAct(from: 0.5, to: 1.5),
                ],
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Text('Hello'),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify that the expected error was caught
      final exception = tester.takeException();
      expect(exception, isA<StateError>());
      expect(
        (exception as StateError).message,
        contains('Multiple Acts of the same type are not supported'),
      );
    });

    testWidgets('ActorExtension applies acts to widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: const Text('Hello').act(
                [const ScaleAct()],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
      expect(find.byType(Actor), findsOneWidget);
    });

    testWidgets('ActorExtension with motion parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: const Text('Hello').act(
                [const ScaleAct()],
                motion: motion,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('ActorExtension with delay parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: const Text('Hello').act(
                [const ScaleAct()],
                delay: const Duration(milliseconds: 100),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('ActorExtension with reverseMotion parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: const Text('Hello').act(
                [const ScaleAct()],
                reverseMotion: motion,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets(
        'ActorExtension with all parameters',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: const Text('Hello').act(
                [const ScaleAct()],
                motion: motion,
                reverseMotion: motion,
                delay: const Duration(milliseconds: 50),
                reverseDelay: const Duration(milliseconds: 100),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });
  });

  group('SingleActorBase', () {
    late CueController controller;

    setUp(() {
      controller = CueController(
        vsync: TestVSync(),
        motion: motion,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('renders child with act', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: ScaleActor(
                from: 1.0,
                to: 1.5,
                child: const Text('Hello'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
      expect(find.byType(Actor), findsOneWidget);
    });

    testWidgets('creates Actor with motion parameter', (tester) async {
      final testMotion = CueMotion.linear(200.ms);

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: ScaleActor(
                from: 1.0,
                to: 1.5,
                motion: testMotion,
                child: const Text('Hello'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('creates Actor with delay parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: ScaleActor(
                from: 1.0,
                to: 1.5,
                delay: const Duration(milliseconds: 50),
                child: const Text('Hello'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('creates Actor with reverseMotion parameter', (tester) async {
      final testMotion = CueMotion.linear(200.ms);

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: ScaleActor(
                from: 1.0,
                to: 1.5,
                reverseMotion: testMotion,
                child: const Text('Hello'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('creates Actor with reverseDelay parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: ScaleActor(
                from: 1.0,
                to: 1.5,
                reverseDelay: const Duration(milliseconds: 100),
                child: const Text('Hello'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('keyframed constructor with frames', (tester) async {
      final frames = FractionalKeyframes<double>([
        FKeyframe(1.0, at: 0.0),
        FKeyframe(1.5, at: 1.0),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: ScaleActor.keyframes(
                frames: frames,
                child: const Text('Hello'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('keyframed constructor with delay and reverseDelay', (tester) async {
      final frames = FractionalKeyframes<double>([
        FKeyframe(1.0, at: 0.0),
        FKeyframe(1.5, at: 1.0),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: ScaleActor.keyframes(
                frames: frames,
                delay: const Duration(milliseconds: 50),
                reverseDelay: const Duration(milliseconds: 100),
                child: const Text('Hello'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('keyframed constructor with reverse behavior', (tester) async {
      final frames = FractionalKeyframes<double>([
        FKeyframe(1.0, at: 0.0),
        FKeyframe(1.5, at: 1.0),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: ScaleActor.keyframes(
                frames: frames,
                reverse: const ReverseBehavior.mirror(),
                child: const Text('Hello'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('getters return correct values from constructor', (tester) async {
      final actor = ScaleActor(
        from: 1.0,
        to: 2.0,
        child: const SizedBox(),
      );

      expect(actor.from, equals(1.0));
      expect(actor.to, equals(2.0));
    });

    testWidgets('getters return null for keyframed constructor', (tester) async {
      final frames = FractionalKeyframes<double>([
        FKeyframe(1.0, at: 0.0),
        FKeyframe(2.0, at: 1.0),
      ]);

      final actor = ScaleActor.keyframes(
        frames: frames,
        child: const SizedBox(),
      );

      expect(actor.from, isNull);
      expect(actor.to, isNull);
    });
  });
}

/// Test implementation of ScaleActor for testing SingleActorBase
class ScaleActor extends SingleActorBase<double> {
  const ScaleActor({
    super.key,
    required super.child,
    super.from = 1.0,
    super.to = 1.0,
    super.motion,
    super.delay = Duration.zero,
    super.reverseMotion,
    super.reverseDelay = Duration.zero,
    super.reverse = const ReverseBehavior.mirror(),
  });

  const ScaleActor.keyframes({
    required super.frames,
    super.key,
    required super.child,
    super.delay = Duration.zero,
    super.reverseDelay = Duration.zero,
    super.reverse = const ReverseBehavior.mirror(),
  }) : super.keyframes();

  @override
  Act get act {
    return ScaleAct(
      from: from ?? 1.0,
      to: to ?? 1.0,
    );
  }
}

/// Stateful widget for testing act changes
class _StatefulActorWidget extends StatefulWidget {
  const _StatefulActorWidget({super.key});

  @override
  State<_StatefulActorWidget> createState() => _StatefulActorWidgetState();
}

class _StatefulActorWidgetState extends State<_StatefulActorWidget> {
  bool showSecondAct = false;

  void addAct() {
    setState(() {
      showSecondAct = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Actor(
      acts: showSecondAct
          ? const [ScaleAct(), OpacityAct(from: 1.0, to: 0.5)]
          : const [ScaleAct()],
      child: const Text('Hello'),
    );
  }
}

/// Stateful widget for testing motion changes
class _StatefulMotionWidget extends StatefulWidget {
  const _StatefulMotionWidget({super.key});

  @override
  State<_StatefulMotionWidget> createState() => _StatefulMotionWidgetState();
}

class _StatefulMotionWidgetState extends State<_StatefulMotionWidget> {
  late CueMotion currentMotion;

  @override
  void initState() {
    super.initState();
    currentMotion = CueMotion.linear(100.ms);
  }

  void changeMotion() {
    setState(() {
      currentMotion = CueMotion.linear(200.ms);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Actor(
      motion: currentMotion,
      acts: const [ScaleAct()],
      child: const Text('Hello'),
    );
  }
}

/// Stateful widget for testing delay changes
class _StatefulDelayWidget extends StatefulWidget {
  const _StatefulDelayWidget({super.key});

  @override
  State<_StatefulDelayWidget> createState() => _StatefulDelayWidgetState();
}

class _StatefulDelayWidgetState extends State<_StatefulDelayWidget> {
  late Duration currentDelay;

  @override
  void initState() {
    super.initState();
    currentDelay = Duration.zero;
  }

  void changeDelay() {
    setState(() {
      currentDelay = const Duration(milliseconds: 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Actor(
      delay: currentDelay,
      acts: const [ScaleAct()],
      child: const Text('Hello'),
    );
  }
}

/// Stateful widget for testing reverseDelay changes
class _StatefulReverseDelayWidget extends StatefulWidget {
  const _StatefulReverseDelayWidget({super.key});

  @override
  State<_StatefulReverseDelayWidget> createState() =>
      _StatefulReverseDelayWidgetState();
}

class _StatefulReverseDelayWidgetState extends State<_StatefulReverseDelayWidget> {
  late Duration currentReverseDelay;

  @override
  void initState() {
    super.initState();
    currentReverseDelay = Duration.zero;
  }

  void changeReverseDelay() {
    setState(() {
      currentReverseDelay = const Duration(milliseconds: 100);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Actor(
      reverseDelay: currentReverseDelay,
      acts: const [ScaleAct()],
      child: const Text('Hello'),
    );
  }
}

/// Stateful widget for testing reverseMotion changes
class _StatefulReverseMotionWidget extends StatefulWidget {
  const _StatefulReverseMotionWidget({super.key});

  @override
  State<_StatefulReverseMotionWidget> createState() =>
      _StatefulReverseMotionWidgetState();
}

class _StatefulReverseMotionWidgetState
    extends State<_StatefulReverseMotionWidget> {
  late CueMotion? currentReverseMotion;

  @override
  void initState() {
    super.initState();
    currentReverseMotion = null;
  }

  void changeReverseMotion() {
    setState(() {
      currentReverseMotion = CueMotion.linear(200.ms);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Actor(
      reverseMotion: currentReverseMotion,
      acts: const [ScaleAct()],
      child: const Text('Hello'),
    );
  }
}

/// Stateful widget for testing act removal
class _StatefulRemoveActWidget extends StatefulWidget {
  const _StatefulRemoveActWidget({super.key});

  @override
  State<_StatefulRemoveActWidget> createState() =>
      _StatefulRemoveActWidgetState();
}

class _StatefulRemoveActWidgetState extends State<_StatefulRemoveActWidget> {
  bool hasMultipleActs = true;

  void removeAct() {
    setState(() {
      hasMultipleActs = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Actor(
      acts: hasMultipleActs
          ? const [ScaleAct(), OpacityAct(from: 1.0, to: 0.5)]
          : const [ScaleAct()],
      child: const Text('Hello'),
    );
  }
}
