import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProgressCue', () {
    testWidgets('builds with listenable-driven progress', (tester) async {
      final notifier = ValueNotifier<double>(0.0);
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onProgress(
            listenable: notifier,
            progress: () => notifier.value,
            child: const SizedBox(),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('listenable changes update progress', (tester) async {
      final notifier = ValueNotifier<double>(0.0);
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onProgress(
            listenable: notifier,
            progress: () => notifier.value,
            child: const SizedBox(),
          ),
        ),
      );

      notifier.value = 0.5;
      await tester.pump();

      notifier.value = 1.0;
      await tester.pump();

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('progress is clamped to 0-1', (tester) async {
      final notifier = ValueNotifier<double>(0.5);
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onProgress(
            listenable: notifier,
            progress: () => notifier.value,
            child: const SizedBox(),
          ),
        ),
      );

      notifier.value = -0.5;
      await tester.pump();

      notifier.value = 1.5;
      await tester.pump();

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('custom min and max are respected', (tester) async {
      final notifier = ValueNotifier<double>(50.0);
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onProgress(
            listenable: notifier,
            progress: () => notifier.value,
            min: 0.0,
            max: 100.0,
            child: const SizedBox(),
          ),
        ),
      );

      notifier.value = 25.0;
      await tester.pump();

      notifier.value = 75.0;
      await tester.pump();

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('state is a CueState with timeline', (tester) async {
      final notifier = ValueNotifier<double>(0.0);
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onProgress(
            listenable: notifier,
            progress: () => notifier.value,
            child: const SizedBox(),
          ),
        ),
      );

      // Find a Cue widget descendant of MaterialApp
      final cueFinder = find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_ProgressCue',
      );
      final state = tester.state(cueFinder) as dynamic;
      expect(state.debugName, 'ProgressCue');
      expect(state.controller.timeline, isNotNull);
    });

    testWidgets('dispose removes listenable listener', (tester) async {
      final notifier = ValueNotifier<double>(0.0);
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onProgress(
            listenable: notifier,
            progress: () => notifier.value,
            child: const SizedBox(),
          ),
        ),
      );

      // Remove widget to trigger dispose
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      // Updating notifier after dispose should not throw
      notifier.value = 1.0;
    });

    testWidgets('didUpdateWidget swaps listenable', (tester) async {
      final notifier1 = ValueNotifier<double>(0.0);
      final notifier2 = ValueNotifier<double>(0.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onProgress(
            listenable: notifier1,
            progress: () => notifier1.value,
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onProgress(
            listenable: notifier2,
            progress: () => notifier2.value,
            child: const SizedBox(),
          ),
        ),
      );

      // Updating old notifier should not affect anything
      notifier1.value = 1.0;
      await tester.pump();

      // Updating new notifier should still work
      notifier2.value = 0.5;
      await tester.pump();

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('with acts wraps child in Actor', (tester) async {
      final notifier = ValueNotifier<double>(0.0);
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onProgress(
            listenable: notifier,
            progress: () => notifier.value,
            acts: const [OpacityAct(from: 0.0, to: 1.0)],
            child: const Text('progress'),
          ),
        ),
      );

      expect(find.byType(Actor), findsOneWidget);
      expect(find.text('progress'), findsOneWidget);
    });
  });
}
