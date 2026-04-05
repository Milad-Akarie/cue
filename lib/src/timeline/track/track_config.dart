import 'package:cue/cue.dart';

/// Configuration for a single animation track.
///
/// Defines how a track animates in both forward and reverse directions.
/// Tracks can be added to a timeline to coordinate multiple animations
/// with potentially different timings.
///
/// The [reverseType] determines how reverse animations behave:
/// - [ReverseBehaviorType.mirror]: Uses [reverseMotion] as a separate path
/// - [ReverseBehaviorType.exclusive]: Only drives reverse, ignores forward
/// - [ReverseBehaviorType.none]: Only drives forward, ignores reverse
/// 
/// Used as track identification and equality is based on the combination of [motion], [reverseMotion], and [reverseType].
class TrackConfig {
  /// The motion defining forward animation timing and easing.
  final CueMotion motion;
  
  /// The motion defining reverse animation timing and easing.
  /// Used when reversing or dismissing the animation.
  final CueMotion reverseMotion;
  
  /// Controls how reverse animations are handled (default: [ReverseBehaviorType.mirror]).
  final ReverseBehaviorType reverseType;

  /// Creates a track configuration with forward and reverse motions.
  ///
  /// [motion] - Timing for forward animations
  /// [reverseMotion] - Timing for reverse animations
  /// [reverseType] - How to handle reverse animations (default: mirror both directions)
  const TrackConfig({
    required this.motion,
    required this.reverseMotion,
    this.reverseType = ReverseBehaviorType.mirror,
  });

  /// Creates a copy with optionally updated fields.
  ///
  /// Useful for deriving new configurations with modified timing or behavior.
  TrackConfig copyWith({
    CueMotion? motion,
    CueMotion? reverseMotion,
    ReverseBehaviorType? reverseType,
  }) {
    return TrackConfig(
      motion: motion ?? this.motion,
      reverseMotion: reverseMotion ?? this.reverseMotion,
      reverseType: reverseType ?? this.reverseType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TrackConfig &&
        other.motion == motion &&
        other.reverseMotion == reverseMotion &&
        other.reverseType == reverseType;
  }

  @override
  int get hashCode => Object.hash(motion, reverseMotion, reverseType);
}
