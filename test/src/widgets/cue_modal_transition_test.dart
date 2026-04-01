import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CueModalTransition', () {
    testWidgets('renders triggerBuilder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CueModalTransition(
            triggerBuilder: (context, showDialog) => const Text('trigger'),
            builder: (context, rect) => const SizedBox(),
          ),
        ),
      );

      expect(find.text('trigger'), findsOneWidget);
    });

    testWidgets('passes showDialog callback to triggerBuilder', (tester) async {
      late void Function() capturedShowDialog;
      await tester.pumpWidget(
        MaterialApp(
          home: CueModalTransition(
            triggerBuilder: (context, showDialog) {
              capturedShowDialog = showDialog;
              return ElevatedButton(
                onPressed: showDialog,
                child: const Text('open'),
              );
            },
            builder: (context, rect) => const Text('modal content'),
          ),
        ),
      );

      expect(capturedShowDialog, isNotNull);

      // Open the modal
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('modal content'), findsOneWidget);
    });

    testWidgets('triggerBuilder receives a ShowModalFunction', (tester) async {
      ShowModalFunction? capturedFn;
      await tester.pumpWidget(
        MaterialApp(
          home: CueModalTransition(
            triggerBuilder: (context, showDialog) {
              capturedFn = showDialog;
              return const SizedBox();
            },
            builder: (context, rect) => const SizedBox(),
          ),
        ),
      );

      expect(capturedFn, isNotNull);
    });

    testWidgets('default motion is CueMotion.defaultTime', (tester) async {
      final widget = CueModalTransition(
        triggerBuilder: (context, _) => const SizedBox(),
        builder: (context, rect) => const SizedBox(),
      );

      expect(widget.motion, equals(CueMotion.defaultTime));
    });

    testWidgets('custom motion is applied', (tester) async {
      final motion = CueMotion.linear(500.ms);
      final widget = CueModalTransition(
        motion: motion,
        triggerBuilder: (context, _) => const SizedBox(),
        builder: (context, rect) => const SizedBox(),
      );

      expect(widget.motion, equals(motion));
    });

    testWidgets('barrierDismissible defaults to true', (tester) async {
      final widget = CueModalTransition(
        triggerBuilder: (context, _) => const SizedBox(),
        builder: (context, rect) => const SizedBox(),
      );

      expect(widget.barrierDismissible, isTrue);
    });

    testWidgets('barrierDismissible is settable', (tester) async {
      final widget = CueModalTransition(
        barrierDismissible: false,
        triggerBuilder: (context, _) => const SizedBox(),
        builder: (context, rect) => const SizedBox(),
      );

      expect(widget.barrierDismissible, isFalse);
    });

    testWidgets('hideTriggerOnTransition defaults to false', (tester) async {
      final widget = CueModalTransition(
        triggerBuilder: (context, _) => const SizedBox(),
        builder: (context, rect) => const SizedBox(),
      );

      expect(widget.hideTriggerOnTransition, isFalse);
    });
    testWidgets('hideTriggerOnTransition hides trigger when modal is open', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CueModalTransition(
            hideTriggerOnTransition: true,
            triggerBuilder: (context, showDialog) => ElevatedButton(
              onPressed: showDialog,
              child: const Text('trigger'),
            ),
            builder: (context, rect) => const Text('modal'),
          ),
        ),
      );

      // Trigger is visible
      expect(find.text('trigger'), findsOneWidget);
      final visibilityBefore = tester.widget<Visibility>(find.byType(Visibility).first);
      expect(visibilityBefore.visible, isTrue);

      // Open modal
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      // Trigger Visibility should be hidden (maintain=false means invisible)
      final visibilityAfter = tester.widget<Visibility>(find.byType(Visibility).first);
      expect(visibilityAfter.visible, isFalse);
      expect(find.text('modal'), findsOneWidget);
    });
    testWidgets('trigger remains visible when hideTriggerOnTransition is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CueModalTransition(
            hideTriggerOnTransition: false,
            triggerBuilder: (context, showDialog) => ElevatedButton(
              onPressed: showDialog,
              child: const Text('trigger'),
            ),
            builder: (context, rect) => const Text('modal'),
          ),
        ),
      );

      // Open modal
      await tester.tap(find.text('trigger'));
      await tester.pumpAndSettle();

      // Trigger should still be visible
      final visibility = tester.widget<Visibility>(find.byType(Visibility).first);
      expect(visibility.visible, isTrue);
      expect(find.text('modal'), findsOneWidget);
    });

    testWidgets('builder receives triggerRect', (tester) async {
      Rect? capturedRect;
      await tester.pumpWidget(
        MaterialApp(
          home: CueModalTransition(
            triggerBuilder: (context, showDialog) => ElevatedButton(
              onPressed: showDialog,
              child: const Text('open'),
            ),
            builder: (context, rect) {
              capturedRect = rect;
              return const Text('content');
            },
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(capturedRect, isNotNull);
    });

    testWidgets('backdrop is rendered when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CueModalTransition(
            backdrop: const Text('backdrop'),
            triggerBuilder: (context, showDialog) => ElevatedButton(
              onPressed: showDialog,
              child: const Text('open'),
            ),
            builder: (context, rect) => const SizedBox(),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('backdrop'), findsOneWidget);
    });

    testWidgets('alignment is applied', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CueModalTransition(
            alignment: Alignment.topCenter,
            triggerBuilder: (context, showDialog) => ElevatedButton(
              onPressed: showDialog,
              child: const Text('open'),
            ),
            builder: (context, rect) => const Text('aligned'),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('aligned'), findsOneWidget);
    });

    testWidgets('useRootNavigator defaults to true', (tester) async {
      final widget = CueModalTransition(
        triggerBuilder: (context, _) => const SizedBox(),
        builder: (context, rect) => const SizedBox(),
      );

      expect(widget.useRootNavigator, isTrue);
    });

    testWidgets('barrierColor is applied', (tester) async {
      final widget = CueModalTransition(
        barrierColor: Colors.red,
        triggerBuilder: (context, _) => const SizedBox(),
        builder: (context, rect) => const SizedBox(),
      );

      expect(widget.barrierColor, equals(Colors.red));
    });

    testWidgets('reverseMotion is applied', (tester) async {
      final motion = CueMotion.linear(300.ms);
      final reverseMotion = CueMotion.linear(200.ms);
      final widget = CueModalTransition(
        motion: motion,
        reverseMotion: reverseMotion,
        triggerBuilder: (context, _) => const SizedBox(),
        builder: (context, rect) => const SizedBox(),
      );

      expect(widget.reverseMotion, equals(reverseMotion));
    });

    testWidgets('barrierLabel defaults to ModalTransition', (tester) async {
      final widget = CueModalTransition(
        triggerBuilder: (context, _) => const SizedBox(),
        builder: (context, rect) => const SizedBox(),
      );

      expect(widget.barrierLabel, equals('ModalTransition'));
    });
  });
}
