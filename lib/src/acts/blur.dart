part of 'base/act.dart';

/// Animates blur intensity on a widget.
///
/// Applies Gaussian blur via [ImageFiltered] using [ImageFilter.blur].
/// Supports tween and keyframed modes. See [BlurAct.new], [BlurAct.keyframed],
/// 
/// Use preset constructors for common blur effects and better readability, e.g.
/// [BlurAct.focus], and [BlurAct.unfocus].
class BlurAct extends TweenAct<double> {

  @override
  final ActKey key = const ActKey('Blur');

  /// {@template act.blur}
  /// Animates blur from [from] to [to] sigma values.
  ///
  /// Both [from] and [to] default to `0.0` (no blur). Blur sigma values should
  /// be non-negative; typical ranges are 0–20.
  ///
  /// ## Usage
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .blur(from: 0, to: 10),
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## Reverse behavior
  ///
  /// ```dart
  /// .blur(
  ///   from: 0,
  ///   to: 15,
  ///   reverse: .exclusive(),
  /// )
  /// ```
  /// {@endtemplate}
  const BlurAct({
    super.from = 0.0,
    super.to = 0.0,
    super.motion,
    super.reverse,
    super.delay,
  }) : super.tween();

  /// {@template act.blur.keyframed}
  /// Animates blur through a sequence of keyframes.
  ///
  /// Use when blur needs to transition through multiple intensity levels,
  /// or when each step requires its own motion curve.
  ///
  /// ## Fractional keyframes with global duration
  ///
  /// ```dart
  /// BlurAct.keyframed(
  ///   frames: Keyframes.fractional([
  ///     .key(0, at: 0.0),
  ///     .key(8, at: 0.5),
  ///     .key(0, at: 1.0),
  ///   ], duration: 400.ms, curve: Curves.easeIn), // default curve for all frames without specific curve
  /// )
  /// ```
  ///
  /// ## Motion per keyframe
  ///
  /// ```dart
  /// BlurAct.keyframed(
  ///   frames: Keyframes([
  ///     .key(0),
  ///     .key(8, motion: .easeOut(150.ms)),
  ///     .key(0, motion: .easeIn(150.ms)),
  ///   ], motion: .smooth()), // default motion for all frames without specific motion
  /// )
  /// ```
  /// {@endtemplate}
  const BlurAct.keyframed({
    required super.frames,
    super.reverse,
    super.delay,
  }) : super.keyframed(from: 0.0);

  /// {@template act.blur.focus}
  /// Animates from blurred to sharp (blur → 0).
  ///
  /// Shorthand for `.blur(from: blur, to: 0)`. Useful for "focus" effects
  /// where a blurred widget becomes sharp.
  ///
  /// ```dart
  /// .focus(from: 10)
  /// ```
  /// {@endtemplate}
  const BlurAct.focus({
    super.from = 10.0,
    super.motion,
    super.reverse,
    super.delay,
  }) : super.tween(to: 0.0);

  /// {@template act.blur.unfocus}
  /// Animates from sharp to blurred (0 → blur).
  ///
  /// Shorthand for `.blur(from: 0, to: blur)`. Useful for "unfocus" effects
  /// where a sharp widget becomes blurred.
  ///
  /// ```dart
  /// .unfocus(to: 10)
  /// ```
  /// {@endtemplate}
  const BlurAct.unfocus({
    super.to = 10.0,
    super.motion,
    super.reverse,
    super.delay,
  }) : super.tween(from: 0.0);

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final blurValue = animation.value;
        return ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: blurValue,
            sigmaY: blurValue,
          ),
          child: child,
        );
      },
    );
  }
}

/// Animates backdrop blur on a widget.
///
/// Applies Gaussian blur to the background behind a widget via [BackdropFilter]
/// and [ImageFilter.blur]. Supports tween and keyframed modes. See
/// [BackdropBlurAct.new] and [BackdropBlurAct.keyframed].
class BackdropBlurAct extends TweenAct<double> {

  @override
  final ActKey key = const ActKey('BackdropBlur');

  /// {@template act.backdrop_blur}
  /// Animates backdrop blur from [from] to [to] sigma values.
  ///
  /// Both [from] and [to] default to `0.0` (no blur). Blur sigma values
  /// should be non-negative; typical ranges are 0–20.
  ///
  /// The optional [blendMode] controls how the blurred background composites
  /// with the widget (default: [BlendMode.srcOver]).
  ///
  /// ## Usage
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .backdropBlur(from: 0, to: 8, blendMode: BlendMode.multiply),
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  /// {@endtemplate}
  const BackdropBlurAct({
    super.from = 0.0,
    super.to = 0.0,
    super.motion,
    super.reverse,
    super.delay,
    this.blendMode = BlendMode.srcOver,
  }) : super.tween();

  /// The blend mode for compositing the blurred background.
  final BlendMode blendMode;

  /// {@template act.backdrop_blur.keyframed}
  /// Animates backdrop blur through a sequence of keyframes.
  ///
  /// Use when backdrop blur needs to transition through multiple intensity
  /// levels, or when each step requires its own motion curve.
  ///
  /// ```dart
  /// BackdropBlurAct.keyframed(
  ///   frames: Keyframes(
  ///     motion: Spring.smooth(),
  ///     frames: [
  ///       KeyFrame(2),
  ///       KeyFrame(10, motion: Spring.bouncy()),
  ///       KeyFrame(0),
  ///     ],
  ///   ),
  ///   blendMode: BlendMode.multiply,
  /// )
  /// ```
  /// {@endtemplate}
  const BackdropBlurAct.keyframed({
    required super.frames,
    super.reverse,
    super.delay,
    this.blendMode = BlendMode.srcOver,
  }) : super.keyframed();

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final blurValue = animation.value;
        return BackdropFilter(
          blendMode: blendMode,
          filter: ImageFilter.blur(
            sigmaX: blurValue,
            sigmaY: blurValue,
          ),
          child: child,
        );
      },
    );
  }
}
