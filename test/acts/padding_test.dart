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
  group('PaddingAct', () {
    group('key', () {
      test('has correct key name', () {
        const act = PaddingAct();
        expect(act.key.key, 'Padding');
      });
    });

    group('constructors', () {
      test('default constructor sets from and to', () {
        const act = PaddingAct(
          from: EdgeInsets.all(10),
          to: EdgeInsets.all(20),
        );
        expect(act.from, EdgeInsets.all(10));
        expect(act.to, EdgeInsets.all(20));
      });

      test('default constructor has default zero padding', () {
        const act = PaddingAct();
        expect(act.from, EdgeInsets.zero);
        expect(act.to, EdgeInsets.zero);
      });

      test('constructor accepts motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = PaddingAct(
          from: EdgeInsets.zero,
          to: EdgeInsets.all(20),
          motion: motion,
        );
        expect(act.motion, motion);
      });

      test('constructor accepts delay', () {
        const act = PaddingAct(delay: Duration(milliseconds: 100));
        expect(act.delay, const Duration(milliseconds: 100));
      });

      test('keyframed constructor sets frames', () {
        final frames = FractionalKeyframes<EdgeInsetsGeometry>([
          FKeyframe(EdgeInsets.zero, at: 0.0),
          FKeyframe(EdgeInsets.all(20), at: 1.0),
        ]);
        final act = PaddingAct.keyframed(frames: frames);
        expect(act.frames, frames);
      });
    });

    group('apply', () {
      testWidgets('wraps child in Padding widget', (tester) async {
        const act = PaddingAct(from: EdgeInsets.zero, to: EdgeInsets.all(20));
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0.5);

        final animation = CueAnimationImpl<EdgeInsetsGeometry>(
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

        expect(find.byType(Padding), findsOneWidget);
        expect(find.text('Child'), findsOneWidget);
      });

      testWidgets('applies padding at progress 0', (tester) async {
        const act = PaddingAct(from: EdgeInsets.all(10), to: EdgeInsets.all(20));
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0.0);

        final animation = CueAnimationImpl<EdgeInsetsGeometry>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const SizedBox());
              },
            ),
          ),
        );

        final padding = tester.widget<Padding>(find.byType(Padding));
        expect(padding.padding, EdgeInsets.all(10));
      });

      testWidgets('applies padding at progress 1', (tester) async {
        const act = PaddingAct(from: EdgeInsets.all(10), to: EdgeInsets.all(20));
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(1.0);

        final animation = CueAnimationImpl<EdgeInsetsGeometry>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const SizedBox());
              },
            ),
          ),
        );

        final padding = tester.widget<Padding>(find.byType(Padding));
        expect(padding.padding, EdgeInsets.all(20));
      });

      testWidgets('interpolates padding at progress 0.5', (tester) async {
        const act = PaddingAct(from: EdgeInsets.all(0), to: EdgeInsets.all(20));
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0.5);

        final animation = CueAnimationImpl<EdgeInsetsGeometry>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const SizedBox());
              },
            ),
          ),
        );

        final padding = tester.widget<Padding>(find.byType(Padding));
        expect(padding.padding, EdgeInsets.all(10));
      });

      testWidgets('supports asymmetric EdgeInsets', (tester) async {
        const act = PaddingAct(
          from: EdgeInsets.only(left: 5, top: 10, right: 15, bottom: 20),
          to: EdgeInsets.only(left: 10, top: 20, right: 30, bottom: 40),
        );
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0.5);

        final animation = CueAnimationImpl<EdgeInsetsGeometry>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const SizedBox());
              },
            ),
          ),
        );

        final padding = tester.widget<Padding>(find.byType(Padding));
        expect(
          padding.padding,
          EdgeInsets.only(left: 7.5, top: 15, right: 22.5, bottom: 30),
        );
      });
    });

    group('equality', () {
      test('equal acts have same hashCode', () {
        const act1 = PaddingAct(from: EdgeInsets.all(10), to: EdgeInsets.all(20));
        const act2 = PaddingAct(from: EdgeInsets.all(10), to: EdgeInsets.all(20));
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });

      test('different from values are not equal', () {
        const act1 = PaddingAct(from: EdgeInsets.all(10), to: EdgeInsets.all(20));
        const act2 = PaddingAct(from: EdgeInsets.all(5), to: EdgeInsets.all(20));
        expect(act1, isNot(act2));
      });

      test('different to values are not equal', () {
        const act1 = PaddingAct(from: EdgeInsets.all(10), to: EdgeInsets.all(20));
        const act2 = PaddingAct(from: EdgeInsets.all(10), to: EdgeInsets.all(30));
        expect(act1, isNot(act2));
      });
    });

    group('isConstant', () {
      test('isConstant when from equals to', () {
        const act = PaddingAct(from: EdgeInsets.all(10), to: EdgeInsets.all(10));
        expect(act.isConstant, isTrue);
      });

      test('isConstant is false when from and to differ', () {
        const act = PaddingAct(from: EdgeInsets.zero, to: EdgeInsets.all(20));
        expect(act.isConstant, isFalse);
      });
    });
  });
}
