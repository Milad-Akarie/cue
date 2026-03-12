import 'package:cue/cue.dart';
import 'package:cue/src/acts/base/utils.dart';
import 'package:cue/src/motion/cue_motion.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef ValueTransformer<R, T> = R Function(ActContext context, T value);

abstract class AnimatablePropBase<T extends Object?, R extends Object?> {

  final T? from;
  final T? to;
  final List<Keyframe<T>>? keyframes;
  final CueMotion? motion;
  final Duration? delay;
  final ReverseBehavior<T> reverse;

  const AnimatablePropBase({
    this.from,
    this.to,
    this.keyframes,
    this.motion,
    this.delay,
    this.reverse = const ReverseBehavior.mirror(),
  });

  const AnimatablePropBase.tween({
    required T this.from,
    required T this.to,
    this.motion,
    this.delay,
    this.reverse = const ReverseBehavior.mirror(),
  }) : keyframes = null;

  const AnimatablePropBase.fixed(T value)
    : from = value,
      to = value,
      keyframes = null,
      motion = null,
      delay = null,

      reverse = const ReverseBehavior.mirror();

  const AnimatablePropBase.keyframes(
    List<Keyframe<T>> this.keyframes, {
    this.motion,
    this.delay,
    this.reverse = const ReverseBehavior.mirror(),
  }) : from = null,
       to = null;



  bool get isConstant => from != null && to != null && from == to;

  R transform(ActContext context, T value);

  Animatable<R> createSingleTween(R from, R to) {
    return Tween<R>(begin: from, end: to);
  }

  ({Animatable<R> tween, Timing? timing}) resolveTween(
    ActContext context, {
    T? from,
    T? to,
    R? implicitFrom,
    List<Keyframe<T>>? keyframes,
    required ValueTransformer<R, T> transform,
  }) {
    final Animatable<R> tween;
    Timing? timing;
    if (keyframes != null) {
      assert(keyframes.isNotEmpty, 'Keyframes list cannot be empty');
      final res = Phase.normalize<T, R>(keyframes, (v) => transform(context, v));
      tween = buildFromPhases<R>(res.phases, createSingleTween);
      if (res.timing != null) {
        timing = res.timing;
      }
    } else {
      final effectiveFrom = implicitFrom ?? transform(context, from as T);
      assert(effectiveFrom != null && to != null, 'From and to values must be provided when not using keyframes');
      if (effectiveFrom == to) {
        tween = ConstantTween<R>(effectiveFrom);
      } else {
        tween = createSingleTween(effectiveFrom, transform(context, to as T));
      }
    }
    return (tween: tween, timing: timing);
  }

  CueAnimtable<R> buildAnimtable(ActContext context, {ValueTransformer<R, T>? transform}) {
    final mainTweenRes = resolveTween(
      context,
      from: from,
      to: to,
      keyframes: keyframes,
      implicitFrom: context.implicitFrom as R?,
      transform: transform ?? this.transform,
    );

    final tween = mainTweenRes.tween;
    if (tween is ConstantTween<R>) {
      return AlwaysStoppedAnimatable<R>(tween.begin as R);
    }

    switch (reverse.type) {
      case ReverseBehaviorType.mirror:
      case ReverseBehaviorType.to:
      case ReverseBehaviorType.keyframes:
        {
          var reverseTweenRes = mainTweenRes;
          bool hasReverse = false;
          if (reverse.to != null || reverse.keyframes != null) {
            hasReverse = true;
            reverseTweenRes = resolveTween(
              context,
              from: to,
              to: reverse.to,
              keyframes: reverse.keyframes,
              transform: transform ?? this.transform,
            );
          }
          Animatable<R>? reverseAnimatable;
          // final effectiveReverseCurve = reverse.curve ?? context.reverseCurve;
          // final effectiveReverseTiming = reverse.timing ?? context.reverseTiming;
          // if (hasReverse || effectiveReverseCurve != null || effectiveReverseTiming != null) {
          //   reverseAnimatable = applyCurves(
          //     reverseTweenRes.tween,
          //     curve: effectiveReverseCurve,
          //     timing: reverseTweenRes.timing ?? effectiveReverseTiming,
          //     isBounded: context.isBounded,
          //   );
          // }
          return DualAnimatable(
            forward: tween,
            reverse: reverseAnimatable,
            flipTimeOnReverse: hasReverse,
          );
        }
      case ReverseBehaviorType.none:
        return ForwardAnimatable(tween);
      case ReverseBehaviorType.exclusive:
        return ReverseAnimatable(tween);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is AnimatablePropBase<T, R> &&
        other.from == from &&
        other.to == to &&
        other.reverse == reverse &&
        listEquals(keyframes, other.keyframes);
  }

  @override
  int get hashCode => Object.hash(from, to, Object.hashAll(keyframes ?? []));
}

enum ReverseBehaviorType { mirror, exclusive, none, to, keyframes }

class ReverseBehavior<T> {
  final ReverseBehaviorType type;
  final T? to;
  final List<Keyframe<T>>? keyframes;
  final CueMotion? motion;
  final Duration? delay;

