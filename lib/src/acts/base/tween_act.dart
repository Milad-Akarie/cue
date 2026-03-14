import 'package:cue/cue.dart';
import 'package:cue/src/acts/base/act_impl.dart';
import 'package:cue/src/motion/animtable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef ValueTransformer<R, T> = R Function(ActContext context, T value);

abstract class TweenActBase<T extends Object?, R extends Object?> extends ActImpl<R, T> {
  final T? from;
  final T? to;
  final List<Keyframe<T>>? keyframes;
  final List<FractionalKeyframe<T>>? fractionalKeyframes;
  final Duration? _fractionalKeyframesDuration;

  @internal
  const TweenActBase({
    this.from,
    this.to,
    this.keyframes,
    this.fractionalKeyframes,
    super.motion,
    super.delay,
    super.reverse = const ReverseBehavior.mirror(),
    Duration? fractionalKeyframesDuration,
  }) : _fractionalKeyframesDuration = fractionalKeyframesDuration;

  const TweenActBase.tween({
    required T this.from,
    required T this.to,
    super.motion,
    super.delay,
    super.reverse = const ReverseBehavior.mirror(),
  }) : keyframes = null,
       fractionalKeyframes = null,
       _fractionalKeyframesDuration = null;

  const TweenActBase.keyframes(
    List<Keyframe<T>> this.keyframes, {
    super.motion,
    super.delay,
    super.reverse = const ReverseBehavior.mirror(),
  }) : from = null,
       to = null,
       fractionalKeyframes = null,
       _fractionalKeyframesDuration = null;

  const TweenActBase.fractionalKeyframes(
    List<FractionalKeyframe<T>> this.fractionalKeyframes, {
    Duration? duration,
    super.motion,
    super.delay,
    super.reverse = const ReverseBehavior.mirror(),
  }) : _fractionalKeyframesDuration = duration,
       from = null,
       to = null,
       keyframes = null;

  bool get isConstant => from != null && to != null && from == to;

  R transform(ActContext context, T value);

  Animatable<R> createSingleTween(R from, R to) {
    return Tween<R>(begin: from, end: to);
  }

  CueAnimtable<R> resolveTween(
    ActContext context, {
    T? from,
    T? to,
    R? implicitFrom,
    List<Keyframe<T>>? keyframes,
    List<FractionalKeyframe<T>>? fractionalKeyframes,
    Duration? fractionalKeyframesDuration,
    required CueMotion motion,
  }) {
    if (keyframes != null) {
      assert(keyframes.isNotEmpty, 'Keyframes list cannot be empty');
      final phases = Phase.resolveAbsoluteFrames<T, R>(keyframes, (v) => transform(context, v));
      return SegmentedAnimtable([
        for (final phase in phases)
          AnimatableSegment(
            animatable: createSingleTween(phase.begin, phase.end),
            motion: phase.motion,
          ),
      ]);
    } else if (fractionalKeyframes != null) {
      assert(fractionalKeyframes.isNotEmpty, 'Fractional keyframes list cannot be empty');
      final totalDuration = fractionalKeyframesDuration ?? motion.duration;
      final phases = Phase.resolveFractionalFrames<T, R>(
        fractionalKeyframes,
        totalDuration,
        (v) => transform(context, v),
      );
      return SegmentedAnimtable([
        for (final phase in phases)
          AnimatableSegment(
            animatable: createSingleTween(phase.begin, phase.end),
            motion: phase.motion,
          ),
      ]);
    } else {
      final effectiveFrom = implicitFrom ?? transform(context, from as T);
      assert(effectiveFrom != null && to != null, 'From and to values must be provided when not using keyframes');
      if (effectiveFrom == to) {
        return AlwaysStoppedAnimatable<R>(effectiveFrom);
      } else {
        return TweenAnimtable<R>(
          createSingleTween(effectiveFrom, transform(context, to as T)),
          motion: motion,
        );
      }
    }
  }

