import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';
import 'package:cue/src/cue/cue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnHoverCue', () {
    testWidgets('creates state with default cursor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onHover(child: const SizedBox()),
        ),
      );

      final widget = tester.widget<OnHoverCue>(find.byType(OnHoverCue));
      expect(widget.cursor, equals(MouseCursor.defer));
    });

    testWidgets('creates state with custom cursor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onHover(
            cursor: SystemMouseCursors.click,
            child: const SizedBox(),
          ),
        ),
      );

      final widget = tester.widget<OnHoverCue>(find.byType(OnHoverCue));
      expect(widget.cursor, equals(SystemMouseCursors.click));
    });

    testWidgets('default opaque is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onHover(child: const SizedBox()),
        ),
      );

      final widget = tester.widget<OnHoverCue>(find.byType(OnHoverCue));
      expect(widget.opaque, isFalse);
    });

    testWidgets('builds with MouseRegion', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onHover(child: const SizedBox()),
        ),
      );

      expect(find.descendant(of: find.byType(OnHoverCue), matching: find.byType(MouseRegion)), findsOneWidget);
    });

    testWidgets('debugName is OnHoverCue', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onHover(child: const SizedBox()),
        ),
      );

      final state = tester.state(find.byType(OnHoverCue)) as dynamic;
      expect(state.debugName, 'OnHoverCue');
    });

    testWidgets('hover enters triggers forward animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onHover(
            motion: CueMotion.linear(100.ms),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state(find.byType(OnHoverCue)) as dynamic;

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      await tester.pump();
      await gesture.moveTo(tester.getCenter(find.byType(OnHoverCue)));
      await tester.pump();

      expect(state.controller.status, equals(AnimationStatus.forward));
    });

    testWidgets('hover exit triggers reverse animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onHover(
            motion: CueMotion.linear(100.ms),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final state = tester.state(find.byType(OnHoverCue)) as dynamic;

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      await tester.pump();
      await gesture.moveTo(tester.getCenter(find.byType(OnHoverCue)));
      await tester.pump();

      expect(state.controller.status, equals(AnimationStatus.forward));

      await gesture.moveTo(const Offset(-500, -500));
      await tester.pump();

      expect(state.controller.status, equals(AnimationStatus.reverse));
    });

    testWidgets('custom motion is applied', (tester) async {
      final motion = CueMotion.linear(500.ms);
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onHover(motion: motion, child: const SizedBox()),
        ),
      );

      final state = tester.state(find.byType(OnHoverCue)) as dynamic;
      expect(state.controller.timeline.mainTrack.motion, equals(motion));
    });

    testWidgets('onEnd callback is wired', (tester) async {
      bool? endResult;
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onHover(
            motion: CueMotion.linear(50.ms),
            onEnd: (completed) => endResult = completed,
            child: const SizedBox(),
          ),
        ),
      );

      // Hover then leave to trigger onEnd(false)
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      await tester.pump();
      await gesture.moveTo(tester.getCenter(find.byType(OnHoverCue)));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      await gesture.moveTo(const Offset(-500, -500));
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(endResult, isNotNull);
    });
  });
}
