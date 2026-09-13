import 'dart:ui';

import 'package:cue/cue.dart';
import 'package:flutter/widgets.dart';

/// Custom tween act and widget for animating arbitrary types with a builder.
typedef TweenActorBuilder<T> = Widget Function(BuildContext context, CueAnimation<T> animation);

/// A custom tween act that animates values of type `T` using a builder function.
typedef TweenActorValueBuilder<T> = Widget Function(BuildContext context, T value, Widget? child);

/// Animates custom tween values using a builder function.
///
/// Allows you to define arbitrary animation values and render them using a
/// custom builder. Useful for animating non-standard types, combining multiple
/// animation properties, or integrating with external animation libraries.
///
/// The animation value `T` can be any type that has a tween defined (via
/// [tweenBuilder]) or implements [Lerpable] for custom interpolation. If neither
/// is provided and `T` is a [Lerpable], the default interpolation uses
/// `lerpTo()`.
class CustomTweenAct<T extends Object?> extends TweenAct<T> {
  @override
  final ActKey key = const ActKey('TweenActor');

  /// The widget builder function that receives the animated value.
  final Widget Function(BuildContext context, CueAnimation<T> animation) builder;

  /// Optional custom tween builder for types without [Lerpable] support.
  final Animatable<T>? tweenBuilder;

  /// {@template act.custom_tween}
  /// Animates custom tween values with a builder.
  ///
  /// [builder] receives the current animated value and must return a widget.
  /// [from] and [to] define the start and end animation values.
  ///
  /// The animation uses [tweenBuilder] to create the tween if provided.
  /// Otherwise, if `T` implements [Lerpable], the default interpolation uses
  /// `lerpTo()`. For other types, you must provide [tweenBuilder].
  ///
  /// ## Single value animation
  ///
  /// ```dart
  /// TweenActor<double>(
  ///   from: 0,
  ///   to: 100,
  ///   builder: (context, animation) => Container(
  ///     width: animation.value,
  ///     color: Colors.blue,
  ///   ),
  /// )
  /// ```
  ///
  /// ## Multi-value animation with custom type
  ///
  /// ```dart
  /// TweenActor<AnimatedValues>(
  ///   from: AnimatedValues(scale: 1.0, opacity: 0.5),
  ///   to: AnimatedValues(scale: 1.2, opacity: 1.0),
  ///   builder: (context, animation) {
  ///     final scale = animation.ma((v) => v.scale);
  ///     final opacity = animation.ma((v) => v.opacity);
  ///     return ScaleTransition(
  ///       scale: scale,
  ///       child: FadeTransition(opacity: opacity, child: MyWidget()),
  ///     );
  ///   },
  /// )
  /// ```
  ///
  /// ## Custom tween builder
  ///
  /// For types without built-in [Lerpable] support, provide a [tweenBuilder]:
  ///
  /// ```dart
  /// TweenActor<MyCustomType>(
  ///   from: MyCustomType(value: 0),
  ///   to: MyCustomType(value: 100),
  ///   tweenBuilder: MyCustomTypeTween(), // custom Animatable<MyCustomType>
  ///   builder: (context, animation) {
  ///      // build widget using animation<MyCustomType>
  ///   }
  /// )
  /// ```
  /// {@endtemplate}
  /// Creates a custom tween act with the given [builder].
  const CustomTweenAct({
    super.from,
    super.to,
    super.motion,
    super.delay,
    super.reverse,
    super.frames,
    required this.builder,
    this.tweenBuilder,
  });

  @override
  Animatable<T> createSingleTween(T from, T to) {
    if (tweenBuilder != null) {
      return tweenBuilder!;
    } else if (from is Lerpable) {
      return InlineFnTween<T>(
        begin: from,
        end: to,
        lerpFn: (t) => from.lerpTo(to as Lerpable?, t) as T,
      );
    }
    return super.createSingleTween(from, to);
  }

  @override
  Widget apply(BuildContext context, covariant CueAnimation<T> animation, Widget child) {
    return builder(context, animation);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomTweenAct<T> &&
        super == other &&
        builder == other.builder &&
        tweenBuilder == other.tweenBuilder;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, builder, tweenBuilder);
}

/// Convenience widget for custom tween animations.
///
/// Pre-composes an [Actor] with a [CustomTweenAct], eliminating boilerplate for
/// simple custom tween animations. Use this instead of wrapping [CustomTweenAct]
/// in [Actor] for better readability.
class TweenActor<T extends Object?> extends SingleActorBase<T> {
  /// The widget builder function that receives the animated value.
  final TweenActorBuilder<T>? _builder;
  final TweenActorValueBuilder<T>? _valueBuilder;
  final Widget? _child;

  /// Optional custom tween builder for types without [Lerpable] support.
  final Animatable<T>? tweenBuilder;

