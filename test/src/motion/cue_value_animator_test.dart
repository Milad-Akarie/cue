import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CueValueAnimator', () {
    testWidgets('creates with initial value', (tester) async {
      final animator = CueValueAnimator<double>(
        0.0,
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );

      expect(animator.value, equals(0.0));
      animator.dispose();
    });

    testWidgets('animates to new value', (tester) async {
      final animator = CueValueAnimator<double>(
        0.0,
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );

      animator.animateTo(100.0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(animator.value, closeTo(50.0, 10.0));
      animator.dispose();
    });

    testWidgets('stops animation when value is set directly', (tester) async {
      final animator = CueValueAnimator<double>(
        0.0,
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );

      animator.animateTo(100.0);
      await tester.pump(const Duration(milliseconds: 100));

      animator.value = 50.0;

      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      expect(animator.value, equals(50.0));
      animator.dispose();
    });

    testWidgets('implements Animation interface', (tester) async {
      final animator = CueValueAnimator<double>(
        0.0,
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );

      expect(animator, isA<Animation<double>>());
      expect(animator.parent, isA<Animation<double>>());

      animator.dispose();
    });

    testWidgets('dispose cleans up controller', (tester) async {
      final animator = CueValueAnimator<double>(
        0.0,
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );

      animator.animateTo(100.0);
      animator.dispose();

      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
