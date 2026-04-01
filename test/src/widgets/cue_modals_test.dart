import 'package:cue/cue.dart';
import 'package:cue/src/core/curves.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CueDialogRoute', () {
    test('constructor sets motion', () {
      final motion = CueMotion.linear(300.ms);
      final route = CueDialogRoute<void>(
        pageBuilder: (context, _, _) => const SizedBox(),
        motion: motion,
      );

      expect(route.motion, equals(motion));
    });

    test('constructor sets reverseMotion', () {
      final motion = CueMotion.linear(300.ms);
      final reverseMotion = CueMotion.linear(200.ms);
      final route = CueDialogRoute<void>(
        pageBuilder: (context, _, _) => const SizedBox(),
        motion: motion,
        reverseMotion: reverseMotion,
      );

      expect(route.reverseMotion, equals(reverseMotion));
    });

    test('constructor sets hideOnPushNext', () {
      final route = CueDialogRoute<void>(
        pageBuilder: (context, _, _) => const SizedBox(),
        motion: CueMotion.linear(300.ms),
        hideOnPushNext: false,
      );

      expect(route.hideOnPushNext, isFalse);
    });

    test('hideOnPushNext defaults to true', () {
      final route = CueDialogRoute<void>(
        pageBuilder: (context, _, _) => const SizedBox(),
        motion: CueMotion.linear(300.ms),
      );

      expect(route.hideOnPushNext, isTrue);
    });

    test('onAnimationStatusChanged is set', () {
      bool called = false;
      final route = CueDialogRoute<void>(
        pageBuilder: (context, _, _) => const SizedBox(),
        motion: CueMotion.linear(300.ms),
        onAnimationStatusChanged: (_) => called = true,
      );

      expect(route.onAnimationStatusChanged, isNotNull);
      route.onAnimationStatusChanged!(AnimationStatus.forward);
      expect(called, isTrue);
    });

    test('barrierDismissible defaults to true', () {
      final route = CueDialogRoute<void>(
        pageBuilder: (context, _, _) => const SizedBox(),
        motion: CueMotion.linear(300.ms),
      );

      expect(route.barrierDismissible, isTrue);
    });

    test('barrierColor is set', () {
      final route = CueDialogRoute<void>(
        pageBuilder: (context, _, _) => const SizedBox(),
        motion: CueMotion.linear(300.ms),
        barrierColor: Colors.red,
      );

      expect(route.barrierColor, equals(Colors.red));
    });
  });

  group('showCueDialog', () {
    testWidgets('opens and closes dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showCueDialog(
                context: context,
                builder: (_) => const Text('dialog content'),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('dialog content'), findsOneWidget);
    });

    testWidgets('uses custom motion', (tester) async {
      final motion = CueMotion.linear(50.ms);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showCueDialog(
                context: context,
                motion: motion,
                builder: (_) => const Text('motion dialog'),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('motion dialog'), findsOneWidget);
    });
    testWidgets('barrierDismissible allows closing by tapping barrier', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showCueDialog(
                context: context,
                barrierDismissible: true,
                builder: (_) => const Text('dismissible'),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('dismissible'), findsOneWidget);

      // Dismiss by popping navigator
      final navigator = tester.state<NavigatorState>(find.byType(Navigator).last);
      navigator.pop();
      await tester.pumpAndSettle();

      expect(find.text('dismissible'), findsNothing);
    });
  });

  group('CueModalRouteMixin', () {
    test('barrierCurve returns BoundedCurve', () {
      final route = _TestCueModalRoute(
        motion: CueMotion.linear(300.ms),
      );

      expect(route.barrierCurve, isA<BoundedCurve>());
    });

    test('createSimulation returns null', () {
      final route = _TestCueModalRoute(
        motion: CueMotion.linear(300.ms),
      );

      expect(route.createSimulation(forward: true), isNull);
      expect(route.createSimulation(forward: false), isNull);
    });

    test('motion getter returns provided motion', () {
      final motion = CueMotion.linear(500.ms);
      final route = _TestCueModalRoute(motion: motion);

      expect(route.motion, equals(motion));
    });

    test('reverseMotion getter returns provided reverseMotion', () {
      final motion = CueMotion.linear(300.ms);
      final reverseMotion = CueMotion.linear(200.ms);
      final route = _TestCueModalRoute(
        motion: motion,
        reverseMotion: reverseMotion,
      );

      expect(route.reverseMotion, equals(reverseMotion));
    });

    test('hideOnPushNext getter returns provided value', () {
      final route = _TestCueModalRoute(
        motion: CueMotion.linear(300.ms),
        hideOnPushNext: false,
      );

      expect(route.hideOnPushNext, isFalse);
    });
  });
}

class _TestCueModalRoute extends RawDialogRoute<void> with CueModalRouteMixin<void> {
  @override
  final CueMotion motion;

  @override
  final CueMotion? reverseMotion;

  @override
  final AnimationStatusListener? onAnimationStatusChanged;

  @override
  final bool hideOnPushNext;

  _TestCueModalRoute({
    required this.motion,
    this.reverseMotion,
    this.onAnimationStatusChanged,
    this.hideOnPushNext = true,
  }) : super(
         pageBuilder: (context, _, _) => const SizedBox(),
         transitionBuilder: (_, _, _, child) => child,
       );

  @override
  Curve get barrierCurve => BoundedCurve(curve: Curves.easeIn);

  @override
  Simulation? createSimulation({required bool forward}) => null;
}
