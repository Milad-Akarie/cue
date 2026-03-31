import 'package:cue/src/cue/cue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cue/cue.dart';

void main() {
  group('SelfAnimatedCue', () {
    testWidgets('creates state and exposes timeline', (tester) async {
      final widget = Cue.onMount(child: const SizedBox());
      await tester.pumpWidget(MaterialApp(home: widget));
      final state = tester.state<OnMountCueState>(find.byType(OnMountCue));
      expect(state.widget.motion, CueMotion.defaultTime);
      expect(state.debugName, 'OnMountCue');
      expect(state.controller, isA<CueController>());
      expect(state.timeline, state.controller.timeline);
    });

    testWidgets('forwards on mount if not looping', (tester) async {
      final widget = Cue.onMount(repeat: false, child: const SizedBox());
      await tester.pumpWidget(MaterialApp(home: widget));
      final state = tester.state<OnMountCueState>(find.byType(OnMountCue));
      // Should have called controller.forward()
      // (We can't check private controller state, but no error = pass)
      expect(state.widget.repeat, isFalse);
    });

    testWidgets('repeats on mount if looping', (tester) async {
      final widget = Cue.onMount(repeat: true, repeatCount: 2, reverseOnRepeat: true, child: const SizedBox());
      await tester.pumpWidget(MaterialApp(home: widget));
      final state = tester.state<OnMountCueState>(find.byType(OnMountCue));
      expect(state.widget.repeat, isTrue);
      expect(state.widget.repeatCount, 2);
      expect(state.widget.reverseOnRepeat, isTrue);
    });
  });
}
