import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';
import 'package:cue/src/cue/cue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnToggleCue', () {
    testWidgets('skipFirstAnimation sets value to 1.0 when toggled is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onToggle(
            toggled: true,
            skipFirstAnimation: true,
            child: const SizedBox(),
          ),
        ),
      );

      final state = tester.state(find.byType(OnToggleCue)) as SelfAnimatedCueState;
      expect(state.controller.value, equals(1.0));
    });

    testWidgets('skipFirstAnimation sets value to 0.0 when toggled is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onToggle(
            toggled: false,
            skipFirstAnimation: true,
            child: const SizedBox(),
          ),
        ),
      );

      final state = tester.state(find.byType(OnToggleCue)) as SelfAnimatedCueState;
      expect(state.controller.value, equals(0.0));
    });

    testWidgets('without skipFirstAnimation starts forward when toggled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onToggle(
            toggled: true,
            skipFirstAnimation: false,
            motion: CueMotion.linear(100.ms),
            child: const SizedBox(),
          ),
        ),
      );

      final state = tester.state(find.byType(OnToggleCue)) as dynamic;
      expect(state.controller.status, equals(AnimationStatus.forward));
    });

    testWidgets('without skipFirstAnimation starts reverse when not toggled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onToggle(
            toggled: false,
            skipFirstAnimation: false,
            motion: CueMotion.linear(100.ms),
            child: const SizedBox(),
          ),
        ),
      );
      final state = tester.state(find.byType(OnToggleCue)) as SelfAnimatedCueState;
     print(state.controller.status);
      expect(state.controller.status, equals(AnimationStatus.reverse));
    });

    testWidgets('toggling from false to true calls forward', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onToggle(
            toggled: false,
            motion: CueMotion.linear(100.ms),
            child: const SizedBox(),
          ),
        ),
      );

      final state = tester.state(find.byType(OnToggleCue)) as dynamic;
      expect(state.controller.value, equals(0.0));

      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onToggle(
            toggled: true,
            motion: CueMotion.linear(100.ms),
            child: const SizedBox(),
          ),
        ),
      );

      expect(state.controller.status, equals(AnimationStatus.forward));
    });

    testWidgets('toggling from true to false calls reverse', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onToggle(
            toggled: true,
            motion: CueMotion.linear(100.ms),
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onToggle(
            toggled: false,
            motion: CueMotion.linear(100.ms),
            child: const SizedBox(),
          ),
        ),
      );

      final state = tester.state(find.byType(OnToggleCue)) as dynamic;
      expect(state.controller.status, equals(AnimationStatus.reverse));
    });

    testWidgets('toggling same value does not restart animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onToggle(
            toggled: true,
            motion: CueMotion.linear(100.ms),
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      final state1 = tester.state(find.byType(OnToggleCue)) as dynamic;
      final statusBefore = state1.controller.status;

      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onToggle(
            toggled: true,
            motion: CueMotion.linear(100.ms),
            child: const SizedBox(),
          ),
        ),
      );

      expect(state1.controller.status, equals(statusBefore));
    });

    testWidgets('debugName is ToggledCue', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onToggle(
            toggled: false,
            child: const SizedBox(),
          ),
        ),
      );

      final state = tester.state(find.byType(OnToggleCue)) as dynamic;
      expect(state.debugName, 'ToggledCue');
    });

    testWidgets('custom motion is applied', (tester) async {
      final motion = CueMotion.linear(500.ms);
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onToggle(
            toggled: true,
            motion: motion,
            child: const SizedBox(),
          ),
        ),
      );

      final state = tester.state(find.byType(OnToggleCue)) as dynamic;
      expect(state.controller.timeline.mainTrack.motion, equals(motion));
    });

    testWidgets('onEnd callback is wired', (tester) async {
      bool? endResult;
      await tester.pumpWidget(
        MaterialApp(
          home: Cue.onToggle(
            toggled: true,
            skipFirstAnimation: false,
            motion: CueMotion.linear(50.ms),
            onEnd: (completed) => endResult = completed,
            child: const SizedBox(),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      expect(endResult, isNotNull);
    });
  });
}
