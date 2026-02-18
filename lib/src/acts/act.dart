import 'dart:math' as math;
import 'dart:ui';

import 'package:cue/cue.dart';
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

  CueAnimation<Object?> buildAnimation(
    Animation<double> driver, {
    Timing? defaultTiming,
    Curve? defaultCurve,
  });

  Widget build(
    BuildContext context,
    covariant CueAnimation<Object?> animation,
    Widget child,
  );
}

class ReverseConfig<T> {
  final T? from;
  final T? to;
  final Curve? curve;
  final Timing? timing;

  const ReverseConfig({
    required this.from,
    required this.to,
    this.curve,
    this.timing,
  });

  const ReverseConfig.hold([T? value]) : from = value, to = value, curve = null, timing = null;

  bool get isHold => from == to;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReverseConfig &&
          runtimeType == other.runtimeType &&
          from == other.from &&
          to == other.to &&
          curve == other.curve &&
          timing == other.timing;

  @override
  int get hashCode => from.hashCode ^ to.hashCode ^ curve.hashCode ^ timing.hashCode;
}

abstract class TweenEffectBase<T extends Object?, R extends Object?> extends Effect {
  final T? _from;
  final T? _to;
  final List<Keyframe<T>>? _keyframes;
  final List<Keyframe<T>>? _reverseKeyframes;
  final ReverseConfig<T>? _reverse;

  const TweenEffectBase({
    required T from,
    required T to,
    super.curve,
    super.timing,
    ReverseConfig<T>? reverse,
  }) : _reverse = reverse,
       _keyframes = null,
       _reverseKeyframes = null,
       _from = from,
       _to = to;

  const TweenEffectBase.keyframes(
    List<Keyframe<T>> keyframes, {
    List<Keyframe<T>>? reverseKeyframes,
    super.curve,
  }) : _keyframes = keyframes,
       _from = null,
       _to = null,
       _reverse = null,
       _reverseKeyframes = reverseKeyframes;

  @nonVirtual
  @override
  Widget build(BuildContext context, covariant CueAnimation<Object?> animation, Widget child) {
    assert(
      animation is CueAnimation<R>,
      'Expected animation of type CueAnimation<$T>, but got ${animation.runtimeType}',
    );
    return apply(context, animation as CueAnimation<R>, child);
  }

  Widget apply(BuildContext context, CueAnimation<R> animation, Widget child);

  R transform(T value);

  Animatable<R> buildSinglePhaseTween(R from, R to) {
    return Tween<R>(begin: from, end: to);
  }

  Animatable<R> _buildAnimatable({
    T? from,
    T? to,
    List<Keyframe<T>>? keyframes,
    Timing? timing,
    Curve? curve,
  }) {
    final List<Phase<R>> phases;

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
    final tween = TweenEffectBase.buildFromPhases<R>(phases, buildSinglePhaseTween);
    if (curve == null && timing == null) {
      return tween;
    }
    final effectiveCurve = timing != null
        ? Interval(timing.start, timing.end, curve: curve ?? Curves.linear)
        : curve ?? Curves.linear;
    return tween.chain(CurveTween(curve: effectiveCurve));
  }

  @override
  CueAnimation<R> buildAnimation(Animation<double> driver, {Timing? defaultTiming, Curve? defaultCurve}) {
    final forwardAnimtable = _buildAnimatable(
      from: _from,
      to: _to,
      keyframes: _keyframes,
      timing: timing ?? defaultTiming,
      curve: curve ?? defaultCurve,
    );

    Animatable<R>? reverseAnimtable;
    if (_reverse != null || _reverseKeyframes != null) {
      reverseAnimtable = _buildAnimatable(
        from: _reverse?.from ?? _to,
        to: _reverse?.to ?? _from,
        keyframes: _reverseKeyframes,
        timing: _reverse?.timing ?? timing ?? defaultTiming,
        curve: _reverse?.curve ?? curve ?? defaultCurve,
      );
    }
    return CueAnimation<R>(
      driver: driver,
      forward: forwardAnimtable,
      reverse: reverseAnimtable,
    );
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
      tween = TweenSequence<T>([
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
          listEquals(_reverseKeyframes, other._reverseKeyframes) &&
          _reverse == other._reverse &&
          curve == other.curve &&
          timing == other.timing;

  @override
  int get hashCode => Object.hash(
    _from,
    _to,
    curve,
    timing,
    Object.hashAll(_keyframes ?? []),
    Object.hashAll(_reverseKeyframes ?? []),
    _reverse,
  );
}

abstract class TweenEffect<T extends Object?> extends TweenEffectBase<T, T> {
  const TweenEffect({
    required super.from,
    required super.to,
    super.reverse,
    super.curve,
    super.timing,
  });

  @override
  T transform(T value) => value;

  const TweenEffect.keyframes(
    super.keyframes, {
    super.reverseKeyframes,
    super.curve,
  }) : super.keyframes();
}