  @override
  (CueAnimtable<R> animtable, CueAnimtable<R>? reverseAnimtable) buildTweens(ActContext context) {

    final animtable = resolveTween(
      context,
      from: from,
      to: to,
      keyframes: keyframes,
      fractionalKeyframes: fractionalKeyframes,
      fractionalKeyframesDuration: _fractionalKeyframesDuration,
      implicitFrom: context.implicitFrom as R?,
      motion: motion ?? context.motion,
    );

    switch (reverse.type) {
      case ReverseBehaviorType.none:
      case ReverseBehaviorType.to:
      case ReverseBehaviorType.keyframes:
        {
          final reverseAnimtable = resolveTween(
            context,
            from: to,
            to: reverse.to,
            keyframes: reverse.keyframes,
            fractionalKeyframes: reverse.fractionalKeyframes,
            fractionalKeyframesDuration: reverse.fractionalKeyframesDuration,
            motion: reverse.motion ?? context.reverseMotion ?? context.motion,
          );
          return (animtable, reverseAnimtable);
        }
      default:
        return (animtable, null);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is TweenActBase<T, R> &&
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
  final List<FractionalKeyframe<T>>? fractionalKeyframes;
  final Duration? fractionalKeyframesDuration;
  final CueMotion? motion;
  final Duration? delay;

  bool get needsReverseTween {
    switch (type) {
      case ReverseBehaviorType.to:
      case ReverseBehaviorType.keyframes:
        return true;
      default:
        return false;
    }
  }

  const ReverseBehavior.mirror({this.motion, this.delay})
    : type = ReverseBehaviorType.mirror,
      to = null,
      keyframes = null,
      fractionalKeyframes = null,
      fractionalKeyframesDuration = null;
  const ReverseBehavior.exclusive()
    : type = ReverseBehaviorType.exclusive,
      to = null,
      keyframes = null,
      fractionalKeyframes = null,
      fractionalKeyframesDuration = null,
      motion = null,
      delay = null;

  const ReverseBehavior.none()
    : type = ReverseBehaviorType.none,
      to = null,
      keyframes = null,
      motion = null,
      fractionalKeyframes = null,
      fractionalKeyframesDuration = null,
      delay = null;

  const ReverseBehavior.to(T this.to, {this.motion, this.delay})
    : type = ReverseBehaviorType.to,
      keyframes = null,
      fractionalKeyframes = null,
      fractionalKeyframesDuration = null;

  const ReverseBehavior.keyframes(List<Keyframe<T>> this.keyframes, {this.motion, this.delay})
    : type = ReverseBehaviorType.keyframes,
      fractionalKeyframes = null,
      fractionalKeyframesDuration = null,
      to = null;

  const ReverseBehavior.fractionalKeyframes(
    List<FractionalKeyframe<T>> this.fractionalKeyframes, {
    Duration? duration,
    this.motion,
    this.delay,
  }) : type = ReverseBehaviorType.keyframes,
       keyframes = null,
       fractionalKeyframesDuration = duration,
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

abstract class TweenAct<T> extends TweenActBase<T, T> {
  const TweenAct({
    super.from,
    super.to,
    super.keyframes,
    super.motion,
    super.delay,
    super.reverse = const ReverseBehavior.mirror(),
  });

  @override
  T transform(_, T value) => value;

  const TweenAct.keyframes(super.keyframes, {super.motion, super.delay, super.reverse}) : super.keyframes();

  @internal
  const TweenAct.internal({
    super.from,
    super.to,
    super.motion,
    super.delay,
    super.reverse,
    super.keyframes,
  });
}

class AnimatableValue<T> {
  final T from;
  final T to;

  const AnimatableValue({
    required this.from,
    required this.to,
  });

  const AnimatableValue.fixed(T value) : from = value, to = value;

  const AnimatableValue.tween({required this.from, required this.to});

  bool get isConstant => from == to;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is AnimatableValue<T> && other.from == from && other.to == to;
  }

  @override
  int get hashCode => Object.hash(from, to);
}
