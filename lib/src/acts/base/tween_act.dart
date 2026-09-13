import 'package:cue/cue.dart';
import 'package:cue/src/acts/base/animatable_act.dart';
import 'package:cue/src/motion/cue_motion.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Signature for a function that transforms a value from its stored type `T`
/// to an animated type `R`.
///
/// Used by [TweenActBase] to normalize or project values before animating.
/// For example, an enum might be transformed to a numeric offset.
///
/// Called during [CueAnimtable] construction, receiving the [ActContext] so
/// that the transformation can depend on properties like [ActContext.textDirection].
typedef ValueTransformer<R, T> = R Function(ActContext context, T value);

/// Base for tween-based and keyframed acts with value transformation.
///
/// [TweenActBase] extends [AnimtableAct] to add support for:
/// - **Tween mode**: `from` and `to` values, plus per-frame reverse behavior
/// - **Keyframed mode**: sequence of keyframes, plus keyframe-based reverse behavior
/// - **Value transformation**: normalizing stored type `T` into animated type `R`
/// - **Reverse behavior resolution**: `ReverseBehavior` (tween mode) or
///   `KFReverseBehavior` (keyframed mode) determine what happens on reverse
///
/// ## Type Parameters
///
/// - `T` — the value type for this act's `from`, `to`, keyframes, and
///   reverse behavior (e.g., `double`, `Offset`, `Color`). Passed to
///   [ReverseBehavior.to] and [KFReverseBehavior.to].
/// - `R` — the animated value type flowing through [CueAnimtable]. Usually
///   `T == R`; they may differ when [transform] normalizes the input
///   (e.g., transforming an enum to a numeric range).
///
/// ## Constructors
///
/// - `.tween()` — tween-based act with `from` and `to` values
/// - `.keyframed()` — keyframed act with `Keyframes<T>` and optional `from`
///   for the first frame
///
/// ## Motion and Delay Resolution
///
/// [resolveMotion] is a static helper that combines and prioritizes motion/delay
/// settings:
/// 1. **Frame-level motion** (from keyframes) overrides act-level and context motion
/// 2. **Delay stacking**: `act.delay` + `context.delay`
/// 3. **Reverse motion/delay**: depends on [ReverseBehaviorBase] variant
///    - `.mirror()`: reverse uses forward motion (no override)
///    - `.exclusive()`: forward and reverse swap, reverse motion from reverse behavior
///    - `.to()` or `.to(Keyframes)`: reverse has its own target/motion/delay
///    - `.none()`: no reverse animation
///
/// Called by [resolve] to build the final [ActContext] for this act.
///
/// ## Reverse Behavior
///
/// The [reverse] parameter determines the act's behavior when the timeline
/// plays backwards:
///
/// - [ReverseBehavior.mirror]: reverse plays forward animatable in reverse
///   (default for tween acts)
/// - [ReverseBehavior.exclusive]: forward animates to `to`, reverse animates
///   to `from` (swapped animation)
/// - [ReverseBehavior.none]: no reverse animation
/// - [ReverseBehavior.to]: forward animates to `to`, reverse animates to
///   a different target value
///
/// For keyframed acts, use [KFReverseBehavior] which has the same variants
/// but `.to()` takes a `Keyframes<T>` instead of a plain value, and no
/// per-frame `motion` override (only `delay`).
///
/// ## Subclassing
///
/// Concrete tween acts override [transform] to normalize their value type,
/// returning the animated value. For example:
///
/// ```dart
/// class ScaleAct extends TweenAct<double> {
///   @override
///   double transform(_, double value) => value; // identity transform
/// }
///
/// class RotateAct extends TweenAct<double> {
///   @override
///   double transform(_, double degrees) => degrees * pi / 180; // degrees to radians
/// }
/// ```
abstract class TweenActBase<T extends Object?, R extends Object?> extends AnimtableAct<T, R> {
  /// The initial animated value for this tween.
  ///
  /// In tween mode, `from` is the start value. If not provided, the current
  /// animated value is used (implicit from).
  ///
  /// In keyframed mode, `from` is optional and used only for constructing
  /// the first keyframe segment when not present in the keyframes themselves.
  final T? from;

