import 'package:cue/cue.dart';
import 'package:cue/src/timeline/track/track.dart';
import 'package:flutter/widgets.dart';

/// A standalone [Animation<T>] for animating a single value using [CueMotion].
///
/// Provides a simple interface to animate values from A→B without requiring
/// Cue widgets or Acts. Internally manages a [CueController] and timeline track.
///
/// **Setting vs. animating**:
/// - [value] setter: Instantly jumps to the new value (stops any in-flight animation)
/// - [animateTo]: Smoothly animates to the target using the configured [CueMotion]
///
/// **Custom tweens**: Pass a [TweenBuilder] for types that need custom tween logic
/// (e.g., `ColorTween.new` for colors).
class CueValueAnimator<T> extends Animation<T> with AnimationWithParentMixin<double> {
  /// Internal controller managing the animation timeline.
  final CueController _controller;

  /// Factory for creating tweens given begin/end values.
  final TweenBuilder<T> _tweenBuilder;

  /// Creates a value animator.
  ///
  /// - [initialValue]: The starting value.
  /// - [vsync]: Ticker provider for animation frame callbacks.
  /// - [motion]: The animation motion (curve, spring, or timing).
  /// - [delay]: Optional delay before animation starts (default: zero).
  /// - [tweenBuilder]: Optional custom tween factory. Defaults to `Tween<T>.new`.
  ///   Use `ColorTween.new` for color animations, or other custom tweens as needed.
  CueValueAnimator(
    T initialValue, {
    required TickerProvider vsync,
    required CueMotion motion,
    Duration delay = Duration.zero,
    TweenBuilder<T>? tweenBuilder,
  }) : _tweenBuilder = tweenBuilder ?? Tween<T>.new,
       _animatable = ConstantAnimtable<T>(initialValue),
       _controller = CueController(
         vsync: vsync,
         motion: delay == Duration.zero ? motion : motion.delayed(delay),
       );

  late final CueTrack _track = _controller.timeline.obtainDefaultTrack().$1;

  late CueAnimtable<T> _animatable;

  @override
  Animation<double> get parent => _track;

  /// Sets the animation to a fixed value instantly.
  ///
  /// Stops any in-flight animation, sets the animatable to a constant, and
  /// resets progress to 0.
  set value(T newValue) {
    if (newValue == value) return;
    _controller.stop();
    _animatable = ConstantAnimtable<T>(newValue);
    _track.setProgress(0.0, alwaysNotify: true);
  }

  /// Animates to a target value using the configured motion.
  ///
  /// - [newTarget]: The target value to animate toward.
  /// - [velocity]: Optional initial velocity for spring motions (default: no velocity).
  ///
  /// Starts from the current value and runs the animation forward from 0.
  void animateTo(T newTarget, {double? velocity}) {
    final currentValue = _animatable.evaluate(_track);
    _animatable = TweenAnimtable<T>(_tweenBuilder(begin: currentValue, end: newTarget));
    _controller.forward(from: 0.0, velocity: velocity);
  }

  /// The current animation value.
  @override
  T get value => _animatable.evaluate(_track);

  /// Disposes the animation controller.
  ///
  /// Must be called when the animator is no longer needed to free resources.
  void dispose() {
    _controller.dispose();
  }
}
