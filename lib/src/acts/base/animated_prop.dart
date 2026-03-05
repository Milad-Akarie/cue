import 'package:cue/cue.dart';
import 'package:cue/src/acts/base/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class AnimatablePropBase<T extends Object?, R extends Object?> {
  const AnimatablePropBase({
    this.from,
    this.to,
    this.keyframes,
    this.timing,
    this.curve,
    this.reverseTiming,
    this.reverseCurve,
  });

  const AnimatablePropBase.tween({
    required T this.from,
    required T this.to,
    this.timing,
    this.curve,
    this.reverseTiming,
    this.reverseCurve,
  }) : keyframes = null;

  const AnimatablePropBase.fixed(T value)
    : from = value,
      to = value,
      keyframes = null,
      timing = null,
      curve = null,
      reverseTiming = null,
      reverseCurve = null;

  const AnimatablePropBase.keyframes(List<Keyframe<T>> this.keyframes, {this.curve, this.reverseCurve})
    : from = null,
      to = null,
      timing = null,
      reverseTiming = null;

  final T? from;
  final T? to;
  final List<Keyframe<T>>? keyframes;
  final Timing? timing;
  final Curve? curve;
  final Timing? reverseTiming;
  final Curve? reverseCurve;

  bool get isConstant => from != null && to != null && from == to;

  R transform(ActContext context, T value);

  Animatable<R> createSingleTween(R from, R to) {
    return Tween<R>(begin: from, end: to);
  }

  ({Animatable<R> tween, Timing? timing}) resolveTween(ActContext context) {
    final Animatable<R> tween;
    Timing? timing;
    if (keyframes != null) {
      assert(keyframes!.isNotEmpty, 'Keyframes list cannot be empty');
      final res = Phase.normalize<T, R>(keyframes!, (v) => transform(context, v));
      tween = buildFromPhases<R>(res.phases, (from, to) {
        return createSingleTween(transform(context, from as T), transform(context, to as T));
      });
      if (res.timing != null) {
        timing = res.timing;
      }
    } else {
      final effectiveFrom = context.implicitFrom ?? transform(context, from as T);
      assert(effectiveFrom != null && to != null, 'From and to values must be provided when not using keyframes');
      if (effectiveFrom == to) {
        tween = ConstantTween<R>(transform(context, to as T));
      } else {
        tween = createSingleTween(effectiveFrom as R, transform(context, to as T));
      }
    }
    return (tween: tween, timing: timing);
  }

  Animatable<R> asAnimtable(ActContext context) {
    final res = resolveTween(context);
    return applyCurves(
      res.tween,
      curve: curve ?? context.curve,
      timing: res.timing,
      isBounded: context.isBounded,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is AnimatablePropBase<T, R> &&
        other.from == from &&
        other.to == to &&
        listEquals(keyframes, other.keyframes);
  }

  @override
  int get hashCode => Object.hash(from, to, Object.hashAll(keyframes ?? []));
}

abstract class AnimatableProp<T> extends AnimatablePropBase<T, T> {
  const AnimatableProp({
    super.from,
    super.to,
    super.keyframes,
    super.timing,
    super.curve,
  });

  @override
  T transform(_, T value) => value;

  const AnimatableProp.tween({required super.from, required super.to, super.timing, super.curve}) : super.tween();
  const AnimatableProp.fixed(super.value) : super.fixed();
  const AnimatableProp.keyframes(super.keyframes, {super.curve}) : super.keyframes();
}

class _LerpFnTween<T> extends Animatable<T> {
  final T from;
  final T to;
  final T Function(T a, T b, double t) lerpFn;

  _LerpFnTween(this.from, this.to, this.lerpFn);

  @override
  T transform(double t) => lerpFn(from, to, t);
}

class ColorProp extends AnimatableProp<Color?> {
  const ColorProp.tween({required Color super.from, required Color super.to, super.timing, super.curve})
    : super.tween();
  const ColorProp.fixed(Color super.value) : super.fixed();
  const ColorProp.keyframes(List<Keyframe<Color>> super.keyframes, {super.curve}) : super.keyframes();

  @override
  Animatable<Color?> createSingleTween(Color? from, Color? to) {
    return ColorTween(begin: from, end: to);
  }
}

