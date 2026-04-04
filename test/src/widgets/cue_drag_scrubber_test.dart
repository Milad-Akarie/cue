import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';
import 'package:cue/src/widgets/cue_drag_scrubber.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CueDragScrubber', () {
    testWidgets('creates with required parameters', (tester) async {
      final controller = CueController(
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CueScope(
            controller: controller,
            reanimateFromCurrent: false,
            child: CueDragScrubber(
              distance: 200,
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      expect(find.byType(CueDragScrubber), findsOneWidget);
    });

    testWidgets('creates with explicit controller', (tester) async {
      final controller = CueController(
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CueDragScrubber(
            controller: controller,
            distance: 200,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      expect(find.byType(CueDragScrubber), findsOneWidget);
    });

    testWidgets('throws when no controller available', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CueDragScrubber(
            distance: 200,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      await tester.startGesture(const Offset(50, 50));
      await tester.pump();

      expect(tester.takeException(), isNotNull);
    });

    testWidgets('respects vertical axis', (tester) async {
      final controller = CueController(
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CueScope(
            controller: controller,
            reanimateFromCurrent: false,
            child: CueDragScrubber(
              distance: 200,
              axis: Axis.vertical,
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('respects horizontal axis', (tester) async {
      final controller = CueController(
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CueScope(
            controller: controller,
            reanimateFromCurrent: false,
            child: CueDragScrubber(
              distance: 200,
              axis: Axis.horizontal,
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('scrubs controller on drag', (tester) async {
      final controller = CueController(
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CueScope(
            controller: controller,
            reanimateFromCurrent: false,
            child: CueDragScrubber(
              distance: 200,
              releaseMode: CueDragReleaseMode.none,
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(const Offset(50, 50));
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();

      expect(controller.value, closeTo(0.5, 0.1));
    });

    testWidgets('snaps on release in snap mode', (tester) async {
      final controller = CueController(
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CueScope(
            controller: controller,
            reanimateFromCurrent: false,
            child: CueDragScrubber(
              distance: 200,
              releaseMode: CueDragReleaseMode.snap,
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(const Offset(50, 50));
      await gesture.moveBy(const Offset(0, 150));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(controller.value, equals(1.0));
    });

    testWidgets('clamps progress between 0 and 1', (tester) async {
      final controller = CueController(
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CueScope(
            controller: controller,
            reanimateFromCurrent: false,
            child: CueDragScrubber(
              distance: 100,
              releaseMode: CueDragReleaseMode.none,
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(const Offset(50, 50));
      await gesture.moveBy(const Offset(0, 300));
      await tester.pump();

      expect(controller.value, equals(1.0));

      await gesture.moveBy(const Offset(0, -400));
      await tester.pump();

      expect(controller.value, equals(0.0));
    });

    testWidgets('respects forceLinearScrubing parameter', (tester) async {
      final controller = CueController(
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CueScope(
            controller: controller,
            reanimateFromCurrent: false,
            child: CueDragScrubber(
              distance: 200,
              forceLinearScrubing: false,
              releaseMode: CueDragReleaseMode.none,
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(const Offset(50, 50));
      await gesture.moveBy(const Offset(0, 100));
      await tester.pump();

      expect(controller.value, greaterThan(0));
    });

    testWidgets('handles zero velocity in fling mode snaps', (tester) async {
      final controller = CueController(
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CueScope(
            controller: controller,
            reanimateFromCurrent: false,
            child: CueDragScrubber(
              distance: 200,
              releaseMode: CueDragReleaseMode.fling,
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(const Offset(50, 50));
      await gesture.moveBy(const Offset(0, 50));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(controller.value, greaterThanOrEqualTo(0));
    });
  });

  group('CueDragReleaseMode', () {
    test('fling has correct value', () {
      expect(CueDragReleaseMode.fling.index, equals(0));
    });

    test('snap has correct value', () {
      expect(CueDragReleaseMode.snap.index, equals(1));
    });

    test('none has correct value', () {
      expect(CueDragReleaseMode.none.index, equals(2));
    });
  });

  group('CueScrubDirection', () {
    test('forward has correct value', () {
      expect(CueScrubDirection.forward.index, equals(0));
    });

    test('reverse has correct value', () {
      expect(CueScrubDirection.reverse.index, equals(1));
    });

    test('auto has correct value', () {
      expect(CueScrubDirection.auto.index, equals(2));
    });
  });
}