  /// The final animated value for this tween (tween mode only).
  ///
  /// Used as the end value of the forward pass when not in keyframed mode.
  /// Ignored if [frames] is non-null.
  final T? to;

  /// Keyframes for this act (keyframed mode only).
  ///
  /// Non-null means this act is in keyframed mode. Can be either
  /// [MotionKeyframes] (with per-frame motion) or [FractionalKeyframes]
  /// (with normalized time steps and optional `curve` at keyframe and
  /// Keyframes level).
  final Keyframes<T>? frames;

  /// Creates a tween act base with optional [from], [to], [frames], [motion], [delay], and [reverse].
  @internal
  const TweenActBase({this.from, this.to, this.frames, super.motion, super.delay, required super.reverse});

  /// Constructs a tween act with `from` and `to` values.
  const TweenActBase.tween({
    required T this.from,
    required T this.to,
    super.motion,
    super.delay,
    ReverseBehavior<T> super.reverse = const ReverseBehavior.mirror(),
  }) : frames = null;

  /// Constructs a keyframed act with `Keyframes<T>`.
  ///
  /// - `frames`: required keyframes sequence
  /// - `from`: optional initial value for the first keyframe segment
  /// - `delay`: delay before animation starts
  /// - `reverse`: [KFReverseBehavior] for reverse behavior
  const TweenActBase.keyframed({
    required Keyframes<T> this.frames,
    super.delay,
    this.from,
    KFReverseBehavior<T> super.reverse = const KFReverseBehavior.mirror(),
  }) : to = null;

  /// Whether this tween is a no-op (from == to).
  bool get isConstant => from != null && to != null && from == to;

  /// Transforms a value of type `T` into an animated value of type `R`.
  ///
  /// Called during [CueAnimtable] construction. For acts where `T == R`,
  /// this is typically an identity function. For acts that normalize their
  /// input (e.g., degrees to radians), override this method.
  R transform(ActContext context, T value);

  /// Creates a single [Animatable] from `from` to `to` values.
  ///
  /// Defaults to [Tween]. Subclasses can override to use specialized
  /// animatables (e.g., [ColorTween], [SizeTween]).
  Animatable<R> createSingleTween(R from, R to) {
    return Tween<R>(begin: from, end: to);
  }

  /// Resolves the final motion and delay for this act after combining all
  /// inheritance and override sources.
  ///
  /// This is a static helper used by the [resolve] method. It handles:
  /// - Frame-level motion from keyframes (if present)
  /// - Act-level motion/delay overrides
  /// - Context motion/delay inheritance
  /// - Reverse motion/delay resolution based on [ReverseBehaviorBase] variant
  ///
  /// Parameters:
  /// - `context`: the initial [ActContext] from [Actor]/[Cue] inheritance
  /// - `motion`: act-level motion override (from this act's field)
  /// - `delay`: act-level delay (from this act's field)
  /// - `reverse`: the reverse behavior with its own motion/delay overrides
  /// - `frames`: optional keyframes (motion may be embedded here)
  /// - `includeFirstFrame`: if true, extract motion from the first keyframe
  ///   segment (used when `from` is explicitly provided)
  ///
  /// Returns a new [ActContext] with resolved `motion` and `reverseMotion`.
  static ActContext resolveMotion<T>(
    ActContext context, {
    CueMotion? motion,
    Duration delay = Duration.zero,
    required ReverseBehaviorBase reverse,
    Keyframes<T>? frames,
    bool includeFirstFrame = false,
  }) {
    CueMotion? framesMotion = switch (frames) {
      MotionKeyframes<T> m => SegmentedMotion(m.extractMotion(includeFirst: includeFirstFrame)),
      FractionalKeyframes<T> m => SegmentedMotion(
        m.extractMotion(
          includeFirst: includeFirstFrame,
          duration: m.duration ?? context.motion.baseDuration,
        ),
      ),
      _ => null,
    };

    CueMotion? reverseFramesMotion = switch (reverse.frames?.reversed) {
      MotionKeyframes<T> m => SegmentedMotion(m.extractMotion(includeFirst: true)),
      FractionalKeyframes<T> m => SegmentedMotion(
        m.extractMotion(
          includeFirst: true,
          duration: m.duration ?? context.reverseMotion.baseDuration,
        ),
      ),
      _ => framesMotion,
    };

    final forwardDelay = delay + context.delay;
    final reverseDelay = reverse.delay + context.reverseDelay;

    CueMotion forwardMotion = framesMotion ?? motion ?? context.motion;
    CueMotion reverseMotion = reverseFramesMotion ?? reverse.motion ?? motion ?? context.reverseMotion;

    if (forwardDelay != Duration.zero) {
      forwardMotion = forwardMotion.delayed(forwardDelay);
    }
    if (reverseDelay != Duration.zero) {
      reverseMotion = reverseMotion.delayed(reverseDelay);
    }
    return context.copyWith(motion: forwardMotion, reverseMotion: reverseMotion);
  }

