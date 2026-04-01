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

  group('AlignAct', () {
    test('key is "Align"', () {
      const act = AlignAct();
      expect(act.key.key, equals('Align'));
    });

    test('default from and to are Alignment.center', () {
      const act = AlignAct();
      expect(act.from, equals(Alignment.center));
      expect(act.to, equals(Alignment.center));
    });

    test('constructor with custom from and to', () {
      const act = AlignAct(
        from: Alignment.topLeft,
        to: Alignment.bottomRight,
      );
      expect(act.from, equals(Alignment.topLeft));
      expect(act.to, equals(Alignment.bottomRight));
    });

    test('constructor with motion', () {
      final motion = CueMotion.linear(500.ms);
      final act = AlignAct(
        from: Alignment.centerLeft,
        to: Alignment.centerRight,
        motion: motion,
      );
      expect(act.motion, equals(motion));
    });

    test('constructor with delay', () {
      const act = AlignAct(delay: Duration(milliseconds: 200));
      expect(act.delay, equals(const Duration(milliseconds: 200)));
    });

    test('keyframed constructor', () {
      final frames = FractionalKeyframes<AlignmentGeometry>([
        FractionalKeyframe(Alignment.topLeft, at: 0.0),
        FractionalKeyframe(Alignment.bottomRight, at: 1.0),
      ]);
      final act = AlignAct.keyframed(frames: frames);
      expect(act.frames, equals(frames));
    });

    test('transform resolves AlignmentGeometry to Alignment', () {
      const act = AlignAct();
      final ctx = actContext;

      final result = act.transform(ctx, Alignment.topLeft);
      expect(result, equals(Alignment.topLeft));

      final result2 = act.transform(ctx, Alignment.bottomRight);
      expect(result2, equals(Alignment.bottomRight));
    });

    test('transform resolves AlignmentDirectional with textDirection', () {
      const act = AlignAct();
      final ctx = actContext.copyWith(textDirection: TextDirection.rtl);

      final directional = AlignmentDirectional.centerStart;
      final result = act.transform(ctx, directional);
      expect(result, isA<Alignment>());
    });

    test('transform returns null for null input', () {
      const act = AlignAct();
      final ctx = actContext;
      final result = act.transform(ctx, null);
      expect(result, isNull);
    });

    test('createSingleTween returns AlignmentTween', () {
      const act = AlignAct();
      final tween = act.createSingleTween(Alignment.topLeft, Alignment.bottomRight);

      expect(tween, isA<AlignmentTween>());
      expect((tween as AlignmentTween).begin, equals(Alignment.topLeft));
      expect(tween.end, equals(Alignment.bottomRight));
    });

    test('createSingleTween with null values', () {
      const act = AlignAct();
      final tween = act.createSingleTween(null, Alignment.center);

      expect(tween, isA<AlignmentTween>());
      expect((tween as AlignmentTween).begin, isNull);
      expect(tween.end, equals(Alignment.center));
    });

    testWidgets('apply wraps child in Align widget', (tester) async {
      const act = AlignAct(from: Alignment.topLeft, to: Alignment.bottomRight);
      final (animtable, _) = act.buildTweens(actContext);

      track.setProgress(0.0);

      final animation = CueAnimationImpl<Alignment?>(
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

      expect(find.byType(Align), findsOneWidget);
    });

    testWidgets('apply uses animation value for alignment', (tester) async {
      const act = AlignAct(from: Alignment.topLeft, to: Alignment.bottomRight);

      final (animtable, _) = act.buildTweens(actContext);

      track.setProgress(0.5);

      final animation = CueAnimationImpl<Alignment?>(
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

      final alignWidget = tester.widget<Align>(find.byType(Align));
      expect(alignWidget.alignment, equals(Alignment.center));
    });

    testWidgets('apply defaults to Alignment.center when animation value is null', (tester) async {
      const act = AlignAct();

      final animation = CueAnimationImpl<Alignment?>(
        parent: track,
        token: ReleaseToken(track.config, timeline),
        animtable: AlwaysStoppedAnimatable<Alignment?>(null),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) => act.apply(context, animation, const SizedBox()),
          ),
        ),
      );

      final alignWidget = tester.widget<Align>(find.byType(Align));
      expect(alignWidget.alignment, equals(Alignment.center));
    });

    test('equality', () {
      const act1 = AlignAct(
        from: Alignment.topLeft,
        to: Alignment.bottomRight,
        delay: Duration(milliseconds: 100),
      );
      const act2 = AlignAct(
        from: Alignment.topLeft,
        to: Alignment.bottomRight,
        delay: Duration(milliseconds: 100),
      );
      const act3 = AlignAct(
        from: Alignment.topLeft,
        to: Alignment.center,
      );

      expect(act1, equals(act2));
      expect(act1, isNot(equals(act3)));
    });

    test('hashCode consistency', () {
      const act1 = AlignAct(from: Alignment.topLeft, to: Alignment.bottomRight);
      const act2 = AlignAct(from: Alignment.topLeft, to: Alignment.bottomRight);

      expect(act1.hashCode, equals(act2.hashCode));
    });

    test('isConstant when from equals to', () {
      const act = AlignAct(from: Alignment.center, to: Alignment.center);
      expect(act.isConstant, isTrue);
    });

    test('isConstant is false when from and to differ', () {
      const act = AlignAct(from: Alignment.topLeft, to: Alignment.bottomRight);
      expect(act.isConstant, isFalse);
    });
  });

  group('AlignAct with ReverseBehavior', () {
    test('constructor with mirror reverse (default)', () {
      const act = AlignAct(
        from: Alignment.topLeft,
        to: Alignment.bottomRight,
      );
      expect(act.reverse.type, equals(ReverseBehaviorType.mirror));
    });

    test('constructor with exclusive reverse', () {
      const act = AlignAct(
        from: Alignment.topLeft,
        to: Alignment.bottomRight,
        reverse: ReverseBehavior.exclusive(),
      );
      expect(act.reverse.type, equals(ReverseBehaviorType.exclusive));
    });

    test('constructor with to reverse', () {
      const act = AlignAct(
        from: Alignment.topLeft,
        to: Alignment.bottomRight,
        reverse: ReverseBehavior.to(Alignment.center),
      );
      expect(act.reverse.type, equals(ReverseBehaviorType.to));
      expect((act.reverse as ReverseBehavior<AlignmentGeometry?>).to, equals(Alignment.center));
    });

    test('constructor with none reverse', () {
      const act = AlignAct(
        from: Alignment.topLeft,
        to: Alignment.bottomRight,
        reverse: ReverseBehavior.none(),
      );
      expect(act.reverse.type, equals(ReverseBehaviorType.none));
    });
  });
}
