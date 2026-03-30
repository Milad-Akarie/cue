import 'dart:ui';

import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

class _CustomTweenAct<T extends Object?> extends TweenAct<T> {
  @override
  final ActKey key = const ActKey('TweenActor');
  final Widget Function(BuildContext context, CueAnimation<T> animation) builder;

  final Animatable<T>? tweenBuilder;
  const _CustomTweenAct({
    super.from,
    super.to,
    super.motion,
    super.delay,
    super.reverse,
    super.frames,
    required this.builder,
    this.tweenBuilder,
  });

  @override
  Animatable<T> createSingleTween(T from, T to) {
    if (tweenBuilder != null) {
      return tweenBuilder!;
    } else if (from is Lerpable) {
      return _InlineFnTween<T>(
        begin: from,
        end: to,
        lerpFn: (t) => from.lerpTo(to as Lerpable?, t) as T,
      );
    }
    return super.createSingleTween(from, to);
  }

  @override
  Widget apply(BuildContext context, covariant CueAnimation<T> animation, Widget child) {
    return builder(context, animation);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _CustomTweenAct<T> &&
        super == other &&
        builder == other.builder &&
        tweenBuilder == other.tweenBuilder;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, builder, tweenBuilder);
}

class TweenActor<T extends Object?> extends SingleActorBase<T> {
  final Widget Function(BuildContext context, CueAnimation<T> animation) builder;
  final Animatable<T>? tweenBuilder;

  const TweenActor({
    super.key,
    required super.from,
    required super.to,
    super.motion,
    super.delay,
    super.reverse,
    required this.builder,
    this.tweenBuilder,
  }) : super(child: const SizedBox.shrink());

  const TweenActor.keyframed({
    super.key,
    required super.frames,
    super.reverse,
    super.delay,
    this.tweenBuilder,
    required this.builder,
  }) : super.keyframes(child: const SizedBox.shrink());

  @override
  Act get act => _CustomTweenAct<T>(
    from: from,
    to: to,
    frames: frames,
    motion: motion,
    delay: delay,
    reverse: reverse,
    builder: builder,
    tweenBuilder: tweenBuilder,
  );
}

class AnimatedValues extends Lerpable<AnimatedValues> {
  final double scale;
  final double opacity;
  final Offset offset;
  final double rotation;
  final Color? color;
  final Size? size;
  final double blur;

  const AnimatedValues({
    this.scale = 1.0,
    this.opacity = 1.0,
    this.offset = Offset.zero,
    this.rotation = 0.0,
    this.blur = 0.0,
    this.color,
    this.size,
  });

  @override
  AnimatedValues lerpTo(covariant AnimatedValues? end, double t) {
    if (end is! AnimatedValues) return this;
    return AnimatedValues(
      scale: lerpDouble(scale, end.scale, t)!,
      opacity: lerpDouble(opacity, end.opacity, t)!,
      offset: Offset.lerp(offset, end.offset, t)!,
      rotation: lerpDouble(rotation, end.rotation, t)!,
      blur: lerpDouble(blur, end.blur, t)!,
      color: Color.lerp(color, end.color, t),
      size: Size.lerp(size, end.size, t),
    );
  }
}

abstract class Lerpable<T extends Lerpable<T>> {
  const Lerpable();
  T lerpTo(covariant T? end, double t);
}

class _InlineFnTween<T extends Object?> extends Tween<T> {
  final T Function(double t) lerpFn;

  _InlineFnTween({required this.lerpFn, super.begin, super.end});

  @override
  T lerp(double t) => lerpFn(t);
}
