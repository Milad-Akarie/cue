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

  group('TransformAct', () {
    group('key', () {
      test('has correct key name', () {
        final act = TransformAct(to: Matrix4.identity());
        expect(act.key.key, 'Transform');
      });
    });

    group('default constructor', () {
      test('accepts to', () {
        final to = Matrix4.translationValues(100, 0, 0);
        final act = TransformAct(to: to);
        expect(act.to, to);
      });

      test('default from is identity', () {
        final act = TransformAct(to: Matrix4.identity());
        expect(act.from, Matrix4.identity());
      });

      test('accepts from', () {
        final from = Matrix4.translationValues(0, 0, 0);
        final to = Matrix4.translationValues(100, 0, 0);
        final act = TransformAct(from: from, to: to);
        expect(act.from, from);
      });

      test('accepts alignment', () {
        final act = TransformAct(
          to: Matrix4.identity(),
          alignment: Alignment.center,
        );
        expect(act.alignment, Alignment.center);
      });

      test('accepts origin', () {
        final origin = const Offset(50, 50);
        final act = TransformAct(
          to: Matrix4.identity(),
          origin: origin,
        );
        expect(act.origin, origin);
      });

      test('accepts motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = TransformAct(to: Matrix4.identity(), motion: motion);
        expect(act.motion, motion);
      });

      test('accepts delay', () {
        final act = TransformAct(
          to: Matrix4.identity(),
          delay: const Duration(milliseconds: 100),
        );
        expect(act.delay, const Duration(milliseconds: 100));
      });
    });

    group('keyframed constructor', () {
      test('accepts frames', () {
        final frames = Keyframes<Matrix4>([
          Keyframe(Matrix4.identity()),
          Keyframe(Matrix4.translationValues(100, 0, 0)),
        ] , motion: CueMotion.linear(100.ms));
        final act = TransformAct.keyframed(frames: frames);
        expect(act.frames, frames);
      });
    });

    group('apply', () {
      testWidgets('wraps child in AnimatedBuilder with Transform', (tester) async {
        final to = Matrix4.translationValues(100, 0, 0);
        final act = TransformAct(to: to);

        final (animtable, _) = act.buildTweens(actContext);

        track.setProgress(0.5);

        final animation = CueAnimationImpl<Matrix4>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const Text('Transform'));
              },
            ),
          ),
        );

        expect(find.text('Transform'), findsOneWidget);
      });

      testWidgets('renders with alignment and origin', (tester) async {
        final to = Matrix4.translationValues(50, 50, 0);
        final act = TransformAct(
          to: to,
          alignment: Alignment.center,
          origin: const Offset(10, 10),
        );

        final (animtable, _) = act.buildTweens(actContext);

        track.setProgress(0);

        final animation = CueAnimationImpl<Matrix4>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const Text('Aligned'));
              },
            ),
          ),
        );

        await tester.pump();
        expect(find.text('Aligned'), findsOneWidget);
      });
    });

    group('equality', () {
      test('equal acts have same hashCode', () {
        final to = Matrix4.translationValues(100, 0, 0);
        final act1 = TransformAct(to: to, alignment: Alignment.center);
        final act2 = TransformAct(to: to, alignment: Alignment.center);
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });

      test('different alignments are not equal', () {
        final to = Matrix4.translationValues(100, 0, 0);
        final act1 = TransformAct(to: to, alignment: Alignment.center);
        final act2 = TransformAct(to: to, alignment: Alignment.topLeft);
        expect(act1, isNot(act2));
      });

      test('different origins are not equal', () {
        final to = Matrix4.translationValues(100, 0, 0);
        final act1 = TransformAct(to: to, origin: const Offset(10, 10));
        final act2 = TransformAct(to: to, origin: const Offset(20, 20));
        expect(act1, isNot(act2));
      });
    });
  });

  group('SkewAct', () {
    group('key', () {
      test('has correct key name', () {
        final act = SkewAct(from: Skew.zero, to: Skew(x: 0.1, y: 0));
        expect(act.key.key, 'Transform:Skew');
      });
    });

    group('default constructor', () {
      test('accepts from and to', () {
        final from = Skew.zero;
        final to = Skew(x: 0.1, y: 0.2);
        final act = SkewAct(from: from, to: to);
        expect(act.from, from);
        expect(act.to, to);
      });

      test('default from and to are Skew.zero', () {
        final act = SkewAct();
        expect(act.from, Skew.zero);
        expect(act.to, Skew.zero);
      });

      test('accepts alignment', () {
        final act = SkewAct(alignment: Alignment.center);
        expect(act.alignment, Alignment.center);
      });

      test('accepts origin', () {
        final origin = const Offset(50, 50);
        final act = SkewAct(origin: origin);
        expect(act.origin, origin);
      });

      test('accepts motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = SkewAct(motion: motion);
        expect(act.motion, motion);
      });

      test('accepts delay', () {
        final act = SkewAct(delay: const Duration(milliseconds: 100));
        expect(act.delay, const Duration(milliseconds: 100));
      });
    });

    group('keyframed constructor', () {
      test('accepts frames', () {
        final frames = Keyframes<Skew>([
          Keyframe(Skew.zero),
          Keyframe(Skew(x: 0.1, y: 0)),
        ] , motion: CueMotion.linear(100.ms));
        final act = SkewAct.keyframed(frames: frames);
        expect(act.frames, frames);
      });
    });

    group('apply', () {
      testWidgets('wraps child in AnimatedBuilder with Transform', (tester) async {
        final act = SkewAct(from: Skew.zero, to: Skew(x: 0.1, y: 0.1));

        final (animtable, _) = act.buildTweens(actContext);

        track.setProgress(0.5);

        final animation = CueAnimationImpl<Matrix4>(
          parent: track,
          token: ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const Text('Skew'));
              },
            ),
          ),
        );

        expect(find.text('Skew'), findsOneWidget);
      });
    });

    group('resolve', () {
      test('returns ActContext with motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = SkewAct(motion: motion);

        final resolved = act.resolve(actContext);
        expect(resolved.motion, isNotNull);
      });
    });
  });

  group('Skew', () {
    group('constructors', () {
      test('default values are 0', () {
        const skew = Skew();
        expect(skew.x, 0);
        expect(skew.y, 0);
      });

      test('accepts x and y', () {
        const skew = Skew(x: 0.1, y: 0.2);
        expect(skew.x, 0.1);
        expect(skew.y, 0.2);
      });

      test('symmetric sets both axes', () {
        const skew = Skew.symmetric(0.15);
        expect(skew.x, 0.15);
        expect(skew.y, 0.15);
      });

      test('zero constant', () {
        expect(Skew.zero.x, 0);
        expect(Skew.zero.y, 0);
      });
    });

    group('equality', () {
      test('equal skews have same hashCode', () {
        const skew1 = Skew(x: 0.1, y: 0.2);
        const skew2 = Skew(x: 0.1, y: 0.2);
        expect(skew1, skew2);
        expect(skew1.hashCode, skew2.hashCode);
      });

      test('different x values are not equal', () {
        const skew1 = Skew(x: 0.1, y: 0.2);
        const skew2 = Skew(x: 0.3, y: 0.2);
        expect(skew1, isNot(skew2));
      });

      test('different y values are not equal', () {
        const skew1 = Skew(x: 0.1, y: 0.2);
        const skew2 = Skew(x: 0.1, y: 0.3);
        expect(skew1, isNot(skew2));
      });
    });

    group('toString', () {
      test('returns formatted string', () {
        const skew = Skew(x: 0.1, y: 0.2);
        expect(skew.toString(), 'Skew(x: 0.1, y: 0.2)');
      });
    });
  });
}
