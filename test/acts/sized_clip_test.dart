import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final motion = CueMotion.linear(300.ms);
  final actContext = ActContext(motion: motion, reverseMotion: motion);
 

  group('NSize', () {
    test('default constructor creates NSize with null values', () {
      const nsize = NSize();
      expect(nsize.w, isNull);
      expect(nsize.h, isNull);
    });

    test('constructor accepts width and height', () {
      const nsize = NSize(w: 100.0, h: 200.0);
      expect(nsize.w, equals(100.0));
      expect(nsize.h, equals(200.0));
    });

    test('childSize constant has null values', () {
      expect(NSize.childSize.w, isNull);
      expect(NSize.childSize.h, isNull);
    });

    test('infinity constant has infinite values', () {
      expect(NSize.infinity.w, equals(double.infinity));
      expect(NSize.infinity.h, equals(double.infinity));
    });

    test('zero constant has zero values', () {
      expect(NSize.zero.w, equals(0.0));
      expect(NSize.zero.h, equals(0.0));
    });

    test('size constructor creates from Size', () {
      final nsize = NSize.size(const Size(150.0, 250.0));
      expect(nsize.w, equals(150.0));
      expect(nsize.h, equals(250.0));
    });

    test('square constructor creates equal width and height', () {
      const nsize = NSize.square(100.0);
      expect(nsize.w, equals(100.0));
      expect(nsize.h, equals(100.0));
    });

    test('width constructor creates fixed width with null height', () {
      const nsize = NSize.width(150.0);
      expect(nsize.w, equals(150.0));
      expect(nsize.h, isNull);
    });

    test('height constructor creates fixed height with null width', () {
      const nsize = NSize.height(200.0);
      expect(nsize.w, isNull);
      expect(nsize.h, equals(200.0));
    });

    test('equality same values are equal', () {
      const nsize1 = NSize(w: 100.0, h: 200.0);
      const nsize2 = NSize(w: 100.0, h: 200.0);
      expect(nsize1, equals(nsize2));
    });

    test('equality different values are not equal', () {
      const nsize1 = NSize(w: 100.0, h: 200.0);
      const nsize2 = NSize(w: 150.0, h: 200.0);
      expect(nsize1, isNot(equals(nsize2)));
    });

    test('hashCode consistency', () {
      const nsize1 = NSize(w: 100.0, h: 200.0);
      const nsize2 = NSize(w: 100.0, h: 200.0);
      expect(nsize1.hashCode, equals(nsize2.hashCode));
    });

    test('toString returns readable format', () {
      const nsize = NSize(w: 100.0, h: 200.0);
      expect(nsize.toString(), contains('NSize'));
    });
  });

  group('ClipGeometry', () {
    test('rect constructor creates no border radius', () {
      const geometry = ClipGeometry.rect();
      expect(geometry.borderRadius, isNull);
      expect(geometry.useSuperEllipse, isFalse);
    });

    test('rrect constructor creates with border radius', () {
      const radius = BorderRadius.all(Radius.circular(10));
      const geometry = ClipGeometry.rrect(radius);
      expect(geometry.borderRadius, equals(radius));
      expect(geometry.useSuperEllipse, isFalse);
    });

    test('superEllipse constructor creates with border radius and superEllipse', () {
      const radius = BorderRadius.all(Radius.circular(10));
      const geometry = ClipGeometry.superEllipse(radius);
      expect(geometry.borderRadius, equals(radius));
      expect(geometry.useSuperEllipse, isTrue);
    });

    test('equality same values are equal', () {
      const radius = BorderRadius.all(Radius.circular(10));
      const geometry1 = ClipGeometry.rrect(radius);
      const geometry2 = ClipGeometry.rrect(radius);
      expect(geometry1, equals(geometry2));
    });

    test('equality different values are not equal', () {
      const radius1 = BorderRadius.all(Radius.circular(10));
      const radius2 = BorderRadius.all(Radius.circular(20));
      const geometry1 = ClipGeometry.rrect(radius1);
      const geometry2 = ClipGeometry.rrect(radius2);
      expect(geometry1, isNot(equals(geometry2)));
    });

    test('hashCode consistency', () {
      const radius = BorderRadius.all(Radius.circular(10));
      const geometry1 = ClipGeometry.rrect(radius);
      const geometry2 = ClipGeometry.rrect(radius);
      expect(geometry1.hashCode, equals(geometry2.hashCode));
    });
  });

  group('SizedClipAct', () {
    test('key has correct key name', () {
      const act = SizedClipAct();
      expect(act.key, equals(const ActKey('SizedClip')));
    });

    test('default constructor accepts from and to', () {
      const act = SizedClipAct(
        from: NSize(w: 100.0, h: 100.0),
        to: NSize(w: 200.0, h: 200.0),
      );
      expect(act.from, equals(const NSize(w: 100.0, h: 100.0)));
      expect(act.to, equals(const NSize(w: 200.0, h: 200.0)));
    });

    test('default constructor default values', () {
      const act = SizedClipAct();
      expect(act.from, equals(NSize.childSize));
      expect(act.to, equals(NSize.childSize));
      expect(act.alignment, isNull);
      expect(act.clipBehavior, equals(Clip.hardEdge));
    });

    test('default constructor accepts alignment', () {
      const act = SizedClipAct(alignment: Alignment.topLeft);
      expect(act.alignment, equals(Alignment.topLeft));
    });

    test('default constructor accepts clipBehavior', () {
      const act = SizedClipAct(clipBehavior: Clip.antiAlias);
      expect(act.clipBehavior, equals(Clip.antiAlias));
    });

    test('default constructor accepts motion', () {
      final motion = CueMotion.linear(300.ms);
      final act = SizedClipAct(motion: motion);
      expect(act.motion, equals(motion));
    });

    test('default constructor accepts delay', () {
      const act = SizedClipAct(delay: Duration(milliseconds: 100));
      expect(act.delay, equals(const Duration(milliseconds: 100)));
    });

    test('default constructor accepts clipGeometry', () {
      const radius = BorderRadius.all(Radius.circular(10));
      const geometry = ClipGeometry.rrect(radius);
      const act = SizedClipAct(clipGeometry: geometry);
      expect(act.clipGeometry, equals(geometry));
    });

    test('keyframed constructor accepts frames', () {
      final frames = Keyframes<NSize>([
        Keyframe(NSize.square(100.0), motion: CueMotion.linear(300.ms)),
      ]);
      final act = SizedClipAct.keyframed(frames: frames);
      expect(act.frames, isNotNull);
    });

    test('keyframed constructor accepts alignment', () {
      final frames = Keyframes<NSize>([
        Keyframe(NSize.square(100.0), motion: CueMotion.linear(300.ms)),
      ]);
      final act = SizedClipAct.keyframed(frames: frames, alignment: Alignment.center);
      expect(act.alignment, equals(Alignment.center));
    });

    test('resolve returns ActContext with motion', () {
      const act = SizedClipAct();
      
      final resolved = act.resolve(actContext);
      expect(resolved, isA<ActContext>());
    });

    test('equality equal acts have same hashCode', () {
      const act1 = SizedClipAct(
        from: NSize.square(100.0),
        to: NSize.square(200.0),
        alignment: Alignment.center,
      );
      const act2 = SizedClipAct(
        from: NSize.square(100.0),
        to: NSize.square(200.0),
        alignment: Alignment.center,
      );
      expect(act1, equals(act2));
      expect(act1.hashCode, equals(act2.hashCode));
    });

    test('equality different from are not equal', () {
      const act1 = SizedClipAct(from: NSize.square(100.0));
      const act2 = SizedClipAct(from: NSize.square(200.0));
      expect(act1, isNot(equals(act2)));
    });

    test('equality different to are not equal', () {
      const act1 = SizedClipAct(to: NSize.square(100.0));
      const act2 = SizedClipAct(to: NSize.square(200.0));
      expect(act1, isNot(equals(act2)));
    });

    test('equality different alignments are not equal', () {
      const act1 = SizedClipAct(alignment: Alignment.center);
      const act2 = SizedClipAct(alignment: Alignment.topLeft);
      expect(act1, isNot(equals(act2)));
    });

    test('equality different clipBehaviors are not equal', () {
      const act1 = SizedClipAct(clipBehavior: Clip.hardEdge);
      const act2 = SizedClipAct(clipBehavior: Clip.antiAlias);
      expect(act1, isNot(equals(act2)));
    });

    test('equality different clipGeometry are not equal', () {
      const act1 = SizedClipAct(clipGeometry: ClipGeometry.rect());
      const act2 = SizedClipAct(
        clipGeometry: ClipGeometry.rrect(BorderRadius.all(Radius.circular(10))),
      );
      expect(act1, isNot(equals(act2)));
    });
  });
}
