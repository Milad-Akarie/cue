import 'core.dart';

class Keyframe<T extends Object?> {
  final T value;
  final double at;

  const Keyframe(this.value, {required this.at});
  const Keyframe.key(this.value, {required this.at});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Keyframe && runtimeType == other.runtimeType && value == other.value && at == other.at;

  @override
  int get hashCode => Object.hash(value, at);
}

class Phase<T extends Object?> {
  final double weight;
  final T begin;
  final T end;

  const Phase({
    required this.begin,
    required this.end,
    required this.weight,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Phase &&
          runtimeType == other.runtimeType &&
          weight == other.weight &&
          begin == other.begin &&
          end == other.end;

  @override
  int get hashCode => Object.hash(weight, begin, end);

  bool get isAlwaysStopped => begin == end;

  static ({List<Phase<T>> phases, Timing? timing}) normalize<T extends Object?>(List<Keyframe<T>> frames) {
    if (frames.isEmpty) {
      return (phases: [], timing: null);
    }

    // Remove duplicates (keep last) and clamp time points to [0, 1]
    final Map<double, T> uniqueFrames = {};
    for (final frame in frames) {
      final clampedTime = frame.at.clamp(0.0, 1.0);
      uniqueFrames[clampedTime] = frame.value;
    }

    // Sort by time
    final sortedTimes = uniqueFrames.keys.toList()..sort();

    // Handle single keyframe case - return constant phase (100% weight)
    if (sortedTimes.length < 2) {
      final time = sortedTimes.first;
      final value = uniqueFrames[time] as T;
      final timing = (time != 0.0 && time != 1.0) ? Timing(start: time, end: time) : null;
      return (phases: [Phase(begin: value, end: value, weight: 100.0)], timing: timing);
    }

    // Calculate phases with weights based on time differences (converted to percentage 0-100)
    final List<Phase<T>> phases = [];
    for (int i = 0; i < sortedTimes.length - 1; i++) {
      final currentTime = sortedTimes[i];
      final nextTime = sortedTimes[i + 1];
      final weight = (nextTime - currentTime) * 100.0;

      phases.add(
        Phase(
          begin: uniqueFrames[currentTime] as T,
          end: uniqueFrames[nextTime] as T,
          weight: weight,
        ),
      );
    }

    // Create timing if frames don't span [0, 1]
    final startTime = sortedTimes.first;
    final endTime = sortedTimes.last;
    final timing = (startTime != 0.0 || endTime != 1.0) ? Timing(start: startTime, end: endTime) : null;

    return (phases: phases, timing: timing);
  }
}
