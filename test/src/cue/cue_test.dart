import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';
import 'package:cue/src/cue/cue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Cue factory', () {
    testWidgets('Cue() creates a ControlledCue', (tester) async {
      final controller = CueController(
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: const Text('hello'),
          ),
        ),
      );

      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('Cue() exposes controller via CueScope', (tester) async {
      final controller = CueController(
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );
      late CueScope scope;
      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Builder(
              builder: (context) {
                scope = CueScope.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(scope.controller, same(controller));
      expect(scope.reanimateFromCurrent, isFalse);
    });
  });

  group('CueState', () {
    testWidgets('build wraps child with Actor when acts provided', (tester) async {
      final controller = CueController(
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            acts: const [OpacityAct(from: 0.0, to: 1.0)],
            child: const Text('acted'),
          ),
        ),
      );

      expect(find.text('acted'), findsOneWidget);
      expect(find.byType(Actor), findsOneWidget);
    });

    testWidgets('build without acts does not add Actor', (tester) async {
      final controller = CueController(
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: const Text('plain'),
          ),
        ),
      );

      expect(find.text('plain'), findsOneWidget);
      expect(find.byType(Actor), findsNothing);
    });

    testWidgets('debugName is available on state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onMount(child: const SizedBox()),
        ),
      );

      final state = tester.state<OnMountCueState>(find.byType(OnMountCue));
      expect(state.debugName, 'OnMountCue');
    });
  });
}
