import 'package:cue/src/motion/cue_motion.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';

void main() {
  group('ActKey equality', () {
    test('same key are equal', () {
      const a = ActKey('Opacity');
      const b = ActKey('Opacity');
      expect(a, equals(b));
    });

    test('different key are not equal', () {
      const a = ActKey('Opacity');
      const b = ActKey('Scale');
      expect(a, isNot(equals(b)));
    });

    test('same key different desc still equal', () {
      const a = ActKey('Opacity', 'desc1');
      const b = ActKey('Opacity', 'desc2');
      expect(a, equals(b));
    });
  });

  group('AnimatableValue equality', () {
    test('identical from/to are equal', () {
      const a = AnimatableValue<double>(from: 0.0, to: 1.0);
      const b = AnimatableValue<double>(from: 0.0, to: 1.0);
      expect(a, equals(b));
    });

    test('different from are not equal', () {
      const a = AnimatableValue<double>(from: 0.0, to: 1.0);
      const b = AnimatableValue<double>(from: 0.5, to: 1.0);
      expect(a, isNot(equals(b)));
    });

    test('different to are not equal', () {
      const a = AnimatableValue<double>(from: 0.0, to: 1.0);
      const b = AnimatableValue<double>(from: 0.0, to: 0.5);
      expect(a, isNot(equals(b)));
    });

    test('fixed value is equal to same fixed', () {
      const a = AnimatableValue.fixed(5.0);
      const b = AnimatableValue.fixed(5.0);
      expect(a, equals(b));
    });

    test('fixed is the same as tween with same values', () {
      const a = AnimatableValue.fixed(5.0);
      const b = AnimatableValue<double>(from: 5.0, to: 5.0);
      expect(a, equals(b));
    });
  });

  group('ReverseBehavior equality', () {
    test('mirror defaults are equal', () {
      const a = ReverseBehavior<double>.mirror();
      const b = ReverseBehavior<double>.mirror();
      expect(a, equals(b));
    });

    test('mirror with different motion are not equal', () {
      const a = ReverseBehavior<double>.mirror(motion: CueMotion.none);
      const b = ReverseBehavior<double>.mirror(motion: CueMotion.linear(Duration(milliseconds: 200)));
      expect(a, isNot(equals(b)));
    });

    test('mirror with same motion are equal', () {
      const a = ReverseBehavior<double>.mirror(motion: CueMotion.linear(Duration(milliseconds: 200)));
      const b = ReverseBehavior<double>.mirror(motion: CueMotion.linear(Duration(milliseconds: 200)));
      expect(a, equals(b));
    });

    test('mirror with different delay are not equal', () {
      const a = ReverseBehavior<double>.mirror(delay: Duration.zero);
      const b = ReverseBehavior<double>.mirror(delay: Duration(milliseconds: 100));
      expect(a, isNot(equals(b)));
    });

    test('mirror with same delay are equal', () {
      const a = ReverseBehavior<double>.mirror(delay: Duration(milliseconds: 150));
      const b = ReverseBehavior<double>.mirror(delay: Duration(milliseconds: 150));
      expect(a, equals(b));
    });

    test('mirror with motion and delay combination', () {
      const a = ReverseBehavior<double>.mirror(
        motion: CueMotion.linear(Duration(milliseconds: 100)),
        delay: Duration(milliseconds: 50),
      );
      const b = ReverseBehavior<double>.mirror(
        motion: CueMotion.linear(Duration(milliseconds: 100)),
        delay: Duration(milliseconds: 50),
      );
      expect(a, equals(b));
    });

    test('mirror with same motion different delay not equal', () {
      const a = ReverseBehavior<double>.mirror(
        motion: CueMotion.linear(Duration(milliseconds: 100)),
        delay: Duration(milliseconds: 50),
      );
      const b = ReverseBehavior<double>.mirror(
        motion: CueMotion.linear(Duration(milliseconds: 100)),
        delay: Duration(milliseconds: 100),
      );
      expect(a, isNot(equals(b)));
    });

    test('mirror with different motion same delay not equal', () {
      const a = ReverseBehavior<double>.mirror(
        motion: CueMotion.linear(Duration(milliseconds: 100)),
        delay: Duration(milliseconds: 50),
      );
      const b = ReverseBehavior<double>.mirror(
        motion: CueMotion.linear(Duration(milliseconds: 200)),
        delay: Duration(milliseconds: 50),
      );
      expect(a, isNot(equals(b)));
    });

    test('exclusive are equal', () {
      const a = ReverseBehavior<double>.exclusive();
      const b = ReverseBehavior<double>.exclusive();
      expect(a, equals(b));
    });

    test('none are equal', () {
      const a = ReverseBehavior<double>.none();
      const b = ReverseBehavior<double>.none();
      expect(a, equals(b));
    });

    test('to with same value are equal', () {
      const a = ReverseBehavior<double>.to(0.5);
      const b = ReverseBehavior<double>.to(0.5);
      expect(a, equals(b));
    });

    test('to with different value are not equal', () {
      const a = ReverseBehavior<double>.to(0.5);
      const b = ReverseBehavior<double>.to(0.8);
      expect(a, isNot(equals(b)));
    });

    test('to with same motion are equal', () {
      const a = ReverseBehavior<double>.to(0.5, motion: CueMotion.linear(Duration(milliseconds: 100)));
      const b = ReverseBehavior<double>.to(0.5, motion: CueMotion.linear(Duration(milliseconds: 100)));
      expect(a, equals(b));
    });

    test('to with different motion are not equal', () {
      const a = ReverseBehavior<double>.to(0.5, motion: CueMotion.linear(Duration(milliseconds: 100)));
      const b = ReverseBehavior<double>.to(0.5, motion: CueMotion.linear(Duration(milliseconds: 200)));
      expect(a, isNot(equals(b)));
    });

    test('to with same delay are equal', () {
      const a = ReverseBehavior<double>.to(0.5, delay: Duration(milliseconds: 50));
      const b = ReverseBehavior<double>.to(0.5, delay: Duration(milliseconds: 50));
      expect(a, equals(b));
    });

    test('to with different delay are not equal', () {
      const a = ReverseBehavior<double>.to(0.5, delay: Duration(milliseconds: 50));
      const b = ReverseBehavior<double>.to(0.5, delay: Duration(milliseconds: 100));
      expect(a, isNot(equals(b)));
    });

    test('different types are not equal', () {
      const a = ReverseBehavior<double>.mirror();
      const b = ReverseBehavior<double>.exclusive();
      expect(a, isNot(equals(b)));
    });

    test('mirror vs none not equal', () {
      const a = ReverseBehavior<double>.mirror();
      const b = ReverseBehavior<double>.none();
      expect(a, isNot(equals(b)));
    });

    test('exclusive vs none not equal', () {
      const a = ReverseBehavior<double>.exclusive();
      const b = ReverseBehavior<double>.none();
      expect(a, isNot(equals(b)));
    });

    test('mirror vs to not equal', () {
      const a = ReverseBehavior<double>.mirror();
      const b = ReverseBehavior<double>.to(0.5);
      expect(a, isNot(equals(b)));
    });

    test('equal ReverseBehaviors have same hashCode', () {
      const a = ReverseBehavior<double>.mirror(
        motion: CueMotion.linear(Duration(milliseconds: 100)),
        delay: Duration(milliseconds: 50),
      );
      const b = ReverseBehavior<double>.mirror(
        motion: CueMotion.linear(Duration(milliseconds: 100)),
        delay: Duration(milliseconds: 50),
      );
      expect(a.hashCode, equals(b.hashCode));
    });

    test('different ReverseBehaviors typically have different hashCode', () {
      const a = ReverseBehavior<double>.mirror(delay: Duration(milliseconds: 50));
      const b = ReverseBehavior<double>.mirror(delay: Duration(milliseconds: 100));
      expect(a.hashCode, isNot(equals(b.hashCode)));
    });
  });

  group('KFReverseBehavior equality', () {
    test('mirror defaults are equal', () {
      const a = KFReverseBehavior<double>.mirror();
      const b = KFReverseBehavior<double>.mirror();
      expect(a, equals(b));
    });

    test('mirror with same delay are equal', () {
      const a = KFReverseBehavior<double>.mirror(delay: Duration(milliseconds: 50));
      const b = KFReverseBehavior<double>.mirror(delay: Duration(milliseconds: 50));
      expect(a, equals(b));
    });

    test('mirror with different delay are not equal', () {
      const a = KFReverseBehavior<double>.mirror(delay: Duration.zero);
      const b = KFReverseBehavior<double>.mirror(delay: Duration(milliseconds: 100));
      expect(a, isNot(equals(b)));
    });

    test('exclusive are equal', () {
      const a = KFReverseBehavior<double>.exclusive();
      const b = KFReverseBehavior<double>.exclusive();
      expect(a, equals(b));
    });

    test('none are equal', () {
      const a = KFReverseBehavior<double>.none();
      const b = KFReverseBehavior<double>.none();
      expect(a, equals(b));
    });

    test('to with same frames are equal', () {
      final frames = MotionKeyframes([Keyframe.key(0.5)],motion: CueMotion.none);
      final a = KFReverseBehavior<double>.to(frames);
      final b = KFReverseBehavior<double>.to(frames);
      expect(a, equals(b));
    });

    test('to with different frames are not equal', () {
      final a = KFReverseBehavior<double>.to(MotionKeyframes([Keyframe.key(0.5)], motion: CueMotion.none));
      final b = KFReverseBehavior<double>.to(MotionKeyframes([Keyframe.key(0.8)], motion: CueMotion.none));
      expect(a, isNot(equals(b)));
    });

    test('to with same delay are equal', () {
      final frames = MotionKeyframes([Keyframe.key(0.5)], motion: CueMotion.none);
      final a = KFReverseBehavior<double>.to(frames, delay: const Duration(milliseconds: 50));
      final b = KFReverseBehavior<double>.to(frames, delay: const Duration(milliseconds: 50));
      expect(a, equals(b));
    });

    test('to with different delay are not equal', () {
      final frames = MotionKeyframes([Keyframe.key(0.5)], motion: CueMotion.none);
      final a = KFReverseBehavior<double>.to(frames, delay: const Duration(milliseconds: 50));
      final b = KFReverseBehavior<double>.to(frames, delay: const Duration(milliseconds: 100));
      expect(a, isNot(equals(b)));
    });

    test('different types are not equal', () {
      const a = KFReverseBehavior<double>.mirror();
      const b = KFReverseBehavior<double>.exclusive();
      expect(a, isNot(equals(b)));
    });

    test('mirror vs none not equal', () {
      const a = KFReverseBehavior<double>.mirror();
      const b = KFReverseBehavior<double>.none();
      expect(a, isNot(equals(b)));
    });

    test('exclusive vs none not equal', () {
      const a = KFReverseBehavior<double>.exclusive();
      const b = KFReverseBehavior<double>.none();
      expect(a, isNot(equals(b)));
    });

    test('mirror vs to not equal', () {
      const a = KFReverseBehavior<double>.mirror();
      final b = KFReverseBehavior<double>.to(MotionKeyframes([Keyframe.key(0.5)], motion: CueMotion.none));
      expect(a, isNot(equals(b)));
    });

    test('equal KFReverseBehaviors have same hashCode', () {
      const a = KFReverseBehavior<double>.mirror(delay: Duration(milliseconds: 50));
      const b = KFReverseBehavior<double>.mirror(delay: Duration(milliseconds: 50));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('CueMotion equality', () {
    test('TimedMotion with same duration are equal', () {
      const a = CueMotion.linear(Duration(milliseconds: 200));
      const b = CueMotion.linear(Duration(milliseconds: 200));
      expect(a, equals(b));
    });

    test('TimedMotion with different duration are not equal', () {
      const a = CueMotion.linear(Duration(milliseconds: 200));
      const b = CueMotion.linear(Duration(milliseconds: 300));
      expect(a, isNot(equals(b)));
    });

    test('TimedMotion.curved with same curve are equal', () {
      const a = CueMotion.curved(Duration(milliseconds: 200), curve: Curves.easeInOut);
      const b = CueMotion.curved(Duration(milliseconds: 200), curve: Curves.easeInOut);
      expect(a, equals(b));
    });

    test('TimedMotion.curved with different curve are not equal', () {
      const a = CueMotion.curved(Duration(milliseconds: 200), curve: Curves.easeIn);
      const b = CueMotion.curved(Duration(milliseconds: 200), curve: Curves.easeOut);
      expect(a, isNot(equals(b)));
    });

    test('CueMotion.none is equal to itself', () {
      expect(CueMotion.none, equals(CueMotion.none));
    });

    test('Spring.smooth with same defaults are equal', () {
      const a = CueMotion.smooth();
      const b = CueMotion.smooth();
      expect(a, equals(b));
    });

    test('Spring.gentle with same defaults are equal', () {
      const a = CueMotion.gentle();
      const b = CueMotion.gentle();
      expect(a, equals(b));
    });
 

    test('Spring.bouncy with same defaults are equal', () {
      const a = CueMotion.bouncy();
      const b = CueMotion.bouncy();
      expect(a, equals(b));
    });

    test('Spring.wobbly with same defaults are equal', () {
      const a = CueMotion.wobbly();
      const b = CueMotion.wobbly();
      expect(a, equals(b));
    });

    test('Spring.snappy with same defaults are equal', () {
      const a = CueMotion.snappy();
      const b = CueMotion.snappy();
      expect(a, equals(b));
    });

    test('Spring.custom with same parameters are equal', () {
      const a = Spring.withDampingRatio(mass: 1.0, stiffness: 100.0, ratio: 0.1);
      const b = Spring.withDampingRatio(mass: 1.0, stiffness: 100.0, ratio: 0.1);
      expect(a, equals(b));
    });

    test('Spring.custom with different mass are not equal', () {
      const a = Spring.withDampingRatio(mass: 1.0, stiffness: 100.0, ratio: 0.1);
      const b = Spring.withDampingRatio(mass: 2.0, stiffness: 100.0, ratio: 0.1);
      expect(a, isNot(equals(b)));
    });

    test('Spring.custom with different stiffness are not equal', () {
      const a = Spring.withDampingRatio(mass: 1.0, stiffness: 100.0, ratio: 0.1);
      const b = Spring.withDampingRatio(mass: 1.0, stiffness: 200.0, ratio: 0.1);
      expect(a, isNot(equals(b)));
    });

    test('Spring.custom with different damping are not equal', () {
      const a = Spring.withDampingRatio(mass: 1.0, stiffness: 100.0, ratio: 0.1);
      const b = Spring.withDampingRatio(mass: 1.0, stiffness: 100.0, ratio: 0.2);
      expect(a, isNot(equals(b)));
    });

    test('Spring.custom with different snapToEnd are not equal', () {
      const a = Spring.withDampingRatio(mass: 1.0, stiffness: 100.0, ratio: 0.1, snapToEnd: true);
      const b = Spring.withDampingRatio(mass: 1.0, stiffness: 100.0, ratio: 0.1, snapToEnd: false);
      expect(a, isNot(equals(b)));
    });

    test('different Spring presets are not equal', () {
      const a = CueMotion.smooth();
      const b = CueMotion.bouncy();
      expect(a, isNot(equals(b)));
    });

    test('SegmentedMotion with same motions are equal', () {
      const a = SegmentedMotion([
        CueMotion.linear(Duration(milliseconds: 100)),
        CueMotion.linear(Duration(milliseconds: 200)),
      ]);
      const b = SegmentedMotion([
        CueMotion.linear(Duration(milliseconds: 100)),
        CueMotion.linear(Duration(milliseconds: 200)),
      ]);
      expect(a, equals(b));
    });

    test('SegmentedMotion with different motions are not equal', () {
      const a = SegmentedMotion([
        CueMotion.linear(Duration(milliseconds: 100)),
        CueMotion.linear(Duration(milliseconds: 200)),
      ]);
      const b = SegmentedMotion([
        CueMotion.linear(Duration(milliseconds: 100)),
        CueMotion.linear(Duration(milliseconds: 300)),
      ]);
      expect(a, isNot(equals(b)));
    });

    test('SegmentedMotion with different lengths are not equal', () {
      const a = SegmentedMotion([CueMotion.linear(Duration(milliseconds: 100))]);
      const b = SegmentedMotion([
        CueMotion.linear(Duration(milliseconds: 100)),
        CueMotion.linear(Duration(milliseconds: 200)),
      ]);
      expect(a, isNot(equals(b)));
    });

    test('DelayedMotion with same base and delay are equal', () {
      final a = CueMotion.linear(Duration(milliseconds: 200)).delayed(const Duration(milliseconds: 50));
      final b = CueMotion.linear(Duration(milliseconds: 200)).delayed(const Duration(milliseconds: 50));
      expect(a, equals(b));
    });

    test('DelayedMotion with different delay are not equal', () {
      final a = CueMotion.linear(Duration(milliseconds: 200)).delayed(const Duration(milliseconds: 50));
      final b = CueMotion.linear(Duration(milliseconds: 200)).delayed(const Duration(milliseconds: 100));
      expect(a, isNot(equals(b)));
    });

    test('DelayedMotion with different base are not equal', () {
      final a = CueMotion.linear(Duration(milliseconds: 200)).delayed(const Duration(milliseconds: 50));
      final b = CueMotion.linear(Duration(milliseconds: 300)).delayed(const Duration(milliseconds: 50));
      expect(a, isNot(equals(b)));
    });

    test('equal TimedMotions have same hashCode', () {
      const a = CueMotion.linear(Duration(milliseconds: 200));
      const b = CueMotion.linear(Duration(milliseconds: 200));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equal Springs have same hashCode', () {
      const a = Spring.withDampingRatio(mass: 1.0, stiffness: 100.0, ratio: 0.1);
      const b = Spring.withDampingRatio(mass: 1.0, stiffness: 100.0, ratio: 0.1);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equal SegmentedMotions have same hashCode', () {
      const a = SegmentedMotion([CueMotion.linear(Duration(milliseconds: 100))]);
      const b = SegmentedMotion([CueMotion.linear(Duration(milliseconds: 100))]);
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('Stretch equality', () {
    test('same values are equal', () {
      const a = Stretch(x: 1.5, y: 2.0);
      const b = Stretch(x: 1.5, y: 2.0);
      expect(a, equals(b));
    });

    test('different x are not equal', () {
      const a = Stretch(x: 1.5, y: 2.0);
      const b = Stretch(x: 1.0, y: 2.0);
      expect(a, isNot(equals(b)));
    });

    test('different y are not equal', () {
      const a = Stretch(x: 1.5, y: 2.0);
      const b = Stretch(x: 1.5, y: 1.0);
      expect(a, isNot(equals(b)));
    });
  });

  group('Rotation3D equality', () {
    test('same values are equal', () {
      const a = Rotation3D(x: 10, y: 20, z: 30);
      const b = Rotation3D(x: 10, y: 20, z: 30);
      expect(a, equals(b));
    });

    test('different x are not equal', () {
      const a = Rotation3D(x: 10, y: 20, z: 30);
      const b = Rotation3D(x: 5, y: 20, z: 30);
      expect(a, isNot(equals(b)));
    });

    test('different y are not equal', () {
      const a = Rotation3D(x: 10, y: 20, z: 30);
      const b = Rotation3D(x: 10, y: 5, z: 30);
      expect(a, isNot(equals(b)));
    });

    test('different z are not equal', () {
      const a = Rotation3D(x: 10, y: 20, z: 30);
      const b = Rotation3D(x: 10, y: 20, z: 5);
      expect(a, isNot(equals(b)));
    });
  });

  group('Skew equality', () {
    test('same values are equal', () {
      const a = Skew(x: 0.5, y: 0.3);
      const b = Skew(x: 0.5, y: 0.3);
      expect(a, equals(b));
    });

    test('different values are not equal', () {
      const a = Skew(x: 0.5, y: 0.3);
      const b = Skew(x: 0.1, y: 0.3);
      expect(a, isNot(equals(b)));
    });
  });

  group('NSize equality', () {
    test('same values are equal', () {
      const a = NSize(w: 100, h: 200);
      const b = NSize(w: 100, h: 200);
      expect(a, equals(b));
    });

    test('childSize are equal', () {
      const a = NSize.childSize;
      const b = NSize.childSize;
      expect(a, equals(b));
    });

    test('different values are not equal', () {
      const a = NSize(w: 100, h: 200);
      const b = NSize(w: 100, h: 300);
      expect(a, isNot(equals(b)));
    });

    test('null vs non-null are not equal', () {
      const a = NSize(w: 100, h: null);
      const b = NSize(w: 100, h: 200);
      expect(a, isNot(equals(b)));
    });
  });

  group('ClipGeometry equality', () {
    test('rect are equal', () {
      const a = ClipGeometry.rect();
      const b = ClipGeometry.rect();
      expect(a, equals(b));
    });

    test('rrect with same radius are equal', () {
      const a = ClipGeometry.rrect(BorderRadius.all(Radius.circular(10)));
      const b = ClipGeometry.rrect(BorderRadius.all(Radius.circular(10)));
      expect(a, equals(b));
    });

    test('rrect with different radius are not equal', () {
      const a = ClipGeometry.rrect(BorderRadius.all(Radius.circular(10)));
      const b = ClipGeometry.rrect(BorderRadius.all(Radius.circular(20)));
      expect(a, isNot(equals(b)));
    });

    test('superEllipse with same radius are equal', () {
      const a = ClipGeometry.superEllipse(BorderRadius.all(Radius.circular(10)));
      const b = ClipGeometry.superEllipse(BorderRadius.all(Radius.circular(10)));
      expect(a, equals(b));
    });

    test('rect vs rrect are not equal', () {
      const a = ClipGeometry.rect();
      const b = ClipGeometry.rrect(BorderRadius.all(Radius.circular(10)));
      expect(a, isNot(equals(b)));
    });

    test('rrect vs superEllipse are not equal', () {
      const a = ClipGeometry.rrect(BorderRadius.all(Radius.circular(10)));
      const b = ClipGeometry.superEllipse(BorderRadius.all(Radius.circular(10)));
      expect(a, isNot(equals(b)));
    });
  });

  group('CardProps equality', () {
    test('default values are equal', () {
      const a = CardProps();
      const b = CardProps();
      expect(a, equals(b));
    });

    test('same values are equal', () {
      const a = CardProps(
        elevation: 4,
        color: Color(0xFF000000),
        shadowColor: Color(0xFF111111),
        surfaceTintColor: Color(0xFF222222),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        margin: EdgeInsets.all(4),
      );
      final b = CardProps(
        elevation: 4,
        color: Color(0xFF000000),
        shadowColor: Color(0xFF111111),
        surfaceTintColor: Color(0xFF222222),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        margin: EdgeInsets.all(4),
      );
      expect(a, equals(b));
    });

    test('different elevation are not equal', () {
      const a = CardProps(elevation: 4);
      const b = CardProps(elevation: 8);
      expect(a, isNot(equals(b)));
    });

    test('different color are not equal', () {
      const a = CardProps(color: Color(0xFF000000));
      const b = CardProps(color: Color(0xFFFFFFFF));
      expect(a, isNot(equals(b)));
    });
  });

  // ─── TweenActBase acts (inherited equality) ───────────────────────

  group('OpacityAct equality', () {
    test('identical defaults are equal', () {
      const a = OpacityAct(from: 0.0, to: 1.0);
      const b = OpacityAct(from: 0.0, to: 1.0);
      expect(a, equals(b));
    });

    test('different from are not equal', () {
      const a = OpacityAct(from: 0.0, to: 1.0);
      const b = OpacityAct(from: 0.5, to: 1.0);
      expect(a, isNot(equals(b)));
    });

    test('different to are not equal', () {
      const a = OpacityAct(from: 0.0, to: 1.0);
      const b = OpacityAct(from: 0.0, to: 0.5);
      expect(a, isNot(equals(b)));
    });

    test('different motion are not equal', () {
      const a = OpacityAct(from: 0.0, to: 1.0, motion: CueMotion.none);
      const b = OpacityAct(from: 0.0, to: 1.0, motion: CueMotion.linear(Duration(milliseconds: 200)));
      expect(a, isNot(equals(b)));
    });

    test('different delay are not equal', () {
      const a = OpacityAct(from: 0.0, to: 1.0, delay: Duration.zero);
      const b = OpacityAct(from: 0.0, to: 1.0, delay: Duration(milliseconds: 100));
      expect(a, isNot(equals(b)));
    });

    test('different reverse are not equal', () {
      const a = OpacityAct(from: 0.0, to: 1.0, reverse: ReverseBehavior.mirror());
      const b = OpacityAct(from: 0.0, to: 1.0, reverse: ReverseBehavior.none());
      expect(a, isNot(equals(b)));
    });

    test('fadeIn defaults are equal', () {
      const a = OpacityAct.fadeIn();
      const b = OpacityAct.fadeIn();
      expect(a, equals(b));
    });

    test('fadeOut defaults are equal', () {
      const a = OpacityAct.fadeOut();
      const b = OpacityAct.fadeOut();
      expect(a, equals(b));
    });

    test('fadeIn vs fadeOut are not equal', () {
      const a = OpacityAct.fadeIn();
      const b = OpacityAct.fadeOut();
      expect(a, isNot(equals(b)));
    });
  });

  group('BlurAct equality', () {
    test('identical defaults are equal', () {
      const a = BlurAct(from: 0.0, to: 5.0);
      const b = BlurAct(from: 0.0, to: 5.0);
      expect(a, equals(b));
    });

    test('different from are not equal', () {
      const a = BlurAct(from: 0.0, to: 5.0);
      const b = BlurAct(from: 2.0, to: 5.0);
      expect(a, isNot(equals(b)));
    });

    test('focus defaults are equal', () {
      const a = BlurAct.focus();
      const b = BlurAct.focus();
      expect(a, equals(b));
    });

    test('unfocus defaults are equal', () {
      const a = BlurAct.unfocus();
      const b = BlurAct.unfocus();
      expect(a, equals(b));
    });

    test('focus vs unfocus are not equal', () {
      const a = BlurAct.focus();
      const b = BlurAct.unfocus();
      expect(a, isNot(equals(b)));
    });
  });

  group('PaddingAct equality', () {
    test('identical values are equal', () {
      const a = PaddingAct(from: EdgeInsets.all(10), to: EdgeInsets.all(20));
      const b = PaddingAct(from: EdgeInsets.all(10), to: EdgeInsets.all(20));
      expect(a, equals(b));
    });

    test('different from are not equal', () {
      const a = PaddingAct(from: EdgeInsets.all(10), to: EdgeInsets.all(20));
      const b = PaddingAct(from: EdgeInsets.all(5), to: EdgeInsets.all(20));
      expect(a, isNot(equals(b)));
    });

    test('different to are not equal', () {
      const a = PaddingAct(from: EdgeInsets.all(10), to: EdgeInsets.all(20));
      const b = PaddingAct(from: EdgeInsets.all(10), to: EdgeInsets.all(30));
      expect(a, isNot(equals(b)));
    });

    test('different motion are not equal', () {
      const a = PaddingAct(from: EdgeInsets.all(10), to: EdgeInsets.all(20), motion: CueMotion.none);
      const b = PaddingAct(
        from: EdgeInsets.all(10),
        to: EdgeInsets.all(20),
        motion: CueMotion.linear(Duration(milliseconds: 100)),
      );
      expect(a, isNot(equals(b)));
    });

    test('different delay are not equal', () {
      const a = PaddingAct(from: EdgeInsets.all(10), to: EdgeInsets.all(20), delay: Duration(milliseconds: 50));
      const b = PaddingAct(from: EdgeInsets.all(10), to: EdgeInsets.all(20), delay: Duration(milliseconds: 100));
      expect(a, isNot(equals(b)));
    });

    test('different reverse are not equal', () {
      const a = PaddingAct(from: EdgeInsets.all(10), to: EdgeInsets.all(20), reverse: ReverseBehavior.mirror());
      const b = PaddingAct(from: EdgeInsets.all(10), to: EdgeInsets.all(20), reverse: ReverseBehavior.none());
      expect(a, isNot(equals(b)));
    });
  });

  group('AlignAct equality', () {
    test('identical values are equal', () {
      const a = AlignAct(from: Alignment.topLeft, to: Alignment.bottomRight);
      const b = AlignAct(from: Alignment.topLeft, to: Alignment.bottomRight);
      expect(a, equals(b));
    });

    test('different from are not equal', () {
      const a = AlignAct(from: Alignment.topLeft, to: Alignment.bottomRight);
      const b = AlignAct(from: Alignment.center, to: Alignment.bottomRight);
      expect(a, isNot(equals(b)));
    });

    test('different to are not equal', () {
      const a = AlignAct(from: Alignment.topLeft, to: Alignment.bottomRight);
      const b = AlignAct(from: Alignment.topLeft, to: Alignment.topRight);
      expect(a, isNot(equals(b)));
    });
  });

  group('ColorTintAct equality', () {
    test('identical values are equal', () {
      const a = ColorTintAct(from: Color(0xFF000000), to: Color(0xFFFFFFFF));
      const b = ColorTintAct(from: Color(0xFF000000), to: Color(0xFFFFFFFF));
      expect(a, equals(b));
    });

    test('different from are not equal', () {
      const a = ColorTintAct(from: Color(0xFF000000), to: Color(0xFFFFFFFF));
      const b = ColorTintAct(from: Color(0xFFFF0000), to: Color(0xFFFFFFFF));
      expect(a, isNot(equals(b)));
    });

    test('different to are not equal', () {
      const a = ColorTintAct(from: Color(0xFF000000), to: Color(0xFFFFFFFF));
      const b = ColorTintAct(from: Color(0xFF000000), to: Color(0xFF00FF00));
      expect(a, isNot(equals(b)));
    });
  });

  group('TextStyleAct equality', () {
    test('identical values are equal', () {
      const a = TextStyleAct(from: TextStyle(fontSize: 14), to: TextStyle(fontSize: 24));
      const b = TextStyleAct(from: TextStyle(fontSize: 14), to: TextStyle(fontSize: 24));
      expect(a, equals(b));
    });

    test('different from are not equal', () {
      const a = TextStyleAct(from: TextStyle(fontSize: 14), to: TextStyle(fontSize: 24));
      const b = TextStyleAct(from: TextStyle(fontSize: 10), to: TextStyle(fontSize: 24));
      expect(a, isNot(equals(b)));
    });

    test('different to are not equal', () {
      const a = TextStyleAct(from: TextStyle(fontSize: 14), to: TextStyle(fontSize: 24));
      const b = TextStyleAct(from: TextStyle(fontSize: 14), to: TextStyle(fontSize: 30));
      expect(a, isNot(equals(b)));
    });
  });

  group('IconThemeAct equality', () {
    test('identical values are equal', () {
      const a = IconThemeAct(from: IconThemeData(size: 16), to: IconThemeData(size: 32));
      const b = IconThemeAct(from: IconThemeData(size: 16), to: IconThemeData(size: 32));
      expect(a, equals(b));
    });

    test('different from are not equal', () {
      const a = IconThemeAct(from: IconThemeData(size: 16), to: IconThemeData(size: 32));
      const b = IconThemeAct(from: IconThemeData(size: 20), to: IconThemeData(size: 32));
      expect(a, isNot(equals(b)));
    });

    test('different to are not equal', () {
      const a = IconThemeAct(from: IconThemeData(size: 16), to: IconThemeData(size: 32));
      const b = IconThemeAct(from: IconThemeData(size: 16), to: IconThemeData(size: 48));
      expect(a, isNot(equals(b)));
    });
  });

  group('RotateLayoutAct equality', () {
    test('identical values are equal', () {
      const a = RotateLayoutAct(from: 0, to: 90);
      const b = RotateLayoutAct(from: 0, to: 90);
      expect(a, equals(b));
    });

    test('different from are not equal', () {
      const a = RotateLayoutAct(from: 0, to: 90);
      const b = RotateLayoutAct(from: 45, to: 90);
      expect(a, isNot(equals(b)));
    });

    test('different to are not equal', () {
      const a = RotateLayoutAct(from: 0, to: 90);
      const b = RotateLayoutAct(from: 0, to: 180);
      expect(a, isNot(equals(b)));
    });
  });

  group('SlideAct equality', () {
    test('identical values are equal', () {
      final a = SlideAct(from: Offset.zero, to: Offset(1, 1));
      final b = SlideAct(from: Offset.zero, to: Offset(1, 1));
      expect(a, equals(b));
    });

    test('different from are not equal', () {
      final a = SlideAct(from: Offset.zero, to: Offset(1, 1));
      final b = SlideAct(from: Offset(0.5, 0), to: Offset(1, 1));
      expect(a, isNot(equals(b)));
    });

    test('different to are not equal', () {
      final a = SlideAct(from: Offset.zero, to: Offset(1, 1));
      final b = SlideAct(from: Offset.zero, to: Offset(2, 2));
      expect(a, isNot(equals(b)));
    });

    test('slideUp defaults are equal', () {
      final a = SlideAct.up();
      final b = SlideAct.up();
      expect(a, equals(b));
    });

    test('slideDown defaults are equal', () {
      final a = SlideAct.down();
      final b = SlideAct.down();
      expect(a, equals(b));
    });

    test('slideUp vs slideDown are not equal', () {
      final a = SlideAct.up();
      final b = SlideAct.down();
      expect(a, isNot(equals(b)));
    });
  });

  group('TranslateAct equality', () {
    test('identical values are equal', () {
      final a = TranslateAct(from: Offset.zero, to: Offset(10, 20));
      final b = TranslateAct(from: Offset.zero, to: Offset(10, 20));
      expect(a, equals(b));
    });

    test('different from are not equal', () {
      final a = TranslateAct(from: Offset.zero, to: Offset(10, 20));
      final b = TranslateAct(from: Offset(5, 5), to: Offset(10, 20));
      expect(a, isNot(equals(b)));
    });

    test('different to are not equal', () {
      final a = TranslateAct(from: Offset.zero, to: Offset(10, 20));
      final b = TranslateAct(from: Offset.zero, to: Offset(30, 40));
      expect(a, isNot(equals(b)));
    });

    test('translateX values are equal', () {
      final a = TranslateAct.fromX(from: 0, to: 100);
      final b = TranslateAct.fromX(from: 0, to: 100);
      expect(a, equals(b));
    });

    test('translateY values are equal', () {
      final a = TranslateAct.y(from: 0, to: 100);
      final b = TranslateAct.y(from: 0, to: 100);
      expect(a, equals(b));
    });
  });

  // ─── Acts with custom equality ────────────────────────────────────

  group('RotateAct equality', () {
    test('identical defaults are equal', () {
      const a = RotateAct(from: 0, to: 90);
      const b = RotateAct(from: 0, to: 90);
      expect(a, equals(b));
    });

    test('different from are not equal', () {
      const a = RotateAct(from: 0, to: 90);
      const b = RotateAct(from: 45, to: 90);
      expect(a, isNot(equals(b)));
    });

    test('different to are not equal', () {
      const a = RotateAct(from: 0, to: 90);
      const b = RotateAct(from: 0, to: 180);
      expect(a, isNot(equals(b)));
    });

    test('different alignment are not equal', () {
      const a = RotateAct(from: 0, to: 90, alignment: Alignment.center);
      const b = RotateAct(from: 0, to: 90, alignment: Alignment.topLeft);
      expect(a, isNot(equals(b)));
    });

    test('different unit are not equal', () {
      const a = RotateAct(from: 0, to: 90, unit: RotateUnit.degrees);
      const b = RotateAct(from: 0, to: 90, unit: RotateUnit.radians);
      expect(a, isNot(equals(b)));
    });

    test('different axis are not equal', () {
      const a = RotateAct(from: 0, to: 90, axis: RotateAxis.z);
      const b = RotateAct(from: 0, to: 90, axis: RotateAxis.x);
      expect(a, isNot(equals(b)));
    });

    test('different motion are not equal', () {
      const a = RotateAct(from: 0, to: 90, motion: CueMotion.none);
      const b = RotateAct(from: 0, to: 90, motion: CueMotion.linear(Duration(milliseconds: 200)));
      expect(a, isNot(equals(b)));
    });

    test('different delay are not equal', () {
      const a = RotateAct(from: 0, to: 90, delay: Duration.zero);
      const b = RotateAct(from: 0, to: 90, delay: Duration(milliseconds: 100));
      expect(a, isNot(equals(b)));
    });

    test('different reverse are not equal', () {
      const a = RotateAct(from: 0, to: 90, reverse: ReverseBehavior.mirror());
      const b = RotateAct(from: 0, to: 90, reverse: ReverseBehavior.none());
      expect(a, isNot(equals(b)));
    });

    test('flipX defaults are equal', () {
      const a = RotateAct.flipX();
      const b = RotateAct.flipX();
      expect(a, equals(b));
    });

    test('flipY defaults are equal', () {
      const a = RotateAct.flipY();
      const b = RotateAct.flipY();
      expect(a, equals(b));
    });

    test('flipX vs flipY are not equal', () {
      const a = RotateAct.flipX();
      const b = RotateAct.flipY();
      expect(a, isNot(equals(b)));
    });
  });

  group('Rotate3DAct equality', () {
    test('identical defaults are equal', () {
      const a = Rotate3DAct(from: Rotation3D.zero, to: Rotation3D(x: 90));
      const b = Rotate3DAct(from: Rotation3D.zero, to: Rotation3D(x: 90));
      expect(a, equals(b));
    });

    test('different from are not equal', () {
      const a = Rotate3DAct(from: Rotation3D.zero, to: Rotation3D(x: 90));
      const b = Rotate3DAct(from: Rotation3D(x: 45), to: Rotation3D(x: 90));
      expect(a, isNot(equals(b)));
    });

    test('different to are not equal', () {
      const a = Rotate3DAct(from: Rotation3D.zero, to: Rotation3D(x: 90));
      const b = Rotate3DAct(from: Rotation3D.zero, to: Rotation3D(x: 180));
      expect(a, isNot(equals(b)));
    });

    test('different alignment are not equal', () {
      const a = Rotate3DAct(from: Rotation3D.zero, to: Rotation3D(x: 90), alignment: Alignment.center);
      const b = Rotate3DAct(from: Rotation3D.zero, to: Rotation3D(x: 90), alignment: Alignment.topLeft);
      expect(a, isNot(equals(b)));
    });

    test('different perspective are not equal', () {
      const a = Rotate3DAct(from: Rotation3D.zero, to: Rotation3D(x: 90), perspective: 0.001);
      const b = Rotate3DAct(from: Rotation3D.zero, to: Rotation3D(x: 90), perspective: 0.005);
      expect(a, isNot(equals(b)));
    });

    test('different unit are not equal', () {
      const a = Rotate3DAct(from: Rotation3D.zero, to: Rotation3D(x: 90), unit: Rotate3DUnit.degrees);
      const b = Rotate3DAct(from: Rotation3D.zero, to: Rotation3D(x: 90), unit: Rotate3DUnit.radians);
      expect(a, isNot(equals(b)));
    });

    test('different motion are not equal', () {
      const a = Rotate3DAct(from: Rotation3D.zero, to: Rotation3D(x: 90), motion: CueMotion.none);
      const b = Rotate3DAct(
        from: Rotation3D.zero,
        to: Rotation3D(x: 90),
        motion: CueMotion.linear(Duration(milliseconds: 100)),
      );
      expect(a, isNot(equals(b)));
    });

    test('different delay are not equal', () {
      const a = Rotate3DAct(from: Rotation3D.zero, to: Rotation3D(x: 90), delay: Duration.zero);
      const b = Rotate3DAct(from: Rotation3D.zero, to: Rotation3D(x: 90), delay: Duration(milliseconds: 100));
      expect(a, isNot(equals(b)));
    });
  });

  group('DecoratedBoxAct equality', () {
    test('identical defaults are equal', () {
      const a = DecoratedBoxAct();
      const b = DecoratedBoxAct();
      expect(a, equals(b));
    });

    test('same color values are equal', () {
      const a = DecoratedBoxAct(
        color: AnimatableValue<Color>(from: Color(0xFF000000), to: Color(0xFFFFFFFF)),
      );
      const b = DecoratedBoxAct(
        color: AnimatableValue<Color>(from: Color(0xFF000000), to: Color(0xFFFFFFFF)),
      );
      expect(a, equals(b));
    });

    test('different color are not equal', () {
      const a = DecoratedBoxAct(
        color: AnimatableValue<Color>(from: Color(0xFF000000), to: Color(0xFFFFFFFF)),
      );
      const b = DecoratedBoxAct(
        color: AnimatableValue<Color>(from: Color(0xFFFF0000), to: Color(0xFFFFFFFF)),
      );
      expect(a, isNot(equals(b)));
    });

    test('different borderRadius are not equal', () {
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

    test('different shape are not equal', () {
      const a = DecoratedBoxAct(shape: BoxShape.rectangle);
      const b = DecoratedBoxAct(shape: BoxShape.circle);
      expect(a, isNot(equals(b)));
    });

    test('different position are not equal', () {
      const a = DecoratedBoxAct(position: DecorationPosition.background);
      const b = DecoratedBoxAct(position: DecorationPosition.foreground);
      expect(a, isNot(equals(b)));
    });
  });

  group('CardAct equality', () {
    test('identical defaults are equal', () {
      const a = CardAct();
      const b = CardAct();
      expect(a, equals(b));
    });

    test('same color values are equal', () {
      const a = CardAct(color: AnimatableValue.fixed(Color(0xFF000000)));
      const b = CardAct(color: AnimatableValue.fixed(Color(0xFF000000)));
      expect(a, equals(b));
    });

    test('different color are not equal', () {
      const a = CardAct(color: AnimatableValue.fixed(Color(0xFF000000)));
      const b = CardAct(color: AnimatableValue.fixed(Color(0xFFFFFFFF)));
      expect(a, isNot(equals(b)));
    });

    test('different elevation are not equal', () {
      const a = CardAct(elevation: AnimatableValue.fixed(4.0));
      const b = CardAct(elevation: AnimatableValue.fixed(8.0));
      expect(a, isNot(equals(b)));
    });

    test('different shadowColor are not equal', () {
      const a = CardAct(shadowColor: AnimatableValue.fixed(Color(0xFF000000)));
      const b = CardAct(shadowColor: AnimatableValue.fixed(Color(0xFF111111)));
      expect(a, isNot(equals(b)));
    });

    test('different surfaceTintColor are not equal', () {
      const a = CardAct(surfaceTintColor: AnimatableValue.fixed(Color(0xFF000000)));
      const b = CardAct(surfaceTintColor: AnimatableValue.fixed(Color(0xFFFFFFFF)));
      expect(a, isNot(equals(b)));
    });

    test('different borderRadius are not equal', () {
      const a = CardAct(
        borderRadius: AnimatableValue<BorderRadiusGeometry>(
          from: BorderRadius.zero,
          to: BorderRadius.all(Radius.circular(10)),
        ),
      );
      const b = CardAct(
        borderRadius: AnimatableValue<BorderRadiusGeometry>(
          from: BorderRadius.zero,
          to: BorderRadius.all(Radius.circular(20)),
        ),
      );
      expect(a, isNot(equals(b)));
    });

    test('different margin are not equal', () {
      const a = CardAct(margin: AnimatableValue.fixed(EdgeInsets.all(4)));
      const b = CardAct(margin: AnimatableValue.fixed(EdgeInsets.all(8)));
      expect(a, isNot(equals(b)));
    });

    test('different clipBehavior are not equal', () {
      const a = CardAct(clipBehavior: Clip.none);
      const b = CardAct(clipBehavior: Clip.hardEdge);
      expect(a, isNot(equals(b)));
    });

    test('different borderOnForeground are not equal', () {
      const a = CardAct(borderOnForeground: true);
      const b = CardAct(borderOnForeground: false);
      expect(a, isNot(equals(b)));
    });

    test('different semanticContainer are not equal', () {
      const a = CardAct(semanticContainer: true);
      const b = CardAct(semanticContainer: false);
      expect(a, isNot(equals(b)));
    });

    test('different motion are equal (motion not in equality)', () {
      const a = CardAct(motion: CueMotion.none);
      const b = CardAct(motion: CueMotion.linear(Duration(milliseconds: 100)));
      expect(a, equals(b));
    });

    test('different delay are equal (delay not in equality)', () {
      const a = CardAct(delay: Duration.zero);
      const b = CardAct(delay: Duration(milliseconds: 100));
      expect(a, equals(b));
    });
  });

  group('ParallaxAct equality', () {
    test('identical values are equal', () {
      const a = ParallaxAct(slide: 0.5);
      const b = ParallaxAct(slide: 0.5);
      expect(a, equals(b));
    });

    test('different slide are not equal', () {
      const a = ParallaxAct(slide: 0.5);
      const b = ParallaxAct(slide: 0.8);
      expect(a, isNot(equals(b)));
    });

    test('different axis are not equal', () {
      const a = ParallaxAct(slide: 0.5, axis: Axis.horizontal);
      const b = ParallaxAct(slide: 0.5, axis: Axis.vertical);
      expect(a, isNot(equals(b)));
    });

    test('different motion are not equal', () {
      const a = ParallaxAct(slide: 0.5, motion: CueMotion.none);
      const b = ParallaxAct(slide: 0.5, motion: CueMotion.linear(Duration(milliseconds: 100)));
      expect(a, isNot(equals(b)));
    });

    test('different delay are not equal', () {
      const a = ParallaxAct(slide: 0.5, delay: Duration.zero);
      const b = ParallaxAct(slide: 0.5, delay: Duration(milliseconds: 100));
      expect(a, isNot(equals(b)));
    });

    test('different reverse are not equal', () {
      const a = ParallaxAct(slide: 0.5, reverse: ReverseBehavior.mirror());
      const b = ParallaxAct(slide: 0.5, reverse: ReverseBehavior.none());
      expect(a, isNot(equals(b)));
    });
  });

  group('SizedClipAct equality', () {
    test('identical defaults are equal', () {
      const a = SizedClipAct();
      const b = SizedClipAct();
      expect(a, equals(b));
    });

    test('different from are not equal', () {
      const a = SizedClipAct(from: NSize(w: 100, h: 100));
      const b = SizedClipAct(from: NSize(w: 200, h: 100));
      expect(a, isNot(equals(b)));
    });

    test('different to are not equal', () {
      const a = SizedClipAct(to: NSize(w: 100, h: 100));
      const b = SizedClipAct(to: NSize(w: 200, h: 100));
      expect(a, isNot(equals(b)));
    });

    test('different alignment are not equal', () {
      const a = SizedClipAct(alignment: Alignment.center);
      const b = SizedClipAct(alignment: Alignment.topLeft);
      expect(a, isNot(equals(b)));
    });

    test('different clipBehavior are not equal', () {
      const a = SizedClipAct(clipBehavior: Clip.hardEdge);
      const b = SizedClipAct(clipBehavior: Clip.antiAlias);
      expect(a, isNot(equals(b)));
    });

    test('different clipGeometry are not equal', () {
      const a = SizedClipAct(clipGeometry: ClipGeometry.rect());
      const b = SizedClipAct(clipGeometry: ClipGeometry.rrect(BorderRadius.all(Radius.circular(10))));
      expect(a, isNot(equals(b)));
    });

    test('different motion are not equal', () {
      const a = SizedClipAct(motion: CueMotion.none);
      const b = SizedClipAct(motion: CueMotion.linear(Duration(milliseconds: 100)));
      expect(a, isNot(equals(b)));
    });
  });

  group('SizedBoxAct equality', () {
    test('identical defaults are equal', () {
      const a = SizedBoxAct();
      const b = SizedBoxAct();
      expect(a, equals(b));
    });

    test('same width/height are equal', () {
      const a = SizedBoxAct(width: AnimatableValue.fixed(100.0), height: AnimatableValue.fixed(200.0));
      const b = SizedBoxAct(width: AnimatableValue.fixed(100.0), height: AnimatableValue.fixed(200.0));
      expect(a, equals(b));
    });

    test('different width are not equal', () {
      const a = SizedBoxAct(width: AnimatableValue.fixed(100.0), height: AnimatableValue.fixed(200.0));
      const b = SizedBoxAct(width: AnimatableValue.fixed(150.0), height: AnimatableValue.fixed(200.0));
      expect(a, isNot(equals(b)));
    });

    test('different height are not equal', () {
      const a = SizedBoxAct(width: AnimatableValue.fixed(100.0), height: AnimatableValue.fixed(200.0));
      const b = SizedBoxAct(width: AnimatableValue.fixed(100.0), height: AnimatableValue.fixed(300.0));
      expect(a, isNot(equals(b)));
    });

    test('different alignment are not equal', () {
      const a = SizedBoxAct(alignment: Alignment.center);
      const b = SizedBoxAct(alignment: Alignment.topLeft);
      expect(a, isNot(equals(b)));
    });

    test('different motion are not equal', () {
      const a = SizedBoxAct(motion: CueMotion.none);
      const b = SizedBoxAct(motion: CueMotion.linear(Duration(milliseconds: 100)));
      expect(a, isNot(equals(b)));
    });

    test('different delay are not equal', () {
      const a = SizedBoxAct(delay: Duration.zero);
      const b = SizedBoxAct(delay: Duration(milliseconds: 100));
      expect(a, isNot(equals(b)));
    });

    test('different reverse are not equal', () {
      const a = SizedBoxAct(reverse: ReverseBehavior.mirror());
      const b = SizedBoxAct(reverse: ReverseBehavior.none());
      expect(a, isNot(equals(b)));
    });
  });

  // ─── Keyframed variants ──────────────────────────────────────────

  group('Keyframed act equality', () {
    test('OpacityAct.keyframed with same frames are equal', () {
      final frames = MotionKeyframes([
        Keyframe.key(0.0),
        Keyframe.key(1.0),
      ], motion: CueMotion.none);
      final a = OpacityAct.keyframed(frames: frames);
      final b = OpacityAct.keyframed(frames: frames);
      expect(a, equals(b));
    });

    test('OpacityAct.keyframed with different frames are not equal', () {
      final a = OpacityAct.keyframed(frames: MotionKeyframes([Keyframe.key(0.0)], motion: CueMotion.none));
      final b = OpacityAct.keyframed(frames: MotionKeyframes([Keyframe.key(1.0)], motion: CueMotion.none));
      expect(a, isNot(equals(b)));
    });

    test('PaddingAct.keyframed with same frames are equal', () {
      final frames = MotionKeyframes([
        Keyframe.key(EdgeInsets.zero),
        Keyframe.key(EdgeInsets.all(10)),
      ], motion: CueMotion.none);
      final a = PaddingAct.keyframed(frames: frames);
      final b = PaddingAct.keyframed(frames: frames);
      expect(a, equals(b));
    });

    test('BlurAct.keyframed with same frames are equal', () {
      final frames = MotionKeyframes([
        Keyframe.key(0.0),
        Keyframe.key(10.0),
      ], motion: CueMotion.none);
      final a = BlurAct.keyframed(frames: frames);
      final b = BlurAct.keyframed(frames: frames);
      expect(a, equals(b));
    });

    test('RotateAct.keyframed with same frames are equal', () {
      final frames = MotionKeyframes([
        Keyframe.key(0.0),
        Keyframe.key(90.0),
      ], motion: CueMotion.none);
      final a = RotateAct.keyframed(frames: frames);
      final b = RotateAct.keyframed(frames: frames);
      expect(a, equals(b));
    });
  });

  // ─── Self-equality and hashCode ───────────────────────────────────

  group('Act self-equality and hashCode consistency', () {
    test('OpacityAct is equal to itself', () {
      const act = OpacityAct(from: 0.0, to: 1.0);
      expect(act, equals(act));
      expect(act.hashCode, equals(act.hashCode));
    });

    test('RotateAct is equal to itself', () {
      const act = RotateAct(from: 0, to: 90, alignment: Alignment.center, unit: RotateUnit.degrees, axis: RotateAxis.z);
      expect(act, equals(act));
      expect(act.hashCode, equals(act.hashCode));
    });

    test('equal acts have same hashCode', () {
      const a = OpacityAct(from: 0.0, to: 1.0);
      const b = OpacityAct(from: 0.0, to: 1.0);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equal RotateActs have same hashCode', () {
      const a = RotateAct(from: 0, to: 90, alignment: Alignment.center, unit: RotateUnit.degrees, axis: RotateAxis.z);
      const b = RotateAct(from: 0, to: 90, alignment: Alignment.center, unit: RotateUnit.degrees, axis: RotateAxis.z);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equal PaddingActs have same hashCode', () {
      const a = PaddingAct(from: EdgeInsets.all(10), to: EdgeInsets.all(20));
      const b = PaddingAct(from: EdgeInsets.all(10), to: EdgeInsets.all(20));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equal DecoratedBoxActs have same hashCode', () {
      const a = DecoratedBoxAct(shape: BoxShape.circle, position: DecorationPosition.foreground);
      const b = DecoratedBoxAct(shape: BoxShape.circle, position: DecorationPosition.foreground);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equal CardActs have same hashCode', () {
      const a = CardAct(clipBehavior: Clip.hardEdge, borderOnForeground: false);
      const b = CardAct(clipBehavior: Clip.hardEdge, borderOnForeground: false);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equal SizedBoxActs have same hashCode', () {
      const a = SizedBoxAct(alignment: Alignment.topLeft);
      const b = SizedBoxAct(alignment: Alignment.topLeft);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('equal ParallaxActs have same hashCode', () {
      const a = ParallaxAct(slide: 0.5, axis: Axis.horizontal);
      const b = ParallaxAct(slide: 0.5, axis: Axis.horizontal);
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
