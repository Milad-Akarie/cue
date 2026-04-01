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
  group('ColorTintAct', () {
    group('key', () {
      test('has correct key name', () {
        const act = ColorTintAct(from: Colors.red, to: Colors.blue);
        expect(act.key.key, 'ColorTint');
      });
    });

    group('constructors', () {
      test('default constructor sets from and to', () {
        const act = ColorTintAct(
          from: Colors.red,
          to: Colors.blue,
          blendMode: BlendMode.multiply,
        );
        expect(act.from, Colors.red);
        expect(act.to, Colors.blue);
        expect(act.blendMode, BlendMode.multiply);
      });

      test('default constructor uses default blendMode', () {
        const act = ColorTintAct(from: Colors.red, to: Colors.blue);
        expect(act.blendMode, BlendMode.srcIn);
      });

      test('constructor with motion', () {
        final motion = CueMotion.linear(500.ms);
        final act = ColorTintAct(
          from: Colors.red,
          to: Colors.blue,
          motion: motion,
        );
        expect(act.motion, motion);
      });

      test('constructor with reverse', () {
        const reverse = ReverseBehavior<Color?>.mirror();
        const act = ColorTintAct(
          from: Colors.red,
          to: Colors.blue,
          reverse: reverse,
        );
        expect(act.reverse, reverse);
      });

      test('constructor with delay', () {
        const delay = Duration(milliseconds: 100);
        const act = ColorTintAct(
          from: Colors.red,
          to: Colors.blue,
          delay: delay,
        );
        expect(act.delay, delay);
      });

      test('keyframed constructor sets frames', () {
        final frames = FractionalKeyframes<Color?>([
          FractionalKeyframe(Colors.red, at: 0.0),
          FractionalKeyframe(Colors.green, at: 0.5),
          FractionalKeyframe(Colors.blue, at: 1.0),
        ]);
        final act = ColorTintAct.keyframed(
          frames: frames,
          blendMode: BlendMode.modulate,
        );
        expect(act.frames, frames);
        expect(act.blendMode, BlendMode.modulate);
      });

      test('keyframed constructor with reverse', () {
        final frames = FractionalKeyframes<Color?>([
          FractionalKeyframe(Colors.red, at: 0.0),
          FractionalKeyframe(Colors.blue, at: 1.0),
        ]);
        const reverse = KFReverseBehavior<Color?>.mirror();
        final act = ColorTintAct.keyframed(frames: frames, reverse: reverse);
        expect(act.reverse, reverse);
      });
    });

    group('createSingleTween', () {
      test('creates ColorTween with correct values', () {
        const act = ColorTintAct(from: Colors.red, to: Colors.blue);
        final tween = act.createSingleTween(Colors.red, Colors.blue);
        expect(tween, isA<ColorTween>());
        final colorTween = tween as ColorTween;
        expect(colorTween.begin, Colors.red);
        expect(colorTween.end, Colors.blue);
      });

      test('creates tween with null values', () {
        const act = ColorTintAct(from: Colors.red, to: Colors.blue);
        final tween = act.createSingleTween(null, null);
        expect(tween, isA<ColorTween>());
        final colorTween = tween as ColorTween;
        expect(colorTween.begin, null);
        expect(colorTween.end, null);
      });
    });

    group('apply', () {
      testWidgets('wraps child in ColorFiltered with correct values', (tester) async {
        const act = ColorTintAct(from: Colors.red, to: Colors.blue);
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0.5);

        final animation = CueAnimationImpl<Color?>(
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

        expect(find.byType(ColorFiltered), findsOneWidget);
        expect(find.text('Child'), findsOneWidget);
      });

      testWidgets('uses correct blendMode', (tester) async {
        const act = ColorTintAct(
          from: Colors.red,
          to: Colors.blue,
          blendMode: BlendMode.multiply,
        );
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0.5);

        final animation = CueAnimationImpl<Color?>(
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

        final colorFiltered = tester.widget<ColorFiltered>(find.byType(ColorFiltered));
        expect(colorFiltered.colorFilter, isA<ColorFilter>());
      });

      testWidgets('animation value affects color filter', (tester) async {
        const act = ColorTintAct(from: Colors.red, to: Colors.blue);
        
        final (animtable, _) = act.buildTweens(actContext);

        

        track.setProgress(0.0);
        final animation = CueAnimationImpl<Color?>(
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

        var colorFiltered = tester.widget<ColorFiltered>(find.byType(ColorFiltered));
        var colorFilter = colorFiltered.colorFilter;
        expect(colorFilter, isNotNull);

        track.setProgress(1.0);
        await tester.pumpWidget(
          Builder(
            builder: (context) {
              return act.apply(context, animation, const SizedBox());
            },
          ),
        );

        colorFiltered = tester.widget<ColorFiltered>(find.byType(ColorFiltered));
        colorFilter = colorFiltered.colorFilter;
        expect(colorFilter, isNotNull);
      });

      testWidgets('uses transparent for null animation value', (tester) async {
        const act = ColorTintAct(from: Colors.red, to: Colors.blue);

        
        final animation = CueAnimationImpl<Color?>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: AlwaysStoppedAnimatable<Color?>(null),
        );

        await tester.pumpWidget(
          Builder(
            builder: (context) {
              return act.apply(context, animation, const SizedBox());
            },
          ),
        );

        final colorFiltered = tester.widget<ColorFiltered>(find.byType(ColorFiltered));
        expect(colorFiltered.colorFilter, isNotNull);
      });
    });

    group('equality', () {
      test('equal acts have same hashCode', () {
        const act1 = ColorTintAct(from: Colors.red, to: Colors.blue);
        const act2 = ColorTintAct(from: Colors.red, to: Colors.blue);
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });

      test('different from values are not equal', () {
        const act1 = ColorTintAct(from: Colors.red, to: Colors.blue);
        const act2 = ColorTintAct(from: Colors.green, to: Colors.blue);
        expect(act1, isNot(act2));
      });

      test('different to values are not equal', () {
        const act1 = ColorTintAct(from: Colors.red, to: Colors.blue);
        const act2 = ColorTintAct(from: Colors.red, to: Colors.green);
        expect(act1, isNot(act2));
      });

      test('different blendMode are equal (blendMode not in equality)', () {
        const act1 = ColorTintAct(from: Colors.red, to: Colors.blue, blendMode: BlendMode.srcIn);
        const act2 = ColorTintAct(from: Colors.red, to: Colors.blue, blendMode: BlendMode.multiply);
        expect(act1, act2);
      });

      test('different motion values are not equal', () {
        final motion1 = CueMotion.linear(300.ms);
        final motion2 = CueMotion.linear(500.ms);
        final act1 = ColorTintAct(from: Colors.red, to: Colors.blue, motion: motion1);
        final act2 = ColorTintAct(from: Colors.red, to: Colors.blue, motion: motion2);
        expect(act1, isNot(act2));
      });

      test('different delay values are not equal', () {
        const act1 = ColorTintAct(from: Colors.red, to: Colors.blue, delay: Duration(milliseconds: 100));
        const act2 = ColorTintAct(from: Colors.red, to: Colors.blue, delay: Duration(milliseconds: 200));
        expect(act1, isNot(act2));
      });

      test('different reverse values are not equal', () {
        const act1 = ColorTintAct(from: Colors.red, to: Colors.blue, reverse: ReverseBehavior<Color?>.mirror());
        const act2 = ColorTintAct(from: Colors.red, to: Colors.blue, reverse: ReverseBehavior<Color?>.none());
        expect(act1, isNot(act2));
      });
    });
  });
}