class BorderRadiusProp extends AnimatablePropBase<BorderRadiusGeometry?, BorderRadius?> {
  const BorderRadiusProp.tween({
    required BorderRadiusGeometry super.from,
    required BorderRadiusGeometry super.to,
    super.timing,
    super.curve,
  }) : super.tween();
  const BorderRadiusProp.fixed(BorderRadiusGeometry super.value) : super.fixed();
  const BorderRadiusProp.keyframes(List<Keyframe<BorderRadiusGeometry>> super.keyframes, {super.curve})
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

class AlignmentProp extends AnimatablePropBase<AlignmentGeometry?, Alignment?> {
  const AlignmentProp.tween({
    required AlignmentGeometry super.from,
    required AlignmentGeometry super.to,
    super.timing,
    super.curve,
  }) : super.tween();

  const AlignmentProp.fixed(AlignmentGeometry super.value) : super.fixed();
  const AlignmentProp.keyframes(List<Keyframe<AlignmentGeometry>> super.keyframes, {super.curve}) : super.keyframes();

  @override
  Alignment? transform(ActContext context, AlignmentGeometry? value) {
    return value?.resolve(context.textDirection);
  }

  @override
  Animatable<Alignment?> createSingleTween(Alignment? from, Alignment? to) {
    return AlignmentTween(begin: from, end: to);
  }
}

class DecorationImageProp extends AnimatableProp<DecorationImage?> {
  const DecorationImageProp.tween({required super.from, required super.to, super.timing, super.curve}) : super.tween();

  const DecorationImageProp.fixed(super.value) : super.fixed();
  const DecorationImageProp.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Animatable<DecorationImage?> createSingleTween(DecorationImage? from, DecorationImage? to) {
    return _LerpFnTween<DecorationImage?>(from, to, DecorationImage.lerp);
  }
}

class BoxBorderProp extends AnimatableProp<BoxBorder?> {
  const BoxBorderProp.tween({required super.from, required super.to, super.timing, super.curve}) : super.tween();

  const BoxBorderProp.fixed(super.value) : super.fixed();
  const BoxBorderProp.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Animatable<BoxBorder?> createSingleTween(BoxBorder? from, BoxBorder? to) {
    return _LerpFnTween<BoxBorder?>(from, to, BoxBorder.lerp);
  }
}

class BoxShadowProp extends AnimatableProp<List<BoxShadow>?> {
  const BoxShadowProp.tween({required super.from, required super.to, super.timing, super.curve}) : super.tween();

  const BoxShadowProp.fixed(super.value) : super.fixed();
  const BoxShadowProp.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Animatable<List<BoxShadow>?> createSingleTween(List<BoxShadow>? from, List<BoxShadow>? to) {
    return _LerpFnTween<List<BoxShadow>?>(from, to, BoxShadow.lerpList);
  }
}

class GradientProp extends AnimatableProp<Gradient?> {
  const GradientProp.tween({required super.from, required super.to, super.timing, super.curve}) : super.tween();

  const GradientProp.fixed(super.value) : super.fixed();
  const GradientProp.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Animatable<Gradient?> createSingleTween(Gradient? from, Gradient? to) {
    return _LerpFnTween<Gradient?>(from, to, Gradient.lerp);
  }
}

class DoubleProp extends AnimatableProp<double> {
  const DoubleProp.tween({required super.from, required super.to, super.timing, super.curve}) : super.tween();

  const DoubleProp.fixed(super.value) : super.fixed();
  const DoubleProp.keyframes(super.keyframes, {super.curve}) : super.keyframes();
}

class ShapeBorderProp extends AnimatableProp<ShapeBorder?> {
  const ShapeBorderProp.tween({required super.from, required super.to, super.timing, super.curve}) : super.tween();

  const ShapeBorderProp.fixed(super.value) : super.fixed();
  const ShapeBorderProp.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Animatable<ShapeBorder?> createSingleTween(ShapeBorder? from, ShapeBorder? to) {
    return ShapeBorderTween(begin: from, end: to);
  }
}

class EdgeInsetsProp extends AnimatablePropBase<EdgeInsetsGeometry?, EdgeInsets?> {
  const EdgeInsetsProp.tween({required super.from, required super.to, super.timing, super.curve}) : super.tween();

  const EdgeInsetsProp.fixed(super.value) : super.fixed();
  const EdgeInsetsProp.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  EdgeInsets? transform(ActContext context, EdgeInsetsGeometry? value) {
    return value?.resolve(context.textDirection);
  }

  @override
  Animatable<EdgeInsets?> createSingleTween(EdgeInsets? from, EdgeInsets? to) {
    return EdgeInsetsTween(begin: from, end: to);
  }
}
