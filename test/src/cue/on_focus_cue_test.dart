import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';
import 'package:cue/src/cue/cue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnFocusCue', () {
    testWidgets('creates state with default motion', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onFocus(child: const SizedBox()),
        ),
      );

      final widget = tester.widget<OnFocusCue>(find.byType(OnFocusCue));
      expect(widget.motion, equals(CueMotion.defaultTime));
    });

    testWidgets('builds with Focus widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onFocus(child: const SizedBox()),
        ),
      );

      expect(find.descendant(of: find.byType(OnFocusCue), matching: find.byType(Focus)), findsOneWidget);
    });

    testWidgets('debugName is OnFocusCue', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onFocus(child: const SizedBox()),
        ),
      );

      final state = tester.state(find.byType(OnFocusCue)) as dynamic;
      expect(state.debugName, 'OnFocusCue');
    });

    testWidgets('focus triggers forward animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onFocus(
            motion: CueMotion.linear(100.ms),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final focusFinder = find.descendant(of: find.byType(OnFocusCue), matching: find.byType(Focus));
      final focusWidget = tester.widget<Focus>(focusFinder);

      focusWidget.focusNode!.requestFocus();
      await tester.pump();

      final state = tester.state(find.byType(OnFocusCue)) as dynamic;
      expect(state.controller.status, equals(AnimationStatus.forward));
    });

    testWidgets('unfocus triggers reverse animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onFocus(
            motion: CueMotion.linear(100.ms),
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      );

      final focusFinder = find.descendant(of: find.byType(OnFocusCue), matching: find.byType(Focus));
      final focusWidget = tester.widget<Focus>(focusFinder);

      focusWidget.focusNode!.requestFocus();
      await tester.pump();

      final state = tester.state(find.byType(OnFocusCue)) as dynamic;
      expect(state.controller.status, equals(AnimationStatus.forward));

      focusWidget.focusNode!.unfocus();
      await tester.pump();

      expect(state.controller.status, equals(AnimationStatus.reverse));
    });

    testWidgets('custom focusNode widget is created correctly', (tester) async {
      final focusNode = FocusNode();
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onFocus(
            focusNode: focusNode,
            motion: CueMotion.linear(100.ms),
            child: const SizedBox(),
          ),
        ),
      );

      final widget = tester.widget<OnFocusCue>(find.byType(OnFocusCue));
      expect(widget.focusNode, same(focusNode));

      // No error on dispose of the Cue widget
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      // Custom focusNode should NOT be disposed by the state -
      // requesting focus should not throw
      focusNode.requestFocus();
      focusNode.dispose();
    });

    testWidgets('custom motion is applied', (tester) async {
      final motion = CueMotion.linear(500.ms);
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onFocus(motion: motion, child: const SizedBox()),
        ),
      );

      final state = tester.state(find.byType(OnFocusCue)) as dynamic;
      expect(state.controller.timeline.mainTrack.motion, equals(motion));
    });

    testWidgets('custom reverseMotion is applied', (tester) async {
      final motion = CueMotion.linear(300.ms);
      final reverseMotion = CueMotion.linear(200.ms);
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onFocus(
            motion: motion,
            reverseMotion: reverseMotion,
            child: const SizedBox(),
          ),
        ),
      );

      final state = tester.state(find.byType(OnFocusCue)) as dynamic;
      expect(state.controller.timeline.mainTrack.reverseMotion, equals(reverseMotion));
    });
  });
}
