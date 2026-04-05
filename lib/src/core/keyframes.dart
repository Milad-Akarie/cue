import 'package:cue/cue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Base class for keyframe types.
///
/// Keyframes represent target values at specific points in an animation.
/// Concrete implementations define how timing is specified:
/// - [Keyframe]: Uses explicit [CueMotion] objects
/// - [FractionalKeyframe]: Uses normalized positions (0-1) within a duration
abstract class KeyframeBase<T extends Object?> {
  /// The target value at this keyframe.
  final T value;
  const KeyframeBase._(this.value);
}

/// A keyframe positioned at a fractional point (0-1) within a duration.
///
/// The [at] value represents the normalized position within the total duration.
/// Duration can be provided inline or inherited from parent/default motion.
/// For spring-based motions, the pre-calculated settle duration is used.
///
/// Use the [FractionalKeyframe.key] shorthand constructor for more readable syntax:
/// ```dart
/// .key(100.0, at: 0.5, curve: Curves.easeOut)
/// ```
class FractionalKeyframe<T> extends KeyframeBase<T> {
  /// The normalized position (0-1) of this keyframe within the duration.
  final double at;
  
  /// Optional curve to apply during motion towards this keyframe.
  final Curve? curve;

  const FractionalKeyframe(super.value, {required this.at, this.curve})
    : assert(at >= 0.0 && at <= 1.0, 'Relative Keyframe time must be between 0 and 1'),
      super._();

  const FractionalKeyframe.key(super.value, {required this.at, this.curve})
    : assert(at >= 0.0 && at <= 1.0, 'Relative Keyframe time must be between 0 and 1'),
      super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FractionalKeyframe &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          at == other.at &&
          curve == other.curve;

  @override
  int get hashCode => Object.hash(value, at, curve);

  FractionalKeyframe<T> copyWith({T? value, double? at, Curve? curve}) {
    return FractionalKeyframe<T>(
      value ?? this.value,
      at: at ?? this.at,
      curve: curve ?? this.curve,
    );
  }

  @override
  String toString() {
    return 'FractionalKeyframe(value: $value, at: $at, curve: $curve)';
  }
}

/// A keyframe with explicit motion timing.
///
/// The [motion] defines how long the animation takes to reach this keyframe
/// from the previous one. Motion is extracted and applied sequentially.
///
/// Use the [Keyframe.key] shorthand constructor for more readable syntax:
/// ```dart
/// .key(100.0, motion: Spring.smooth())
/// ```
class Keyframe<T> extends KeyframeBase<T> {
  /// The motion describing how to animate towards this keyframe.
  final CueMotion motion;

  const Keyframe(super.value, {required this.motion}) : super._();

  const Keyframe.key(super.value, {required this.motion}) : super._();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Keyframe && runtimeType == other.runtimeType && value == other.value && motion == other.motion;

  @override
  int get hashCode => Object.hash(value, motion);

  Keyframe<T> copyWith({T? value, CueMotion? motion}) {
    return Keyframe<T>(
      value ?? this.value,
      motion: motion ?? this.motion,
    );
  }

  @override
  String toString() {
    return 'Keyframe(value: $value, motion: $motion)';
  }
}

/// Base abstraction for keyframe sequences.
///
/// Provides two variants for specifying keyframe sequences:
/// - [Keyframes()]: Uses explicit [CueMotion] objects between frames
/// - [Keyframes.fractional()]: Uses normalized positions with a total duration
///
/// Both variants can be reversed and mapped to transform values.
///
/// Build readable keyframe sequences using the `.key()` shorthand constructors:
/// ```dart
/// // Motion-based keyframes
/// Keyframes([
///   .key(100.0, motion: Spring.smooth()),
///   .key(200.0, motion: Spring.bouncy()),
/// ])
///
/// // Fractional keyframes
/// Keyframes.fractional([
///   .key(100.0, at: 0.0),
///   .key(200.0, at: 0.5),
///   .key(150.0, at: 1.0),
/// ], duration: Duration(seconds: 1))
/// ```
sealed class Keyframes<T> {
  /// Creates a keyframe sequence with explicit motion timing.
  const factory Keyframes(List<Keyframe<T>> frames) = MotionKeyframes<T>;

  /// Creates a keyframe sequence with fractional positioning.
  ///
  /// The [duration] can be provided inline or inherited from parent/default motion.
  /// For spring-based default motions, the pre-calculated settle duration is used.
  const factory Keyframes.fractional(
    List<FractionalKeyframe<T>> frames, {
    Duration? duration,
  }) = FractionalKeyframes<T>;

  T get lastTarget;

  Keyframes<E> mapValues<E>(E Function(T value) transform);

  List<T> get values;

