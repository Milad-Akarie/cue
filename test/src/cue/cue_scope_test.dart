import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';
import 'package:cue/src/cue/cue.dart';
import 'package:cue/src/timeline/track/track_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CueScope', () {
    testWidgets('of() retrieves scope from context', (tester) async {
      final timeline = CueTimelineImpl.fromMotion(CueMotion.linear(300.ms));
      late CueScope scope;

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            timeline: timeline,
            child: Builder(
              builder: (context) {
                scope = CueScope.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(scope.timeline, same(timeline));
      expect(scope.mainConfig, equals(timeline.mainTrackConfig));
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

    testWidgets('updateShouldNotify returns true when timeline changes', (tester) async {
      final timeline1 = CueTimelineImpl.fromMotion(CueMotion.linear(300.ms));
      final timeline2 = CueTimelineImpl.fromMotion(CueMotion.linear(500.ms));

      final scope1 = CueScope(
        timeline: timeline1,
        mainConfig: timeline1.mainTrackConfig,
        reanimateFromCurrent: false,
        child: const SizedBox(),
      );
      final scope2 = CueScope(
        timeline: timeline2,
        mainConfig: timeline2.mainTrackConfig,
        reanimateFromCurrent: false,
        child: const SizedBox(),
      );

      expect(scope1.updateShouldNotify(scope2), isTrue);
    });

    testWidgets('updateShouldNotify returns true when reanimateFromCurrent changes', (tester) async {
      final timeline = CueTimelineImpl.fromMotion(CueMotion.linear(300.ms));

      final scope1 = CueScope(
        timeline: timeline,
        mainConfig: timeline.mainTrackConfig,
        reanimateFromCurrent: false,
        child: const SizedBox(),
      );
      final scope2 = CueScope(
        timeline: timeline,
        mainConfig: timeline.mainTrackConfig,
        reanimateFromCurrent: true,
        child: const SizedBox(),
      );

      expect(scope1.updateShouldNotify(scope2), isTrue);
    });

    testWidgets('updateShouldNotify returns true when mainConfig changes', (tester) async {
      final config1 = TrackConfig(
        motion: CueMotion.linear(300.ms),
        reverseMotion: CueMotion.linear(300.ms),
      );
      final config2 = TrackConfig(
        motion: CueMotion.linear(500.ms),
        reverseMotion: CueMotion.linear(500.ms),
      );

      final timeline = CueTimelineImpl.fromMotion(CueMotion.linear(300.ms));

      final scope1 = CueScope(
        timeline: timeline,
        mainConfig: config1,
        reanimateFromCurrent: false,
        child: const SizedBox(),
      );
      final scope2 = CueScope(
        timeline: timeline,
        mainConfig: config2,
        reanimateFromCurrent: false,
        child: const SizedBox(),
      );

      expect(scope1.updateShouldNotify(scope2), isTrue);
    });

    testWidgets('updateShouldNotify returns false when nothing changes', (tester) async {
      final timeline = CueTimelineImpl.fromMotion(CueMotion.linear(300.ms));
      final config = timeline.mainTrackConfig;

      final scope1 = CueScope(
        timeline: timeline,
        mainConfig: config,
        reanimateFromCurrent: false,
        child: const SizedBox(),
      );
      final scope2 = CueScope(
        timeline: timeline,
        mainConfig: config,
        reanimateFromCurrent: false,
        child: const SizedBox(),
      );

      expect(scope1.updateShouldNotify(scope2), isFalse);
    });

    testWidgets('reanimateFromCurrent is accessible', (tester) async {
      final timeline = CueTimelineImpl.fromMotion(CueMotion.linear(300.ms));
      final scope = CueScope(
        timeline: timeline,
        mainConfig: timeline.mainTrackConfig,
        reanimateFromCurrent: true,
        child: const SizedBox(),
      );

      expect(scope.reanimateFromCurrent, isTrue);
    });
  });
}
