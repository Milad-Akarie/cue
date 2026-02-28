import 'package:cue/cue.dart';
import 'package:cue/src/effects/base/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class TweenEffectBase<T extends Object?, R extends Object?> extends Effect {
  final T? _from;
  final T? _to;
  final List<Keyframe<T>>? _keyframes;

  const TweenEffectBase({
    required T from,
    required T to,
    super.curve,
    super.timing,
  }) : _keyframes = null,
       _from = from,
       _to = to;

  const TweenEffectBase.keyframes(
    List<Keyframe<T>> keyframes, {
    super.curve,
  }) : _keyframes = keyframes,
       _from = null,
       _to = null;

  @internal
  const TweenEffectBase.internal({
    T? from,
    T? to,
    List<Keyframe<T>>? keyframes,
    super.curve,
    super.timing,
  }) : _keyframes = keyframes,
       _from = from,
       _to = to;

  @nonVirtual
  @override
  Widget build(BuildContext context, covariant Animation<Object?> animation, Widget child) {
    assert(
      animation is Animation<R>,
      'Expected animation of type Animation<$T>, but got ${animation.runtimeType}',
    );
    return apply(context, animation as Animation<R>, child);
  }

  Widget apply(BuildContext context, Animation<R> animation, Widget child);

  R transform(T value);

  Animatable<R> buildSinglePhaseAnimtable(R from, R to) {
    return Tween<R>(begin: from, end: to);
  }

  ({Animatable<R> tween, Timing? timing}) _buildTween({
    T? from,
    T? to,
    List<Keyframe<T>>? keyframes,
    Timing? defaultTiming,
  }) {
    final List<Phase<R>> phases;

    Timing? timing = defaultTiming;
    if (keyframes == null) {
      assert(
        from != null && to != null,
        'Begin and end values must be provided when not using keyframes',
      );
      phases = [
        Phase<R>(
          begin: transform(from as T),
          end: transform(to as T),
          weight: 100,
        ),
      ];
    } else {
      assert(keyframes.isNotEmpty, 'Keyframes list cannot be empty');
      final result = Phase.normalize(keyframes, transform);
      phases = result.phases;
      if (result.timing != null) {
        timing = result.timing;
      }
    }
    return (
      tween: buildFromPhases<R>(phases, buildSinglePhaseAnimtable),
      timing: timing,
    );
  }

  @override
  Animation<R> buildAnimation(Animation<double> driver, ActorContext context) {
    final tweenRes = _buildTween(
      from: _from,
      to: _to,
      keyframes: _keyframes,
      defaultTiming: timing ?? context.timing,
    );

    final tween = tweenRes.tween;
    if (tween is ConstantTween<R>) {
      // todo: rethink what status should the animation be in
      return AlwaysStoppedAnimation(tween.begin as R);
    }

    final animatable = applyCurves(
      tween,
      curve: context.curve,
      timing: tweenRes.timing,
      isBounded: context.isBounded,
    );

    Animatable<R>? reverseAnimatable;
    if (context.reverseCurve != null || context.reverseTiming != null) {
      reverseAnimatable = applyCurves<R>(
        tween,
        curve: context.reverseCurve,
        timing: context.reverseTiming,
        isBounded: context.isBounded,
      );
    }

    return switch (context.role) {
      ActorRole.both =>
        reverseAnimatable == null
            ? driver.drive(animatable)
            : DualAnimation(
                parent: driver,
                forward: animatable,
                reverse: reverseAnimatable,
              ),
      ActorRole.forward => ForwardOrStoppedAnimation(driver).drive(animatable),
      ActorRole.reverse => ReverseOrStoppedAnimation(driver).drive(animatable),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TweenEffectBase &&
          runtimeType == other.runtimeType &&
          _from == other._from &&
          _to == other._to &&
          listEquals(_keyframes, other._keyframes) &&
          curve == other.curve &&
          timing == other.timing;

  @override
  int get hashCode => Object.hash(
    _from,
    _to,
    curve,
    timing,
    Object.hashAll(_keyframes ?? []),
  );
}

abstract class TweenEffect<T extends Object?> extends TweenEffectBase<T, T> {
  const TweenEffect({
    required super.from,
    required super.to,
    super.curve,
    super.timing,
  });

  @override
  T transform(T value) => value;

  const TweenEffect.keyframes(
    super.keyframes, {
    super.curve,
  }) : super.keyframes();

  @internal
  const TweenEffect.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
  }) : super.internal();
}