  /// {@template actor.tween}
  /// Creates a custom tween animation widget.
  ///
  /// [builder] receives the current animated value and must return a widget.
  /// [from] and [to] define start and end values. Both are required.
  ///
  /// The animation uses [tweenBuilder] if provided, otherwise [Lerpable.lerpTo()]
  /// for custom types or the default tween for built-ins (double, Offset, etc.).
  ///
  /// ## Simple double animation
  ///
  /// ```dart
  /// TweenActor<double>(
  ///   from: 0,
  ///   to: 100,
  ///   builder: (context, animation) => Container(
  ///     width: animation.value,
  ///     height: 50,
  ///     color: Colors.blue,
  ///   ),
  /// )
  /// ```
  ///
  /// ## Multi-property custom type
  ///
  /// ```dart
  /// TweenActor<AnimatedValues>(
  ///   from: AnimatedValues(
  ///     scale: 1.0,
  ///     opacity: 0.5,
  ///     offset: Offset.zero,
  ///   ),
  ///   to: AnimatedValues(
  ///     scale: 1.3,
  ///     opacity: 1.0,
  ///     offset: Offset(50, 0),
  ///   ),
  ///   builder: (context, animation) {
  ///     final scale = animation.ma((v) => v.scale);
  ///     final opacity = animation.ma((v) => v.opacity);
  ///     final offset = animation.ma((v) => v.offset);
  ///     return SlideTransition(
  ///       position: offset.drive(Tween(begin: Offset.zero, end: Offset(1, 0))),
  ///       child: ScaleTransition(
  ///         scale: scale,
  ///         child: FadeTransition(opacity: opacity, child: MyWidget()),
  ///       ),
  ///     );
  ///   },
  /// )
  /// ```
  ///
  /// Extract individual animated values using `.ma()` mapper:
  ///
  /// ```dart
  /// TweenActor<AnimatedValues>(
  ///   from: AnimatedValues(scale: 1.0, opacity: 0.5),
  ///   to: AnimatedValues(scale: 1.3, opacity: 1.0),
  ///   builder: (context, animation) {
  ///     final scaleAnimation = animation.ma((v) => v.scale);
  ///     final opacityAnimation = animation.ma((v) => v.opacity);
  ///     return ScaleTransition(
  ///       scale: scaleAnimation,
  ///       child: FadeTransition(
  ///         opacity: opacityAnimation,
  ///         child: MyWidget(),
  ///       ),
  ///     );
  ///   },
  /// )
  /// ```
  /// {@endtemplate}
  const TweenActor({
    super.key,
    required super.from,
    required super.to,
    super.motion,
    super.delay,
    super.reverse,
    required TweenActorBuilder<T> builder,
    this.tweenBuilder,
  }) : _builder = builder,
       _valueBuilder = null,
       _child = null,
       super(child: const SizedBox.shrink());

  /// Creates a custom tween animation widget with a value builder.
  ///
  /// Similar to [TweenActor], but the builder receives the current animated value
  /// directly instead of the full animation. This is useful for simple cases where
  /// you only need the value and don't require animation status or progress.
  ///
  /// [builder] receives the current animated value and an optional child widget.
  /// [from] and [to] define the start and end values. Both are required.
  ///
  /// The animation uses [tweenBuilder] if provided, otherwise [Lerpable.lerpTo()]
  /// for custom types or the default tween for built-ins (double, Offset, etc.).
  ///
  /// ## Example usage
  //// ```dart
  /// TweenActor&lt;double&gt;.value(
  ///   from: 0,
  ///   to: 100,
  ///   builder: (context, value, child) => Container(
  ///     width: value,
  ///     height: 50,
  ///     color: Colors.blue,
  ///  ),
  /// )
  /// ```
  const TweenActor.value({
    super.key,
    required super.from,
    required super.to,
    super.motion,
    super.delay,
    super.reverse,
    required TweenActorValueBuilder<T> builder,
    Widget? child,
    this.tweenBuilder,
  }) : _builder = null,
       _valueBuilder = builder,
       _child = child,
       super(child: child ?? const SizedBox.shrink());

  /// {@template actor.tween.keyframed}
  /// Creates a multi-frame custom tween animation.
  ///
  /// [frames] defines the animation keyframes (type `Keyframes<T>`).
  /// [builder] receives the current animated value and renders a widget.
  ///
  /// ## Fractional keyframes with global duration
  ///
  /// ```dart
  /// TweenActor<double>.keyframed(
  ///   frames: Keyframes.fractional([
  ///     .key(0, at: 0.0),
  ///     .key(50, at: 0.5),
  ///     .key(100, at: 1.0),
  ///   ], duration: 600.ms, curve: Curves.easeInOut),
  ///   builder: (context, animation) => Container(
  ///     width: animation.value,
  ///     color: Colors.blue,
  ///   ),
  /// )
  /// ```
  ///
  /// ## Motion per keyframe
  ///
  /// ```dart
  /// TweenActor<double>.keyframed(
  ///   frames: Keyframes([
  ///     .key(0),
  ///     .key(50, motion: .easeOut(200.ms)),
  ///     .key(100, motion: .smooth()),
  ///   ]),
  ///   builder: (context, animation) => Container(
  ///     width: animation.value,
  ///     color: Colors.blue,
  ///   ),
  /// )
  /// ```
  /// {@endtemplate}
  const TweenActor.keyframed({
    super.key,
    required super.frames,
    super.reverse,
    super.delay,
    this.tweenBuilder,
    required TweenActorBuilder<T> builder,
  }) : _builder = builder,
       _valueBuilder = null,
       _child = null,
       super.keyframes(child: const SizedBox.shrink());