  /// Resolves the final [ActContext] for this act by calling [resolveMotion].
  ///
  /// Passes this act's `from`, `to`, keyframes, and reverse behavior to
  /// [resolveMotion] so that motion and delay are properly combined.
  @override
  ActContext resolve(ActContext context) {
    return resolveMotion(
      context,
      motion: motion,
      delay: delay,
      reverse: reverse,
      frames: frames,
      includeFirstFrame: from != null,
    );
  }

  /// Builds a [CueAnimtable] from tween or keyframe values.
  ///
  /// Central method for constructing the animatable based on the input:
  /// - If `keyframes` is non-null, uses [SegmentedAnimtable] with per-frame
  ///   phases (either [Phase.resolveMotionFrames] or [Phase.resolveFractionalFrames])
  /// - If `keyframes` is null, uses a basic [TweenAnimtable] (or [ConstantAnimtable]
  ///   if from == to)
  ///
  /// Also applies [transform] to all values, handling the `implicitFrom` case
  /// where the initial value comes from the current animation state.
  ///
  /// Parameters:
  /// - `from`: the (untransformed) initial value
  /// - `to`: the (untransformed) final value
  /// - `iniitalkeyframe`: initial value for keyframe segments (typo in param name)
  /// - `implicitFrom`: if non-null, use this as the transformed `from` instead
  ///   of transforming `from` directly (used when animating from current value)
  /// - `forReverse`: if true, mark phases for reverse animation
  /// - `keyframes`: optional keyframes sequence
  CueAnimtable<R> resolveTween(
    ActContext context, {
    required T? from,
    required T? to,
    T? iniitalkeyframe,
    R? implicitFrom,
    bool forReverse = false,
    required Keyframes<T>? keyframes,
  }) {
    if (keyframes != null) {
      final phases = switch (keyframes) {
        MotionKeyframes<T>(:final frames) => Phase.resolveMotionFrames<T, R>(
          frames,
          from: iniitalkeyframe,
          forReverse: forReverse,
          transform: (v) => transform(context, v),
        ),
        FractionalKeyframes<T>(:final frames) => Phase.resolveFractionalFrames<T, R>(
          frames,
          from: iniitalkeyframe,
          forReverse: forReverse,
          transform: (v) => transform(context, v),
        ),
      };
      return SegmentedAnimtable([for (final phase in phases) createSingleTween(phase.begin, phase.end)]);
    } else {
      final effectiveFrom = implicitFrom ?? transform(context, from as T);
      assert(effectiveFrom != null && to != null, 'From and to values must be provided when not using keyframes');
      if (effectiveFrom == to) {
        return ConstantAnimtable<R>(effectiveFrom);
      } else {
        return TweenAnimtable<R>(
          createSingleTween(effectiveFrom, transform(context, to as T)),
        );
      }
    }
  }

