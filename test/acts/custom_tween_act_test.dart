import 'dart:ui';

import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ActContext createActContext() {
    final motion = CueMotion.linear(300.ms);
    return ActContext(motion: motion, reverseMotion: motion);
  }

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
  });
}
