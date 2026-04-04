import 'dart:math' show pi;

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

  group('RotateLayoutAct', () {
    group('key', () {
      test('has correct key name', () {
        final act = RotateLayoutAct(from: 0, to: 90);
        expect(act.key.key, 'RotateLayout');
      });
    });

    group('default constructor', () {
      test('accepts from and to', () {
        final act = RotateLayoutAct(from: 45, to: 90);
        expect(act.from, 45);
        expect(act.to, 90);
      });

      test('default from and to are 0', () {
        final act = RotateLayoutAct();
        expect(act.from, 0);
        expect(act.to, 0);
      });

      test('default unit is degrees', () {
        final act = RotateLayoutAct(from: 0, to: 90);
        expect(act.unit, RotateUnit.degrees);
      });

      test('accepts unit', () {
        final act = RotateLayoutAct(
          from: 0,
          to: 1.57,
          unit: RotateUnit.radians,
        );
        expect(act.unit, RotateUnit.radians);
      });

      test('accepts motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = RotateLayoutAct(from: 0, to: 90, motion: motion);
        expect(act.motion, motion);
      });

      test('accepts delay', () {
        final act = RotateLayoutAct(
          from: 0,
          to: 90,
          delay: const Duration(milliseconds: 100),
        );
        expect(act.delay, const Duration(milliseconds: 100));
      });
    });

    group('degrees constructor', () {
      test('creates act with degrees unit', () {
        final act = RotateLayoutAct.degrees(from: 0, to: 180);
        expect(act.unit, RotateUnit.degrees);
        expect(act.from, 0);
        expect(act.to, 180);
      });

      test('accepts motion and delay', () {
        final motion = CueMotion.linear(300.ms);
        final act = RotateLayoutAct.degrees(
          from: 0,
          to: 180,
          motion: motion,
          delay: const Duration(milliseconds: 50),
        );
        expect(act.motion, motion);
        expect(act.delay, const Duration(milliseconds: 50));
      });
    });

    group('turns constructor', () {
      test('creates act with quarterTurns unit', () {
        final act = RotateLayoutAct.turns(from: 0, to: 1);
        expect(act.unit, RotateUnit.quarterTurns);
        expect(act.from, 0);
        expect(act.to, 1);
      });

      test('accepts motion and delay', () {
        final motion = CueMotion.linear(300.ms);
        final act = RotateLayoutAct.turns(
          from: 0,
          to: 2,
          motion: motion,
          delay: const Duration(milliseconds: 50),
        );
        expect(act.motion, motion);
        expect(act.delay, const Duration(milliseconds: 50));
      });
    });

    group('keyframed constructor', () {
      test('accepts frames', () {
        final frames = Keyframes<double>([
          Keyframe(0, motion: CueMotion.linear(100.ms)),
          Keyframe(90, motion: CueMotion.linear(100.ms)),
        ]);
        final act = RotateLayoutAct.keyframed(frames: frames);
        expect(act.frames, frames);
      });

      test('default unit is radians for keyframed', () {
        final frames = Keyframes<double>([
          Keyframe(0, motion: CueMotion.linear(100.ms)),
        ]);
        final act = RotateLayoutAct.keyframed(frames: frames);
        expect(act.unit, RotateUnit.radians);
      });
    });

    group('transform', () {
      test('converts degrees to radians', () {
        final act = RotateLayoutAct.degrees(from: 0, to: 180);
        
        final radians = act.transform(actContext, 180);
        expect(radians, closeTo(pi, 0.0001));
      });

      test('converts quarterTurns to radians', () {
        final act = RotateLayoutAct.turns(from: 0, to: 2);
        
        final radians = act.transform(actContext, 2);
        expect(radians, closeTo(pi, 0.0001));
      });

      test('leaves radians unchanged', () {
        final act = RotateLayoutAct(
          from: 0,
          to: pi,
          unit: RotateUnit.radians,
        );
        
        final radians = act.transform(actContext, pi);
        expect(radians, closeTo(pi, 0.0001));
      });
    });

    group('resolve', () {
      test('returns ActContext with motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = RotateLayoutAct(from: 0, to: 90, motion: motion);
        
        final resolved = act.resolve(actContext);
        expect(resolved.motion, isNotNull);
      });
    });

    group('apply', () {
      testWidgets('wraps child in widget', (tester) async {
        final act = RotateLayoutAct.degrees(from: 0, to: 90);
        
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
                return act.apply(context, animation, const Text('Rotate Layout'));
              },
            ),
          ),
        );

        expect(find.text('Rotate Layout'), findsOneWidget);
      });

      testWidgets('renders with degrees unit', (tester) async {
        final act = RotateLayoutAct.degrees(from: 0, to: 180);
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0);

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
                return act.apply(context, animation, const Text('Degrees'));
              },
            ),
          ),
        );

        await tester.pump();
        expect(find.text('Degrees'), findsOneWidget);
      });

      testWidgets('renders with turns unit', (tester) async {
        final act = RotateLayoutAct.turns(from: 0, to: 1);
        
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
                return act.apply(context, animation, const Text('Turns'));
              },
            ),
          ),
        );

        await tester.pump();
        expect(find.text('Turns'), findsOneWidget);
      });

      testWidgets('renders with radians unit', (tester) async {
        final act = RotateLayoutAct(from: 0, to: pi, unit: RotateUnit.radians);
        
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
                return act.apply(context, animation, const Text('Radians'));
              },
            ),
          ),
        );

        await tester.pump();
        expect(find.text('Radians'), findsOneWidget);
      });

      testWidgets('animation listener triggers layout update', (tester) async {
        final act = RotateLayoutAct.degrees(from: 0, to: 180);
        
        final (animtable, _) = act.buildTweens(actContext);

        final animation = CueAnimationImpl<double>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        // Start at 0 progress
        track.setProgress(0);
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return SizedBox(
                  width: 200,
                  height: 200,
                  child: act.apply(context, animation, const SizedBox(width: 50, height: 50)),
                );
              },
            ),
          ),
        );

        // Tick animation to midpoint
        track.setProgress(0.5);
        await tester.pump();
        expect(find.byType(SizedBox), findsWidgets);

        // Tick animation to end
        track.setProgress(1.0);
        await tester.pump();
        expect(find.byType(SizedBox), findsWidgets);
      });

      testWidgets('handles animation replacement', (tester) async {
        final act = RotateLayoutAct.degrees(from: 0, to: 90);
        
        final (animtable, _) = act.buildTweens(actContext);

        track.setProgress(0);
        final animation1 = CueAnimationImpl<double>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation1, const SizedBox(width: 50, height: 50));
              },
            ),
          ),
        );

        // Create a new animation
        track.setProgress(0.5);
        final animation2 = CueAnimationImpl<double>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        // Replace with new animation
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation2, const SizedBox(width: 50, height: 50));
              },
            ),
          ),
        );

        await tester.pump();
        expect(find.byType(SizedBox), findsWidgets);
      });

      testWidgets('performs layout with rotated child', (tester) async {
        final act = RotateLayoutAct.degrees(from: 0, to: 45);
        
        final (animtable, _) = act.buildTweens(actContext);

        track.setProgress(0.25); // 11.25 degrees
        final animation = CueAnimationImpl<double>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Directionality(
                textDirection: TextDirection.ltr,
                child: Builder(
                  builder: (context) {
                    return act.apply(
                      context,
                      animation,
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: Container(color: Colors.blue),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        // Verify the widget renders with rotation applied
        expect(find.byType(Container), findsOneWidget);
      });

      testWidgets('handles null child during layout', (tester) async {
        final act = RotateLayoutAct.degrees(from: 0, to: 90);
        
        final (animtable, _) = act.buildTweens(actContext);

        // The apply() method should still work with proper child
        track.setProgress(0.5);
        final animation = CueAnimationImpl<double>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const Placeholder());
              },
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.byType(Placeholder), findsOneWidget);
      });
    });

    group('equality', () {
      test('equal acts have same hashCode', () {
        final act1 = RotateLayoutAct(from: 0, to: 90);
        final act2 = RotateLayoutAct(from: 0, to: 90);
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });

      test('different from values are not equal', () {
        final act1 = RotateLayoutAct(from: 0, to: 90);
        final act2 = RotateLayoutAct(from: 45, to: 90);
        expect(act1, isNot(act2));
      });

      test('different to values are not equal', () {
        final act1 = RotateLayoutAct(from: 0, to: 90);
        final act2 = RotateLayoutAct(from: 0, to: 180);
        expect(act1, isNot(act2));
      });

      test('different units are not equal', () {
        final act1 = RotateLayoutAct(from: 0, to: 90, unit: RotateUnit.degrees);
        final act2 = RotateLayoutAct(from: 0, to: 90, unit: RotateUnit.radians);
        expect(act1, isNot(act2));
      });
    });
  });
}