  /// Implements the core reverse behavior logic for tween and keyframed acts.
  ///
  /// Returns a pair `(forward, reverse?)` where:
  /// - **forward** is always the animatable for the forward pass
  /// - **reverse** (optional) is a different animatable for the reverse pass,
  ///   only present when the reverse behavior is [ReverseBehaviorType.to]
  ///
  /// Reverse behavior handling:
  /// - [ReverseBehaviorType.exclusive]: forward and reverse are swapped
  ///   (forward goes to `to`, reverse goes to `from` — no separate reverse
  ///   animatable needed, they're both built via `resolveTween` with swapped
  ///   args)
  /// - [ReverseBehaviorType.to]: both forward and reverse animatables are built,
  ///   reverse targets `reverse.to` or the last keyframe
  /// - [ReverseBehaviorType.mirror]: only forward animatable is built (reverse
  ///   plays it backwards)
  /// - [ReverseBehaviorType.none]: only forward animatable is built (no reverse)
  @override
  (CueAnimtable<R>, CueAnimtable<R>?) buildTweens(ActContext context) {
    if (reverse.type == ReverseBehaviorType.exclusive) {
      return (
        resolveTween(
          context,
          from: to,
          to: from,
          iniitalkeyframe: from,
          keyframes: frames?.reversed,
          implicitFrom: context.implicitFrom as R?,
        ),
        null,
      );
    }

    final animtable = resolveTween(
      context,
      from: from,
      iniitalkeyframe: from,
      to: to,
      keyframes: frames,
      implicitFrom: context.implicitFrom as R?,
    );

    if (reverse.type == ReverseBehaviorType.to) {
      final reverseTo = reverse.to ?? reverse.frames?.lastTarget;
      final reverseAnimtable = resolveTween(
        context,
        from: reverseTo,
        to: to,
        iniitalkeyframe: frames?.lastTarget ?? to,
        keyframes: reverse.frames?.reversed,
        forReverse: true,
      );
      return (animtable, reverseAnimtable);
    }

    return (animtable, null);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is TweenActBase<T, R> &&
        other.from == from &&
        other.to == to &&
        other.delay == delay &&
        other.motion == motion &&
        other.reverse == reverse &&
        frames == other.frames;
  }

  @override
  int get hashCode => Object.hash(from, to, frames, reverse, motion, delay);
}

/// Enumeration of reverse behavior types for tween-based and keyframed acts.
///
/// Determines what happens to the animation when the timeline plays in reverse.
/// Set via [ReverseBehavior] (for tween acts) or [KFReverseBehavior]
/// (for keyframed acts).
enum ReverseBehaviorType {
  /// Reverse plays the forward animatable in reverse (default).
  ///
  /// Example: if forward goes 0→1, reverse goes 1→0.
  /// Can specify a separate reverse motion/delay, but the same animatable is used for both directions.
  mirror,

  /// Forward and reverse have opposite targets.
  ///
  /// Example: forward animates to `to`, reverse animates to `from`.
  /// The forward and reverse animations are essentially swapped.
  exclusive,

  /// No reverse animation occurs.
  ///
  /// When the timeline reverses, this act stops animating.
  none,

  /// Reverse has a different target than forward.
  ///
  /// Forward animates to `to`, reverse animates to a custom target
  /// value or keyframes sequence.
  /// Can specify separate motion/delay for reverse.
  to;

  /// Whether this type requires a separate reverse animatable.
  bool get needsReverseTween => this == ReverseBehaviorType.to;

  /// Whether this type is [mirror].
  bool get isMirror => this == ReverseBehaviorType.mirror;

  /// Whether this type is [exclusive].
  bool get isExclusive => this == ReverseBehaviorType.exclusive;

  /// Whether this type is [none].
  bool get isNone => this == ReverseBehaviorType.none;
}