  Keyframes<T> get reversed;
}

/// Keyframe sequence with explicit motion timing between frames.
///
/// Each frame specifies its own [CueMotion] to determine animation timing
/// from the previous frame. Motions are extracted and applied sequentially.
final class MotionKeyframes<T> implements Keyframes<T> {
  /// The ordered list of keyframes with explicit motion.
  final List<Keyframe<T>> frames;
  const MotionKeyframes(this.frames);

  @override
  List<T> get values => List.unmodifiable(frames.map((f) => f.value));

  List<CueMotion> extractMotion({bool includeFirst = false}) {
    final motions = frames.map((f) => f.motion);
    return List.unmodifiable(includeFirst ? motions : motions.skip(1));
  }

  @override
  MotionKeyframes<E> mapValues<E>(E Function(T value) transform) {
    return MotionKeyframes<E>(
      List.unmodifiable(
        frames.map(
          (frame) => Keyframe<E>(
            transform(frame.value),
            motion: frame.motion,
          ),
        ),
      ),
    );
  }

  @override
  MotionKeyframes<T> get reversed {
    return MotionKeyframes<T>(List.unmodifiable(frames.reversed));
  }

  @override
  T get lastTarget {
    assert(frames.isNotEmpty, 'Keyframes must have at least one frame to determine last target');
    return frames.last.value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MotionKeyframes && runtimeType == other.runtimeType && listEquals(frames, other.frames);

  @override
  int get hashCode => Object.hashAll(frames);

  @override
  String toString() {
    return 'MotionKeyframes(frames: $frames)';
  }
}

/// Keyframe sequence positioned at fractional points within a duration.
///
/// Frames are positioned using normalized values (0-1). The total [duration]
/// can be provided inline or inherited. Motion is calculated based on
/// fractional positions within the duration.
final class FractionalKeyframes<T> implements Keyframes<T> {
  /// The ordered list of keyframes with fractional positioning.
  final List<FractionalKeyframe<T>> frames;
  
  /// Optional total duration for the entire sequence.
  /// If null, duration is inherited from parent or default motion.
  final Duration? duration;
  const FractionalKeyframes(this.frames, {this.duration});

  @override
  List<T> get values => List.unmodifiable(frames.map((f) => f.value));

  @override
  FractionalKeyframes<E> mapValues<E>(E Function(T value) transform) {
    return FractionalKeyframes<E>(
      List.unmodifiable(
        frames.map(
          (frame) => FractionalKeyframe<E>(
            transform(frame.value),
            at: frame.at,
            curve: frame.curve,
          ),
        ),
      ),
      duration: duration,
    );
  }

  @override
  FractionalKeyframes<T> get reversed {
    return FractionalKeyframes<T>(
      List.unmodifiable(
        frames.reversed.map((frame) => frame.copyWith(at: 1.0 - frame.at)),
      ),
      duration: duration,
    );
  }

  @override
  T get lastTarget {
    assert(frames.isNotEmpty, 'Keyframes must have at least one frame to determine last target');
    return frames.last.value;
  }

  /// Extracts motion durations based on fractional keyframe positions.
  ///
  /// Calculates the motion between consecutive keyframes based on their
  /// normalized positions and the total [duration]. Curve is preserved
  /// from each keyframe.
  ///
  /// [includeFirst]: If true, includes motion to the first keyframe.
  /// [duration]: The total duration to distribute across keyframes.
  List<CueMotion> extractMotion({bool includeFirst = false, required Duration duration}) {
    // Remove duplicates (keep last) and track curves
    final Map<double, Curve?> frameCurves = {};

    for (int i = 0; i < frames.length; i++) {
      final frame = frames[i];
      final clampedTime = frame.at.clamp(0.0, 1.0);
      frameCurves[clampedTime] = frame.curve;
    }

    // Sort by time
    final sortedTimes = frameCurves.keys.toList()..sort();

    if (sortedTimes.isEmpty || (!includeFirst && sortedTimes.length < 2)) return [];

    final List<CueMotion> motions = [];

    // Add motion to first frame if requested
    if (includeFirst) {
      final firstTime = sortedTimes.first;
      final firstCurve = frameCurves[firstTime] ?? Curves.linear;
      motions.add(
        CueMotion.curved(Duration(milliseconds: (duration.inMilliseconds * firstTime).round()), curve: firstCurve),
      );
    }

    // Add motions between consecutive frames
    for (int i = 0; i < sortedTimes.length - 1; i++) {
      final currentTime = sortedTimes[i];
      final nextTime = sortedTimes[i + 1];
      final weight = nextTime - currentTime;
      final curve = frameCurves[nextTime] ?? Curves.linear;
      motions.add(CueMotion.curved(Duration(milliseconds: (duration.inMilliseconds * weight).round()), curve: curve));
    }

    return motions;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FractionalKeyframes &&
          runtimeType == other.runtimeType &&
          listEquals(frames, other.frames) &&
          duration == other.duration;

  @override
  int get hashCode => Object.hash(Object.hashAll(frames), duration);

  @override
  String toString() {
    return 'FractionalKeyframes(frames: $frames, duration: $duration)';
  }
}

/// Represents a single animation segment (tween) from [begin] to [end] value.
///
/// Phases are resolved from keyframe sequences and converted to actual
/// tween implementations later in the animation pipeline.
class Phase<T extends Object?> {
  /// The starting value for this animation segment.
  final T begin;
  
