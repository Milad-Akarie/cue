import 'package:cue/cue.dart';
import 'package:cue/src/effects/base/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class AnimatableProp<T extends Object?> {
  const AnimatableProp.from(T this.from, {required T this.to, this.timing, this.curve}) : keyframes = null;
  const AnimatableProp.fixed(T value) : from = value, to = value, keyframes = null, timing = null, curve = null;
  const AnimatableProp.keyframes(List<Keyframe<T>> this.keyframes, {this.curve})
    : from = null,
      to = null,
      timing = null;

  final T? from;
  final T? to;
  final List<Keyframe<T>>? keyframes;
  final Timing? timing;
  final Curve? curve;

  bool get isConstant => from != null && to != null && from == to;

  Animatable<T> buildTween(ActorContext context, T from, T to) {
    if (isConstant) {
      return ConstantTween<T>(from);
    }
    return Tween<T>(begin: from, end: to);
  }

  Animatable<T> buildAnimatable(ActorContext context) {
    final Animatable<T> tween;
    Timing? timing = this.timing ?? context.timing;
    Curve? curve = this.curve ?? context.curve;
    if (keyframes != null) {
      final res = Phase.normalize<T, T>(keyframes!, (v) => v);
      tween = buildFromPhases<T>(res.phases, (from, to) => buildTween(context, from, to));
      if (res.timing != null) {
        timing = res.timing;
      }
    } else {
      assert(from != null && to != null, 'From and to values must be provided when not using keyframes');
      tween = buildTween(context, from as T, to as T);
    }
    return applyCurves(
      tween,
      curve: curve,
      timing: timing,
      isBounded: context.isBounded,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is AnimatableProp<T> && other.from == from && other.to == to && listEquals(keyframes, other.keyframes);
  }

  @override
  int get hashCode => Object.hash(from, to, Object.hashAll(keyframes ?? []));
}

class _InlinTween<T> extends Animatable<T> {
  final T from;
  final T to;
  final T Function(T a, T b, double t) lerpFn;

  _InlinTween(this.from, this.to, this.lerpFn);

  @override
  T transform(double t) => lerpFn(from, to, t);
}

class ColorProp extends AnimatableProp<Color?> {
  const ColorProp.from(Color super.from, {required Color super.to, super.timing, super.curve}) : super.from();
  const ColorProp.fixed(Color super.value) : super.fixed();
  const ColorProp.keyframes(List<Keyframe<Color>> super.keyframes, {super.curve}) : super.keyframes();

  @override
  Animatable<Color?> buildTween(ActorContext data, Color? from, Color? to) {
    if (isConstant) {
      return ConstantTween<Color?>(from);
    }
    return ColorTween(begin: from, end: to);
  }
}

class BorderRadiusProp extends AnimatableProp<BorderRadiusGeometry?> {
  const BorderRadiusProp.from(
    BorderRadiusGeometry super.from, {
    required BorderRadiusGeometry super.to,
    super.timing,
    super.curve,
  }) : super.from();
  const BorderRadiusProp.fixed(BorderRadiusGeometry super.value) : super.fixed();
  const BorderRadiusProp.keyframes(List<Keyframe<BorderRadiusGeometry>> super.keyframes, {super.curve})
    : super.keyframes();

  @override
  Animatable<BorderRadiusGeometry?> buildTween(
    ActorContext context,
    BorderRadiusGeometry? from,
    BorderRadiusGeometry? to,
  ) {
    if (isConstant) {
      return ConstantTween<BorderRadiusGeometry?>(from?.resolve(context.textDirection));
    }
    return BorderRadiusTween(begin: from?.resolve(context.textDirection), end: to?.resolve(context.textDirection));
  }
}

class DecorationImageProp extends AnimatableProp<DecorationImage?> {
  const DecorationImageProp.from(
    super.from, {
    required super.to,
    super.timing,
    super.curve,
  }) : super.from();

  const DecorationImageProp.fixed(super.value) : super.fixed();
  const DecorationImageProp.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Animatable<DecorationImage?> buildTween(ActorContext context, DecorationImage? from, DecorationImage? to) {
    if (isConstant) {
      return ConstantTween<DecorationImage?>(from);
    }
    return _InlinTween<DecorationImage?>(from, to, DecorationImage.lerp);
  }
}

class BoxBorderProp extends AnimatableProp<BoxBorder?> {
  const BoxBorderProp.from(
    super.from, {
    required super.to,
    super.timing,
    super.curve,
  }) : super.from();

  const BoxBorderProp.fixed(super.value) : super.fixed();
  const BoxBorderProp.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Animatable<BoxBorder?> buildTween(ActorContext context, BoxBorder? from, BoxBorder? to) {
    if (isConstant) {
      return ConstantTween<BoxBorder?>(from);
    }
    return _InlinTween<BoxBorder?>(from, to, BoxBorder.lerp);
  }
}

class BoxShadowProp extends AnimatableProp<List<BoxShadow>?> {
  const BoxShadowProp.from(
    super.from, {
    required super.to,
    super.timing,
    super.curve,
  }) : super.from();

  const BoxShadowProp.fixed(super.value) : super.fixed();
  const BoxShadowProp.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Animatable<List<BoxShadow>?> buildTween(ActorContext context, List<BoxShadow>? from, List<BoxShadow>? to) {
    if (isConstant) {
      return ConstantTween<List<BoxShadow>?>(from);
    }
    return _InlinTween<List<BoxShadow>?>(from, to, BoxShadow.lerpList);
  }
}

class GradientProp extends AnimatableProp<Gradient?> {
  const GradientProp.from(
    super.from, {
    required super.to,
    super.timing,
    super.curve,
  }) : super.from();

  const GradientProp.fixed(super.value) : super.fixed();
  const GradientProp.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Animatable<Gradient?> buildTween(ActorContext context, Gradient? from, Gradient? to) {
    if (isConstant) {
      return ConstantTween<Gradient?>(from);
    }
    return _InlinTween<Gradient?>(from, to, Gradient.lerp);
  }
}
