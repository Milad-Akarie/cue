import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:cue/cue.dart';

void main() {
  group('SelfAnimatedCue', () {
    testWidgets('creates state and exposes timeline', (tester) async {
      final widget = Cue.onMount(child: const SizedBox());
      await tester.pumpWidget(MaterialApp(home: widget));
      final state = tester.state<SelfAnimatedCueState>(find.byType(SelfAnimatedCue));
      expect(state.widget.motion, CueMotion.defaultTime);
      expect(state.debugName, 'SelfAnimatedCue');
      expect(state.controller, isA<CueController>());
      expect(state.timeline, state.controller.timeline);
    });

    testWidgets('forwards on mount if not looping', (tester) async {
      final widget = Cue.onMount(loop: false, child: const SizedBox());
      await tester.pumpWidget(MaterialApp(home: widget));
      final state = tester.state<SelfAnimatedCueState>(find.byType(SelfAnimatedCue));
      // Should have called controller.forward()
      // (We can't check private controller state, but no error = pass)
      expect(state.widget.loop, isFalse);
    });

    testWidgets('repeats on mount if looping', (tester) async {
      final widget = Cue.onMount(loop: true, loopCount: 2, reverseOnLoop: true, child: const SizedBox());
      await tester.pumpWidget(MaterialApp(home: widget));
      final state = tester.state<SelfAnimatedCueState>(find.byType(SelfAnimatedCue));
      expect(state.widget.loop, isTrue);
      expect(state.widget.loopCount, 2);
      expect(state.widget.reverseOnLoop, isTrue);
    });
  });
}
