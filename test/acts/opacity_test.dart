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

  group('OpacityAct', () {
    group('key', () {
      test('has correct key name', () {
        const act = OpacityAct(to: 0.0);
        expect(act.key.key, 'Opacity');
      });
    });

    group('constructors', () {
      test('default constructor sets from and to', () {
        const act = OpacityAct(from: 0.5, to: 0.0);
        expect(act.from, 0.5);
        expect(act.to, 0.0);
      });

      test('default constructor uses default from', () {
        const act = OpacityAct(to: 0.0);
        expect(act.from, 1.0);
      });

      test('fadeIn constructor', () {
        const act = OpacityAct.fadeIn();
        expect(act.from, 0.0);
        expect(act.to, 1.0);
      });

      test('fadeIn constructor with custom motion', () {
        final motion = CueMotion.linear(500.ms);
        final act = OpacityAct.fadeIn(motion: motion);
        expect(act.motion, motion);
      });

      test('fadeIn constructor with custom values', () {
        const act = OpacityAct.fadeIn(from: 0.2, to: 0.8);
        expect(act.from, 0.2);
        expect(act.to, 0.8);
      });

      test('fadeOut constructor', () {
        const act = OpacityAct.fadeOut();
        expect(act.from, 1.0);
        expect(act.to, 0.0);
      });

      test('fadeOut constructor with custom motion', () {
        final motion = CueMotion.linear(500.ms);
        final act = OpacityAct.fadeOut(motion: motion);
        expect(act.motion, motion);
      });

      test('fadeOut constructor with custom values', () {
        const act = OpacityAct.fadeOut(from: 0.9, to: 0.1);
        expect(act.from, 0.9);
        expect(act.to, 0.1);
      });

      test('constructor with motion', () {
        final motion = CueMotion.linear(500.ms);
        final act = OpacityAct(to: 0.0, motion: motion);
        expect(act.motion, motion);
      });

      test('constructor with reverse', () {
        const reverse = ReverseBehavior<double>.mirror();
        const act = OpacityAct(to: 0.0, reverse: reverse);
        expect(act.reverse, reverse);
      });

      test('constructor with delay', () {
        const delay = Duration(milliseconds: 100);
        const act = OpacityAct(to: 0.0, delay: delay);
        expect(act.delay, delay);
      });

      test('keyframed constructor sets frames', () {
        final frames = FractionalKeyframes<double>([
          FractionalKeyframe(1.0, at: 0.0),
          FractionalKeyframe(0.5, at: 0.5),
          FractionalKeyframe(0.0, at: 1.0),
        ]);
        final act = OpacityAct.keyframed(frames: frames);
        expect(act.frames, frames);
      });

      test('keyframed constructor with reverse', () {
        final frames = FractionalKeyframes<double>([
          FractionalKeyframe(1.0, at: 0.0),
          FractionalKeyframe(0.0, at: 1.0),
        ]);
        const reverse = KFReverseBehavior<double>.mirror();
        final act = OpacityAct.keyframed(frames: frames, reverse: reverse);
        expect(act.reverse, reverse);
      });
    });

    group('apply', () {
      testWidgets('wraps child in FadeTransition', (tester) async {
        const act = OpacityAct(from: 1.0, to: 0.0);
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0.5);

        final animation = CueAnimationImpl<double>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const Text('Child'));
              },
            ),
          ),
        );

        expect(find.byType(FadeTransition), findsOneWidget);
        expect(find.text('Child'), findsOneWidget);
      });

      testWidgets('FadeTransition uses animation', (tester) async {
        const act = OpacityAct(from: 1.0, to: 0.0);
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0.5);

        final animation = CueAnimationImpl<double>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Builder(
            builder: (context) {
              return act.apply(context, animation, const SizedBox());
            },
          ),
        );

        final fadeTransition = tester.widget<FadeTransition>(find.byType(FadeTransition));
        expect(fadeTransition.opacity, animation);
      });

      testWidgets('animation value affects opacity at start', (tester) async {
        const act = OpacityAct(from: 1.0, to: 0.0);
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0.0);

        final animation = CueAnimationImpl<double>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Builder(
            builder: (context) {
              return act.apply(context, animation, const SizedBox());
            },
          ),
        );

        expect(animation.value, 1.0);
      });

      testWidgets('animation value affects opacity at end', (tester) async {
        const act = OpacityAct(from: 1.0, to: 0.0);
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(1.0);

        final animation = CueAnimationImpl<double>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Builder(
            builder: (context) {
              return act.apply(context, animation, const SizedBox());
            },
          ),
        );

        expect(animation.value, 0.0);
      });
    });

    group('equality', () {
      test('equal acts have same hashCode', () {
        const act1 = OpacityAct(from: 0.5, to: 0.0);
        const act2 = OpacityAct(from: 0.5, to: 0.0);
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });

      test('different from values are not equal', () {
        const act1 = OpacityAct(from: 0.5, to: 0.0);
        const act2 = OpacityAct(from: 0.8, to: 0.0);
        expect(act1, isNot(act2));
      });

      test('different to values are not equal', () {
        const act1 = OpacityAct(from: 0.5, to: 0.0);
        const act2 = OpacityAct(from: 0.5, to: 0.3);
        expect(act1, isNot(act2));
      });

      test('different motion values are not equal', () {
        final motion1 = CueMotion.linear(300.ms);
        final motion2 = CueMotion.linear(500.ms);
        final act1 = OpacityAct(to: 0.0, motion: motion1);
        final act2 = OpacityAct(to: 0.0, motion: motion2);
        expect(act1, isNot(act2));
      });

      test('different delay values are not equal', () {
        const act1 = OpacityAct(to: 0.0, delay: Duration(milliseconds: 100));
        const act2 = OpacityAct(to: 0.0, delay: Duration(milliseconds: 200));
        expect(act1, isNot(act2));
      });

      test('different reverse values are not equal', () {
        const act1 = OpacityAct(to: 0.0, reverse: ReverseBehavior<double>.mirror());
        const act2 = OpacityAct(to: 0.0, reverse: ReverseBehavior<double>.none());
        expect(act1, isNot(act2));
      });
    });

    group('isConstant', () {
      test('isConstant when from equals to', () {
        const act = OpacityAct(from: 0.5, to: 0.5);
        expect(act.isConstant, isTrue);
      });

      test('isConstant is false when from and to differ', () {
        const act = OpacityAct(from: 1.0, to: 0.0);
        expect(act.isConstant, isFalse);
      });
    });
  });
}
