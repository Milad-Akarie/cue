
import 'package:flutter/widgets.dart';

/// Extensions on [int] for convenient duration literals.
///
/// Enables shorthand syntax for specifying durations in code:
/// ```dart
/// 200.ms   // 200 milliseconds
/// 2.s      // 2 seconds
/// ```
extension DurationExtension on int {
  /// Returns this value as a duration in milliseconds.
  Duration get ms => Duration(milliseconds: this);

  /// Returns this value as a duration in seconds.
  Duration get s => Duration(seconds: this);
}

/// Extensions on [double] for convenient duration literals.
///
/// Enables fractional second durations:
/// ```dart
/// 0.5.s    // 500 milliseconds
/// 1.5.s    // 1.5 seconds
/// ```
extension DoubleDurationExtension on double {
  /// Returns this value as a duration in seconds (with fractional precision).
  Duration get s => Duration(microseconds: (this * 1e6).round());
}

/// A factory function that creates [Tween<T>] instances.
///
/// Used to defer tween creation with custom implementations for specific types.
/// Example: `ColorTween.new` for color tweens, or `Tween<T>.new` as default.
typedef TweenBuilder<T> = Tween<T> Function({T? begin, T? end});
