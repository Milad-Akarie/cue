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

      test('up constructor with motion', () {
        final customMotion = CueMotion.linear(500.ms);
        final act = SlideAct.up(motion: customMotion);
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        expect(animtableAct.motion, customMotion);
      });

      test('up constructor with delay', () {
        final act = SlideAct.up(delay: 100.ms);
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        expect(animtableAct.delay, 100.ms);
      });

      test('up constructor with reverse', () {
        const reverse = ReverseBehavior<Offset>.mirror();
        final act = SlideAct.up(reverse: reverse);
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        expect(animtableAct.reverse, reverse);
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

      test('down constructor with motion', () {
        final customMotion = CueMotion.linear(500.ms);
        final act = SlideAct.down(motion: customMotion);
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        expect(animtableAct.motion, customMotion);
      });

      test('down constructor with delay', () {
        final act = SlideAct.down(delay: 100.ms);
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        expect(animtableAct.delay, 100.ms);
      });

      test('down constructor with reverse', () {
        const reverse = ReverseBehavior<Offset>.mirror();
        final act = SlideAct.down(reverse: reverse);
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        expect(animtableAct.reverse, reverse);
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

      test('fromLeading constructor with motion', () {
        final customMotion = CueMotion.linear(500.ms);
        final act = SlideAct.fromLeading(motion: customMotion);
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        expect(animtableAct.motion, customMotion);
      });

      test('fromLeading constructor with delay', () {
        final act = SlideAct.fromLeading(delay: 100.ms);
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        expect(animtableAct.delay, 100.ms);
      });

      test('fromLeading constructor with reverse', () {
        const reverse = ReverseBehavior<Offset>.mirror();
        final act = SlideAct.fromLeading(reverse: reverse);
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        expect(animtableAct.reverse, reverse);
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

      test('fromTrailing constructor with motion', () {
        final customMotion = CueMotion.linear(500.ms);
        final act = SlideAct.fromTrailing(motion: customMotion);
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        expect(animtableAct.motion, customMotion);
      });

      test('fromTrailing constructor with delay', () {
        final act = SlideAct.fromTrailing(delay: 100.ms);
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        expect(animtableAct.delay, 100.ms);
      });

      test('fromTrailing constructor with reverse', () {
        const reverse = ReverseBehavior<Offset>.mirror();
        final act = SlideAct.fromTrailing(reverse: reverse);
        final animtableAct = act as AnimtableAct<Offset, Offset>;
        expect(animtableAct.reverse, reverse);
      });

      test('keyframed constructor sets frames', () {
        final frames = FractionalKeyframes<Offset>([
          FKeyframe(const Offset(0, 0), at: 0),
          FKeyframe(const Offset(1, 1), at: 1),
        ]);
        final act = SlideAct.keyframed(frames: frames);
        final tweenAct = act as TweenActBase<Offset, Offset>;
        expect(tweenAct.frames, frames);
      });

      test('keyframed constructor with reverse', () {
        final reverse = KFReverseBehavior<Offset>.mirror();
        final frames = FractionalKeyframes<Offset>([
          FKeyframe(const Offset(0, 0), at: 0),
          FKeyframe(const Offset(1, 1), at: 1),
        ]);
        final act = SlideAct.keyframed(frames: frames, reverse: reverse);
        final tweenAct = act as TweenActBase<Offset, Offset>;
        expect(tweenAct.reverse, reverse);
      });

      test('keyframed constructor with delay', () {
        final frames = FractionalKeyframes<Offset>([
          FKeyframe(const Offset(0, 0), at: 0),
          FKeyframe(const Offset(1, 1), at: 1),
        ]);
        final act = SlideAct.keyframed(frames: frames, delay: 100.ms);
        final tweenAct = act as TweenActBase<Offset, Offset>;
        expect(tweenAct.delay, 100.ms);
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

      test('y constructor with motion', () {
        final customMotion = CueMotion.linear(500.ms);
        final act = SlideAct.y(from: -1, to: 0, motion: customMotion);
        final animtableAct = act as AnimtableAct<double, Offset>;
        expect(animtableAct.motion, customMotion);
      });

      test('y constructor with delay', () {
        final act = SlideAct.y(from: -1, to: 0, delay: 100.ms);
        final animtableAct = act as AnimtableAct<double, Offset>;
        expect(animtableAct.delay, 100.ms);
      });

      test('y constructor with reverse', () {
        const reverse = ReverseBehavior<double>.mirror();
        final act = SlideAct.y(from: -1, to: 0, reverse: reverse);
        final animtableAct = act as AnimtableAct<double, Offset>;
        expect(animtableAct.reverse, reverse);
      });

      test('keyframedY constructor sets frames on Y axis', () {
        final frames = FractionalKeyframes<double>([
          FKeyframe(0.0, at: 0),
          FKeyframe(1.0, at: 1),
        ]);
        final act = SlideAct.keyframedY(frames: frames);
        final tweenAct = act as TweenActBase<double, Offset>;
        expect(tweenAct.frames, frames);
      });

      test('keyframedY constructor with reverse', () {
        final reverse = KFReverseBehavior<double>.mirror();
        final frames = FractionalKeyframes<double>([
          FKeyframe(0.0, at: 0),
          FKeyframe(1.0, at: 1),
        ]);
        final act = SlideAct.keyframedY(frames: frames, reverse: reverse);
        final tweenAct = act as TweenActBase<double, Offset>;
        expect(tweenAct.reverse, reverse);
      });

      test('keyframedY constructor with delay', () {
        final frames = FractionalKeyframes<double>([
          FKeyframe(0.0, at: 0),
          FKeyframe(1.0, at: 1),
        ]);
        final act = SlideAct.keyframedY(frames: frames, delay: 100.ms);
        final tweenAct = act as TweenActBase<double, Offset>;
        expect(tweenAct.delay, 100.ms);
      });

      test('fromX constructor slides on X axis', () {
        final act = SlideAct.x(from: -1, to: 0);
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

      test('fromX constructor with motion', () {
        final customMotion = CueMotion.linear(500.ms);
        final act = SlideAct.x(from: -1, to: 0, motion: customMotion);
        final animtableAct = act as AnimtableAct<double, Offset>;
        expect(animtableAct.motion, customMotion);
      });

      test('fromX constructor with delay', () {
        final act = SlideAct.x(from: -1, to: 0, delay: 100.ms);
        final animtableAct = act as AnimtableAct<double, Offset>;
        expect(animtableAct.delay, 100.ms);
      });

      test('fromX constructor with reverse', () {
        const reverse = ReverseBehavior<double>.mirror();
        final act = SlideAct.x(from: -1, to: 0, reverse: reverse);
        final animtableAct = act as AnimtableAct<double, Offset>;
        expect(animtableAct.reverse, reverse);
      });

      test('keyframedX constructor sets frames on X axis', () {
        final frames = FractionalKeyframes<double>([
          FKeyframe(0.0, at: 0),
          FKeyframe(1.0, at: 1),
        ]);
        final act = SlideAct.keyframedX(frames: frames);
        final tweenAct = act as TweenActBase<double, Offset>;
        expect(tweenAct.frames, frames);
      });

      test('keyframedX constructor with reverse', () {
        final reverse = KFReverseBehavior<double>.mirror();
        final frames = FractionalKeyframes<double>([
          FKeyframe(0.0, at: 0),
          FKeyframe(1.0, at: 1),
        ]);
        final act = SlideAct.keyframedX(frames: frames, reverse: reverse);
        final tweenAct = act as TweenActBase<double, Offset>;
        expect(tweenAct.reverse, reverse);
      });

      test('keyframedX constructor with delay', () {
        final frames = FractionalKeyframes<double>([
          FKeyframe(0.0, at: 0),
          FKeyframe(1.0, at: 1),
        ]);
        final act = SlideAct.keyframedX(frames: frames, delay: 100.ms);
        final tweenAct = act as TweenActBase<double, Offset>;
        expect(tweenAct.delay, 100.ms);
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

    group('axis slide effect equality', () {
      test('equal horizontal axis slide effects have same hashCode', () {
        final act1 = SlideAct.x(from: -1, to: 0);
        final act2 = SlideAct.x(from: -1, to: 0);
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });

      test('equal vertical axis slide effects have same hashCode', () {
        final act1 = SlideAct.y(from: -1, to: 0);
        final act2 = SlideAct.y(from: -1, to: 0);
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });

      test('different axis values are not equal', () {
        final actX = SlideAct.x(from: -1, to: 0);
        final actY = SlideAct.y(from: -1, to: 0);
        expect(actX, isNot(actY));
      });

      test('different from values are not equal', () {
        final act1 = SlideAct.x(from: -1, to: 0);
        final act2 = SlideAct.x(from: -0.5, to: 0);
        expect(act1, isNot(act2));
      });

      test('different to values are not equal', () {
        final act1 = SlideAct.x(from: -1, to: 0);
        final act2 = SlideAct.x(from: -1, to: 0.5);
        expect(act1, isNot(act2));
      });

      test('identical act is equal to itself', () {
        final act = SlideAct.x(from: -1, to: 0);
        expect(act, same(act));
      });
    });

    group('axis slide effect transform', () {
      test('horizontal axis slide produces X-only offsets', () {
        final act = SlideAct.x(from: -1, to: 0);
        final animtableAct = act as AnimtableAct<double, Offset>;
        
        final (animtable, _) = animtableAct.buildTweens(actContext);

        // Test at progress 0.5 to verify transform is applied correctly
        track.setProgress(0.5);

        final animation = CueAnimationImpl<Offset>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        final value = animation.value;
        expect(value.dx, closeTo(-0.5, 0.01)); // Should interpolate between -1 and 0
        expect(value.dy, 0); // Y should always be 0
      });

      test('vertical axis slide produces Y-only offsets', () {
        final act = SlideAct.y(from: -1, to: 0);
        final animtableAct = act as AnimtableAct<double, Offset>;
        
        final (animtable, _) = animtableAct.buildTweens(actContext);

        track.setProgress(0.5);

        final animation = CueAnimationImpl<Offset>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        final value = animation.value;
        expect(value.dx, 0); // X should always be 0
        expect(value.dy, closeTo(-0.5, 0.01)); // Should interpolate between -1 and 0
      });

      test('horizontal axis transforms different values correctly', () {
        final act = SlideAct.x(from: 0.5, to: 1.5);
        final animtableAct = act as AnimtableAct<double, Offset>;
        
        final (animtable, _) = animtableAct.buildTweens(actContext);

        track.setProgress(0);
        final animationStart = CueAnimationImpl<Offset>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animtable,
        );
        expect(animationStart.value.dx, closeTo(0.5, 0.01));
        expect(animationStart.value.dy, 0);

        track.setProgress(1);
        final animationEnd = CueAnimationImpl<Offset>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animtable,
        );
        expect(animationEnd.value.dx, closeTo(1.5, 0.01));
        expect(animationEnd.value.dy, 0);
      });

      testWidgets('horizontal axis slide renders correctly', (tester) async {
        final act = SlideAct.x(from: -1, to: 0);
        final animtableAct = act as AnimtableAct<double, Offset>;
        
        final (animtable, _) = animtableAct.buildTweens(actContext);

        track.setProgress(0.5);

        final animation = CueAnimationImpl<Offset>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return animtableAct.apply(context, animation, const Text('Slide X'));
              },
            ),
          ),
        );

        expect(find.byType(SlideTransition), findsOneWidget);
        expect(find.text('Slide X'), findsOneWidget);
      });

      testWidgets('vertical axis slide renders correctly', (tester) async {
        final act = SlideAct.y(from: -1, to: 0);
        final animtableAct = act as AnimtableAct<double, Offset>;
        
        final (animtable, _) = animtableAct.buildTweens(actContext);

        track.setProgress(0.5);

        final animation = CueAnimationImpl<Offset>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return animtableAct.apply(context, animation, const Text('Slide Y'));
              },
            ),
          ),
        );

        expect(find.byType(SlideTransition), findsOneWidget);
        expect(find.text('Slide Y'), findsOneWidget);
      });

      test('horizontal and vertical slides produce different results', () {
        final actX = SlideAct.x(from: -1, to: 0);
        final actY = SlideAct.y(from: -1, to: 0);
        
        final animtableActX = actX as AnimtableAct<double, Offset>;
        final animtableActY = actY as AnimtableAct<double, Offset>;
        
        final (animtableX, _) = animtableActX.buildTweens(actContext);
        final (animtableY, _) = animtableActY.buildTweens(actContext);

        track.setProgress(0.5);

        final animationX = CueAnimationImpl<Offset>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animtableX,
        );
        
        final animationY = CueAnimationImpl<Offset>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animtableY,
        );

        expect(animationX.value.dx, isNot(0)); // X slide should have non-zero DX
        expect(animationX.value.dy, 0);
        expect(animationY.value.dx, 0);
        expect(animationY.value.dy, isNot(0)); // Y slide should have non-zero DY
      });
    });
  });
}
