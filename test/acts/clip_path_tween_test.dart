import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';

void main() {
  group('ClipAct', () {
    test('ClipAct.circular creates valid instance', () {
      const act = ClipAct.circular();
      expect(act.key, equals(const ActKey('Clip')));
    });

    test('ClipAct.width creates valid instance', () {
      const act = ClipAct.width(fromFactor: 0, toFactor: 1);
      expect(act.key, equals(const ActKey('Clip')));
    });

    test('ClipAct.height creates valid instance', () {
      const act = ClipAct.height(fromFactor: 0, toFactor: 1);
      expect(act.key, equals(const ActKey('Clip')));
    });

    test('ClipAct with borderRadius creates valid instance', () {
      const act = ClipAct(borderRadius: BorderRadius.all(Radius.circular(10)));
      expect(act.key, equals(const ActKey('Clip')));
    });

    test('ClipAct with useSuperellipse creates valid instance', () {
      const act = ClipAct(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        useSuperellipse: true,
      );
      expect(act.key, equals(const ActKey('Clip')));
    });

    test('ClipAct.circular equality', () {
      const a = ClipAct.circular();
      const b = ClipAct.circular();
      expect(a, equals(b));
    });

    test('ClipAct.width equality', () {
      const a = ClipAct.width(fromFactor: 0, toFactor: 1);
      const b = ClipAct.width(fromFactor: 0, toFactor: 1);
      expect(a, equals(b));
    });

    test('ClipAct.height equality', () {
      const a = ClipAct.height(fromFactor: 0, toFactor: 1);
      const b = ClipAct.height(fromFactor: 0, toFactor: 1);
      expect(a, equals(b));
    });

    test('ClipAct.width vs height not equal', () {
      const a = ClipAct.width(fromFactor: 0, toFactor: 1);
      const b = ClipAct.height(fromFactor: 0, toFactor: 1);
      expect(a, isNot(equals(b)));
    });

    test('ClipAct with different alignment not equal', () {
      const a = ClipAct.circular(alignment: Alignment.center);
      const b = ClipAct.circular(alignment: Alignment.topLeft);
      expect(a, isNot(equals(b)));
    });

    test('ClipAct with different motion not equal', () {
      const a = ClipAct.circular(motion: CueMotion.none);
      const b = ClipAct.circular(motion: CueMotion.linear(Duration(milliseconds: 200)));
      expect(a, isNot(equals(b)));
    });

    test('ClipAct with different delay not equal', () {
      const a = ClipAct.circular(delay: Duration.zero);
      const b = ClipAct.circular(delay: Duration(milliseconds: 100));
      expect(a, isNot(equals(b)));
    });

    test('ClipAct.hashCode consistency', () {
      const a = ClipAct.circular();
      const b = ClipAct.circular();
      expect(a.hashCode, equals(b.hashCode));
    });

    test('ClipAct.width hashCode consistency', () {
      const a = ClipAct.width(fromFactor: 0, toFactor: 1);
      const b = ClipAct.width(fromFactor: 0, toFactor: 1);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('ClipAct.height hashCode consistency', () {
      const a = ClipAct.height(fromFactor: 0, toFactor: 1);
      const b = ClipAct.height(fromFactor: 0, toFactor: 1);
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('PathMotionAct', () {
    test('PathMotionAct creates valid instance', () {
      final path = Path()..addRect(Rect.fromLTWH(0, 0, 100, 100));
      final act = PathMotionAct(path: path);
      expect(act.key, equals(const ActKey('PathMotionAct')));
      expect(act.autoRotate, isFalse);
      expect(act.alignment, equals(Alignment.center));
    });

    test('PathMotionAct.circular creates valid instance', () {
      final act = PathMotionAct.circular(radius: 50);
      expect(act.key, equals(const ActKey('PathMotionAct')));
      expect(act.autoRotate, isFalse);
      expect(act.alignment, equals(Alignment.center));
    });

    test('PathMotionAct.arc creates valid instance', () {
      final act = PathMotionAct.arc(
        radius: 50,
        sweepAngle: 180,
      );
      expect(act.key, equals(const ActKey('PathMotionAct')));
      expect(act.autoRotate, isFalse);
      expect(act.alignment, equals(Alignment.center));
    });

    test('PathMotionAct with autoRotate creates valid instance', () {
      final path = Path()..addRect(Rect.fromLTWH(0, 0, 100, 100));
      final act = PathMotionAct(path: path, autoRotate: true);
      expect(act.autoRotate, isTrue);
    });

    test('PathMotionAct with custom alignment creates valid instance', () {
      final path = Path()..addRect(Rect.fromLTWH(0, 0, 100, 100));
      final act = PathMotionAct(path: path, alignment: Alignment.topLeft);
      expect(act.alignment, equals(Alignment.topLeft));
    });

    test('PathMotionAct with motion creates valid instance', () {
      final path = Path()..addRect(Rect.fromLTWH(0, 0, 100, 100));
      final act = PathMotionAct(path: path, motion: CueMotion.linear(Duration(milliseconds: 300)));
      expect(act.motion, equals(CueMotion.linear(Duration(milliseconds: 300))));
    });

    test('PathMotionAct with delay creates valid instance', () {
      final path = Path()..addRect(Rect.fromLTWH(0, 0, 100, 100));
      final act = PathMotionAct(path: path, delay: Duration(milliseconds: 100));
      expect(act.delay, equals(Duration(milliseconds: 100)));
    });

    test('PathMotionAct equality with same path', () {
      final path = Path()..addRect(Rect.fromLTWH(0, 0, 100, 100));
      final a = PathMotionAct(path: path);
      final b = PathMotionAct(path: path);
      expect(a, equals(b));
    });

    test('PathMotionAct with different autoRotate not equal', () {
      final path = Path()..addRect(Rect.fromLTWH(0, 0, 100, 100));
      final a = PathMotionAct(path: path, autoRotate: false);
      final b = PathMotionAct(path: path, autoRotate: true);
      expect(a, isNot(equals(b)));
    });

    test('PathMotionAct with different alignment not equal', () {
      final path = Path()..addRect(Rect.fromLTWH(0, 0, 100, 100));
      final a = PathMotionAct(path: path, alignment: Alignment.center);
      final b = PathMotionAct(path: path, alignment: Alignment.topLeft);
      expect(a, isNot(equals(b)));
    });

    test('PathMotionAct.hashCode consistency', () {
      final path = Path()..addRect(Rect.fromLTWH(0, 0, 100, 100));
      final a = PathMotionAct(path: path);
      final b = PathMotionAct(path: path);
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('TweenActor', () {
    test('TweenActor creates valid instance', () {
      final actor = TweenActor<double>(
        from: 0,
        to: 1,
        builder: (context, animation) => Container(),
      );
      expect(actor.from, equals(0));
      expect(actor.to, equals(1));
    });

    test('TweenActor.keyframed creates valid instance', () {
      final frames = MotionKeyframes<double>([
        Keyframe.key(0.0, motion: CueMotion.none),
        Keyframe.key(1.0, motion: CueMotion.none),
      ]);
      final actor = TweenActor<double>.keyframed(
        frames: frames,
        builder: (context, animation) => Container(),
      );
      expect(actor.frames, equals(frames));
    });

    test('TweenActor with motion creates valid instance', () {
      final actor = TweenActor<double>(
        from: 0,
        to: 1,
        motion: CueMotion.linear(Duration(milliseconds: 300)),
        builder: (context, animation) => Container(),
      );
      expect(actor.motion, equals(CueMotion.linear(Duration(milliseconds: 300))));
    });

    test('TweenActor with delay creates valid instance', () {
      final actor = TweenActor<double>(
        from: 0,
        to: 1,
        delay: Duration(milliseconds: 100),
        builder: (context, animation) => Container(),
      );
      expect(actor.delay, equals(Duration(milliseconds: 100)));
    });

    test('TweenActor with reverse creates valid instance', () {
      final actor = TweenActor<double>(
        from: 0,
        to: 1,
        reverse: ReverseBehavior<double>.mirror(),
        builder: (context, animation) => Container(),
      );
      expect(actor.reverse, equals(ReverseBehavior<double>.mirror()));
    });
  });

  group('AnimatedValues', () {
    test('AnimatedValues creates with defaults', () {
      const values = AnimatedValues();
      expect(values.scale, equals(1.0));
      expect(values.opacity, equals(1.0));
      expect(values.offset, equals(Offset.zero));
      expect(values.rotation, equals(0.0));
      expect(values.blur, equals(0.0));
      expect(values.color, isNull);
      expect(values.size, isNull);
    });

    test('AnimatedValues creates with custom values', () {
      const values = AnimatedValues(
        scale: 2.0,
        opacity: 0.5,
        offset: Offset(10, 20),
        rotation: 45.0,
        blur: 5.0,
        color: Color(0xFF000000),
        size: Size(100, 200),
      );
      expect(values.scale, equals(2.0));
      expect(values.opacity, equals(0.5));
      expect(values.offset, equals(Offset(10, 20)));
      expect(values.rotation, equals(45.0));
      expect(values.blur, equals(5.0));
      expect(values.color, equals(Color(0xFF000000)));
      expect(values.size, equals(Size(100, 200)));
    });

    test('AnimatedValues.lerpTo interpolates correctly', () {
      const start = AnimatedValues(scale: 1.0, opacity: 0.0);
      const end = AnimatedValues(scale: 2.0, opacity: 1.0);
      final mid = start.lerpTo(end, 0.5);
      expect(mid.scale, closeTo(1.5, 0.001));
      expect(mid.opacity, closeTo(0.5, 0.001));
    });

    test('AnimatedValues.lerpTo returns self for non-AnimatedValues', () {
      const values = AnimatedValues(scale: 1.0);
      final result = values.lerpTo(null, 0.5);
      expect(result, equals(values));
    });

    test('AnimatedValues.lerpTo with color interpolation', () {
      const start = AnimatedValues(color: Color(0xFF000000));
      const end = AnimatedValues(color: Color(0xFFFFFFFF));
      final mid = start.lerpTo(end, 0.5);
      expect(mid.color, isNotNull);
    });

    test('AnimatedValues.lerpTo with size interpolation', () {
      const start = AnimatedValues(size: Size(100, 100));
      const end = AnimatedValues(size: Size(200, 200));
      final mid = start.lerpTo(end, 0.5);
      expect(mid.size, isNotNull);
    });
  });
}
