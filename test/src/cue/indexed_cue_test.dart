import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';
import 'package:cue/src/cue/cue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CueIndexController', () {
    testWidgets('initializes with correct values', (tester) async {
      late CueIndexController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueIndexController(
                length: 5,
                vsync: const _TestTickerProvider(),
                initialIndex: 2,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(controller.length, 5);
      expect(controller.currentIndex, 2);
      expect(controller.destinationIndex, 2);
      expect(controller.lastSettledIndex, 2);
      expect(controller.isAnimating, isFalse);
      expect(controller.globalOffset, 2.0);
      expect(controller.animateAll, isFalse);
    });

    testWidgets('initialIndex defaults to 0', (tester) async {
      late CueIndexController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueIndexController(
                length: 3,
                vsync: const _TestTickerProvider(),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(controller.currentIndex, 0);
      expect(controller.globalOffset, 0.0);
    });

    testWidgets('jumpTo updates all indices', (tester) async {
      late CueIndexController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueIndexController(
                length: 5,
                vsync: const _TestTickerProvider(),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      controller.jumpTo(3);

      expect(controller.currentIndex, 3);
      expect(controller.destinationIndex, 3);
      expect(controller.lastSettledIndex, 3);
      expect(controller.globalOffset, 3.0);
    });

    testWidgets('stop snaps to nearest integer', (tester) async {
      late CueIndexController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueIndexController(
                length: 5,
                vsync: const _TestTickerProvider(),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      controller.animationController.value = 2.7;
      controller.stop();

      expect(controller.currentIndex, 3);
      expect(controller.destinationIndex, 3);
      expect(controller.lastSettledIndex, 3);
    });

    testWidgets('dispose cleans up animation controller', (tester) async {
      late CueIndexController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueIndexController(
                length: 3,
                vsync: const _TestTickerProvider(),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      // Remove the widget - should not throw
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    });

    testWidgets('asserts length > 0', (tester) async {
      expect(
        () => CueIndexController(
          length: 0,
          vsync: const _TestTickerProvider(),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('asserts initialIndex in range', (tester) async {
      expect(
        () => CueIndexController(
          length: 3,
          initialIndex: -1,
          vsync: const _TestTickerProvider(),
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => CueIndexController(
          length: 3,
          initialIndex: 3,
          vsync: const _TestTickerProvider(),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('asserts animateTo index in range', (tester) async {
      late CueIndexController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueIndexController(
                length: 3,
                vsync: const _TestTickerProvider(),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(
        () => controller.animateTo(-1),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => controller.animateTo(3),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('asserts jumpTo index in range', (tester) async {
      late CueIndexController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueIndexController(
                length: 3,
                vsync: const _TestTickerProvider(),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(
        () => controller.jumpTo(-1),
        throwsA(isA<AssertionError>()),
      );

      expect(
        () => controller.jumpTo(3),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('tickListenable returns animationController', (tester) async {
      late CueIndexController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueIndexController(
                length: 3,
                vsync: const _TestTickerProvider(),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(controller.tickListenable, same(controller.animationController));
    });
  });

  group('IndexedCueController mixin', () {
    testWidgets('valueFor returns correct value for non-animating', (tester) async {
      late CueIndexController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueIndexController(
                length: 5,
                vsync: const _TestTickerProvider(),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      controller.jumpTo(2);

      // value at index 2 should be 1.0 (current position)
      expect(controller.valueFor(2), equals(1.0));

      // value at index 1 should be 0.0 (distance = 1, 1-1=0)
      expect(controller.valueFor(1), equals(0.0));

      // value at index 3 should be 0.0 (distance = 1, 1-1=0)
      expect(controller.valueFor(3), equals(0.0));
    });

    testWidgets('calculateOffsetFor computes distance-based offset', (tester) async {
      late CueIndexController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueIndexController(
                length: 5,
                vsync: const _TestTickerProvider(),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      controller.jumpTo(2);

      // Distance 0 → 1.0
      expect(controller.calculateOffsetFor(2), equals(1.0));

      // Distance 1 → 0.0 (clamped)
      expect(controller.calculateOffsetFor(1), equals(0.0));
      expect(controller.calculateOffsetFor(3), equals(0.0));
    });
  });

  group('IndexedCue widget', () {
    testWidgets('creates with required parameters', (tester) async {
      final cueController = CueIndexController(
        length: 3,
        vsync: const _TestTickerProvider(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Cue.indexed(
            controller: cueController,
            index: 0,
            child: const Text('indexed'),
          ),
        ),
      );

      expect(find.text('indexed'), findsOneWidget);
    });

    testWidgets('state has correct debugName', (tester) async {
      final cueController = CueIndexController(
        length: 3,
        vsync: const _TestTickerProvider(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Cue.indexed(
            controller: cueController,
            index: 0,
            child: const SizedBox(),
          ),
        ),
      );

      final state = tester.state(find.byType(IndexedCue)) as dynamic;
      expect(state.debugName, 'IndexedCue');
    });

    testWidgets('dispose cleans up listener', (tester) async {
      final cueController = CueIndexController(
        length: 3,
        vsync: const _TestTickerProvider(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Cue.indexed(
            controller: cueController,
            index: 0,
            child: const SizedBox(),
          ),
        ),
      );

      // Remove should not throw
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    });
  });
}

class _TestTickerProvider extends TickerProvider {
  const _TestTickerProvider();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