  const ReverseBehavior.mirror({this.motion, this.delay})
    : type = ReverseBehaviorType.mirror,
      to = null,
      keyframes = null;
  const ReverseBehavior.exclusive()
    : type = ReverseBehaviorType.exclusive,
      to = null,
      keyframes = null,
      motion = null,
      delay = null;

  const ReverseBehavior.none()
    : type = ReverseBehaviorType.none,
      to = null,
      keyframes = null,
      motion = null,
      delay = null;

  const ReverseBehavior.to(T this.to, {this.motion, this.delay}) : type = ReverseBehaviorType.to, keyframes = null;
  const ReverseBehavior.keyframes(List<Keyframe<T>> this.keyframes, {this.motion, this.delay})
    : type = ReverseBehaviorType.keyframes,
      to = null;
      

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ReverseBehavior<T> &&
        other.type == type &&
        other.to == to &&
        listEquals(keyframes, other.keyframes) &&
        other.motion == motion &&
        other.delay == delay;
  }

  @override
  int get hashCode => Object.hash(type, to, Object.hashAll(keyframes ?? []), motion, delay);
}

abstract class AnimatableProp<T> extends AnimatablePropBase<T, T> {
  const AnimatableProp({
    super.from,
    super.to,
    super.keyframes,
    super.motion,
    super.delay,
  });

  @override
  T transform(_, T value) => value;

  const AnimatableProp.tween({
    required super.from,
    required super.to,
    super.motion,
    super.delay,
    super.reverse,
  }) : super.tween();
  const AnimatableProp.fixed(super.value) : super.fixed();
  const AnimatableProp.keyframes(super.keyframes, {super.motion, super.delay, super.reverse}) : super.keyframes();
}

class _LerpFnTween<T> extends Animatable<T> {
  final T from;
  final T to;
  final T Function(T a, T b, double t) lerpFn;

  _LerpFnTween(this.from, this.to, this.lerpFn);

  @override
  T transform(double t) => lerpFn(from, to, t);
}

class AnimtableColor extends AnimatableProp<Color?> {
  const AnimtableColor.tween({required Color super.from, required Color super.to, super.motion, super.delay})
    : super.tween();
  const AnimtableColor.fixed(Color super.value) : super.fixed();
  const AnimtableColor.keyframes(List<Keyframe<Color>> super.keyframes, {super.motion}) : super.keyframes();

  @override
  Animatable<Color?> createSingleTween(Color? from, Color? to) {
    return ColorTween(begin: from, end: to);
  }
}

class AnimtableBorderRadius extends AnimatablePropBase<BorderRadiusGeometry?, BorderRadius?> {
  const AnimtableBorderRadius.tween({
    required BorderRadiusGeometry super.from,
    required BorderRadiusGeometry super.to,
    super.motion,
  }) : super.tween();
  const AnimtableBorderRadius.fixed(BorderRadiusGeometry super.value) : super.fixed();
  const AnimtableBorderRadius.keyframes(List<Keyframe<BorderRadiusGeometry>> super.keyframes, {super.motion})
    : super.keyframes();

  @override
  BorderRadius? transform(ActContext context, BorderRadiusGeometry? value) {
    return value?.resolve(context.textDirection);
  }

  @override
  Animatable<BorderRadius?> createSingleTween(BorderRadius? from, BorderRadius? to) {
    return BorderRadiusTween(begin: from, end: to);
  }
}

class AnimtableAlignment extends AnimatablePropBase<AlignmentGeometry?, Alignment?> {
  const AnimtableAlignment.tween({
    required AlignmentGeometry super.from,
    required AlignmentGeometry super.to,
    super.motion,
  }) : super.tween();

  const AnimtableAlignment.fixed(AlignmentGeometry super.value) : super.fixed();
  const AnimtableAlignment.keyframes(List<Keyframe<AlignmentGeometry>> super.keyframes, {super.motion})
    : super.keyframes();

  @override
  Alignment? transform(ActContext context, AlignmentGeometry? value) {
    return value?.resolve(context.textDirection);
  }

  @override
  Animatable<Alignment?> createSingleTween(Alignment? from, Alignment? to) {
    return AlignmentTween(begin: from, end: to);
  }
}

