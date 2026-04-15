import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';
import 'package:cue/src/cue/cue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnScrollVisibleCue', () {
    testWidgets('creates with default parameters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: SizedBox(
              height: 1000,
              child: Cue.onScrollVisible(
                child: const SizedBox(height: 100),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(OnScrollVisibleCue), findsOneWidget);
    });

    testWidgets('creates with enabled false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: SizedBox(
              height: 1000,
              child: Cue.onScrollVisible(
                enabled: false,
                child: const SizedBox(height: 100),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(OnScrollVisibleCue), findsOneWidget);
    });

    testWidgets('throws when not inside scrollable', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onScrollVisible(
            child: const SizedBox(height: 100),
          ),
        ),
      );

      expect(tester.takeException(), isA<FlutterError>());
    });

    testWidgets('creates state with controller', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: SizedBox(
              height: 1000,
              child: Cue.onScrollVisible(
                child: const SizedBox(height: 100),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final state = tester.state<OnScrollVisibleCueState>(find.byType(OnScrollVisibleCue));
      expect(state.controller, isA<CueController>());
      expect(state.debugName, equals('OnScrollVisibleCue'));
    });

    testWidgets('uses acts parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: SizedBox(
              height: 1000,
              child: Cue.onScrollVisible(
                acts: [OpacityAct.fadeIn()],
                child: const SizedBox(height: 100),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(Actor), findsOneWidget);
    });

    testWidgets('controller starts at progress 1.0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            height: 500,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 100,
                    child: Cue.onScrollVisible(
                      acts: [.fadeIn()],
                      child: const Text('Test'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      final state = tester.state<OnScrollVisibleCueState>(find.byType(OnScrollVisibleCue));
      expect(state.controller.value, equals(1.0));
    });

    testWidgets('disables correctly on didUpdateWidget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: SizedBox(
              height: 1000,
              child: Cue.onScrollVisible(
                enabled: true,
                child: const SizedBox(height: 100),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: SizedBox(
              height: 1000,
              child: Cue.onScrollVisible(
                enabled: false,
                child: const SizedBox(height: 100),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final state = tester.state<OnScrollVisibleCueState>(find.byType(OnScrollVisibleCue));
      expect(state.controller.value, equals(1.0));
    });

    testWidgets('updates controller on scroll', (tester) async {
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            controller: scrollController,
            child: SizedBox(
              height: 1000,
              child: Column(
                children: [
                  SizedBox(height: 200),
                  Cue.onScrollVisible(
                    child: const SizedBox(height: 100),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      scrollController.jumpTo(150);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final state = tester.state<OnScrollVisibleCueState>(find.byType(OnScrollVisibleCue));
      expect(state.controller.value, lessThanOrEqualTo(1.0));
      expect(state.controller.value, greaterThanOrEqualTo(0.0));
    });

    testWidgets('enables correctly on didUpdateWidget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: SizedBox(
              height: 1000,
              child: Cue.onScrollVisible(
                enabled: false,
                child: const SizedBox(height: 100),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Re-enable the scroll visibility tracking
      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: SizedBox(
              height: 1000,
              child: Cue.onScrollVisible(
                enabled: true,
                child: const SizedBox(height: 100),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      final state = tester.state<OnScrollVisibleCueState>(find.byType(OnScrollVisibleCue));
      expect(state.controller, isA<CueController>());
      expect(find.byType(OnScrollVisibleCue), findsOneWidget);
    });
  });
}
