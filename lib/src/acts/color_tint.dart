part of 'base/act.dart';

/// Animates a color tint overlay on a widget.
///
/// Applies a color filter via [ColorFiltered] using [ColorTween] and
/// [ColorFilter.mode]. Supports both tween and keyframed modes. See
/// [ColorTintAct.new] and [ColorTintAct.keyframed].
class ColorTintAct extends TweenAct<Color?> {

  @override
  final ActKey key = const ActKey('ColorTint');
  
  /// {@template act.color_tint}
  /// Animates color tint from [from] to [to] using [ColorTween].
  ///
  /// Renders a [ColorFiltered] overlay with the specified [blendMode]
  /// (default: [BlendMode.srcIn]). Both [from] and [to] are required.
  ///
  /// ## Usage
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .colorTint(from: Colors.transparent, to: Colors.blue.withOpacity(0.5)),
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## Blend modes
  ///
  /// Adjust the tint effect by changing [blendMode]:
  ///
  /// ```dart
  /// ColorTintAct(
  ///   from: Colors.transparent,
  ///   to: Colors.red.withOpacity(0.3),
  ///   blendMode: .multiply,
  /// )
  /// ```
  ///
  /// ## Reverse behavior
  ///
  /// ```dart
  /// .colorTint(
  ///   from: Colors.transparent,
  ///   to: Colors.blue,
  ///   reverse: .to(Colors.green),
  /// )
  /// ```
  /// {@endtemplate}
  const ColorTintAct({
    required super.from,
    required super.to,
    super.motion,
    super.reverse,
    this.blendMode = BlendMode.srcIn,
    super.delay,
  }) : super.tween();

  /// The blend mode for compositing the tint color.
  ///
  /// Default is [BlendMode.srcIn], which renders the tint color directly.
  /// Other common modes: [BlendMode.multiply], [BlendMode.screen],
  /// [BlendMode.colorDodge].
  final BlendMode blendMode;

  /// {@template act.color_tint.keyframed}
  /// Animates color tint through a sequence of keyframes.
  ///
  /// Use when the tint needs to transition through multiple colors, or when
  /// each step requires its own motion curve.
  ///
  /// ## Fractional keyframes with global duration
  ///
  /// ```dart
  /// ColorTintAct.keyframed(
  ///   frames: Keyframes.fractional([
  ///     .key(Colors.transparent, at: 0.0),
  ///     .key(Colors.blue.withOpacity(0.5), at: 0.5),
  ///     .key(Colors.transparent, at: 1.0),
  ///   ], duration: 500.ms, curve: Curves.easeInOut),
  ///   blendMode: BlendMode.multiply,
  /// )
  /// ```
  ///
  /// ## Motion per keyframe
  ///
  /// ```dart
  /// ColorTintAct.keyframed(
  ///   frames: Keyframes([
  ///     .key(Colors.transparent),
  ///     .key(Colors.blue),
  ///     .key(Colors.transparent, motion: .easeOut(200.ms)),
  ///   ], motion: .smooth()), // default motion for all frames without specific motion
  ///   blendMode: BlendMode.multiply,
  /// )
  /// ```
  /// {@endtemplate}
  const ColorTintAct.keyframed({
    required super.frames,
    super.reverse,
    super.delay,
    this.blendMode = BlendMode.srcIn,
  }) : super.keyframed();

  @override
  Animatable<Color?> createSingleTween(Color? from, Color? to) {
    return ColorTween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<Color?> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return ColorFiltered(
          colorFilter: ColorFilter.mode(
            animation.value ?? Colors.transparent,
            blendMode,
          ),
          child: child,
        );
      },
    );
  }
}