  /// The ending value for this animation segment.
  final T end;

  const Phase({
    required this.begin,
    required this.end,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Phase && runtimeType == other.runtimeType && begin == other.begin && end == other.end;

  @override
  int get hashCode => Object.hash(begin, end);

  bool get isAlwaysStopped => begin == end;

  /// Resolves fractional keyframes into animation phases.
  ///
  /// Converts [FractionalKeyframe]s into [Phase] segments with optional
  /// starting value [from]. Handles deduplication and sorting by position.
  /// [transform] converts each keyframe value to the target type.
  ///
  /// [forReverse]: If true, the starting value is appended at the end
  /// instead of prepended, for reversed animations.
  static List<Phase<R>> resolveFractionalFrames<T extends Object?, R extends Object?>(
    List<FractionalKeyframe<T>> frames, {
    T? from,
    bool forReverse = false,
    required R Function(T value) transform,
  }) {
    if (frames.isEmpty) {
      return [];
    }

    // Remove duplicates (keep last) and track curves
    final Map<double, T> uniqueFrames = {};
    final Map<double, Curve?> frameCurves = {};

    // Without an explicit starting value, the first frame is the starting point at t=0.
    if (from == null) {
      uniqueFrames[0.0] = frames[0].value;
      frameCurves[0.0] = null;
    }

    for (int i = from == null ? 1 : 0; i < frames.length; i++) {
      final frame = frames[i];
      final clampedTime = frame.at.clamp(0.0, 1.0);
      uniqueFrames[clampedTime] = frame.value;
      frameCurves[clampedTime] = frame.curve;
    }

    // Sort by time
    final sortedTimes = uniqueFrames.keys.toList()..sort();

    // Handle single keyframe case without an explicit starting value.
    if (from == null && sortedTimes.length < 2) {
      final time = sortedTimes.first;
      final value = transform(uniqueFrames[time] as T);

      return [
        Phase(begin: value, end: value),
      ];
    }

    final resolvedFrames = <FractionalKeyframe<T>>[
      for (final time in sortedTimes)
        FractionalKeyframe<T>(
          uniqueFrames[time] as T,
          at: time,
          curve: frameCurves[time],
        ),
    ];

    if (from != null) {
      final fromFrame = FractionalKeyframe<T>(
        from,
        at: forReverse ? 1.0 : 0.0,
      );
      if (forReverse) {
        resolvedFrames.add(fromFrame);
      } else {
        resolvedFrames.insert(0, fromFrame);
      }
    }

    final List<Phase<R>> phases = [];
    for (int i = 1; i < resolvedFrames.length; i++) {
      phases.add(
        Phase(
          begin: transform(resolvedFrames[i - 1].value),
          end: transform(resolvedFrames[i].value),
        ),
      );
    }

    return phases;
  }

  /// Resolves motion keyframes into animation phases.
  ///
  /// Converts [Keyframe]s into [Phase] segments with optional
  /// starting value [from]. [transform] converts each keyframe value
  /// to the target type.
  ///
  /// [forReverse]: If true, the starting value is appended at the end
  /// instead of prepended, for reversed animations.
  static List<Phase<R>> resolveMotionFrames<T extends Object?, R extends Object?>(
    List<Keyframe<T>> frames, {
    T? from,
    bool forReverse = false,
    required R Function(T value) transform,
  }) {
    if (frames.isEmpty) {
      return [];
    }
    final mFrames = List.from(frames);
    final List<Phase<R>> phases = [];
    if (from != null) {
      if (forReverse) {
        mFrames.add(Keyframe(from, motion: CueMotion.none));
      } else {
        mFrames.insert(0, Keyframe(from, motion: CueMotion.none));
      }
    }

    for (int i = 1; i < mFrames.length; i++) {
      final currentFrame = mFrames[i];
      phases.add(
        Phase(
          begin: transform(mFrames[i - 1].value),
          end: transform(currentFrame.value),
        ),
      );
    }

    return phases;
  }
}
