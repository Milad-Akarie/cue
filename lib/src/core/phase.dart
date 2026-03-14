import 'package:cue/src/motion/cue_motion.dart';
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
    List<FractionalKeyframe<T>> frames,
    Duration duration,
    R Function(T value) transform,
  ) {
    if (frames.isEmpty) {
      return [];
    }

    // Remove duplicates (keep last) and track curves
    final Map<double, T> uniqueFrames = {};
    final Map<double, Curve?> frameCurves = {};
    for (final frame in frames) {
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

    // Calculate phases with weights based on time differences
    final List<Phase<R>> phases = [];
    for (int i = 0; i < sortedTimes.length - 1; i++) {
      final currentTime = sortedTimes[i];
      final nextTime = sortedTimes[i + 1];
      final weight = nextTime - currentTime;
      final curve = frameCurves[currentTime] ?? Curves.linear;

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

  static List<Phase<R>> resolveAbsoluteFrames<T extends Object?, R extends Object?>(
    List<Keyframe<T>> frames,
    R Function(T value) transform,
  ) {
    if (frames.isEmpty) {
      return [];
    }

    // Handle single keyframe case - return constant phase
    if (frames.length < 2) {
      final frame = frames.first;
      final value = transform(frame.value);
      return [
        Phase(
          begin: value,
          end: value,
          motion: frame.motion,
        ),
      ];
    }

    // Create phases for each transition using standalone motions
    final List<Phase<R>> phases = [];
    for (int i = 0; i < frames.length - 1; i++) {
      final currentFrame = frames[i];
      final nextFrame = frames[i + 1];

      phases.add(
        Phase(
          begin: transform(currentFrame.value),
          end: transform(nextFrame.value),
          motion: currentFrame.motion,
        ),
      );
    }

    return phases;
  }
}
