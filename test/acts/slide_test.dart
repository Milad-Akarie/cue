import 'package:cue/cue.dart';
import 'package:cue/src/timeline/track/track.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:cue/src/acts/base/animatable_act.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

 

  final motion = CueMotion.linear(300.ms);
  final actContext = ActContext(motion: motion, reverseMotion: motion);
  final track = CueTrackImpl(TrackConfig(motion: motion, reverseMotion: motion));
  final timeline = CueTimelineImpl.fromMotion(motion);


  group('SlideAct', () {
    group('key', () {
      test('has correct key name', () {
        final act = SlideAct();
        expect(act.key.key, 'Slide');
      });
    });

    group('constructors', () {
      test('default constructor sets from and to', () {
        final act = SlideAct(
          from: const Offset(0.5, 0.5),
          to: const Offset(1, 1),
        );
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        
        final (animtable, _) = animtableAct.buildTweens(actContext);

        
        track.setProgress(0);

        final animation = CueAnimationImpl<Offset>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        expect(animation.value, const Offset(0.5, 0.5));
      });

      test('default constructor uses default values', () {
        final act = SlideAct();
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        
        final (animtable, _) = animtableAct.buildTweens(actContext);

        
        track.setProgress(0);

        final animation = CueAnimationImpl<Offset>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        expect(animation.value, Offset.zero);
      });

      test('up constructor slides from bottom to center', () {
        final act = SlideAct.up();
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        
        final (animtable, _) = animtableAct.buildTweens(actContext);

        
        track.setProgress(0);

        final animation = CueAnimationImpl<Offset>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        expect(animation.value, const Offset(0, 1));

        track.setProgress(1);
        expect(animation.value, Offset.zero);
      });

      test('down constructor slides from top to center', () {
        final act = SlideAct.down();
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        
        final (animtable, _) = animtableAct.buildTweens(actContext);

        
        track.setProgress(0);

        final animation = CueAnimationImpl<Offset>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        expect(animation.value, const Offset(0, -1));

        track.setProgress(1);
        expect(animation.value, Offset.zero);
      });

      test('fromLeading constructor slides from left to center', () {
        final act = SlideAct.fromLeading();
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        
        final (animtable, _) = animtableAct.buildTweens(actContext);

        
        track.setProgress(0);

        final animation = CueAnimationImpl<Offset>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        expect(animation.value, const Offset(-1, 0));

        track.setProgress(1);
        expect(animation.value, Offset.zero);
      });

      test('fromTrailing constructor slides from right to center', () {
        final act = SlideAct.fromTrailing();
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        
        final (animtable, _) = animtableAct.buildTweens(actContext);

        
        track.setProgress(0);

        final animation = CueAnimationImpl<Offset>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        expect(animation.value, const Offset(1, 0));

        track.setProgress(1);
        expect(animation.value, Offset.zero);
      });

      test('keyframed constructor sets frames', () {
        final frames = FractionalKeyframes<Offset>([
          FractionalKeyframe(const Offset(0, 0), at: 0),
          FractionalKeyframe(const Offset(1, 1), at: 1),
        ]);
        final act = SlideAct.keyframed(frames: frames);
        final tweenAct = act as TweenActBase<Offset, Offset>;
        expect(tweenAct.frames, frames);
      });

      test('y constructor slides on Y axis', () {
        final act = SlideAct.y(from: -1, to: 0);
        final animtableAct = act as AnimtableAct<double, Offset>;
        
        final (animtable, _) = animtableAct.buildTweens(actContext);

        
        track.setProgress(0);

        final animation = CueAnimationImpl<Offset>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        expect(animation.value, const Offset(0, -1));

        track.setProgress(1);
        expect(animation.value, Offset.zero);
      });

      test('keyframedY constructor sets frames on Y axis', () {
        final frames = FractionalKeyframes<double>([
          FractionalKeyframe(0.0, at: 0),
          FractionalKeyframe(1.0, at: 1),
        ]);
        final act = SlideAct.keyframedY(frames: frames);
        final tweenAct = act as TweenActBase<double, Offset>;
        expect(tweenAct.frames, frames);
      });

      test('fromX constructor slides on X axis', () {
        final act = SlideAct.fromX(from: -1, to: 0);
        final animtableAct = act as AnimtableAct<double, Offset>;
        
        final (animtable, _) = animtableAct.buildTweens(actContext);

        
        track.setProgress(0);

        final animation = CueAnimationImpl<Offset>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        expect(animation.value, const Offset(-1, 0));

        track.setProgress(1);
        expect(animation.value, Offset.zero);
      });

      test('keyframedX constructor sets frames on X axis', () {
        final frames = FractionalKeyframes<double>([
          FractionalKeyframe(0.0, at: 0),
          FractionalKeyframe(1.0, at: 1),
        ]);
        final act = SlideAct.keyframedX(frames: frames);
        final tweenAct = act as TweenActBase<double, Offset>;
        expect(tweenAct.frames, frames);
      });

      test('constructor accepts delay', () {
        final act = SlideAct(delay: 100.ms);
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        expect(animtableAct.delay, 100.ms);
      });
    });

    group('apply', () {
      testWidgets('wraps child in SlideTransition', (tester) async {
        final act = SlideAct(from: const Offset(-1, 0), to: Offset.zero);
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        
        final (animtable, _) = animtableAct.buildTweens(actContext);

        
        track.setProgress(0.5);

        final animation = CueAnimationImpl<Offset>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return animtableAct.apply(context, animation, const Text('Test'));
              },
            ),
          ),
        );

        expect(find.byType(SlideTransition), findsOneWidget);
        expect(find.text('Test'), findsOneWidget);
      });
    });
  });
}
