import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';
import 'package:cue/src/cue/cue.dart';

void main() {
  group('OnChangeCue', () {
    testWidgets('creates with default skipFirstAnimation true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onChange(
            value: 'initial',
            child: const SizedBox(),
          ),
        ),
      );

      final widget = tester.widget<OnChangeCue>(find.byType(OnChangeCue));
      expect(widget.skipFirstAnimation, isTrue);
      expect(widget.fromCurrentValue, isFalse);
    });

    testWidgets('skipFirstAnimation sets value to 1.0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onChange(
            value: 'initial',
            skipFirstAnimation: true,
            child: const SizedBox(),
          ),
        ),
      );

      final state = tester.state(find.byType(OnChangeCue)) as dynamic;
      expect(state.controller.value, equals(1.0));
    });

    testWidgets('without skipFirstAnimation starts forward', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onChange(
            value: 'initial',
            motion: CueMotion.linear(100.ms),
            skipFirstAnimation: false,
            acts: [.fadeIn()],
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pump();

      final state = tester.state(find.byType(OnChangeCue)) as dynamic;
      expect(state.controller.value, equals(0.0));
    });

    testWidgets('value change triggers forward from 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onChange(
            value: 'first',
            motion: CueMotion.linear(100.ms),
            acts: [.fadeIn()],
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      final state = tester.state(find.byType(OnChangeCue)) as SelfAnimatedCueState;
      expect(state.controller.value, equals(1.0));

      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onChange(
            value: 'second',
            motion: CueMotion.linear(100.ms),
            acts: [.fadeIn()],
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pump();

      expect(state.controller.value, equals(0.0));
    });

    testWidgets('same value does not trigger animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onChange(
            value: 42,
            motion: CueMotion.linear(100.ms),
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      final state = tester.state(find.byType(OnChangeCue)) as dynamic;
      final statusBefore = state.controller.status;

      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onChange(
            value: 42,
            motion: CueMotion.linear(100.ms),
            child: const SizedBox(),
          ),
        ),
      );

      expect(state.controller.status, equals(statusBefore));
    });

    testWidgets('reanimateFromCurrent returns fromCurrentValue', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onChange(
            value: 'test',
            fromCurrentValue: true,
            child: const SizedBox(),
          ),
        ),
      );

      final state = tester.state(find.byType(OnChangeCue)) as dynamic;
      expect(state.reanimateFromCurrent, isTrue);
    });

    testWidgets('reanimateFromCurrent is false by default', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onChange(
            value: 'test',
            child: const SizedBox(),
          ),
        ),
      );

      final state = tester.state(find.byType(OnChangeCue)) as dynamic;
      expect(state.reanimateFromCurrent, isFalse);
    });

    testWidgets('debugName is OnChangeCue', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onChange(value: 'x', child: const SizedBox()),
        ),
      );

      final state = tester.state(find.byType(OnChangeCue)) as dynamic;
      expect(state.debugName, 'OnChangeCue');
    });

    testWidgets('custom motion is applied', (tester) async {
      final motion = CueMotion.linear(500.ms);
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onChange(
            value: 'test',
            motion: motion,
            child: const SizedBox(),
          ),
        ),
      );

      final state = tester.state(find.byType(OnChangeCue)) as SelfAnimatedCueState;
      final track = state.controller.timeline.obtainDefaultTrack().$1;
      expect(track.motion, equals(motion));
    });
  });
}
