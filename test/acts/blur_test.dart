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

  group('BlurAct', () {
    test('key is "Blur"', () {
      const act = BlurAct();
      expect(act.key.key, equals('Blur'));
    });

    test('default from and to are 0.0', () {
      const act = BlurAct();
      expect(act.from, equals(0.0));
      expect(act.to, equals(0.0));
    });

    test('constructor with custom from and to', () {
      const act = BlurAct(from: 5.0, to: 10.0);
      expect(act.from, equals(5.0));
      expect(act.to, equals(10.0));
    });

    test('constructor with motion', () {
      final motion = CueMotion.linear(500.ms);
      final act = BlurAct(from: 0.0, to: 10.0, motion: motion);
      expect(act.motion, equals(motion));
    });

    test('constructor with delay', () {
      const act = BlurAct(delay: Duration(milliseconds: 200));
      expect(act.delay, equals(const Duration(milliseconds: 200)));
    });

    test('focus constructor defaults', () {
      const act = BlurAct.focus();
      expect(act.from, equals(10.0));
      expect(act.to, equals(0.0));
    });

    test('focus constructor with custom values', () {
      const act = BlurAct.focus(from: 20.0,);
      expect(act.from, equals(20.0));
    });

    test('focus constructor with motion', () {
      final motion = CueMotion.linear(500.ms);
      final act = BlurAct.focus(motion: motion);
      expect(act.motion, equals(motion));
      expect(act.from, equals(10.0));
      expect(act.to, equals(0.0));
    });

    test('focus constructor with reverse', () {
      const reverse = ReverseBehavior<double>.mirror();
      const act = BlurAct.focus(reverse: reverse);
      expect(act.reverse, equals(reverse));
      expect(act.from, equals(10.0));
      expect(act.to, equals(0.0));
    });

    test('focus constructor with delay', () {
      const delay = Duration(milliseconds: 150);
      const act = BlurAct.focus(delay: delay);
      expect(act.delay, equals(delay));
      expect(act.from, equals(10.0));
      expect(act.to, equals(0.0));
    });

    test('focus constructor with all parameters', () {
      final motion = CueMotion.linear(500.ms);
      const delay = Duration(milliseconds: 150);
      const reverse = ReverseBehavior<double>.mirror();
      final act = BlurAct.focus(
        from: 15.0,
        motion: motion,
        reverse: reverse,
        delay: delay,
      );
      expect(act.from, equals(15.0));
      expect(act.to, equals(0.0));
      expect(act.motion, equals(motion));
      expect(act.reverse, equals(reverse));
      expect(act.delay, equals(delay));
    });

    test('unfocus constructor defaults', () {
      const act = BlurAct.unfocus();
      expect(act.from, equals(0.0));
      expect(act.to, equals(10.0));
    });

    test('unfocus constructor with custom values', () {
      const act = BlurAct.unfocus(to: 20.0);
      expect(act.to, equals(20.0));
    });

    test('unfocus constructor with motion', () {
      final motion = CueMotion.linear(500.ms);
      final act = BlurAct.unfocus(motion: motion);
      expect(act.motion, equals(motion));
      expect(act.from, equals(0.0));
      expect(act.to, equals(10.0));
    });

    test('unfocus constructor with reverse', () {
      const reverse = ReverseBehavior<double>.mirror();
      const act = BlurAct.unfocus(reverse: reverse);
      expect(act.reverse, equals(reverse));
      expect(act.from, equals(0.0));
      expect(act.to, equals(10.0));
    });

    test('unfocus constructor with delay', () {
      const delay = Duration(milliseconds: 150);
      const act = BlurAct.unfocus(delay: delay);
      expect(act.delay, equals(delay));
      expect(act.from, equals(0.0));
      expect(act.to, equals(10.0));
    });

    test('unfocus constructor with all parameters', () {
      final motion = CueMotion.linear(500.ms);
      const delay = Duration(milliseconds: 150);
      const reverse = ReverseBehavior<double>.mirror();
      final act = BlurAct.unfocus(
        to: 15.0,
        motion: motion,
        reverse: reverse,
        delay: delay,
      );
      expect(act.from, equals(0.0));
      expect(act.to, equals(15.0));
      expect(act.motion, equals(motion));
      expect(act.reverse, equals(reverse));
      expect(act.delay, equals(delay));
    });

    test('keyframed constructor', () {
      final frames = FractionalKeyframes<double>([
        FKeyframe(0.0, at: 0.0),
        FKeyframe(10.0, at: 1.0),
      ]);
      final act = BlurAct.keyframed(frames: frames);
      expect(act.frames, equals(frames));
    });

    testWidgets('apply wraps child in ImageFiltered', (tester) async {
      const act = BlurAct(from: 0.0, to: 10.0);
      final (animtable, _) = act.buildTweens(actContext);

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
            builder: (context) => act.apply(context, animation, const SizedBox()),
          ),
        ),
      );

      expect(find.byType(ImageFiltered), findsOneWidget);
    });

    testWidgets('apply uses animation value for blur', (tester) async {
      const act = BlurAct(from: 0.0, to: 10.0);
      final (animtable, _) = act.buildTweens(actContext);

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
            builder: (context) => act.apply(context, animation, const SizedBox()),
          ),
        ),
      );

      final imageFiltered = tester.widget<ImageFiltered>(find.byType(ImageFiltered));
      expect(imageFiltered.imageFilter, isNotNull);
    });

    test('equality', () {
      const act1 = BlurAct(from: 0.0, to: 10.0, delay: Duration(milliseconds: 100));
      const act2 = BlurAct(from: 0.0, to: 10.0, delay: Duration(milliseconds: 100));
      const act3 = BlurAct(from: 0.0, to: 5.0);

      expect(act1, equals(act2));
      expect(act1, isNot(equals(act3)));
    });

    test('hashCode consistency', () {
      const act1 = BlurAct(from: 0.0, to: 10.0);
      const act2 = BlurAct(from: 0.0, to: 10.0);

      expect(act1.hashCode, equals(act2.hashCode));
    });

    test('isConstant when from equals to', () {
      const act = BlurAct(from: 5.0, to: 5.0);
      expect(act.isConstant, isTrue);
    });

    test('isConstant is false when from and to differ', () {
      const act = BlurAct(from: 0.0, to: 10.0);
      expect(act.isConstant, isFalse);
    });
  });

  group('BackdropBlurAct', () {
    test('key is "BackdropBlur"', () {
      const act = BackdropBlurAct();
      expect(act.key.key, equals('BackdropBlur'));
    });

    test('default from and to are 0.0', () {
      const act = BackdropBlurAct();
      expect(act.from, equals(0.0));
      expect(act.to, equals(0.0));
    });

    test('default blendMode is srcOver', () {
      const act = BackdropBlurAct();
      expect(act.blendMode, equals(BlendMode.srcOver));
    });

    test('constructor with custom from and to', () {
      const act = BackdropBlurAct(from: 5.0, to: 10.0);
      expect(act.from, equals(5.0));
      expect(act.to, equals(10.0));
    });

    test('constructor with custom blendMode', () {
      const act = BackdropBlurAct(blendMode: BlendMode.multiply);
      expect(act.blendMode, equals(BlendMode.multiply));
    });

    test('constructor with motion', () {
      final motion = CueMotion.linear(500.ms);
      final act = BackdropBlurAct(from: 0.0, to: 10.0, motion: motion);
      expect(act.motion, equals(motion));
    });

    test('constructor with delay', () {
      const act = BackdropBlurAct(delay: Duration(milliseconds: 200));
      expect(act.delay, equals(const Duration(milliseconds: 200)));
    });

    test('keyframed constructor', () {
      final frames = FractionalKeyframes<double>([
        FKeyframe(0.0, at: 0.0),
        FKeyframe(10.0, at: 1.0),
      ]);
      final act = BackdropBlurAct.keyframed(frames: frames);
      expect(act.frames, equals(frames));
    });

    test('keyframed constructor with custom blendMode', () {
      final frames = FractionalKeyframes<double>([
        FKeyframe(0.0, at: 0.0),
        FKeyframe(10.0, at: 1.0),
      ]);
      final act = BackdropBlurAct.keyframed(frames: frames, blendMode: BlendMode.screen);
      expect(act.blendMode, equals(BlendMode.screen));
    });

    testWidgets('apply wraps child in BackdropFilter', (tester) async {
      const act = BackdropBlurAct(from: 0.0, to: 10.0);
      final (animtable, _) = act.buildTweens(actContext);

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
            builder: (context) => act.apply(context, animation, const SizedBox()),
          ),
        ),
      );

      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('apply uses animation value for blur', (tester) async {
      const act = BackdropBlurAct(from: 0.0, to: 10.0);
      final (animtable, _) = act.buildTweens(actContext);

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
            builder: (context) => act.apply(context, animation, const SizedBox()),
          ),
        ),
      );

      final backdropFilter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      expect(backdropFilter.blendMode, equals(BlendMode.srcOver));
      expect(backdropFilter.filter, isNotNull);
    });

    testWidgets('apply uses custom blendMode', (tester) async {
      const act = BackdropBlurAct(from: 0.0, to: 10.0, blendMode: BlendMode.multiply);
      final (animtable, _) = act.buildTweens(actContext);

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
            builder: (context) => act.apply(context, animation, const SizedBox()),
          ),
        ),
      );

      final backdropFilter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
      expect(backdropFilter.blendMode, equals(BlendMode.multiply));
    });

    test('equality', () {
      const act1 = BackdropBlurAct(from: 0.0, to: 10.0, delay: Duration(milliseconds: 100));
      const act2 = BackdropBlurAct(from: 0.0, to: 10.0, delay: Duration(milliseconds: 100));
      const act3 = BackdropBlurAct(from: 0.0, to: 5.0);

      expect(act1, equals(act2));
      expect(act1, isNot(equals(act3)));
    });

    test('hashCode consistency', () {
      const act1 = BackdropBlurAct(from: 0.0, to: 10.0);
      const act2 = BackdropBlurAct(from: 0.0, to: 10.0);

      expect(act1.hashCode, equals(act2.hashCode));
    });

    test('isConstant when from equals to', () {
      const act = BackdropBlurAct(from: 5.0, to: 5.0);
      expect(act.isConstant, isTrue);
    });

    test('isConstant is false when from and to differ', () {
      const act = BackdropBlurAct(from: 0.0, to: 10.0);
      expect(act.isConstant, isFalse);
    });
  });
}
