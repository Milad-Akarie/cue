import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';
import 'package:cue/src/cue/cue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SelfAnimatedCue', () {
    group('General behavior', () {
      testWidgets('creates controller with correct motion', (tester) async {
        final motion = CueMotion.linear(400.ms);
        await tester.pumpWidget(
          MaterialApp(
            home: Cue.onMount(motion: motion, child: const SizedBox()),
          ),
        );

        final state = tester.state<OnMountCueState>(find.byType(OnMountCue));
        expect(state.controller, isA<CueController>());
        expect(state.controller.timeline.mainTrack.motion, equals(motion));
      });

      testWidgets('timeline getter returns controller timeline', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Cue.onMount(child: const SizedBox()),
          ),
        );

        final state = tester.state<OnMountCueState>(find.byType(OnMountCue));
        expect(state.timeline, same(state.controller.timeline));
      });

      testWidgets('dispose cleans up controller', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Cue.onMount(child: const SizedBox()),
          ),
        );

        // Remove the widget to trigger dispose
        await tester.pumpWidget(const MaterialApp(home: SizedBox()));
        // No error = dispose succeeded
      });
    });

    group('Motion update via didUpdateWidget', () {
      testWidgets('updates motion when widget changes', (tester) async {
        final motion1 = CueMotion.linear(300.ms);
        final motion2 = CueMotion.linear(500.ms);

        await tester.pumpWidget(
          MaterialApp(
            home: Cue.onMount(motion: motion1, child: const SizedBox()),
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Cue.onMount(motion: motion2, child: const SizedBox()),
          ),
        );

        final state = tester.state<OnMountCueState>(find.byType(OnMountCue));
        expect(state.controller.timeline.mainTrack.motion, equals(motion2));
      });

      testWidgets('updates reverseMotion when widget changes', (tester) async {
        final motion = CueMotion.linear(300.ms);
        final reverse1 = CueMotion.linear(200.ms);
        final reverse2 = CueMotion.linear(400.ms);

        await tester.pumpWidget(
          MaterialApp(
            home: Cue.onMount(
              motion: motion,
              reverseMotion: reverse1,
              child: const SizedBox(),
            ),
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Cue.onMount(
              motion: motion,
              reverseMotion: reverse2,
              child: const SizedBox(),
            ),
          ),
        );

        final state = tester.state<OnMountCueState>(find.byType(OnMountCue));
        expect(state.controller.timeline.mainTrack.reverseMotion, equals(reverse2));
      });

      testWidgets('does not update when motion stays the same', (tester) async {
        final motion = CueMotion.linear(300.ms);

        await tester.pumpWidget(
          MaterialApp(
            home: Cue.onMount(
              motion: motion,
              child: const Text('first'),
            ),
          ),
        );

        final state1 = tester.state<OnMountCueState>(find.byType(OnMountCue));

        await tester.pumpWidget(
          MaterialApp(
            home: Cue.onMount(
              motion: motion,
              child: const Text('second'),
            ),
          ),
        );

        final state2 = tester.state<OnMountCueState>(find.byType(OnMountCue));
        expect(identical(state1, state2), isTrue);
      });
    });

    group('onEnd callback', () {
      testWidgets('calls onEnd with true when completed', (tester) async {
        bool? result;
        await tester.pumpWidget(
          MaterialApp(
            home: Cue.onMount(
              motion: CueMotion.linear(50.ms),
              onEnd: (completed) => result = completed,
              child: const SizedBox(),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(milliseconds: 200));
        expect(result, isTrue);
      });

      testWidgets('updates onEnd callback when widget changes', (tester) async {
        final results1 = <bool>[];
        final results2 = <bool>[];

        await tester.pumpWidget(
          MaterialApp(
            home: Cue.onMount(
              motion: CueMotion.linear(50.ms),
              onEnd: (c) => results1.add(c),
              child: const SizedBox(),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(milliseconds: 200));

        await tester.pumpWidget(
          MaterialApp(
            home: Cue.onMount(
              motion: CueMotion.linear(50.ms),
              onEnd: (c) => results2.add(c),
              child: const SizedBox(),
            ),
          ),
        );

        expect(results1, isNotEmpty);
      });
    });
  });
}
