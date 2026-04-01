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
  });
}
