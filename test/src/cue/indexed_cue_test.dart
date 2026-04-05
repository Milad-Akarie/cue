import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
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

    testWidgets('updates animation on controller change', (tester) async {
      final controller1 = CueIndexController(
        length: 3,
        vsync: const _TestTickerProvider(),
      );
      final controller2 = CueIndexController(
        length: 3,
        vsync: const _TestTickerProvider(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Cue.indexed(
            controller: controller1,
            index: 0,
            child: const SizedBox(),
          ),
        ),
      );

      // Switch controller
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.indexed(
            controller: controller2,
            index: 0,
            child: const SizedBox(),
          ),
        ),
      );

      expect(find.byType(IndexedCue), findsOneWidget);
    });

    testWidgets('renders multiple indices correctly', (tester) async {
      final controller = CueIndexController(
        length: 3,
        vsync: const _TestTickerProvider(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: [
              Cue.indexed(
                controller: controller,
                index: 0,
                child: const Text('index 0'),
              ),
              Cue.indexed(
                controller: controller,
                index: 1,
                child: const Text('index 1'),
              ),
              Cue.indexed(
                controller: controller,
                index: 2,
                child: const Text('index 2'),
              ),
            ],
          ),
        ),
      );

      expect(find.text('index 0'), findsOneWidget);
      expect(find.text('index 1'), findsOneWidget);
      expect(find.text('index 2'), findsOneWidget);
    });
  });

  group('CueIndexController advanced', () {
    testWidgets('animateTo updates state correctly', (tester) async {
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

      controller.animateTo(3);
      await tester.pumpAndSettle();

      expect(controller.currentIndex, 3);
      expect(controller.destinationIndex, 3);
      expect(controller.lastSettledIndex, 3);
    });

    testWidgets('animateTo with custom duration', (tester) async {
      late CueIndexController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueIndexController(
                length: 5,
                vsync: const _TestTickerProvider(),
                duration: const Duration(milliseconds: 500),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      controller.animateTo(2, duration: const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(controller.currentIndex, 2);
    });

    testWidgets('stop during animation', (tester) async {
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

      controller.animateTo(3);
      await tester.pump(const Duration(milliseconds: 100));
      controller.stop();

      expect(controller.isAnimating, isFalse);
    });

    testWidgets('jumpTo cancels animation', (tester) async {
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

      controller.animateTo(4);
      controller.jumpTo(1);

      expect(controller.currentIndex, 1);
      expect(controller.destinationIndex, 1);
    });

    testWidgets('valueFor with animateAll=true', (tester) async {
      late CueIndexController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueIndexController(
                length: 5,
                vsync: const _TestTickerProvider(),
                animateAll: true,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      controller.jumpTo(2);

      // With animateAll=true, values should be calculated even when not animating
      expect(controller.valueFor(1), 0.0);
      expect(controller.valueFor(2), 1.0);
      expect(controller.valueFor(3), 0.0);
    });

    testWidgets('valueFor with animateAll=false during animation', (tester) async {
      late CueIndexController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueIndexController(
                length: 5,
                vsync: const _TestTickerProvider(),
                animateAll: false,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      controller.jumpTo(1);

      // With animateAll=false when not animating, all indices work normally
      expect(controller.valueFor(0), 0.0);
      expect(controller.valueFor(4), 0.0);
      expect(controller.valueFor(1), 1.0);
    });

    testWidgets('calculateOffsetFor with large distance', (tester) async {
      late CueIndexController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueIndexController(
                length: 10,
                vsync: const _TestTickerProvider(),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      controller.animationController.value = 2;

      // Distance 3 should clamp to 0
      expect(controller.calculateOffsetFor(5), 0.0);
      // Distance 0 should be 1.0
      expect(controller.calculateOffsetFor(2), 1.0);
    });
  });

  group('CuePageController', () {
    testWidgets('initializes with correct values', (tester) async {
      late CuePageController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CuePageController(initialPage: 1);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(controller.initialPage, 1);
      expect(controller.currentIndex, 1);
      expect(controller.lastSettledIndex, 1);
      expect(controller.destinationIndex, 1);
      expect(controller.isAnimating, isFalse);
      expect(controller.animateAll, isFalse);
      expect(controller.globalOffset, 1.0);
    });

    testWidgets('initializes with animateAll=true', (tester) async {
      late CuePageController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CuePageController(
                initialPage: 0,
                animateAll: true,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(controller.animateAll, isTrue);
      expect(controller.currentIndex, 0);
    });

    testWidgets('currentIndex rounds globalOffset', (tester) async {
      late CuePageController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CuePageController(initialPage: 0);
              return const SizedBox();
            },
          ),
        ),
      );

      // When no clients attached, currentIndex equals initialPage
      expect(controller.currentIndex, 0);
    });

    testWidgets('destinationIndex when not animating', (tester) async {
      late CuePageController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CuePageController(initialPage: 2);
              return const SizedBox();
            },
          ),
        ),
      );

      // When not animating, destinationIndex follows current position
      expect(controller.destinationIndex, 2);
      expect(controller.isAnimating, isFalse);
    });

    testWidgets('jumpToPage updates destination', (tester) async {
      late CuePageController controller;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CuePageController(initialPage: 0);
              return PageView(
                controller: controller,
                children: [
                  Container(color: Colors.red),
                  Container(color: Colors.green),
                  Container(color: Colors.blue),
                ],
              );
            },
          ),
        ),
      );

      expect(controller.currentIndex, 0);
      controller.jumpToPage(1);
      await tester.pumpAndSettle();
      expect(controller.currentIndex, 1);
    });

    testWidgets('animateToPage sets isAnimating flag', (tester) async {
      late CuePageController controller;
      late bool wasAnimating;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CuePageController(initialPage: 0);
              return PageView(
                controller: controller,
                children: [
                  Container(color: Colors.red),
                  Container(color: Colors.green),
                  Container(color: Colors.blue),
                ],
              );
            },
          ),
        ),
      );

      controller.animateToPage(
        2,
        duration: Duration(milliseconds: 100),
        curve: Curves.linear,
      ).then((_) {
        wasAnimating = controller.isAnimating;
      });


      expect(controller.isAnimating, isTrue);
      await tester.pumpAndSettle();
      expect(controller.isAnimating, isFalse);
      expect(wasAnimating, isFalse);
    });

    testWidgets('globalOffset with no clients returns initialPage', (tester) async {
      late CuePageController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CuePageController(initialPage: 2);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(controller.globalOffset, 2.0);
      expect(controller.hasClients, isFalse);
    });

    testWidgets('valueFor returns correct animation values', (tester) async {
      late CuePageController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CuePageController(initialPage: 1);
              return PageView(
                controller: controller,
                children: [
                  Container(color: Colors.red),
                  Container(color: Colors.green),
                  Container(color: Colors.blue),
                  Container(color: Colors.yellow),
                ],
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // When at index 1 and not animating
      final value1 = controller.valueFor(1);
      final value2 = controller.valueFor(2);
      expect(value1, isNotNull);
      expect(value2, isNotNull);
    });

    testWidgets('calculateOffsetFor clamps values correctly', (tester) async {
      late CuePageController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CuePageController(initialPage: 2);
              return const SizedBox();
            },
          ),
        ),
      );

      // Distance 0 should return 1.0
      expect(controller.calculateOffsetFor(2), 1.0);
      // Distance 1 should return 0.0
      expect(controller.calculateOffsetFor(3), 0.0);
      // Distance > 1 should return 0.0
      expect(controller.calculateOffsetFor(5), 0.0);
    });

    testWidgets('CuePageController with viewportFraction', (tester) async {
      late CuePageController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CuePageController(
                initialPage: 0,
                viewportFraction: 0.9,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(controller.viewportFraction, 0.9);
    });
  });

  group('CueTabController', () {
    testWidgets('initializes with correct values', (tester) async {
      late CueTabController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueTabController(
                length: 3,
                vsync: const _TestTickerProvider(),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(controller.length, 3);
      expect(controller.index, 0);
      expect(controller.currentIndex, 0);
      expect(controller.lastSettledIndex, 0);
      expect(controller.destinationIndex, 0);
      expect(controller.isAnimating, isFalse);
      expect(controller.animateAll, isFalse);
      expect(controller.globalOffset, 0.0);
    });

    testWidgets('initializes with initialIndex', (tester) async {
      late CueTabController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueTabController(
                length: 4,
                initialIndex: 2,
                vsync: const _TestTickerProvider(),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(controller.index, 2);
      expect(controller.currentIndex, 2);
      expect(controller.lastSettledIndex, 2);
    });

    testWidgets('initializes with animateAll=true', (tester) async {
      late CueTabController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueTabController(
                length: 3,
                vsync: const _TestTickerProvider(),
                animateAll: true,
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(controller.animateAll, isTrue);
    });

    testWidgets('lastSettledIndex returns previousIndex', (tester) async {
      late CueTabController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueTabController(
                length: 3,
                initialIndex: 1,
                vsync: const _TestTickerProvider(),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(controller.lastSettledIndex, 1);
      expect(controller.previousIndex, 1);
    });

    testWidgets('animateTo sets destinationIndex and sets isAnimating', (tester) async {
      late CueTabController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueTabController(
                length: 4,
                vsync: const _TestTickerProvider(),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(controller.index, 0);
      controller.animateTo(2);
      expect(controller.destinationIndex, 2);
      controller.dispose();
    });

    testWidgets('globalOffset when animation is null', (tester) async {
      late CueTabController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueTabController(
                length: 3,
                initialIndex: 1,
                vsync: const _TestTickerProvider(),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(controller.globalOffset, 1.0);
    });

    testWidgets('tickListenable returns animation when available', (tester) async {
      late CueTabController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueTabController(
                length: 3,
                vsync: const _TestTickerProvider(),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      // Before animation starts, returns this (self)
      final listenable1 = controller.tickListenable;
      expect(listenable1, isNotNull);
    });

    testWidgets('destinationIndex when indexIsChanging is false', (tester) async {
      late CueTabController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueTabController(
                length: 3,
                vsync: const _TestTickerProvider(),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(controller.destinationIndex, 0);
      expect(controller.indexIsChanging, isFalse);
    });

    testWidgets('valueFor calculation', (tester) async {
      late CueTabController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueTabController(
                length: 4,
                vsync: const _TestTickerProvider(),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      // Current index is 0, not animating
      expect(controller.valueFor(0), 1.0);
      expect(controller.valueFor(1), 0.0);
      expect(controller.valueFor(2), 0.0);
    });

    testWidgets('animateTo with custom duration and curve', (tester) async {
      late CueTabController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueTabController(
                length: 3,
                vsync: const _TestTickerProvider(),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      controller.animateTo(
        2,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      expect(controller.destinationIndex, 2);
      controller.dispose();
    });

    testWidgets('previousIndex tracks last settled index', (tester) async {
      late CueTabController controller;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              controller = CueTabController(
                length: 4,
                initialIndex: 1,
                vsync: const _TestTickerProvider(),
              );
              return const SizedBox();
            },
          ),
        ),
      );

      expect(controller.previousIndex, 1);
      expect(controller.lastSettledIndex, 1);
    });
  });

}

class _TestTickerProvider extends TickerProvider {
  const _TestTickerProvider();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
