import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';

void main() {
  group('ParallaxAct', () {
    test('ParallaxAct creates valid instance', () {
      const act = ParallaxAct(slide: 0.5);
      expect(act.key, equals(const ActKey('Parallax')));
      expect(act.slide, equals(0.5));
      expect(act.axis, equals(Axis.horizontal));
    });

    test('ParallaxAct with vertical axis creates valid instance', () {
      const act = ParallaxAct(slide: 0.5, axis: Axis.vertical);
      expect(act.axis, equals(Axis.vertical));
    });

    test('ParallaxAct with motion creates valid instance', () {
      const act = ParallaxAct(
        slide: 0.5,
        motion: CueMotion.linear(Duration(milliseconds: 300)),
      );
      expect(act.motion, equals(CueMotion.linear(Duration(milliseconds: 300))));
    });

    test('ParallaxAct with delay creates valid instance', () {
      const act = ParallaxAct(slide: 0.5, delay: Duration(milliseconds: 100));
      expect(act.delay, equals(Duration(milliseconds: 100)));
    });

    test('ParallaxAct equality', () {
      const a = ParallaxAct(slide: 0.5);
      const b = ParallaxAct(slide: 0.5);
      expect(a, equals(b));
    });

    test('ParallaxAct with different slide not equal', () {
      const a = ParallaxAct(slide: 0.5);
      const b = ParallaxAct(slide: 0.8);
      expect(a, isNot(equals(b)));
    });

    test('ParallaxAct with different axis not equal', () {
      const a = ParallaxAct(slide: 0.5, axis: Axis.horizontal);
      const b = ParallaxAct(slide: 0.5, axis: Axis.vertical);
      expect(a, isNot(equals(b)));
    });

    test('ParallaxAct with different motion not equal', () {
      const a = ParallaxAct(slide: 0.5, motion: CueMotion.none);
      const b = ParallaxAct(
        slide: 0.5,
        motion: CueMotion.linear(Duration(milliseconds: 200)),
      );
      expect(a, isNot(equals(b)));
    });

    test('ParallaxAct with different delay not equal', () {
      const a = ParallaxAct(slide: 0.5, delay: Duration.zero);
      const b = ParallaxAct(slide: 0.5, delay: Duration(milliseconds: 100));
      expect(a, isNot(equals(b)));
    });

    test('ParallaxAct with different reverse not equal', () {
      const a = ParallaxAct(slide: 0.5, reverse: ReverseBehavior.mirror());
      const b = ParallaxAct(slide: 0.5, reverse: ReverseBehavior.none());
      expect(a, isNot(equals(b)));
    });

    test('ParallaxAct.hashCode consistency', () {
      const a = ParallaxAct(slide: 0.5);
      const b = ParallaxAct(slide: 0.5);
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('DecoratedBoxAct', () {
    test('DecoratedBoxAct creates valid instance', () {
      const act = DecoratedBoxAct();
      expect(act.key, equals(const ActKey('DecoratedBox')));
    });

    test('DecoratedBoxAct with color creates valid instance', () {
      const act = DecoratedBoxAct(
        color: AnimatableValue<Color>(from: Color(0xFF000000), to: Color(0xFFFFFFFF)),
      );
      expect(act.color, isNotNull);
    });

    test('DecoratedBoxAct with borderRadius creates valid instance', () {
      const act = DecoratedBoxAct(
        borderRadius: AnimatableValue<BorderRadiusGeometry>(
          from: BorderRadius.zero,
          to: BorderRadius.all(Radius.circular(10)),
        ),
      );
      expect(act.borderRadius, isNotNull);
    });

    test('DecoratedBoxAct with border creates valid instance', () {
      final act = DecoratedBoxAct(
        border: AnimatableValue<BoxBorder>(
          from: Border(),
          to: Border.all(width: 2),
        ),
      );
      expect(act.border, isNotNull);
    });

    test('DecoratedBoxAct with boxShadow creates valid instance', () {
      final act = DecoratedBoxAct(
        boxShadow: AnimatableValue<List<BoxShadow>>(
          from: [],
          to: [BoxShadow(blurRadius: 10)],
        ),
      );
      expect(act.boxShadow, isNotNull);
    });

    test('DecoratedBoxAct with gradient creates valid instance', () {
      const act = DecoratedBoxAct(
        gradient: AnimatableValue<Gradient>(
          from: LinearGradient(colors: [Color(0xFF000000)]),
          to: LinearGradient(colors: [Color(0xFFFFFFFF)]),
        ),
      );
      expect(act.gradient, isNotNull);
    });

    test('DecoratedBoxAct with shape creates valid instance', () {
      const act = DecoratedBoxAct(shape: BoxShape.circle);
      expect(act.shape, equals(BoxShape.circle));
    });

    test('DecoratedBoxAct with position creates valid instance', () {
      const act = DecoratedBoxAct(position: DecorationPosition.foreground);
      expect(act.position, equals(DecorationPosition.foreground));
    });

    test('DecoratedBoxAct.keyframed creates valid instance', () {
      final frames = MotionKeyframes<Decoration>([
        Keyframe.key(BoxDecoration(color: Color(0xFF000000))),
        Keyframe.key(BoxDecoration(color: Color(0xFFFFFFFF))),
      ], motion: .none);
      final act = DecoratedBoxAct.keyframed(frames: frames);
      expect(act.frames, equals(frames));
      expect(act.color, isNull);
      expect(act.borderRadius, isNull);
      expect(act.border, isNull);
      expect(act.boxShadow, isNull);
      expect(act.gradient, isNull);
    });

    test('DecoratedBoxAct equality', () {
      const a = DecoratedBoxAct();
      const b = DecoratedBoxAct();
      expect(a, equals(b));
    });

    test('DecoratedBoxAct with different color not equal', () {
      const a = DecoratedBoxAct(
        color: AnimatableValue<Color>(from: Color(0xFF000000), to: Color(0xFFFFFFFF)),
      );
      const b = DecoratedBoxAct(
        color: AnimatableValue<Color>(from: Color(0xFFFF0000), to: Color(0xFFFFFFFF)),
      );
      expect(a, isNot(equals(b)));
    });

    test('DecoratedBoxAct with different borderRadius not equal', () {
      const a = DecoratedBoxAct(
        borderRadius: AnimatableValue<BorderRadiusGeometry>(
          from: BorderRadius.zero,
          to: BorderRadius.all(Radius.circular(10)),
        ),
      );
      const b = DecoratedBoxAct(
        borderRadius: AnimatableValue<BorderRadiusGeometry>(
          from: BorderRadius.zero,
          to: BorderRadius.all(Radius.circular(20)),
        ),
      );
      expect(a, isNot(equals(b)));
    });

    test('DecoratedBoxAct with different shape not equal', () {
      const a = DecoratedBoxAct(shape: BoxShape.rectangle);
      const b = DecoratedBoxAct(shape: BoxShape.circle);
      expect(a, isNot(equals(b)));
    });

    test('DecoratedBoxAct with different position not equal', () {
      const a = DecoratedBoxAct(position: DecorationPosition.background);
      const b = DecoratedBoxAct(position: DecorationPosition.foreground);
      expect(a, isNot(equals(b)));
    });

    test('DecoratedBoxAct.hashCode consistency', () {
      const a = DecoratedBoxAct();
      const b = DecoratedBoxAct();
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
