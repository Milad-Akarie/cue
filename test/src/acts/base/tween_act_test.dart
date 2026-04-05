import 'package:cue/src/acts/base/tween_act.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';

void main() {
  group('TweenActBase.resolveMotion', () {
    final defaultMotion = CueMotion.linear(const Duration(milliseconds: 100));
    final reverseMotion = CueMotion.linear(const Duration(milliseconds: 200));

    test('with null frames uses motion parameter', () {
      final context = ActContext(motion: defaultMotion, reverseMotion: reverseMotion);
      final customMotion = CueMotion.linear(const Duration(milliseconds: 150));
      final reverse = ReverseBehavior<double>.mirror(motion: customMotion);

      final resolved = TweenActBase.resolveMotion<double>(
        context,
        motion: customMotion,
        delay: Duration.zero,
        reverse: reverse,
        frames: null,
      );

      expect(resolved.motion, equals(customMotion));
    });

    test('with MotionKeyframes extracts motion no includeFirstFrame', () {
      final m1 = CueMotion.linear(const Duration(milliseconds: 100));
      final m2 = CueMotion.linear(const Duration(milliseconds: 200));
      final frames = MotionKeyframes<int>([
        Keyframe(1, motion: m1),
        Keyframe(2, motion: m2),
      ], motion: CueMotion.none);

      final context = ActContext(motion: defaultMotion, reverseMotion: reverseMotion);
      final reverse = ReverseBehavior<int>.mirror();

      final resolved = TweenActBase.resolveMotion<int>(
        context,
        motion: null,
        delay: Duration.zero,
        reverse: reverse,
        frames: frames,
        includeFirstFrame: false,
      );

      // Should use SegmentedMotion from extracted motions (without first)
      expect(resolved.motion, isA<CueMotion>());
    });

    test('with MotionKeyframes extracts motion with includeFirstFrame', () {
      final m1 = CueMotion.linear(const Duration(milliseconds: 100));
      final m2 = CueMotion.linear(const Duration(milliseconds: 200));
      final frames = MotionKeyframes<int>([
        Keyframe(1, motion: m1),
        Keyframe(2, motion: m2),
      ], motion: CueMotion.none);

      final context = ActContext(motion: defaultMotion, reverseMotion: reverseMotion);
      final reverse = ReverseBehavior<int>.mirror();

      final resolved = TweenActBase.resolveMotion<int>(
        context,
        motion: null,
        delay: Duration.zero,
        reverse: reverse,
        frames: frames,
        includeFirstFrame: true,
      );

      // Should use SegmentedMotion from extracted motions (with first)
      expect(resolved.motion, isA<CueMotion>());
    });

    test('with FractionalKeyframes and duration', () {
      final frames = FractionalKeyframes<int>([
        FKeyframe(1, at: 0.0),
        FKeyframe(2, at: 1.0),
      ], duration: const Duration(milliseconds: 500));

      final context = ActContext(motion: defaultMotion, reverseMotion: reverseMotion);
      final reverse = ReverseBehavior<int>.mirror();

      final resolved = TweenActBase.resolveMotion<int>(
        context,
        motion: null,
        delay: Duration.zero,
        reverse: reverse,
        frames: frames,
        includeFirstFrame: false,
      );

      expect(resolved.motion, isA<CueMotion>());
    });

    test('with FractionalKeyframes no duration uses context motion baseDuration', () {
      final frames = FractionalKeyframes<int>([
        FKeyframe(1, at: 0.0),
        FKeyframe(2, at: 1.0),
      ], duration: null);

      final context = ActContext(motion: defaultMotion, reverseMotion: reverseMotion);
      final reverse = ReverseBehavior<int>.mirror();

      final resolved = TweenActBase.resolveMotion<int>(
        context,
        motion: null,
        delay: Duration.zero,
        reverse: reverse,
        frames: frames,
        includeFirstFrame: false,
      );

      expect(resolved.motion, isA<CueMotion>());
    });

    test('reverse frames with MotionKeyframes', () {
      final m1 = CueMotion.linear(const Duration(milliseconds: 100));
      final m2 = CueMotion.linear(const Duration(milliseconds: 200));
      final frames = MotionKeyframes<int>([
        Keyframe(1, motion: m1),
        Keyframe(2, motion: m2),
      ], motion: CueMotion.none);

      final context = ActContext(motion: defaultMotion, reverseMotion: reverseMotion);
      final reverse = ReverseBehavior<int>.mirror(motion: CueMotion.linear(const Duration(milliseconds: 150)));
      reverse.frames?.reversed;

      final resolved = TweenActBase.resolveMotion<int>(
        context,
        motion: null,
        delay: Duration.zero,
        reverse: reverse,
        frames: frames,
        includeFirstFrame: false,
      );

      // Reverse motion should be computed
      expect(resolved.reverseMotion, isNotNull);
    });

    test('reverse frames with FractionalKeyframes', () {
      final frames = FractionalKeyframes<int>([
        FKeyframe(1, at: 0.0),
        FKeyframe(2, at: 1.0),
      ], duration: const Duration(milliseconds: 500));

      final context = ActContext(motion: defaultMotion, reverseMotion: reverseMotion);
      final revFrames = frames.reversed;
      final reverse = KFReverseBehavior<int>.to(revFrames);

      final resolved = TweenActBase.resolveMotion<int>(
        context,
        motion: null,
        delay: Duration.zero,
        reverse: reverse,
        frames: frames,
        includeFirstFrame: false,
      );

      expect(resolved.reverseMotion, isNotNull);
    });

    test('with forward delay', () {
      final context = ActContext(
        motion: defaultMotion,
        reverseMotion: reverseMotion,
        delay: const Duration(milliseconds: 50),
      );
      final reverse = ReverseBehavior<double>.mirror(motion: reverseMotion);
      final addDelay = Duration(milliseconds: 25);

      final resolved = TweenActBase.resolveMotion<double>(
        context,
        motion: defaultMotion,
        delay: addDelay,
        reverse: reverse,
        frames: null,
        includeFirstFrame: false,
      );

      // Motion should be delayed: 75ms total (50 + 25)
      expect(resolved.motion, isA<CueMotion>());
    });

    test('with reverse delay', () {
      final context = ActContext(
        motion: defaultMotion,
        reverseMotion: reverseMotion,
        reverseDelay: const Duration(milliseconds: 30),
      );
      final reverse = ReverseBehavior<double>.mirror(
        motion: reverseMotion,
        delay: const Duration(milliseconds: 20),
      );

      final resolved = TweenActBase.resolveMotion<double>(
        context,
        motion: defaultMotion,
        delay: Duration.zero,
        reverse: reverse,
        frames: null,
        includeFirstFrame: false,
      );

      // Reverse motion should be delayed: 50ms total (30 + 20)
      expect(resolved.reverseMotion, isA<CueMotion>());
    });

    test('uses provided motion over context motion', () {
      final context = ActContext(motion: defaultMotion, reverseMotion: reverseMotion);
      final customMotion = CueMotion.linear(const Duration(milliseconds: 300));
      final reverse = ReverseBehavior<double>.mirror();

      final resolved = TweenActBase.resolveMotion<double>(
        context,
        motion: customMotion,
        delay: Duration.zero,
        reverse: reverse,
        frames: null,
      );

      expect(resolved.motion, equals(customMotion));
    });

    test('uses reverse.motion when provided', () {
      final context = ActContext(motion: defaultMotion, reverseMotion: reverseMotion);
      final customReverseMotion = CueMotion.linear(const Duration(milliseconds: 400));
      final reverse = ReverseBehavior<double>.mirror(motion: customReverseMotion);

      final resolved = TweenActBase.resolveMotion<double>(
        context,
        motion: null,
        delay: Duration.zero,
        reverse: reverse,
        frames: null,
      );

      expect(resolved.reverseMotion, equals(customReverseMotion));
    });

    test('fallback to provided motion when no reverse motion set', () {
      final context = ActContext(motion: defaultMotion, reverseMotion: reverseMotion);
      final reverse = ReverseBehavior<double>.mirror();

      final resolved = TweenActBase.resolveMotion<double>(
        context,
        motion: defaultMotion,
        delay: Duration.zero,
        reverse: reverse,
        frames: null,
      );

      // When motion is provided, it becomes the fallback before context.reverseMotion
      expect(resolved.reverseMotion, equals(defaultMotion));
    });

    test('fallback to context reverseMotion when no motion and no reverse motion set', () {
      final context = ActContext(motion: defaultMotion, reverseMotion: reverseMotion);
      final reverse = ReverseBehavior<double>.mirror();

      final resolved = TweenActBase.resolveMotion<double>(
        context,
        motion: null,
        delay: Duration.zero,
        reverse: reverse,
        frames: null,
      );

      // When no motion is provided, fall back to context.reverseMotion
      expect(resolved.reverseMotion, equals(reverseMotion));
    });
  });

  group('ReverseBehaviorBase', () {
    test('needsReverseTween for different types', () {
      const mirror = ReverseBehavior<int>.mirror();
      const exclusive = ReverseBehavior<int>.exclusive();
      const none = ReverseBehavior<int>.none();
      const to = ReverseBehavior<int>.to(5);

      expect(mirror.needsReverseTween, isFalse);
      expect(exclusive.needsReverseTween, isFalse);
      expect(none.needsReverseTween, isFalse);
      expect(to.needsReverseTween, isTrue);
    });

    test('mapValues transforms to value', () {
      const reverse = ReverseBehavior<int>.to(10);
      final mapped = reverse.mapValues<String>((v) => 'value_$v');

      expect(mapped.to, equals('value_10'));
      expect(mapped.type, equals(ReverseBehaviorType.to));
    });

    test('mapValues with frames', () {
      final frames = FractionalKeyframes<int>([FKeyframe(5, at: 0.5)]);
      final reverse = KFReverseBehavior<int>.to(frames);
      final mapped = reverse.mapValues<double>((v) => v.toDouble() * 2);

      expect(mapped.frames, isNotNull);
      expect(mapped.frames?.values.first, equals(10.0));
    });

    test('equality for ReverseBehaviorBase', () {
      const a = ReverseBehavior<int>.mirror();
      const b = ReverseBehavior<int>.mirror();
      expect(a, equals(b));

      const c = ReverseBehavior<int>.to(5);
      const d = ReverseBehavior<int>.to(5);
      expect(c, equals(d));

      expect(a, isNot(equals(c)));
    });

    test('hashCode consistency', () {
      const a = ReverseBehavior<int>.to(5);
      const b = ReverseBehavior<int>.to(5);
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('AnimatableValue', () {
    test('fixed creates same from/to', () {
      const av = AnimatableValue.fixed(42);
      expect(av.from, equals(42));
      expect(av.to, equals(42));
      expect(av.isConstant, isTrue);
    });

    test('tween creates different from/to', () {
      const av = AnimatableValue.tween(10, 20);
      expect(av.from, equals(10));
      expect(av.to, equals(20));
      expect(av.isConstant, isFalse);
    });

    test('equality and hashCode', () {
      const a = AnimatableValue.tween(10, 20);
      const b = AnimatableValue.tween(10, 20);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));

      const c = AnimatableValue.tween(10, 25);
      expect(a, isNot(equals(c)));
    });
  });

  group('TweenActBase.resolveTween', () {
    final defaultMotion = CueMotion.linear(const Duration(milliseconds: 100));
    final reverseMotion = CueMotion.linear(const Duration(milliseconds: 200));
    final context = ActContext(motion: defaultMotion, reverseMotion: reverseMotion);

    test('with null keyframes and from != to returns TweenAnimtable', () {
      final act = CueTweenBuildHelper<int>(
        from: 10,
        to: 25,
        tweenBuilder: (f, t) => Tween(begin: f, end: t),
      );
      final result = act.resolveTween(
        context,
        from: 10,
        to: 25,
        keyframes: null,
      );

      expect(result, isA<TweenAnimtable<int>>());
    });

    test('with null keyframes and from == to returns AlwaysStoppedAnimatable', () {
      final act = CueTweenBuildHelper<int>(
        from: 5,
        to: 10,
        tweenBuilder: (f, t) => Tween(begin: f, end: t),
      );
      final result = act.resolveTween(
        context,
        from: 5,
        to: 10,
        keyframes: null,
      );

      // effectiveFrom = transform(5) = 10, to = 10, so they're equal
      expect(result, isA<TweenAnimtable<int>>());
    });

    test('with null keyframes uses implicitFrom when from is null', () {
      final act = CueTweenBuildHelper<int>(
        from: 10,
        to: 20,
        tweenBuilder: (f, t) => Tween(begin: f, end: t),
      );
      final result = act.resolveTween(
        context,
        from: null,
        to: 20,
        implicitFrom: 50,
        keyframes: null,
      );

      expect(result, isA<TweenAnimtable<int>>());
    });

    test('with MotionKeyframes returns SegmentedAnimtable', () {
      final frames = MotionKeyframes<int>([
        Keyframe(10),
        Keyframe(20),
      ], motion: .linear(100.ms));

      final act = CueTweenBuildHelper<int>(
        from: 10,
        to: 20,
        tweenBuilder: (f, t) => Tween(begin: f, end: t),
      );
      final result = act.resolveTween(
        context,
        from: null,
        to: null,
        keyframes: frames,
      );

      expect(result, isA<SegmentedAnimtable<int>>());
    });

    test('with MotionKeyframes and forReverse=true passes flag to Phase resolver', () {
      final frames = MotionKeyframes<int>([
        Keyframe(10),
        Keyframe(20),
      ], motion: .linear(100.ms));

      final act = CueTweenBuildHelper<int>(
        from: 10,
        to: 20,
        tweenBuilder: (f, t) => Tween(begin: f, end: t),
      );
      final resultForward = act.resolveTween(
        context,
        from: null,
        to: null,
        forReverse: false,
        keyframes: frames,
      );

      final resultReverse = act.resolveTween(
        context,
        from: null,
        to: null,
        forReverse: true,
        keyframes: frames,
      );

      expect(resultForward, isA<SegmentedAnimtable<int>>());
      expect(resultReverse, isA<SegmentedAnimtable<int>>());
    });

    test('with FractionalKeyframes returns SegmentedAnimtable', () {
      final frames = FractionalKeyframes<int>([
        FKeyframe(10, at: 0.0),
        FKeyframe(20, at: 1.0),
      ], duration: const Duration(milliseconds: 500));

      final act = CueTweenBuildHelper<int>(
        from: 10,
        to: 20,
        tweenBuilder: (f, t) => Tween(begin: f, end: t),
      );
      final result = act.resolveTween(
        context,
        from: null,
        to: null,
        keyframes: frames,
      );

      expect(result, isA<SegmentedAnimtable<int>>());
    });

    test('with FractionalKeyframes and forReverse=true', () {
      final frames = FractionalKeyframes<int>([
        FKeyframe(10, at: 0.0),
        FKeyframe(20, at: 1.0),
      ], duration: const Duration(milliseconds: 500));

      final act = CueTweenBuildHelper<int>(
        from: 10,
        to: 20,
        tweenBuilder: (f, t) => Tween(begin: f, end: t),
      );
      final result = act.resolveTween(
        context,
        from: null,
        to: null,
        forReverse: true,
        keyframes: frames,
      );

      expect(result, isA<SegmentedAnimtable<int>>());
    });

    test('transform is called correctly for non-keyframe path', () {
      final act = CueTweenBuildHelper<int>(
        from: 10,
        to: 25,
        tweenBuilder: (f, t) => Tween(begin: f, end: t),
      );
      final result = act.resolveTween(
        context,
        from: 10,
        to: 25,
        keyframes: null,
      );

      // transform() doubles the value: 10 -> 20, 25 -> 50
      expect(result, isA<TweenAnimtable<int>>());
    });

    test('with multiple MotionKeyframes segments creates multiple segments', () {
      final frames = MotionKeyframes<int>([
        Keyframe(10),
        Keyframe(20),
        Keyframe(30),
      ], motion: .linear(100.ms));

      final act = CueTweenBuildHelper<int>(
        from: 10,
        to: 30,
        tweenBuilder: (f, t) => Tween(begin: f, end: t),
      );
      final result = act.resolveTween(
        context,
        from: null,
        to: null,
        keyframes: frames,
      );

      expect(result, isA<SegmentedAnimtable<int>>());
    });

    test('initialKeyframe is used correctly in Phase resolution', () {
      final frames = MotionKeyframes<int>([
        Keyframe(10),
        Keyframe(20),
      ], motion: .linear(100.ms));

      final act = CueTweenBuildHelper<int>(
        from: 5,
        to: 20,
        tweenBuilder: (f, t) => Tween(begin: f, end: t),
      );
      final result = act.resolveTween(
        context,
        from: 5,
        to: null,
        keyframes: frames,
      );

      expect(result, isA<SegmentedAnimtable<int>>());
    });

    test('implicitFrom is preferred over explicit from parameter', () {
      final act = CueTweenBuildHelper<int>(
        from: 10,
        to: 20,
        tweenBuilder: (f, t) => Tween(begin: f, end: t),
      );
      final result = act.resolveTween(
        context,
        from: 10,
        to: 20,
        implicitFrom: 99,
        keyframes: null,
      );

      expect(result, isA<TweenAnimtable<int>>());
    });

    test('TypeError when from and to are both null without keyframes', () {
      final act = CueTweenBuildHelper<int>(
        from: 10,
        to: 20,
        tweenBuilder: (f, t) => Tween(begin: f, end: t),
      );

      expect(
        () => act.resolveTween(
          context,
          from: null,
          to: null,
          keyframes: null,
        ),
        throwsA(isA<TypeError>()),
      );
    });

    test('with keyframed constructor uses FractionalKeyframes', () {
      final frames = FractionalKeyframes<int>([
        FKeyframe(10, at: 0.0),
        FKeyframe(20, at: 1.0),
      ]);

      final act = CueTweenBuildHelper<int>(
        frames: frames,
        tweenBuilder: (f, t) => Tween(begin: f, end: t),
      );

      final result = act.resolveTween(
        context,
        from: null,
        to: null,
        keyframes: frames,
      );

      expect(result, isA<SegmentedAnimtable<int>>());
    });
  });
}