/// Reverse behavior for keyframed acts.
///
/// Similar to [ReverseBehavior] but for keyframed animations:
/// - `.mirror()` — reverse plays forward keyframes in reverse (default)
/// - `.exclusive()` — forward and reverse keyframes are swapped
/// - `.none()` — no reverse animation
/// - `.to(Keyframes<T>)` — reverse animates to a custom keyframe sequence
///
/// Key difference from [ReverseBehavior]: `.mirror()` and `.to()` accept only
/// `delay:` (no `motion:`), because motion is embedded in the keyframes
/// themselves via [MotionKeyframes] or [FractionalKeyframes].
class KFReverseBehavior<T> extends ReverseBehaviorBase<T> {
  /// Play forward keyframes in reverse (default for keyframed acts).
  const KFReverseBehavior.mirror({super.delay}) : super._(type: ReverseBehaviorType.mirror);

  /// Forward and reverse keyframes are swapped.
  const KFReverseBehavior.exclusive() : super._(type: ReverseBehaviorType.exclusive);

  /// No reverse animation.
  const KFReverseBehavior.none() : super._(type: ReverseBehaviorType.none);

  /// Reverse animates to a custom keyframe sequence.
  ///
  /// The `frames` parameter specifies the animation sequence for the reverse
  /// pass. Motion is embedded in the keyframes; no per-frame motion override
  /// is supported.
  const KFReverseBehavior.to(Keyframes<T> frames, {super.delay})
    : super._(type: ReverseBehaviorType.to, frames: frames);
}

/// Reverse behavior for tween acts.
///
/// Determines what the act does when the timeline plays in reverse:
/// - `.mirror()` — reverse plays forward animation in reverse (default)
/// - `.exclusive()` — forward and reverse targets are swapped
/// - `.none()` — no reverse animation
/// - `.to(T to)` — reverse animates to a custom target value
///
/// The `.mirror()` and `.to()` variants accept both `motion:` (reverse motion
/// override) and `delay:` (reverse delay). These are the only ways to set
/// reverse-specific motion/delay on an act.
class ReverseBehavior<T> extends ReverseBehaviorBase<T> {
  /// Play forward animation in reverse (default for tween acts).
  ///
  /// Parameters:
  /// - `motion`: custom motion for reverse (overrides act/context motion)
  /// - `delay`: custom delay for reverse (added to context reverse delay)
  const ReverseBehavior.mirror({super.motion, super.delay}) : super._(type: ReverseBehaviorType.mirror);

  /// Forward and reverse targets are swapped.
  ///
  /// Forward animates to `to`, reverse animates to `from`. No custom motion
  /// or delay can be set — they use `from` and `to` as-is.
  const ReverseBehavior.exclusive() : super._(type: ReverseBehaviorType.exclusive);

  /// No reverse animation.
  ///
  /// When the timeline plays backwards, this act does not animate.
  const ReverseBehavior.none() : super._(type: ReverseBehaviorType.none);

  /// Reverse animates to a custom target value.
  ///
  /// Forward animates to `to`, reverse animates to `to` (the parameter).
  /// Use this to make reverse go to a different endpoint than forward.
  ///
  /// Parameters:
  /// - `to`: the target value for reverse
  /// - `motion`: custom motion for reverse (overrides act/context motion)
  /// - `delay`: custom delay for reverse (added to context reverse delay)
  const ReverseBehavior.to(T to, {super.motion, super.delay}) : super._(type: ReverseBehaviorType.to, to: to);
}

/// Base class for reverse behavior, shared by tween and keyframed acts.
///
/// Stores the reverse type, optional target (for `.to()` tween mode), optional
/// keyframes (for `.to()` keyframed mode), and optional motion/delay overrides.
///
/// Subtypes: [ReverseBehavior] (for tween acts) and [KFReverseBehavior]
/// (for keyframed acts).
class ReverseBehaviorBase<T> {
  /// The reverse behavior type.
  final ReverseBehaviorType type;

  /// The target value for reverse (only for [ReverseBehavior.to]).
  ///
  /// Null when `type` is not [ReverseBehaviorType.to] or when using
  /// keyframes instead.
  final T? to;

  /// The keyframe sequence for reverse (only for [KFReverseBehavior.to]).
  ///
  /// Null when `type` is not [ReverseBehaviorType.to] or when using
  /// a plain value instead.
  final Keyframes<T>? frames;