class AnimtableDecorationImage extends AnimatableProp<DecorationImage?> {
  const AnimtableDecorationImage.tween({required super.from, required super.to, super.motion})
    : super.tween();

  const AnimtableDecorationImage.fixed(super.value) : super.fixed();
  const AnimtableDecorationImage.keyframes(super.keyframes, {super.motion}) : super.keyframes();

  @override
  Animatable<DecorationImage?> createSingleTween(DecorationImage? from, DecorationImage? to) {
    return _LerpFnTween<DecorationImage?>(from, to, DecorationImage.lerp);
  }
}

class AnimtableBoxBorder extends AnimatableProp<BoxBorder?> {
  const AnimtableBoxBorder.tween({required super.from, required super.to, super.motion}) : super.tween();

  const AnimtableBoxBorder.fixed(super.value) : super.fixed();
  const AnimtableBoxBorder.keyframes(super.keyframes, {super.motion}) : super.keyframes();

  @override
  Animatable<BoxBorder?> createSingleTween(BoxBorder? from, BoxBorder? to) {
    return _LerpFnTween<BoxBorder?>(from, to, BoxBorder.lerp);
  }
}

class AnimtableBoxShadow extends AnimatableProp<List<BoxShadow>?> {
  const AnimtableBoxShadow.tween({required super.from, required super.to, super.motion}) : super.tween();

  const AnimtableBoxShadow.fixed(super.value) : super.fixed();
  const AnimtableBoxShadow.keyframes(super.keyframes, {super.motion}) : super.keyframes();

  @override
  Animatable<List<BoxShadow>?> createSingleTween(List<BoxShadow>? from, List<BoxShadow>? to) {
    return _LerpFnTween<List<BoxShadow>?>(from, to, BoxShadow.lerpList);
  }
}

class AnimtableGradient extends AnimatableProp<Gradient?> {
  const AnimtableGradient.tween({required super.from, required super.to, super.motion}) : super.tween();

  const AnimtableGradient.fixed(super.value) : super.fixed();
  const AnimtableGradient.keyframes(super.keyframes, {super.motion}) : super.keyframes();

  @override
  Animatable<Gradient?> createSingleTween(Gradient? from, Gradient? to) {
    return _LerpFnTween<Gradient?>(from, to, Gradient.lerp);
  }
}

class AnimatableValue<T> extends AnimatableProp<T> {
  @internal
  const AnimatableValue({
    super.from,
    super.to,
    super.keyframes,
  
    super.motion,
  });

  const AnimatableValue.tween({required super.from, required super.to, super.motion,super.reverse}) : super.tween();

  const AnimatableValue.fixed(super.value) : super.fixed();
  const AnimatableValue.keyframes(super.keyframes, {super.motion}) : super.keyframes();
}

class AnimtableShapeBorder extends AnimatableProp<ShapeBorder?> {
  const AnimtableShapeBorder.tween({required super.from, required super.to, super.motion}) : super.tween();

  const AnimtableShapeBorder.fixed(super.value) : super.fixed();
  const AnimtableShapeBorder.keyframes(super.keyframes, {super.motion}) : super.keyframes();

  @override
  Animatable<ShapeBorder?> createSingleTween(ShapeBorder? from, ShapeBorder? to) {
    return ShapeBorderTween(begin: from, end: to);
  }
}

class AnimtableEdgeInsets extends AnimatablePropBase<EdgeInsetsGeometry?, EdgeInsets?> {
  const AnimtableEdgeInsets.tween({
    required super.from,
    required super.to,
    super.motion,
  }) : super.tween();

  const AnimtableEdgeInsets.fixed(super.value) : super.fixed();
  const AnimtableEdgeInsets.keyframes(super.keyframes, {super.motion}) : super.keyframes();

  @override
  EdgeInsets? transform(ActContext context, EdgeInsetsGeometry? value) {
    return value?.resolve(context.textDirection);
  }

  @override
  Animatable<EdgeInsets?> createSingleTween(EdgeInsets? from, EdgeInsets? to) {
    return EdgeInsetsTween(begin: from, end: to);
  }
}

class AnimtableSize extends AnimatableProp<Size?> {
  @internal
  const AnimtableSize({
    super.from,
    super.to,
    super.keyframes,
    super.motion,
  });

  const AnimtableSize.tween({required super.from, required super.to, super.motion}) : super.tween();

  const AnimtableSize.fixed(super.value) : super.fixed();
  const AnimtableSize.keyframes(super.keyframes, {super.motion}) : super.keyframes();

  @override
  Animatable<Size?> createSingleTween(Size? from, Size? to) {
    return SizeTween(begin: from, end: to);
  }
}
