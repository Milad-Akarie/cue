import 'package:cue/cue.dart';
import 'package:cue/src/timeline/track/track.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final motion = CueMotion.linear(300.ms);
  final actContext = ActContext(motion: motion, reverseMotion: motion);
  final track = CueTrackImpl(TrackConfig(motion: motion, reverseMotion: motion));
  final timeline = CueTimelineImpl.fromMotion(motion);


  group('PositionAct', () {
    group('key', () {
      test('has correct key name', () {
        const act = PositionAct(
          from: Position(top: 0),
          to: Position(top: 100),
        );
        expect(act.key.key, 'Position');
      });
    });

    group('constructors', () {
      test('default constructor sets from and to', () {
        const act = PositionAct(
          from: Position(top: 0, start: 0),
          to: Position(top: 100, start: 50),
        );
        expect(act.from, const Position(top: 0, start: 0));
        expect(act.to, const Position(top: 100, start: 50));
      });

      test('relative constructor sets relativeTo', () {
        const act = PositionAct.relative(
          from: Position(top: 0),
          to: Position(top: 0.5),
          size: Size(100, 200),
        );
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0.5);

        final animation = CueAnimationImpl<Position>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        final pos = animation.value;
        expect(pos.top, 0.25);
      });

      test('keyframed constructor sets frames', () {
        final frames = FractionalKeyframes<Position>([
          FractionalKeyframe(const Position(top: 0), at: 0),
          FractionalKeyframe(const Position(top: 100), at: 1),
        ]);
        final act = PositionAct.keyframed(frames: frames);
        expect(act.frames, frames);
      });

      test('constructor accepts delay', () {
        const delay = Duration(milliseconds: 100);
        const act = PositionAct(
          from: Position(top: 0),
          to: Position(top: 100),
          delay: delay,
        );
        expect(act.delay, delay);
      });
    });

    group('buildTweens', () {
      test('creates correct animtable', () {
        const act = PositionAct(
          from: Position(top: 0),
          to: Position(top: 100),
        );
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0);

        final animation = CueAnimationImpl<Position>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        expect(animation.value.top, 0);

        track.setProgress(1);
        expect(animation.value.top, 100);
      });

      test('lerps all position properties', () {
        const act = PositionAct(
          from: Position(top: 0, start: 0, width: 50, height: 50),
          to: Position(top: 100, start: 100, width: 100, height: 100),
        );
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0.5);

        final animation = CueAnimationImpl<Position>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        final pos = animation.value;
        expect(pos.top, 50);
        expect(pos.start, 50);
        expect(pos.width, 75);
        expect(pos.height, 75);
      });
    });

    group('apply', () {
      testWidgets('wraps child in Positioned', (tester) async {
        const act = PositionAct(
          from: Position(top: 0, start: 0),
          to: Position(top: 100, start: 100),
        );
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0.5);

        final animation = CueAnimationImpl<Position>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              children: [
                Builder(
                  builder: (context) {
                    return act.apply(context, animation, const Text('Test'));
                  },
                ),
              ],
            ),
          ),
        );

        expect(find.byType(Positioned), findsOneWidget);
        expect(find.text('Test'), findsOneWidget);
      });
    });

    group('equality', () {
      test('equal acts have same hashCode', () {
        const a = PositionAct(
          from: Position(top: 0),
          to: Position(top: 100),
        );
        const b = PositionAct(
          from: Position(top: 0),
          to: Position(top: 100),
        );
        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('different from values are not equal', () {
        const a = PositionAct(
          from: Position(top: 0),
          to: Position(top: 100),
        );
        const b = PositionAct(
          from: Position(top: 10),
          to: Position(top: 100),
        );
        expect(a, isNot(b));
      });

      test('different relativeTo are not equal', () {
        const a = PositionAct.relative(
          from: Position(top: 0),
          to: Position(top: 1),
          size: Size(100, 100),
        );
        const b = PositionAct.relative(
          from: Position(top: 0),
          to: Position(top: 1),
          size: Size(200, 200),
        );
        expect(a, isNot(b));
      });
    });

    group('createSingleTween', () {
      test('returns PositionTween', () {
        const act = PositionAct(
          from: Position(top: 0, start: 0),
          to: Position(top: 100, start: 100),
        );
        final tween = act.createSingleTween(
          const Position(top: 0, start: 0),
          const Position(top: 100, start: 100),
        );
        expect(tween, isA<Tween<Position>>());
      });

    });

    group('internal constructor', () {
      test('creates act with relativeTo', () {
        const act = PositionAct.internal(
          from: Position(top: 0),
          to: Position(top: 1),
          relativeTo: Size(100, 100),
        );
        
        final (animtable, _) = act.buildTweens(actContext);
        track.setProgress(0.5);

        final animation = CueAnimationImpl<Position>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        final pos = animation.value;
        expect(pos.top, 0.5);
      });

      test('creates act with frames', () {
        final frames = FractionalKeyframes<Position>([
          FractionalKeyframe(const Position(top: 0), at: 0),
          FractionalKeyframe(const Position(top: 100), at: 1),
        ]);
        final act = PositionAct.internal(
          from: const Position(),
          to: const Position(),
          frames: frames,
        );
        expect(act.frames, frames);
      });
    });

  group('Position', () {
    test('default constructor', () {
      const pos = Position(top: 10, start: 20, width: 100, height: 50);
      expect(pos.top, 10);
      expect(pos.start, 20);
      expect(pos.width, 100);
      expect(pos.height, 50);
    });

    test('fill constructor', () {
      const pos = Position.fill();
      expect(pos.top, 0);
      expect(pos.start, 0);
      expect(pos.end, 0);
      expect(pos.bottom, 0);
      expect(pos.width, null);
      expect(pos.height, null);
    });

    test('lerp interpolates values', () {
      const a = Position(top: 0, start: 0, width: 50);
      const b = Position(top: 100, start: 100, width: 100);
      final result = Position.lerp(a, b, 0.5);
      expect(result.top, 50);
      expect(result.start, 50);
      expect(result.width, 75);
    });

    test('lerp handles null values', () {
      const a = Position(top: 0);
      const b = Position(start: 100);
      final result = Position.lerp(a, b, 0.5);
      expect(result.top, 0);
      expect(result.start, 50);
    });

    test('lerp both null returns null', () {
      const a = Position();
      const b = Position();
      final result = Position.lerp(a, b, 0.5);
      expect(result.top, null);
      expect(result.start, null);
    });

    test('fromSTEB constructor', () {
      const pos = Position.fromSTEB(10, 20, 30, 40);
      expect(pos.start, 10);
      expect(pos.top, 20);
      expect(pos.end, 30);
      expect(pos.bottom, 40);
      expect(pos.width, null);
      expect(pos.height, null);
    });

    test('topStart constructor', () {
      const pos = Position.topStart(top: 5, start: 15);
      expect(pos.top, 5);
      expect(pos.start, 15);
      expect(pos.end, null);
      expect(pos.bottom, null);
    });

    test('topEnd constructor', () {
      const pos = Position.topEnd(top: 5, end: 15);
      expect(pos.top, 5);
      expect(pos.end, 15);
      expect(pos.start, null);
      expect(pos.bottom, null);
    });

    test('bottomStart constructor', () {
      const pos = Position.bottomStart(bottom: 10, start: 20);
      expect(pos.bottom, 10);
      expect(pos.start, 20);
      expect(pos.top, null);
      expect(pos.end, null);
    });

    test('bottomEnd constructor', () {
      const pos = Position.bottomEnd(bottom: 10, end: 20);
      expect(pos.bottom, 10);
      expect(pos.end, 20);
      expect(pos.top, null);
      expect(pos.start, null);
    });
  });

  group('PositionActor', () {
    test('creates PositionAct with correct values', () {
      const actor = PositionActor(
        from: Position(top: 0),
        to: Position(top: 100),
        child: SizedBox(),
      );
      final act = actor.act as PositionAct;
      expect(act.from, const Position(top: 0));
      expect(act.to, const Position(top: 100));
    });

    test('keyframed constructor', () {
      final frames = FractionalKeyframes<Position>([
        FractionalKeyframe(const Position(top: 0), at: 0),
        FractionalKeyframe(const Position(top: 100), at: 1),
      ]);
      final actor = PositionActor.keyframed(
        frames: frames,
        child: const SizedBox(),
      );
      final act = actor.act as PositionAct;
      expect(act.frames, frames);
    });

    test('relative constructor', () {
      const actor = PositionActor.relative(
        from: Position(top: 0),
        to: Position(top: 1),
        size: Size(100, 100),
        child: SizedBox(),
      );
      final act = actor.act as PositionAct;
      expect(act.from, const Position(top: 0));
      expect(act.to, const Position(top: 1));
    });

    test('keyframed constructor with relativeTo', () {
      final frames = FractionalKeyframes<Position>([
        FractionalKeyframe(const Position(top: 0), at: 0),
        FractionalKeyframe(const Position(top: 1), at: 1),
      ]);
      final actor = PositionActor.keyframed(
        frames: frames,
        relativeTo: const Size(200, 100),
        child: const SizedBox(),
      );
      final act = actor.act as PositionAct;
      expect(act.frames, frames);
    });

    test('passes motion to act', () {
      final actor = PositionActor(
        from: const Position(top: 0),
        to: const Position(top: 100),
        motion: motion,
        child: const SizedBox(),
      );
      final act = actor.act as PositionAct;
      expect(act.motion, equals(motion));
    });

    test('passes delay to act', () {
      const delay = Duration(milliseconds: 100);
      const actor = PositionActor(
        from: Position(top: 0),
        to: Position(top: 100),
        delay: delay,
        child: SizedBox(),
      );
      final act = actor.act as PositionAct;
      expect(act.delay, equals(delay));
    });

    testWidgets('build renders child in positioned context', (tester) async {
      final actor = PositionActor(
        from: const Position(top: 0, start: 0),
        to: const Position(top: 100, start: 100),
        child: const Text('Positioned Content'),
      );

      final motion = CueMotion.linear(300.ms);

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: CueController(
              vsync: tester,
              motion: motion,
            ),
            child: Scaffold(
              body: Stack(
                children: [actor],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Positioned Content'), findsOneWidget);
    });

    testWidgets('relative constructor applies scale correctly', (tester) async {
      final actor = PositionActor.relative(
        from: const Position(top: 0, start: 0),
        to: const Position(top: 1, start: 1), // 100% of size
        size: const Size(200, 100),
        child: const Text('Relative Positioned'),
      );

      final motion = CueMotion.linear(300.ms);

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: CueController(
              vsync: tester,
              motion: motion,
            ),
            child: Scaffold(
              body: Stack(
                children: [actor],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Relative Positioned'), findsOneWidget);
      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('keyframed constructor animates through frames', (tester) async {
      final frames = FractionalKeyframes<Position>([
        FractionalKeyframe(const Position(top: 0, start: 0), at: 0),
        FractionalKeyframe(const Position(top: 100, start: 100), at: 1),
      ]);

      final actor = PositionActor.keyframed(
        frames: frames,
        child: const Text('Keyframed Positioned'),
      );

      final motion = CueMotion.linear(300.ms);

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: CueController(
              vsync: tester,
              motion: motion,
            ),
            child: Scaffold(
              body: Stack(
                children: [actor],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Keyframed Positioned'), findsOneWidget);
      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('keyframed with relative positions applies both scale and interpolation', (tester) async {
      final frames = FractionalKeyframes<Position>([
        FractionalKeyframe(const Position(top: 0, start: 0), at: 0),
        FractionalKeyframe(const Position(top: 0.5, start: 0.5), at: 1),
      ]);

      final actor = PositionActor.keyframed(
        frames: frames,
        relativeTo: const Size(200, 100),
        child: const Text('Keyframed Relative'),
      );

      final motion = CueMotion.linear(300.ms);

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: CueController(
              vsync: tester,
              motion: motion,
            ),
            child: Scaffold(
              body: Stack(
                children: [actor],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Keyframed Relative'), findsOneWidget);
      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('passes motion and delay parameters', (tester) async {
      final motion = CueMotion.linear(500.ms);
      final delay = Duration(milliseconds: 100);

      final actor = PositionActor(
        from: const Position(top: 0),
        to: const Position(top: 50),
        motion: motion,
        delay: delay,
        child: const Text('Motion Test'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: CueController(
              vsync: tester,
              motion: motion,
            ),
            child: Scaffold(
              body: Stack(
                children: [actor],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Motion Test'), findsOneWidget);
    });
  });
});
}