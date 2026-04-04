import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CueScope', () {
    testWidgets('of() retrieves scope from context', (tester) async {
      final controller = CueController(
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );
      late CueScope scope;

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Builder(
              builder: (context) {
                scope = CueScope.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(scope.controller, same(controller));
      expect(scope.reanimateFromCurrent, isFalse);
    });

    testWidgets('of() throws assert when no CueScope in context', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(
                () => CueScope.of(context),
                throwsA(isA<AssertionError>()),
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('updateShouldNotify returns true when controller changes', (tester) async {
      final controller1 = CueController(
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );
      final controller2 = CueController(
        vsync: tester,
        motion: CueMotion.linear(500.ms),
      );

      final scope1 = CueScope(
        controller: controller1,
        reanimateFromCurrent: false,
        child: const SizedBox(),
      );
      final scope2 = CueScope(
        controller: controller2,
        reanimateFromCurrent: false,
        child: const SizedBox(),
      );

      expect(scope1.updateShouldNotify(scope2), isTrue);
    });

    testWidgets('updateShouldNotify returns true when reanimateFromCurrent changes', (tester) async {
      final controller = CueController(
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );

      final scope1 = CueScope(
        controller: controller,
        reanimateFromCurrent: false,
        child: const SizedBox(),
      );
      final scope2 = CueScope(
        controller: controller,
        reanimateFromCurrent: true,
        child: const SizedBox(),
      );

      expect(scope1.updateShouldNotify(scope2), isTrue);
    });

    testWidgets('updateShouldNotify returns false when nothing changes', (tester) async {
      final controller = CueController(
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );

      final scope1 = CueScope(
        controller: controller,
        reanimateFromCurrent: false,
        child: const SizedBox(),
      );
      final scope2 = CueScope(
        controller: controller,
        reanimateFromCurrent: false,
        child: const SizedBox(),
      );

      expect(scope1.updateShouldNotify(scope2), isFalse);
    });

    testWidgets('reanimateFromCurrent is accessible', (tester) async {
      final controller = CueController(
        vsync: tester,
        motion: CueMotion.linear(300.ms),
      );
      final scope = CueScope(
        controller: controller,
        reanimateFromCurrent: true,
        child: const SizedBox(),
      );

      expect(scope.reanimateFromCurrent, isTrue);
    });
  });
}
