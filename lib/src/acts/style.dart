part of 'base/act.dart';

/// {@template text_style_act}
/// Animates text style properties like color, size, weight, and more.
///
/// [TextStyleAct] smoothly transitions between two [TextStyle] configurations.
/// All animatable text properties are interpolated, including color, font size,
/// letter spacing, line height, and font weight.
///
/// Use [Act.textStyle()] factory to create instances.
///
/// ## Basic Style Animation
///
/// ```dart
/// // Animate from small to large text
/// Actor(
///   acts: [
///     .textStyle(
///       from: TextStyle(fontSize: 12, color: Colors.blue),
///       to: TextStyle(fontSize: 24, color: Colors.red),
///     ),
///   ],
///   motion: .smooth(damping: 23),
///   child: MyWidget(),
/// )
/// ```
///
/// ## Color Transition
///
/// ```dart
/// // Animate text color on interaction
/// Actor(
///   acts: [
///     .textStyle(
///       from: TextStyle(color: Colors.grey),
///       to: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
///     ),
///   ],
///   motion: .smooth(damping: 23),
///   child: MyWidget(),
/// )
/// ```
///
/// ## Size and Weight Change
///
/// ```dart
/// // Enlarge and bold text
/// Actor(
///   acts: [
///     .textStyle(
///       from: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
///       to: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
///     ),
///   ],
///   motion: .smooth(damping: 23),
///   child: MyWidget(),
/// )
/// ```
/// {@endtemplate}
class TextStyleAct extends TweenAct<TextStyle> {
  /// {@template act.text_style}
  /// Animates between two text styles.
  ///
  /// [from] is the starting [TextStyle] and [to] is the target style.
  /// All animatable properties (color, fontSize, fontWeight, letterSpacing, etc.)
  /// are smoothly interpolated.
  ///
  /// ## Basic Usage
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .textStyle(
  ///       from: TextStyle(fontSize: 12, color: Colors.red),
  ///       to: TextStyle(fontSize: 18, color: Colors.blue),
  ///     ),
  ///   ],
  ///   motion: .smooth(damping: 23),
  ///   child: Text('Animated Text'),
  /// )
  /// ```
  ///
  /// ## Color and Weight
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .textStyle(
  ///       from: TextStyle(
  ///         color: Colors.grey,
  ///         fontWeight: FontWeight.normal,
  ///       ),
  ///       to: TextStyle(
  ///         color: Colors.purple,
  ///         fontWeight: FontWeight.bold,
  ///       ),
  ///     ),
  ///   ],
  ///   motion: .smooth(damping: 23),
  ///   child: Text('Styled Text'),
  /// )
  /// ```
  /// {@endtemplate}
  @override
  final ActKey key = const ActKey('TextStyle');

  const TextStyleAct({
    required super.from,
    required super.to,
    super.motion,
    super.reverse,
    super.delay,
  }) : super.tween();

  /// {@template act.style.keyframed}
  /// Animates through multiple text style keyframes.
  ///
  /// [frames] define multiple [TextStyle] targets at different times.
  ///
  /// ## Keyframed Style Animation
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     TextStyleAct.keyframed(
  ///       frames: Keyframes.fractional([
  ///         .key(TextStyle(fontSize: 12, color: Colors.red), at: 0.0),
  ///         .key(TextStyle(fontSize: 18, color: Colors.orange), at: 0.5),
  ///         .key(TextStyle(fontSize: 24, color: Colors.blue), at: 1.0),
  ///       ], duration: 1000.ms),
  ///     ),
  ///   ],
  ///   child: Text('Keyframed Text'),
  /// )
  /// ```
  ///
  /// ## With Motion Override
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     TextStyleAct.keyframed(
  ///       frames: Keyframes([
  ///         .key(TextStyle(fontSize: 14, color: Colors.grey)),
  ///         .key(
  ///           TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
  ///           motion: Spring.bouncy(),
  ///         ),
  ///       ], motion: Spring.smooth()),
  ///     ),
  ///   ],
  ///   child: Text('Dynamic Text'),
  /// )
  /// ```
  /// {@endtemplate}
  const TextStyleAct.keyframed({
    required super.frames,
    super.reverse,
    super.delay,
  }) : super.keyframed();

  @override
  Animatable<TextStyle> createSingleTween(TextStyle from, TextStyle to) {
    return TextStyleTween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<TextStyle> animation, Widget child) {
    return DefaultTextStyleTransition(style: animation, child: child);
  }
}

/// {@template icon_theme_act}
/// Animates icon theme properties like color, size, and opacity.
///
/// [IconThemeAct] smoothly transitions between two [IconThemeData] configurations.
/// This affects all icons within the widget tree, including their color, size,
/// and opacity settings.
///
/// Use [Act.iconTheme()] factory to create instances.
///
/// ## Basic Icon Theme Animation
///
/// ```dart
/// // Animate icon color and size
/// Actor(
///   acts: [
///     .iconTheme(
///       from: IconThemeData(color: Colors.grey, size: 24),
///       to: IconThemeData(color: Colors.blue, size: 32),
///     ),
///   ],
///   motion: .smooth(damping: 23),
///   child: Icon(Icons.star),
/// )
/// ```
///
/// ## Color and Opacity Change
///
/// ```dart
/// // Fade and color icon
/// Actor(
///   acts: [
///     .iconTheme(
///       from: IconThemeData(color: Colors.grey, opacity: 0.5),
///       to: IconThemeData(color: Colors.amber, opacity: 1.0),
///     ),
///   ],
///   motion: .smooth(damping: 23),
///   child: Icon(Icons.favorite),
/// )
/// ```
/// {@endtemplate}
class IconThemeAct extends TweenAct<IconThemeData> {
  /// {@template act.icon_theme}
  /// Animates between two icon theme configurations.
  ///
  /// [from] is the starting [IconThemeData] and [to] is the target theme.
  /// Icon color, size, and opacity are smoothly interpolated.
  ///
  /// ## Basic Usage
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .iconTheme(
  ///       from: IconThemeData(color: Colors.red, size: 20),
  ///       to: IconThemeData(color: Colors.blue, size: 28),
  ///     ),
  ///   ],
  ///   motion: .smooth(damping: 23),
  ///   child: Icon(Icons.home),
  /// )
  /// ```
  ///
  /// ## With Opacity
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .iconTheme(
  ///       from: IconThemeData(color: Colors.grey, size: 24, opacity: 0.6),
  ///       to: IconThemeData(color: Colors.purple, size: 32, opacity: 1.0),
  ///     ),
  ///   ],
  ///   motion: .smooth(damping: 23),
  ///   child: Icon(Icons.settings),
  /// )
  /// ```
  /// {@endtemplate}
  
  @override
  final ActKey key = const ActKey('IconTheme');

  const IconThemeAct({
    required super.from,
    required super.to,
    super.motion,
    super.reverse,
    super.delay,
  }) : super.tween();

  /// {@template act.icon_theme.keyframed}
  /// Animates through multiple icon theme keyframes.
  ///
  /// [frames] define multiple [IconThemeData] targets at different times.
  ///
  /// ## Keyframed Icon Theme Animation
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     IconThemeAct.keyframed(
  ///       frames: Keyframes.fractional([
  ///         .key(IconThemeData(color: Colors.red, size: 20), at: 0.0),
  ///         .key(IconThemeData(color: Colors.orange, size: 24), at: 0.5),
  ///         .key(IconThemeData(color: Colors.blue, size: 32), at: 1.0),
  ///       ], duration: 1000.ms),
  ///     ),
  ///   ],
  ///   child: Icon(Icons.star),
  /// )
  /// ```
  ///
  /// ## With Motion Override
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     IconThemeAct.keyframed(
  ///       frames: Keyframes([
  ///         .key(IconThemeData(color: Colors.grey, size: 24, opacity: 0.5)),
  ///         .key(
  ///           IconThemeData(color: Colors.blue, size: 32, opacity: 1.0),
  ///           motion: Spring.bouncy(),
  ///         ),
  ///       ], motion: Spring.smooth()),
  ///     ),
  ///   ],
  ///   child: Icon(Icons.check_circle),
  /// )
  /// ```
  /// {@endtemplate}
  const IconThemeAct.keyframed({
    required super.frames,
    super.delay,
    super.reverse,
  }) : super.keyframed();

  @override
  Animatable<IconThemeData> createSingleTween(IconThemeData from, IconThemeData to) {
    return _IconThemeDataTween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<IconThemeData> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return IconTheme(
          data: animation.value,
          child: child!,
        );
      },
      child: child,
    );
  }
}

class _IconThemeDataTween extends Tween<IconThemeData> {
  _IconThemeDataTween({required super.begin, required super.end});

  @override
  IconThemeData lerp(double t) {
    return IconThemeData.lerp(begin, end, t);
  }
}