  /// Custom motion for reverse (only for `.mirror()` and `.to()` in tween mode).
  ///
  /// Null means reverse uses the motion determined by motion inheritance and
  /// override rules. Only [ReverseBehavior] supports this; [KFReverseBehavior]
  /// always has null because motion is embedded in keyframes.
  final CueMotion? motion;

  /// Custom delay for reverse.
  ///
  /// Added on top of the context's [ActContext.reverseDelay]. Only `.mirror()`
  /// and `.to()` variants support this.
  final Duration delay;

  const ReverseBehaviorBase._({
    required this.type,
    this.to,
    this.frames,
    this.motion,
    this.delay = Duration.zero,
  });

  /// Whether this reverse behavior requires a separate reverse tween.
  bool get needsReverseTween => type == ReverseBehaviorType.to;

  /// Transforms all values in this reverse behavior using the given transformer.
  ///
  /// Used internally to map value types when normalizing (e.g., enum to double).
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

/// Simplified [TweenActBase] where the animated value type equals the input type.
///
/// For acts where `T == R` (no value transformation needed), [TweenAct]
/// provides a cleaner base class. The [transform] method is an identity
/// function — override it only if value normalization is needed.
///
/// ## Constructors
///
/// - `.tween()` — tween-based act with `from` and `to` values
/// - `.keyframed()` — keyframed act with `Keyframes<T>`
///
/// Example:
/// ```dart
/// class ScaleAct extends TweenAct<double> {
///   const ScaleAct.tween({
///     required super.from,
///     required super.to,
///     super.motion,
///     super.delay,
///     super.reverse,
///   }) : super.tween();
///
///   @override
///   Widget apply(BuildContext context, CueAnimation<double> animation, Widget child) {
///     return Transform.scale(
///       scale: animation.value,
///       child: child,
///     );
///   }
/// }
/// ```
abstract class TweenAct<T> extends TweenActBase<T, T> {
  /// Creates a TweenAct with optional tween or keyframed values.
  @internal
  const TweenAct({
    super.from,
    super.to,
    super.frames,
    super.motion,
    super.delay,
    super.reverse = const ReverseBehavior.mirror(),
  });

  /// Creates a TweenAct from explicit tween values (from/to).
  const TweenAct.tween({
    required super.from,
    required super.to,
    super.motion,
    super.delay,
    super.reverse,
  }) : super.tween();

  /// Creates a TweenAct from keyframes.
  const TweenAct.keyframed({
    required super.frames,
    super.delay,
    super.reverse,
    super.from,
  }) : super.keyframed();

  /// Identity transform — returns the input value unchanged.
  ///
  /// Override this method if the act needs to normalize or project its input
  /// (e.g., converting degrees to radians, enum to numeric offset).
  @override
  T transform(_, T value) => value;
}

/// Holds description of how a value[T] animates between two states.
///
/// if [from] and [to] are the same, this is a constant value (no animation).
class AnimatableValue<T> {
  /// The starting value for the animation.
  final T from;

  /// The ending value for the animation.
  final T to;

  /// Creates an animatable value with explicit [from] and [to] values.
  const AnimatableValue({
    required this.from,
    required this.to,
  });

  /// Creates a fixed value that doesn't animate (from and to are the same).
  const AnimatableValue.fixed(T value) : from = value, to = value;

  /// Alias for the main constructor (from/to as positional args).
  const AnimatableValue.tween(this.from, this.to);

  /// Whether this value is constant (from equals to).
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

@internal
class CueTweenBuildHelper<T extends Object?> extends TweenAct<T> {
  CueTweenBuildHelper({super.reverse, super.from, super.to, super.frames, required this.tweenBuilder});

  final Animatable<T> Function(T from, T to) tweenBuilder;

  @override
  Animatable<T> createSingleTween(T from, T to) {
    return tweenBuilder(from, to);
  }

  @override
  Widget apply(BuildContext context, covariant CueAnimation<T> animation, Widget child) {
    throw UnimplementedError(
      'TempTweenBuilder is a utility class for building tweens and should not be used directly in the widget tree.',
    );
  }

  @override
  ActKey get key => throw UnimplementedError();
}
