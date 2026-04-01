import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';

void main() {
  group('DeferredTweenAct', () {
    test('SizedClipAct keyframed constructor creates valid instance', () {
      final frames = MotionKeyframes<NSize>([
        Keyframe.key(NSize(w: 100, h: 100), motion: CueMotion.none),
        Keyframe.key(NSize(w: 200, h: 200), motion: CueMotion.none),
      ]);

      final act = SizedClipAct.keyframed(frames: frames);
      expect(act.key, equals(const ActKey('SizedClip')));
      expect(act.frames, equals(frames));
      expect(act.from, isNull);
      expect(act.to, isNull);
    });

    test('SizedClipAct equality with keyframed', () {
      final frames = MotionKeyframes<NSize>([
        Keyframe.key(NSize(w: 100, h: 100), motion: CueMotion.none),
      ]);

      final a = SizedClipAct.keyframed(frames: frames);
      final b = SizedClipAct.keyframed(frames: frames);
      expect(a, equals(b));
    });

    test('SizedClipAct keyframed vs default not equal', () {
      final frames = MotionKeyframes<NSize>([
        Keyframe.key(NSize(w: 100, h: 100), motion: CueMotion.none),
      ]);

      final a = SizedClipAct.keyframed(frames: frames);
      const b = SizedClipAct();
      expect(a, isNot(equals(b)));
    });

    test('SizedClipAct with different frames not equal', () {
      final framesA = MotionKeyframes<NSize>([
        Keyframe.key(NSize(w: 100, h: 100), motion: CueMotion.none),
      ]);
      final framesB = MotionKeyframes<NSize>([
        Keyframe.key(NSize(w: 200, h: 200), motion: CueMotion.none),
      ]);

      final a = SizedClipAct.keyframed(frames: framesA);
      final b = SizedClipAct.keyframed(frames: framesB);
      expect(a, isNot(equals(b)));
    });

    test('SizedClipAct with different delay not equal', () {
      final frames = MotionKeyframes<NSize>([
        Keyframe.key(NSize(w: 100, h: 100), motion: CueMotion.none),
      ]);

      final a = SizedClipAct.keyframed(frames: frames, delay: Duration(milliseconds: 100));
      final b = SizedClipAct.keyframed(frames: frames, delay: Duration(milliseconds: 200));
      expect(a, isNot(equals(b)));
    });

    test('NSize constructors', () {
      const size = NSize(w: 100, h: 200);
      expect(size.w, equals(100));
      expect(size.h, equals(200));

      const childSize = NSize.childSize;
      expect(childSize.w, isNull);
      expect(childSize.h, isNull);

      const infinity = NSize.infinity;
      expect(infinity.w, equals(double.infinity));
      expect(infinity.h, equals(double.infinity));

      const zero = NSize.zero;
      expect(zero.w, equals(0));
      expect(zero.h, equals(0));

      const square = NSize.square(50);
      expect(square.w, equals(50));
      expect(square.h, equals(50));

      const widthOnly = NSize.width(100);
      expect(widthOnly.w, equals(100));
      expect(widthOnly.h, isNull);

      const heightOnly = NSize.height(200);
      expect(heightOnly.w, isNull);
      expect(heightOnly.h, equals(200));

      final fromSize = NSize.size(Size(150, 250));
      expect(fromSize.w, equals(150));
      expect(fromSize.h, equals(250));
    });

    test('NSize toString', () {
      const size = NSize(w: 100, h: 200);
      expect(size.toString(), equals('NSize(width: 100.0, height: 200.0)'));
    });

    test('ClipGeometry constructors', () {
      const rect = ClipGeometry.rect();
      expect(rect.borderRadius, isNull);
      expect(rect.useSuperEllipse, isFalse);

      const rrect = ClipGeometry.rrect(BorderRadius.all(Radius.circular(10)));
      expect(rrect.borderRadius, isNotNull);
      expect(rrect.useSuperEllipse, isFalse);

      const superEllipse = ClipGeometry.superEllipse(BorderRadius.all(Radius.circular(10)));
      expect(superEllipse.borderRadius, isNotNull);
      expect(superEllipse.useSuperEllipse, isTrue);
    });

    test('SizedClipAct with different alignment not equal', () {
      const a = SizedClipAct(alignment: Alignment.center);
      const b = SizedClipAct(alignment: Alignment.topLeft);
      expect(a, isNot(equals(b)));
    });

    test('SizedClipAct with different clipBehavior not equal', () {
      const a = SizedClipAct(clipBehavior: Clip.hardEdge);
      const b = SizedClipAct(clipBehavior: Clip.antiAlias);
      expect(a, isNot(equals(b)));
    });

    test('SizedClipAct with different clipGeometry not equal', () {
      const a = SizedClipAct(clipGeometry: ClipGeometry.rect());
      const b = SizedClipAct(clipGeometry: ClipGeometry.rrect(BorderRadius.all(Radius.circular(10))));
      expect(a, isNot(equals(b)));
    });

    test('SizedClipAct hashCode consistency', () {
      const a = SizedClipAct(from: NSize(w: 100, h: 100), to: NSize(w: 200, h: 200));
      const b = SizedClipAct(from: NSize(w: 100, h: 100), to: NSize(w: 200, h: 200));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