  @override
  Act get act => CustomTweenAct<T>(
    from: from,
    to: to,
    frames: frames,
    motion: motion,
    delay: delay,
    reverse: reverse,
    builder: (context, animation) {
      if (_builder != null) {
        return _builder(context, animation);
      }
      assert(_valueBuilder != null, 'Either builder or valueBuilder must be provided');
      return AnimatedBuilder(
        animation: animation,
        builder: (context, child) => _valueBuilder!(context, animation.value, child),
        child: _child,
      );
    },
    tweenBuilder: tweenBuilder,
  );
}

/// Default data class implementing [Lerpable] for common animated values.
///
/// Demonstrates how to create a custom type that can interpolate multiple
/// properties simultaneously. All numeric/object fields support standard lerping;
/// nullable fields may be null at either end (or both).
///
/// Use this as a template for your own multi-property animation types.
class AnimatedValues extends Lerpable<AnimatedValues> {
  /// The scale factor.
  final double scale;

  /// The opacity value (0-1).
  final double opacity;

  /// The offset position.
  final Offset offset;

  /// The rotation angle in radians.
  final double rotation;

  /// The optional color value.
  final Color? color;

  /// The optional size value.
  final Size? size;

  /// The blur amount.
  final double blur;

  /// Default constructor
  const AnimatedValues({
    this.scale = 1.0,
    this.opacity = 1.0,
    this.offset = Offset.zero,
    this.rotation = 0.0,
    this.blur = 0.0,
    this.color,
    this.size,
  });

  @override
  AnimatedValues lerpTo(covariant AnimatedValues? end, double t) {
    if (end is! AnimatedValues) return this;
    return AnimatedValues(
      scale: lerpDouble(scale, end.scale, t)!,
      opacity: lerpDouble(opacity, end.opacity, t)!,
      offset: Offset.lerp(offset, end.offset, t)!,
      rotation: lerpDouble(rotation, end.rotation, t)!,
      blur: lerpDouble(blur, end.blur, t)!,
      color: Color.lerp(color, end.color, t),
      size: Size.lerp(size, end.size, t),
    );
  }
}

/// Base interface for custom interpolatable types.
///
/// Implement this on your custom data types to enable animations via
/// [CustomTweenAct] and [TweenActor]. The [lerpTo] method must interpolate
/// between this instance and another, with `t` ranging from 0 (this) to 1 (end).
///
/// ## Implementing Lerpable
///
/// ```dart
/// class MyAnimatedValue extends Lerpable<MyAnimatedValue> {
///   final double opacity;
///   final Offset position;
///
///   const MyAnimatedValue({
///     required this.opacity,
///     required this.position,
///   });
///
///   @override
///   MyAnimatedValue lerpTo(covariant MyAnimatedValue? end, double t) {
///     if (end is! MyAnimatedValue) return this;
///     return MyAnimatedValue(
///       opacity: lerpDouble(opacity, end.opacity, t) ?? 0,
///       position: Offset.lerp(position, end.position, t) ?? Offset.zero,
///     );
///   }
/// }
/// ```
///
/// Then use it with [TweenActor]:
///
/// ```dart
/// TweenActor<MyAnimatedValue>(
///   from: MyAnimatedValue(opacity: 0, position: Offset(0, 0)),
///   to: MyAnimatedValue(opacity: 1, position: Offset(100, 100)),
///   builder: (context, animation) => Opacity(
///     opacity: animation.value.opacity,
///     child: Transform.translate(
///       offset: animation.value.position,
///       child: MyWidget(),
///     ),
///   ),
/// )
/// ```
abstract class Lerpable<T extends Lerpable<T>> {
  /// Default const constructor
  const Lerpable();

  /// Interpolates from this to [end] with progress `t` (0 to 1).
  ///
  /// [t] = 0 should return this instance; [t] = 1 should return [end].
  /// Values between 0 and 1 should return proportional interpolations.
  T lerpTo(covariant T? end, double t);
}

/// Internal tween implementation for inline lerp functions.
///
/// Used internally by [CustomTweenAct.createSingleTween] when a [Lerpable]
/// type is detected and no explicit [tweenBuilder] is provided.
///
@visibleForTesting
class InlineFnTween<T extends Object?> extends Tween<T> {
  /// The custom lerp function that defines how to interpolate between `begin` and `end`.
  final T Function(double t) lerpFn;

  /// Default constructor
  InlineFnTween({required this.lerpFn, super.begin, super.end});

  @override
  T lerp(double t) => lerpFn(t);
}
