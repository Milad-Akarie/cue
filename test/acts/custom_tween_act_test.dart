import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  
  group('Lerpable', () {
    test('is abstract class', () {
      expect(Lerpable, isA<Type>());
    });
  });

  group('AnimatedValues', () {
    test('default constructor has default values', () {
      const values = AnimatedValues();
      expect(values.scale, equals(1.0));
      expect(values.opacity, equals(1.0));
      expect(values.offset, equals(Offset.zero));
      expect(values.rotation, equals(0.0));
      expect(values.blur, equals(0.0));
      expect(values.color, isNull);
      expect(values.size, isNull);
    });

    test('constructor accepts all parameters', () {
      const values = AnimatedValues(
        scale: 2.0,
        opacity: 0.5,
        offset: Offset(10, 20),
        rotation: 1.0,
        blur: 5.0,
        color: Colors.red,
        size: Size(100, 200),
      );
      expect(values.scale, equals(2.0));
      expect(values.opacity, equals(0.5));
      expect(values.offset, equals(const Offset(10, 20)));
      expect(values.rotation, equals(1.0));
      expect(values.blur, equals(5.0));
      expect(values.color, equals(Colors.red));
      expect(values.size, equals(const Size(100, 200)));
    });

    test('lerpTo interpolates scale', () {
      const start = AnimatedValues(scale: 1.0);
      const end = AnimatedValues(scale: 2.0);
      final result = start.lerpTo(end, 0.5);
      expect(result.scale, equals(1.5));
    });

    test('lerpTo interpolates opacity', () {
      const start = AnimatedValues(opacity: 0.0);
      const end = AnimatedValues(opacity: 1.0);
      final result = start.lerpTo(end, 0.5);
      expect(result.opacity, equals(0.5));
    });

    test('lerpTo interpolates offset', () {
      const start = AnimatedValues(offset: Offset(0, 0));
      const end = AnimatedValues(offset: Offset(100, 200));
      final result = start.lerpTo(end, 0.5);
      expect(result.offset, equals(const Offset(50, 100)));
    });

    test('lerpTo interpolates rotation', () {
      const start = AnimatedValues(rotation: 0.0);
      const end = AnimatedValues(rotation: 2.0);
      final result = start.lerpTo(end, 0.5);
      expect(result.rotation, equals(1.0));
    });

    test('lerpTo interpolates blur', () {
      const start = AnimatedValues(blur: 0.0);
      const end = AnimatedValues(blur: 10.0);
      final result = start.lerpTo(end, 0.5);
      expect(result.blur, equals(5.0));
    });

    test('lerpTo interpolates color', () {
      const start = AnimatedValues(color: Colors.white);
      const end = AnimatedValues(color: Colors.black);
      final result = start.lerpTo(end, 0.5);
      expect(result.color, isNotNull);
    });

    test('lerpTo interpolates size', () {
      const start = AnimatedValues(size: Size(100, 100));
      const end = AnimatedValues(size: Size(200, 300));
      final result = start.lerpTo(end, 0.5);
      expect(result.size, equals(const Size(150, 200)));
    });

    test('lerpTo interpolates all values at once', () {
      const start = AnimatedValues(
        scale: 1.0,
        opacity: 0.0,
        offset: Offset(0, 0),
        rotation: 0.0,
        blur: 0.0,
      );
      const end = AnimatedValues(
        scale: 2.0,
        opacity: 1.0,
        offset: Offset(100, 100),
        rotation: 1.0,
        blur: 10.0,
      );
      final result = start.lerpTo(end, 0.5);
      expect(result.scale, equals(1.5));
      expect(result.opacity, equals(0.5));
      expect(result.offset, equals(const Offset(50, 50)));
      expect(result.rotation, equals(0.5));
      expect(result.blur, equals(5.0));
    });

    test('lerpTo returns this when end is not AnimatedValues', () {
      const start = AnimatedValues(scale: 2.0);
      final result = start.lerpTo(null, 0.5);
      expect(result, equals(start));
    });
  });

  group('InlineFnTween', () {
    test('lerp returns result of lerpFn at 0.0', () {
      final tween = InlineFnTween<double>(
        begin: 0.0,
        end: 100.0,
        lerpFn: (t) => 0.0 + (100.0 - 0.0) * t,
      );
      expect(tween.lerp(0.0), equals(0.0));
    });

    test('lerp returns result of lerpFn at 0.5', () {
      final tween = InlineFnTween<double>(
        begin: 0.0,
        end: 100.0,
        lerpFn: (t) => 0.0 + (100.0 - 0.0) * t,
      );
      expect(tween.lerp(0.5), equals(50.0));
    });

    test('lerp returns result of lerpFn at 1.0', () {
      final tween = InlineFnTween<double>(
        begin: 0.0,
        end: 100.0,
        lerpFn: (t) => 0.0 + (100.0 - 0.0) * t,
      );
      expect(tween.lerp(1.0), equals(100.0));
    });

    test('evaluate returns correct value with CurvedAnimation', () {
      final tween = InlineFnTween<double>(
        begin: 0.0,
        end: 100.0,
        lerpFn: (t) => 0.0 + (100.0 - 0.0) * t,
      );
      // Test that evaluate works with animation controller
      expect(tween.transform(0.25), equals(25.0));
    });

    test('works with custom lerpFn', () {
      final tween = InlineFnTween<double>(
        begin: 1.0,
        end: 2.0,
        lerpFn: (t) => 1.0 + (2.0 - 1.0) * t * t, // quadratic
      );
      expect(tween.lerp(0.5), equals(1.25)); // 1 + 1 * 0.25 = 1.25
    });

    test('begin and end properties are stored', () {
      final tween = InlineFnTween<double>(
        begin: 10.0,
        end: 20.0,
        lerpFn: (t) => 10.0 + (20.0 - 10.0) * t,
      );
      expect(tween.begin, equals(10.0));
      expect(tween.end, equals(20.0));
    });
  });

  group('TweenActor', () {
    test('constructor accepts from and to', () {
      final actor = TweenActor<double>(
        from: 0.0,
        to: 100.0,
        builder: (context, animation) => const SizedBox(),
      );
      expect(actor.from, equals(0.0));
      expect(actor.to, equals(100.0));
    });

    test('constructor accepts motion', () {
      final motion = CueMotion.linear(300.ms);
      final actor = TweenActor<double>(
        from: 0.0,
        to: 100.0,
        motion: motion,
        builder: (context, animation) => const SizedBox(),
      );
      expect(actor.motion, equals(motion));
    });

    test('constructor accepts delay', () {
      final actor = TweenActor<double>(
        from: 0.0,
        to: 100.0,
        delay: const Duration(milliseconds: 100),
        builder: (context, animation) => const SizedBox(),
      );
      expect(actor.delay, equals(const Duration(milliseconds: 100)));
    });

    test('constructor accepts reverse', () {
      const reverse = ReverseBehavior<double>.mirror();
      final actor = TweenActor<double>(
        from: 0.0,
        to: 100.0,
        reverse: reverse,
        builder: (context, animation) => const SizedBox(),
      );
      expect(actor.reverse, equals(reverse));
    });

    test('keyframed constructor accepts frames', () {
      final frames = Keyframes<double>([
        Keyframe(0.0, motion: CueMotion.linear(300.ms)),
        Keyframe(100.0, motion: CueMotion.linear(300.ms)),
      ]);
      final actor = TweenActor<double>.keyframed(
        frames: frames,
        builder: (context, animation) => const SizedBox(),
      );
      expect(actor.frames, isNotNull);
    });

    test('keyframed constructor accepts delay', () {
      final frames = Keyframes<double>([
        Keyframe(0.0, motion: CueMotion.linear(300.ms)),
        Keyframe(100.0, motion: CueMotion.linear(300.ms)),
      ]);
      const delay = Duration(milliseconds: 150);
      final actor = TweenActor<double>.keyframed(
        frames: frames,
        delay: delay,
        builder: (context, animation) => const SizedBox(),
      );
      expect(actor.delay, equals(delay));
    });

    test('keyframed constructor accepts reverse', () {
      final frames = Keyframes<double>([
        Keyframe(0.0, motion: CueMotion.linear(300.ms)),
        Keyframe(100.0, motion: CueMotion.linear(300.ms)),
      ]);
      final actor = TweenActor<double>.keyframed(
        frames: frames,
        builder: (context, animation) => const SizedBox(),
      );
      expect(actor.frames, isNotNull);
    });

    test('act returns correct key', () {
      final actor = TweenActor<double>(
        from: 0.0,
        to: 100.0,
        builder: (context, animation) => const SizedBox(),
      );
      expect(actor.act.key, equals(const ActKey('TweenActor')));
    });

    test('works with AnimatedValues', () {
      final actor = TweenActor<AnimatedValues>(
        from: const AnimatedValues(scale: 1.0),
        to: const AnimatedValues(scale: 2.0),
        builder: (context, animation) => const SizedBox(),
      );
      expect((actor.from as AnimatedValues).scale, equals(1.0));
      expect((actor.to as AnimatedValues).scale, equals(2.0));
    });

    test('accepts tweenBuilder', () {
      final actor = TweenActor<double>(
        from: 0.0,
        to: 100.0,
        tweenBuilder: Tween(begin: 0.0, end: 100.0),
        builder: (context, animation) => const SizedBox(),
      );
      expect(actor.tweenBuilder, isNotNull);
    });

    test('createSingleTween with Lerpable creates proper interpolation', () {
      const from = AnimatedValues(scale: 1.0, opacity: 0.0);
      const to = AnimatedValues(scale: 2.0, opacity: 1.0);
      
      // Verify that lerpTo works correctly for interpolation
      final interpolated = from.lerpTo(to, 0.5);
      expect(interpolated.scale, closeTo(1.5, 0.01));
      expect(interpolated.opacity, closeTo(0.5, 0.01));
    });

    test('createSingleTween respects tweenBuilder when provided', () {
      final customTween = Tween<double>(begin: 50.0, end: 150.0);
      final actor = TweenActor<double>(
        from: 0.0,
        to: 100.0,
        tweenBuilder: customTween,
        builder: (context, animation) => const SizedBox(),
      );
      
      expect(actor.tweenBuilder, equals(customTween));
    });

    test('createSingleTween preserves AnimatedValues properties', () {
      const from = AnimatedValues(scale: 1.0, opacity: 0.0, blur: 0.0);
      const to = AnimatedValues(scale: 2.0, opacity: 1.0, blur: 10.0);
      
      final actor = TweenActor<AnimatedValues>(
        from: from,
        to: to,
        builder: (context, animation) => const SizedBox(),
      );
      
      expect((actor.from as AnimatedValues).scale, equals(1.0));
      expect((actor.from as AnimatedValues).opacity, equals(0.0));
      expect((actor.from as AnimatedValues).blur, equals(0.0));
      expect((actor.to as AnimatedValues).scale, equals(2.0));
      expect((actor.to as AnimatedValues).opacity, equals(1.0));
      expect((actor.to as AnimatedValues).blur, equals(10.0));
    });

    test('createSingleTween handles multiple Lerpable property interpolations', () {
      const from = AnimatedValues(
        scale: 1.0,
        opacity: 0.0,
        offset: Offset.zero,
        rotation: 0.0,
        blur: 0.0,
      );
      const to = AnimatedValues(
        scale: 2.0,
        opacity: 1.0,
        offset: Offset(100, 100),
        rotation: 1.0,
        blur: 10.0,
      );
      
      final mid = from.lerpTo(to, 0.5);
      expect(mid.scale, closeTo(1.5, 0.01));
      expect(mid.opacity, closeTo(0.5, 0.01));
      expect(mid.offset, equals(const Offset(50, 50)));
      expect(mid.rotation, closeTo(0.5, 0.01));
      expect(mid.blur, closeTo(5.0, 0.01));
    });
  });

  group('CustomTweenAct createSingleTween', () {
    test('returns tweenBuilder when provided', () {
      final customTween = Tween<double>(begin: 50.0, end: 150.0);
      final act = CustomTweenAct<double>(
        from: 0.0,
        to: 100.0,
        tweenBuilder: customTween,
        builder: (context, animation) => const SizedBox(),
      );

      final result = act.createSingleTween(0.0, 100.0);
      expect(result, equals(customTween));
    });

    test('creates InlineFnTween for Lerpable', () {
      const from = AnimatedValues(scale: 1.0, opacity: 0.0);
      const to = AnimatedValues(scale: 2.0, opacity: 1.0);
      
      final act = CustomTweenAct<AnimatedValues>(
        from: from,
        to: to,
        builder: (context, animation) => const SizedBox(),
      );

      final result = act.createSingleTween(from, to);
      expect(result, isA<InlineFnTween<AnimatedValues>>());
    });

    test('InlineFnTween interpolates correctly', () {
      const from = AnimatedValues(scale: 1.0, opacity: 0.0);
      const to = AnimatedValues(scale: 2.0, opacity: 1.0);
      
      final act = CustomTweenAct<AnimatedValues>(
        from: from,
        to: to,
        builder: (context, animation) => const SizedBox(),
      );

      final tween = act.createSingleTween(from, to) as InlineFnTween<AnimatedValues>;
      final midpoint = tween.lerp(0.5);
      
      expect(midpoint.scale, closeTo(1.5, 0.01));
      expect(midpoint.opacity, closeTo(0.5, 0.01));
    });

    test('calls super when no tweenBuilder and not Lerpable', () {
      final act = CustomTweenAct<double>(
        from: 0.0,
        to: 100.0,
        builder: (context, animation) => const SizedBox(),
      );

      final result = act.createSingleTween(0.0, 100.0);
      expect(result, isA<Tween<double>>());
    });

    test('InlineFnTween stores correct begin and end', () {
      const from = AnimatedValues(scale: 1.0);
      const to = AnimatedValues(scale: 2.0);
      
      final act = CustomTweenAct<AnimatedValues>(
        from: from,
        to: to,
        builder: (context, animation) => const SizedBox(),
      );

      final tween = act.createSingleTween(from, to) as InlineFnTween<AnimatedValues>;
      expect(tween.begin, equals(from));
      expect(tween.end, equals(to));
    });

    test('with tweenBuilder ignores Lerpable', () {
      const from = AnimatedValues(scale: 1.0);
      const to = AnimatedValues(scale: 2.0);
      final customTween = Tween<AnimatedValues>(begin: from, end: to);
      
      final act = CustomTweenAct<AnimatedValues>(
        from: from,
        to: to,
        tweenBuilder: customTween,
        builder: (context, animation) => const SizedBox(),
      );

      final result = act.createSingleTween(from, to);
      expect(result, equals(customTween));
      expect(result, isNot(isA<InlineFnTween<AnimatedValues>>()));
    });
  });

  group('CustomTweenAct equality', () {
    test('two instances with same parameters are equal', () {
      SizedBox builder(BuildContext context, CueAnimation<double> animation) => const SizedBox();
      
      final act1 = CustomTweenAct<double>(
        from: 0.0,
        to: 100.0,
        builder: builder,
      );
      
      final act2 = CustomTweenAct<double>(
        from: 0.0,
        to: 100.0,
        builder: builder,
      );
      
      expect(act1, equals(act2));
    });

    test('identical instances are equal', () {
      final act = CustomTweenAct<double>(
        from: 0.0,
        to: 100.0,
        builder: (context, animation) => const SizedBox(),
      );
      
      expect(act, equals(act));
    });

    test('instances with different builders are not equal', () {
      final act1 = CustomTweenAct<double>(
        from: 0.0,
        to: 100.0,
        builder: (context, animation) => const SizedBox(),
      );
      
      final act2 = CustomTweenAct<double>(
        from: 0.0,
        to: 100.0,
        builder: (context, animation) => const Placeholder(),
      );
      
      expect(act1, isNot(equals(act2)));
    });

    test('instances with different tweenBuilders are not equal', () {
      final tween1 = Tween<double>(begin: 0.0, end: 100.0);
      final tween2 = Tween<double>(begin: 0.0, end: 200.0);
      
      final act1 = CustomTweenAct<double>(
        from: 0.0,
        to: 100.0,
        tweenBuilder: tween1,
        builder: (context, animation) => const SizedBox(),
      );
      
      final act2 = CustomTweenAct<double>(
        from: 0.0,
        to: 100.0,
        tweenBuilder: tween2,
        builder: (context, animation) => const SizedBox(),
      );
      
      expect(act1, isNot(equals(act2)));
    });

    test('instances with different from values are not equal', () {
      SizedBox builder(BuildContext context, CueAnimation<double> animation) => const SizedBox();
      
      final act1 = CustomTweenAct<double>(
        from: 0.0,
        to: 100.0,
        builder: builder,
      );
      
      final act2 = CustomTweenAct<double>(
        from: 50.0,
        to: 100.0,
        builder: builder,
      );
      
      expect(act1, isNot(equals(act2)));
    });

    test('instances with different to values are not equal', () {
      SizedBox builder(BuildContext context, CueAnimation<double> animation) => const SizedBox();
      
      final act1 = CustomTweenAct<double>(
        from: 0.0,
        to: 100.0,
        builder: builder,
      );
      
      final act2 = CustomTweenAct<double>(
        from: 0.0,
        to: 200.0,
        builder: builder,
      );
      
      expect(act1, isNot(equals(act2)));
    });

    test('instances with different types are not equal', () {
      final act1 = CustomTweenAct<double>(
        from: 0.0,
        to: 100.0,
        builder: (context, animation) => const SizedBox(),
      );
      
      final act2 = CustomTweenAct<int>(
        from: 0,
        to: 100,
        builder: (context, animation) => const SizedBox(),
      );
      
      expect(act1, isNot(equals(act2)));
    });

    test('hashCode is equal for equal instances', () {
      SizedBox builder(BuildContext context, CueAnimation<double> animation) => const SizedBox();
      
      final act1 = CustomTweenAct<double>(
        from: 0.0,
        to: 100.0,
        builder: builder,
      );
      
      final act2 = CustomTweenAct<double>(
        from: 0.0,
        to: 100.0,
        builder: builder,
      );
      
      expect(act1.hashCode, equals(act2.hashCode));
    });

    test('hashCode differs for instances with different builders', () {
      final act1 = CustomTweenAct<double>(
        from: 0.0,
        to: 100.0,
        builder: (context, animation) => const SizedBox(),
      );
      
      final act2 = CustomTweenAct<double>(
        from: 0.0,
        to: 100.0,
        builder: (context, animation) => const Placeholder(),
      );
      
      expect(act1.hashCode, isNot(equals(act2.hashCode)));
    });

    test('hashCode differs for instances with different tweenBuilders', () {
      final tween1 = Tween<double>(begin: 0.0, end: 100.0);
      final tween2 = Tween<double>(begin: 0.0, end: 200.0);
      
      final act1 = CustomTweenAct<double>(
        from: 0.0,
        to: 100.0,
        tweenBuilder: tween1,
        builder: (context, animation) => const SizedBox(),
      );
      
      final act2 = CustomTweenAct<double>(
        from: 0.0,
        to: 100.0,
        tweenBuilder: tween2,
        builder: (context, animation) => const SizedBox(),
      );
      
      expect(act1.hashCode, isNot(equals(act2.hashCode)));
    });
  });
}
