part of 'base/act.dart';

/// Animates widget opacity (transparency).
///
/// Smoothly cross-fades opacity from one value to another. Useful for fading
/// widgets in/out, or transitioning opacity over time. Wraps [FadeTransition]
/// for smooth rendering.
class OpacityAct extends TweenAct<double> {
  
  @override
  final ActKey key = const ActKey('Opacity');

  /// {@template act.opacity}
  /// Animates custom opacity values.
  ///
  /// [from] defaults to 1.0 (fully opaque). [to] is required.
  /// Values range from 0 (fully transparent) to 1 (fully opaque).
  ///
  /// ## Custom opacity range
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .opacity(from: 0.5), // 'to' defaults to 1.0
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## Reverse example
  ///
  /// ```dart
  /// actor.onToggle(
  ///   toggled: isVisible,
  ///   child: Actor(
  ///     acts: [
  ///       .opacity(to: 1.0, reverse: ReverseBehavior.mirror()),
  ///     ],
  ///     child: MyWidget(),
  ///   ),
  /// )
  /// // When toggled, fades in/out with symmetric motion
  /// ```
  /// {@endtemplate}
  const OpacityAct({
    super.from = 1.0,
    required super.to,
    super.motion,
    super.reverse,
    super.delay,
  }) : super.tween();

  /// {@template act.opacity.fade_in}
  /// Animates fade-in (opacity 0 → 1).
  ///
  /// Shorthand for `.opacity(from: 0, to: 1)`.
  ///
  /// ```dart
  /// .fadeIn()
  /// ```
  /// {@endtemplate}
  const OpacityAct.fadeIn({
    super.from = 0.0,
    super.motion,
    super.reverse,
    super.delay,
  }) : super.tween(to: 1.0);

  /// {@template act.opacity.fade_out}
  /// Animates fade-out (opacity 1 → 0).
  ///
  /// Shorthand for `.opacity(from: 1, to: 0)`.
  ///
  /// ```dart
  /// .fadeOut()
  /// ```
  /// {@endtemplate}
  const OpacityAct.fadeOut({
    super.from = 1.0,
    super.motion,
    super.reverse,
    super.delay,
  }) : super.tween(to: 0.0);

  /// {@template act.opacity.keyframed}
  /// Animates opacity through multiple keyframe values.
  ///
  /// [frames] defines the animation keyframes (type `Keyframes<double>`).
  ///
  /// ## Fractional keyframes with global duration
  ///
  /// ```dart
  /// OpacityAct.keyframed(
  ///   frames: Keyframes.fractional([
  ///     .key(0.0, at: 0.0),
  ///     .key(1.0, at: 0.3),
  ///     .key(0.5, at: 0.7),
  ///     .key(1.0, at: 1.0),
  ///   ], duration: 800.ms, curve: Curves.easeInOut),
  /// )
  /// ```
  ///
  /// ## Motion per keyframe
  ///
  /// ```dart
  /// OpacityAct.keyframed(
  ///   frames: Keyframes([
  ///     .key(0.0),
  ///     .key(1.0,),
  ///     .key(0.5, motion: .easeInOut(150.ms)),
  ///     .key(1.0),
  ///   ], motion: .smooth()), // default motion for all frames without specific motion
  /// )
  /// ```
  /// {@endtemplate}
  const OpacityAct.keyframed({
    required super.frames,
    super.delay,
    super.reverse,
  }) : super.keyframed(from: 1.0);

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }
}
