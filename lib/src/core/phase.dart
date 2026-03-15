import 'package:cue/src/motion/cue_motion.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class KeyframeBase<T extends Object?> {
  final T value;
  const KeyframeBase._(this.value);
}

class FractionalKeyframe<T> extends KeyframeBase<T> {
  final double at;
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
}

class Keyframe<T> extends KeyframeBase<T> {
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
}

sealed class Keyframes<T> {
  const factory Keyframes(List<Keyframe<T>> frames) = MotionKeyframes<T>;

  const factory Keyframes.fractional(
    List<FractionalKeyframe<T>> frames, {
    Duration? duration,
  }) = FractionalKeyframes<T>;

  T get lastTarget;

  Keyframes<E> mapValues<E>(E Function(T value) transform);

  List<T> get values;
}

final class MotionKeyframes<T> implements Keyframes<T> {
  final List<Keyframe<T>> frames;
  const MotionKeyframes(this.frames);

  @override
  List<T> get values => List.unmodifiable(frames.map((f) => f.value));

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
}

final class FractionalKeyframes<T> implements Keyframes<T> {
  final List<FractionalKeyframe<T>> frames;
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
  T get lastTarget {
    assert(frames.isNotEmpty, 'Keyframes must have at least one frame to determine last target');
    return frames.last.value;
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
}

class Phase<T extends Object?> {
  final CueMotion motion;
  final T begin;
  final T end;

  const Phase({
    required this.begin,
    required this.end,
    required this.motion,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Phase &&
          runtimeType == other.runtimeType &&
          motion == other.motion &&
          begin == other.begin &&
          end == other.end;

  @override
  int get hashCode => Object.hash(motion, begin, end);

  bool get isAlwaysStopped => begin == end;

  static List<Phase<R>> resolveFractionalFrames<T extends Object?, R extends Object?>(
    List<FractionalKeyframe<T>> frames, {
    required Duration duration,
    required R Function(T value) transform,
  }) {
    if (frames.isEmpty) {
      return [];
    }

    // Remove duplicates (keep last) and track curves
    final Map<double, T> uniqueFrames = {};
    final Map<double, Curve?> frameCurves = {};

    // First frame is the starting point at t=0
    if (frames.isNotEmpty) {
      uniqueFrames[0.0] = frames[0].value;
      frameCurves[0.0] = null;
    }

    for (int i = 1; i < frames.length; i++) {
      final frame = frames[i];
      final clampedTime = frame.at.clamp(0.0, 1.0);
      uniqueFrames[clampedTime] = frame.value;
      frameCurves[clampedTime] = frame.curve;
    }

    // Sort by time
    final sortedTimes = uniqueFrames.keys.toList()..sort();

    // Handle single keyframe case - return constant phase (100% weight)
    if (sortedTimes.length < 2) {
      final time = sortedTimes.first;
      final value = transform(uniqueFrames[time] as T);
      final phaseDuration = duration * time;
      final curve = frameCurves[time];

      return [
        Phase(
          begin: value,
          end: value,
          motion: CueMotion.curved(phaseDuration, curve: curve ?? Curves.linear),
        ),
      ];
    }

    // Calculate phases with weights based on time differences.
    // Each frame's curve describes how to arrive at that frame (target curve).
    // The first frame is the starting point; its curve is ignored.
    final List<Phase<R>> phases = [];
    for (int i = 0; i < sortedTimes.length - 1; i++) {
      final currentTime = sortedTimes[i];
      final nextTime = sortedTimes[i + 1];
      final weight = nextTime - currentTime;
      final curve = frameCurves[nextTime] ?? Curves.linear;

      phases.add(
        Phase(
          begin: transform(uniqueFrames[currentTime] as T),
          end: transform(uniqueFrames[nextTime] as T),
          motion: CueMotion.curved(duration * weight, curve: curve),
        ),
      );
    }

    return phases;
  }

  static List<Phase<R>> resolveMotionFrames<T extends Object?, R extends Object?>(
    List<Keyframe<T>> frames, {
    required R Function(T value) transform,
  }) {
    if (frames.isEmpty) {
      return [];
    }

    final List<Phase<R>> phases = [];

    // Each frame's motion describes how to arrive at that frame (target motion).
    // The first frame is the starting point; its motion is ignored.
    for (int i = 0; i < frames.length - 1; i++) {
      final currentFrame = frames[i];
      final nextFrame = frames[i + 1];

      phases.add(
        Phase(
          begin: transform(currentFrame.value),
          end: transform(nextFrame.value),
          motion: nextFrame.motion,
        ),
      );
    }

    return phases;
  }
}
