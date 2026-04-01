import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';
import 'package:cue/src/cue/cue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnMountCue', () {
    testWidgets('creates state with default motion', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onMount(child: const SizedBox()),
        ),
      );

      final state = tester.state<OnMountCueState>(find.byType(OnMountCue));
      expect(state.widget.motion, equals(CueMotion.defaultTime));
      expect(state.debugName, 'OnMountCue');
    });

    testWidgets('creates state with custom motion', (tester) async {
      final motion = CueMotion.linear(500.ms);
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onMount(motion: motion, child: const SizedBox()),
        ),
      );

      final state = tester.state<OnMountCueState>(find.byType(OnMountCue));
      expect(state.widget.motion, equals(motion));
    });

    testWidgets('forwards on mount when repeat is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onMount(repeat: false, child: const SizedBox()),
        ),
      );

      final state = tester.state<OnMountCueState>(find.byType(OnMountCue));
      expect(state.widget.repeat, isFalse);
      expect(state.controller.status, equals(AnimationStatus.forward));
    });

    testWidgets('repeats on mount when repeat is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onMount(
            repeat: true,
            repeatCount: 3,
            reverseOnRepeat: true,
            child: const SizedBox(),
          ),
        ),
      );

      final state = tester.state<OnMountCueState>(find.byType(OnMountCue));
      expect(state.widget.repeat, isTrue);
      expect(state.widget.repeatCount, 3);
      expect(state.widget.reverseOnRepeat, isTrue);
    });

    testWidgets('custom reverseMotion is passed to controller', (tester) async {
      final motion = CueMotion.linear(300.ms);
      final reverseMotion = CueMotion.linear(200.ms);
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onMount(
            motion: motion,
            reverseMotion: reverseMotion,
            child: const SizedBox(),
          ),
        ),
      );

      final state = tester.state<OnMountCueState>(find.byType(OnMountCue));
      expect(state.widget.reverseMotion, equals(reverseMotion));
      expect(state.controller.timeline.mainTrack.reverseMotion, equals(reverseMotion));
    });

    testWidgets('onEnd callback is wired up', (tester) async {
      bool? endValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onMount(
            motion: CueMotion.linear(50.ms),
            onEnd: (completed) => endValue = completed,
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      expect(endValue, isNotNull);
    });

    testWidgets('didUpdateWidget restarts animation on repeat change', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onMount(repeat: false, child: const SizedBox()),
        ),
      );

      final state1 = tester.state<OnMountCueState>(find.byType(OnMountCue));
      expect(state1.widget.repeat, isFalse);

      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onMount(repeat: true, repeatCount: 2, child: const SizedBox()),
        ),
      );

      final state2 = tester.state<OnMountCueState>(find.byType(OnMountCue));
      expect(state2.widget.repeat, isTrue);
      expect(state2.widget.repeatCount, 2);
    });

    testWidgets('didUpdateWidget restarts animation on reverseOnRepeat change', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onMount(
            repeat: true,
            reverseOnRepeat: false,
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onMount(
            repeat: true,
            reverseOnRepeat: true,
            child: const SizedBox(),
          ),
        ),
      );

      final state = tester.state<OnMountCueState>(find.byType(OnMountCue));
      expect(state.widget.reverseOnRepeat, isTrue);
    });

    testWidgets('animation completes after duration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onMount(
            motion: CueMotion.linear(50.ms),
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      final state = tester.state<OnMountCueState>(find.byType(OnMountCue));
      expect(state.controller.status, equals(AnimationStatus.completed));
      expect(state.controller.value, equals(1.0));
    });
  });
}
