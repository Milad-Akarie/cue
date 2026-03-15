import 'package:cue/cue.dart';
import 'package:cue/src/acts/base/act_impl.dart';
import 'package:cue/src/motion/animtable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef ValueTransformer<R, T> = R Function(ActContext context, T value);

abstract class TweenActBase<T extends Object?, R extends Object?> extends ActImpl<R, T> {
  final T? from;
  final T? to;
  final Keyframes<T>? frames;

  @internal
  const TweenActBase({this.from, this.to, this.frames, super.motion, super.delay, required super.reverse});

  const TweenActBase.tween({
    required T this.from,
    required T this.to,
    super.motion,
    super.delay,
    ReverseBehavior<T> super.reverse = const ReverseBehavior.mirror(),
  }) : frames = null;

  const TweenActBase.keyframed({
    required Keyframes<T> this.frames,
    super.delay,
    KFReverseBehavior<T> reverse = const KFReverseBehavior.mirror(),
  }) : to = null,
       from = null,
       super(reverse: reverse);

  bool get isConstant => from != null && to != null && from == to;

  R transform(ActContext context, T value);

  Animatable<R> createSingleTween(R from, R to) {
    return Tween<R>(begin: from, end: to);
  }

  CueAnimtable<R> resolveTween(
    ActContext context, {
    required T? from,
    required T? to,
    R? implicitFrom,
    required Keyframes<T>? keyframes,
    required CueMotion motion,
  }) {
    if (keyframes != null) {
      final phases = switch (keyframes) {
        MotionKeyframes<T>(:final frames) => Phase.resolveMotionFrames<T, R>(
          frames,
          transform: (v) => transform(context, v),
        ),
        FractionalKeyframes<T>(:final frames, :final duration) => Phase.resolveFractionalFrames<T, R>(
          frames,
          duration: duration ?? motion.duration,
          transform: (v) => transform(context, v),
        ),
      };
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
      to: to,
      from: from,
      keyframes: frames,
      implicitFrom: context.implicitFrom as R?,
      motion: motion ?? context.motion,
    );

    switch (reverse.type) {
      case ReverseBehaviorType.to:
        {
          final reverseTo = reverse.to ?? reverse.frames?.lastTarget;
          final reverseAnimtable = resolveTween(
            context,
            from: to,
            to: reverseTo,
            keyframes: reverse.frames,
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
        frames == other.frames;
  }

  @override
  int get hashCode => Object.hash(from, to, frames);
}

enum ReverseBehaviorType { mirror, exclusive, none, to }

class KFReverseBehavior<T> extends ReverseBehaviorBase<T> {
  const KFReverseBehavior.mirror({super.delay}) : super._(type: ReverseBehaviorType.mirror);

  const KFReverseBehavior.exclusive() : super._(type: ReverseBehaviorType.mirror);

  const KFReverseBehavior.none() : super._(type: ReverseBehaviorType.none);

  const KFReverseBehavior.to(Keyframes<T> frames, {super.delay})
    : super._(type: ReverseBehaviorType.to, frames: frames);
}

class ReverseBehavior<T> extends ReverseBehaviorBase<T> {
  const ReverseBehavior.mirror({super.motion, super.delay}) : super._(type: ReverseBehaviorType.mirror);

  const ReverseBehavior.exclusive() : super._(type: ReverseBehaviorType.exclusive);

  const ReverseBehavior.none() : super._(type: ReverseBehaviorType.none);

  const ReverseBehavior.to({required T super.to, super.motion, super.delay}) : super._(type: ReverseBehaviorType.to);
}

class ReverseBehaviorBase<T> {
  final ReverseBehaviorType type;
  final T? to;
  final Keyframes<T>? frames;
  final CueMotion? motion;
  final Duration? delay;

  const ReverseBehaviorBase._({
    required this.type,
    this.to,
    this.frames,
    this.motion,
    this.delay,
  });

  bool get needsReverseTween => type == ReverseBehaviorType.to;

  ReverseBehaviorBase<E> mapValues<E>(E Function(T value) transform) {
    return ReverseBehaviorBase<E>._(
      type: type,
      to: to == null ? null : transform(to as T),
      frames: frames?.mapValues(transform),
      motion: motion,
      delay: delay,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ReverseBehaviorBase<T> &&
        other.type == type &&
        other.to == to &&
        frames == other.frames &&
        other.motion == motion &&
        other.delay == delay;
  }

  @override
  int get hashCode => Object.hash(type, to, frames, motion, delay);
}

abstract class TweenAct<T> extends TweenActBase<T, T> {
  @internal
  const TweenAct({
    super.from,
    super.to,
    super.frames,
    super.motion,
    super.delay,
    super.reverse = const ReverseBehavior.mirror(),
  });

  const TweenAct.tween({
    required super.from,
    required super.to,
    super.motion,
    super.delay,
    super.reverse,
  }) : super.tween();

  const TweenAct.keyframed({
    required super.frames,
    super.delay,
    super.reverse,
  }) : super.keyframed();

  @override
  T transform(_, T value) => value;
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
