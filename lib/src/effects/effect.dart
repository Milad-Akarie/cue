import 'dart:math' as math;
import 'dart:ui';

import 'package:cue/cue.dart';
import 'package:cue/src/core/curves.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

part 'size.dart';
part 'translate.dart';
part 'decorate.dart';
part 'rotate.dart';
part 'scale.dart';
part 'fade.dart';
part 'blur.dart';
part 'align.dart';
part 'padding.dart';
part 'style.dart';
part 'clip_reveal.dart';
part 'slide.dart';
part 'position.dart';
part 'transfrom.dart';

typedef TweenBuilder<T> = Animatable<T> Function(T from, T to);

abstract class Effect {
  final Timing? timing;
  final Curve? curve;

  const Effect({
    this.timing,
    this.curve,
  });

  Animation<Object?> buildAnimation(Animation<double> driver, AnimationBuildData data);

  Widget build(BuildContext context, covariant Animation<Object?> animation, Widget child);
}

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

  Animatable<R> buildSinglePhaseTween(R from, R to) {
    return Tween<R>(begin: from, end: to);
  }

  Animatable<R> applyCurves(Animatable<R> animatable, {Curve? curve, Timing? timing, bool isBounded = false}) {
    if (curve == null && timing == null) {
      return animatable;
    }
    final effectiveCurve = timing != null
        ? BoundedInterval(timing.start, timing.end, curve: curve ?? Curves.linear)
        : curve ?? Curves.linear;
    return animatable.chain(BoundedCurveTween(curve: effectiveCurve, applyBounds: isBounded));
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
        Phase<R>(begin: transform(from as T), end: transform(to as T), weight: 100),
      ];
    } else {
      final result = Phase.normalize(keyframes, (value) => transform(value));
      phases = result.phases;
      if (result.timing != null) {
        timing = result.timing;
      }
    }
    return (
      tween: TweenEffectBase.buildFromPhases<R>(phases, buildSinglePhaseTween),
      timing: timing,
    );
  }

  @override
  Animation<R> buildAnimation(Animation<double> driver, AnimationBuildData data) {
    final tweenRes = _buildTween(
      from: _from,
      to: _to,
      keyframes: _keyframes,
      defaultTiming: timing ?? data.timing,
    );

    final animatable = applyCurves(
      tweenRes.tween,
      curve: data.curve,
      timing: tweenRes.timing,
      isBounded: data.isBounded,
    );

    Animatable<R>? reverseAnimatable;
    if (data.reverseCurve != null || data.reverseTiming != null) {
      reverseAnimatable = applyCurves(
        tweenRes.tween,
        curve: data.reverseCurve,
        timing: data.reverseTiming,
        isBounded: data.isBounded,
      );
    }

    return switch (data.role) {
      ActorRole.both =>
        reverseAnimatable == null
            ? driver.drive(animatable)
            : DaulAnimation(
                parent: driver,
                forward: animatable,
                reverse: reverseAnimatable,
              ),
      ActorRole.forward => ForwardOrStoppedAnimation(driver).drive(animatable),
      ActorRole.reverse => ReverseOrStoppedAnimation(driver).drive(animatable),
    };
  }

  static Animatable<T> buildFromPhases<T extends Object?>(
    List<Phase<T>> phases,
    TweenBuilder<T> tweenBuilder,
  ) {
    Animatable<T> tween;
    if (phases.length == 1) {
      final phase = phases.single;
      if (phase.isAlwaysStopped) {
        return ConstantTween<T>(phase.begin);
      }
      tween = tweenBuilder(phase.begin, phase.end);
    } else {
      tween = BoundedTweenSequence<T>([
        for (final phase in phases)
          TweenSequenceItem(
            tween: phase.isAlwaysStopped
                ? ConstantTween<T>(phase.begin)
                : tweenBuilder(
                    phase.begin,
                    phase.end,
                  ),
            weight: phase.weight,
          ),
      ]);
    }
    return tween;
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
}

class AnimationBuildData {
  final Timing? timing;
  final Timing? reverseTiming;
  final Curve? curve;
  final Curve? reverseCurve;
  final bool isBounded;
  final ActorRole role;

  const AnimationBuildData({
    this.timing,
    this.curve,
    this.isBounded = true,
    this.reverseTiming,
    this.reverseCurve,
    this.role = ActorRole.both,
  });
}

enum ActorRole { forward, reverse, both }
