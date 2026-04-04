import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';
import 'package:cue/src/cue/cue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnScrollCue', () {
    testWidgets('creates and renders child', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: SizedBox(
              height: 1000,
              child: Cue.onScroll(
                child: const SizedBox(height: 100),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(OnScrollCue), findsOneWidget);
    });

    testWidgets('throws when not inside scrollable', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onScroll(
            child: const SizedBox(height: 100),
          ),
        ),
      );

      expect(tester.takeException(), isA<FlutterError>());
    });

    testWidgets('uses acts parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            child: SizedBox(
              height: 1000,
              child: Cue.onScroll(
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

    testWidgets('updates controller on scroll', (tester) async {
      final scrollController = ScrollController();
      CueController? foundController;

      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            controller: scrollController,
            child: SizedBox(
              height: 1000,
              child: Column(
                children: [
                  SizedBox(height: 200),
                  Cue.onScroll(
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

      final cueFinder = find.byType(OnScrollCue);
      expect(cueFinder, findsOneWidget);
      final state = tester.state(cueFinder) as dynamic;
      foundController = state.controller as CueController;
      expect(foundController.value, lessThanOrEqualTo(1.0));
      expect(foundController.value, greaterThanOrEqualTo(0.0));
    });

    testWidgets('clamps progress between 0 and 1', (tester) async {
      final scrollController = ScrollController();
      CueController? controller;

      await tester.pumpWidget(
        MaterialApp(
          home: SingleChildScrollView(
            controller: scrollController,
            child: SizedBox(
              height: 1000,
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Cue.onScroll(
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

      scrollController.jumpTo(1000);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final cueFinder = find.byType(OnScrollCue);
      final state = tester.state(cueFinder) as dynamic;
      controller = state.controller as CueController;
      expect(controller.value, lessThanOrEqualTo(1.0));
      expect(controller.value, greaterThanOrEqualTo(0.0));
    });
  });
}
