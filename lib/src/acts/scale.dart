part of 'base/act.dart';

/// {@template scale_act}
/// Animates uniform scaling of a widget (both X and Y axes equally).
///
/// [ScaleAct] grows or shrinks the entire widget proportionally from a starting
/// scale value to an ending scale value. The transformation occurs around a fixed
/// alignment point (defaults to center).
///
/// Use [Act.scale()] factory to create instances. This is the recommended approach
/// for most scaling animations.
///
/// ## Basic Scale Animation
///
/// ```dart
/// Actor(
///   acts: [
///     .scale(from: 0.5, to: 1.0),
///   ],
///   child: MyWidget(),
/// )
/// ```
///
/// ## Zoom In / Zoom Out
///
/// Convenience named constructors for common effects:
///
/// ```dart
/// // Fade in with scale in
/// Actor(
///   acts: [
///     .zoomIn(),
///     .fadeIn(),
///   ],
///   child: MyWidget(),
/// )
///
/// // Fade out with scale out
/// Actor(
///   acts: [
///     .zoomOut(),
///     .fadeOut(),
///   ],
///   child: MyWidget(),
/// )
/// ```
///
/// ## Scale from Alignment
///
/// Change the pivot point using [alignment] (defaults to [Alignment.center]):
///
/// ```dart
/// Actor(
///   acts: [
///     .scale(
///       from: 1.0,
///       to: 1.5,
///       alignment: .topLeft,
///     ),
///   ],
///   child: MyWidget(),
/// )
/// ```
///
/// ## Pulse Effect with Keyframes
///
/// Create multiple scale keyframes for complex animations:
///
/// ```dart
/// Actor(
///   acts: [
///     ScaleAct.keyframed(
///       frames: Keyframes.fractional([
///         .key(1.0, at: 0.0),
///         .key(1.2, at: 0.25),
///         .key(1.0, at: 0.50),
///         .key(1.1, at: 0.75),
///         .key(1.0, at: 1.0),
///       ], duration: 1000.ms),
///     ),
///   ],
///   child: MyWidget(),
/// )
/// ```
///
/// ## Non-Uniform Scaling
///
/// For separate X and Y scaling, use [StretchAct] instead:
///
/// ```dart
/// Actor(
///   acts: [
///     .stretch(
///       from: Stretch(x: 1.0, y: 1.0),
///       to: Stretch(x: 1.0, y: 0.5),
///     ),
///   ],
///   child: MyWidget(),
/// )
/// ```
///
/// {@endtemplate}
class ScaleAct extends TweenAct<double> {
  @override
  final ActKey key = const ActKey('Scale');

  /// The alignment point around which scaling occurs.
  ///
  /// Defaults to [Alignment.center]. Use other alignments to scale from
  /// corners or edges:
  ///
  /// ```dart
  /// // Scale from top-left corner
  /// Act.scale(to: 1.5, alignment: Alignment.topLeft)
  ///
  /// // Scale from bottom-right corner
  /// Act.scale(to: 1.5, alignment: Alignment.bottomRight)
  /// ```
  final AlignmentGeometry? alignment;

  /// {@template act.scale}
  /// Animates uniform scaling from one scale value to another.
  ///
  /// Both horizontal and vertical axes scale uniformly by the same factor.
  /// For separate X/Y scaling, use [StretchAct] instead.
  ///
  /// ## Basic Usage
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .scale(from: 0.5, to: 1.0),
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## With Spring Motion
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .scale(
  ///       from: 1.0,
  ///       to: 1.3,
  ///       motion: .smooth(damping: 23),
  ///       alignment: .center,
  ///     ),
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// See also:
  /// - [ScaleAct.zoomIn] for fade-in effects
  /// - [ScaleAct.zoomOut] for fade-out effects
  /// - [StretchAct] for non-uniform (separate X/Y) scaling
  /// {@endtemplate}
  const ScaleAct({
    super.from = 1.0,
    super.to = 1.0,
    super.motion,
    super.reverse,
    this.alignment,
    super.delay,
  }) : super.tween();

  /// {@template act.scale.zoomIn}
  /// Scale from 0.0 to 1.0 for entrance animations.
  ///
  /// Often combined with [OpacityAct.fadeIn()] for a zoom-in entrance:
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .zoomIn(),
  ///     .fadeIn(),
  ///   ],
  ///   motion: Spring.smooth(damping: 23),
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## With Custom Alignment
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .zoomIn(alignment: Alignment.topLeft),
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  /// {@endtemplate}
  const ScaleAct.zoomIn({
    super.motion,
    super.reverse,
    this.alignment,
    super.delay,
  }) : super.tween(from: 0.0, to: 1.0);

  /// {@template act.scale.zoomOut}
  /// Scale from 1.0 to 0.0 for exit animations.
  ///
  /// Often combined with [OpacityAct.fadeOut()] for a zoom-out exit:
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .zoomOut(),
  ///     .fadeOut(),
  ///   ],
  ///   motion: Spring.smooth(damping: 23),
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## With Custom Alignment
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .zoomOut(alignment: Alignment.center),
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  /// {@endtemplate}
  const ScaleAct.zoomOut({
    super.motion,
    super.reverse,
    this.alignment,
    super.delay,
  }) : super.tween(from: 1.0, to: 0.0);

  /// {@template act.scale.keyframed}
  /// Animates through multiple scale keyframes.
  ///
  /// [frames] define multiple scale targets at different times.
  ///
  /// ## Fractional keyframes with shared duration
  ///
  /// ```dart
  /// ScaleAct.keyframed(
  ///   frames: .fractional([
  ///     .key(1.0, at: 0.0),
  ///     .key(1.2, at: 0.25),
  ///     .key(1.0, at: 0.50),
  ///     .key(1.1, at: 0.75),
  ///     .key(1.0, at: 1.0),
  ///   ], duration: 800.ms),
  /// )
  /// ```
  ///
  /// ## Per-keyframe motion with override
  ///
  /// ```dart
  /// ScaleAct.keyframed(
  ///   frames: Keyframes(
  ///     [
  ///       .key(0.8, motion: Spring.smooth()),
  ///       .key(1.2),  // Uses default motion
  ///       .key(1.0, motion: Linear(300.ms)),  // Overrides default
  ///     ],
  ///     motion: Spring.bouncy(),  // Default motion
  ///   ),
  /// )
  /// ```
  /// {@endtemplate}
  const ScaleAct.keyframed({
    required super.frames,
    super.reverse,
    super.delay,
    this.alignment,
  }) : super.keyframed(from: 1.0);

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    final directionality = Directionality.maybeOf(context);
    final effectiveAlignment = alignment?.resolve(directionality) ?? Alignment.center;
    return ScaleTransition(
      scale: animation,
      alignment: effectiveAlignment,
      child: child,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScaleAct && super == other && other.alignment == alignment;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, alignment);
}

/// {@template stretch_act}
/// Animates non-uniform scaling with separate X and Y scale factors.
///
/// Unlike [ScaleAct], which scales both axes equally, [StretchAct] allows
/// independent control over horizontal and vertical scaling.
///
/// Use separate [Stretch] values for `from` and `to` to specify different
/// X and Y factors. The scaling occurs around a fixed center alignment.
///
/// ## Basic Stretch Animation
///
/// ```dart
/// Actor(
///   acts: [
///     .stretch(
///       from: Stretch(x: 1.0, y: 1.0),
///       to: Stretch(x: 1.2, y: 0.8),
///     ),
///   ],
///   child: MyWidget(),
/// )
/// ```
///
/// ## Vertical Compression
///
/// ```dart
/// // Compress vertically while maintaining horizontal size
/// Actor(
///   acts: [
///     .stretch(
///       from: Stretch.none,
///       to: Stretch(x: 1.0, y: 0.5),
///       motion: Spring.smooth(damping: 23),
///     ),
///   ],
///   child: MyWidget(),
/// )
/// ```
///
/// ## Width Animation Only
///
/// ```dart
/// // Animate width while keeping height constant
/// Actor(
///   acts: [
///     .stretch(
///       from: Stretch(x: 1.0, y: 1.0),
///       to: Stretch(x: 1.5, y: 1.0),
///     ),
///   ],
///   child: MyWidget(),
/// )
/// ```
///
/// ## Keyframe Sequences
///
/// ```dart
/// Actor(
///   acts: [
///     StretchAct  .keyframed(
///       frames: Keyframes.fractional([
///         .key(Stretch.none, at: 0.0),
///         .key(Stretch(x: 1.2, y: 0.8), at: 0.5),
///         .key(Stretch.none, at: 1.0),
///       ], duration: 1000.ms),
///     ),
///   ],
///   child: MyWidget(),
/// )
/// ```
///
/// {@endtemplate}
class StretchAct extends TweenAct<Stretch> {
  @override
  final ActKey key = const ActKey('Stretch');

  /// The alignment point around which stretching occurs.
  ///
  /// Defaults to [Alignment.center]. Use other alignments to stretch from
  /// corners or edges:
  ///
  /// ```dart
  /// // Stretch from top-left corner
  /// Act.stretch(to: Stretch(x: 1.5, y: 1.0), alignment: Alignment.topLeft)
  /// ```
  final AlignmentGeometry alignment;

  /// {@template act.stretch}
  /// Animates non-uniform scaling with separate X and Y factors.
  ///
  /// Specify different [Stretch] values for horizontal and vertical scaling.
  /// Use [Stretch] constructor or [Stretch.none] for no scaling.
  ///
  /// ## Basic Usage
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .stretch(
  ///       from: Stretch(x: 1.0, y: 1.0),
  ///       to: Stretch(x: 1.2, y: 0.8),
  ///       motion: Spring.smooth(damping: 23),
  ///     ),
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// See also:
  /// - [StretchAct.keyframed] for multi-step stretch animations
  /// - [ScaleAct] for uniform (equal X/Y) scaling
  /// {@endtemplate}
  const StretchAct({
    super.from = Stretch.none,
    super.to = Stretch.none,
    super.motion,
    super.reverse,
    super.delay,
    this.alignment = Alignment.center,
  }) : super.tween();

  /// {@template act.stretch.keyframed}
  /// Animates through multiple non-uniform stretch keyframes.
  ///
  /// [frames] define multiple [Stretch] targets at different times.
  ///
  /// ## Fractional keyframes with shared duration
  ///
  /// ```dart
  /// StretchAct.keyframed(
  ///   frames: Keyframes.fractional([
  ///     .key(Stretch.none, at: 0.0),
  ///     .key(Stretch(x: 1.2, y: 0.8), at: 0.5),
  ///     .key(Stretch.none, at: 1.0),
  ///   ], duration: 1000.ms),
  /// )
  /// ```
  ///
  /// ## Per-keyframe motion with override
  ///
  /// ```dart
  /// StretchAct.keyframed(
  ///   frames: Keyframes(
  ///     [
  ///       .key(Stretch.none),  // Uses default motion
  ///       .key(Stretch(x: 1.5, y: 0.5), motion: Spring.bouncy()),  // Overrides
  ///       .key(Stretch.none, motion: Linear(400.ms)),  // Overrides
  ///     ],
  ///     motion: Spring.smooth(),  // Default motion
  ///   ),
  /// )
  /// ```
  /// {@endtemplate}
  const StretchAct.keyframed({
    required super.frames,
    super.reverse,
    super.delay,
    this.alignment = Alignment.center,
  }) : super.keyframed(from: Stretch.none);

  // @override
  // Matrix4 transform(_, Stretch value) {
  //   return Matrix4.diagonal3Values(
  //     value.x.clamp(0, double.maxFinite),
  //     value.y.clamp(0, double.maxFinite),
  //     1.0,
  //   );
  // }

  @override
  Animatable<Stretch> createSingleTween(Stretch from, Stretch to) {
    return _StretchTween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<Stretch> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final matrix = Matrix4.diagonal3Values(
          animation.value.x.clamp(0, double.maxFinite),
          animation.value.y.clamp(0, double.maxFinite),
          1.0,
        );
        return Transform(
          transform: matrix,
          alignment: alignment,
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StretchAct && super == other && other.alignment == alignment;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, alignment);
}

/// {@template stretch}
/// Non-uniform scaling factors with separate X and Y values.
///
/// Used with [StretchAct] to animate independent horizontal and vertical
/// scaling. Both values default to 1.0 (no scaling).
///
/// ## Creating Stretch Values
///
/// ```dart
/// // Stretch by 1.2x horizontal, 0.8x vertical
/// Stretch(x: 1.2, y: 0.8)
///
/// // No scaling (both 1.0)
/// Stretch.none
///
/// // Only horizontal stretch
/// Stretch(x: 1.5, y: 1.0)
/// ```
///
/// ## With StretchAct
///
/// ```dart
/// Actor(
///   acts: [
///     Act.stretch(
///       from: Stretch.none,
///       to: Stretch(x: 1.2, y: 0.8),
///     ),
///   ],
///   child: MyWidget(),
/// )
/// ```
/// {@endtemplate}
class Stretch {
  /// Horizontal scaling factor (width multiplier).
  ///
  /// Default is 1.0 (no scaling).
  /// Values > 1.0 stretch wider, < 1.0 compress narrower.
  ///
  /// ```dart
  /// Stretch(x: 2.0, y: 1.0) // 2x wider
  /// Stretch(x: 0.5, y: 1.0) // half width
  /// ```
  final double x;

  /// Vertical scaling factor (height multiplier).
  ///
  /// Default is 1.0 (no scaling).
  /// Values > 1.0 stretch taller, < 1.0 compress shorter.
  ///
  /// ```dart
  /// Stretch(x: 1.0, y: 2.0) // 2x taller
  /// Stretch(x: 1.0, y: 0.5) // half height
  /// ```
  final double y;

  /// Creates scaling factors for separate X and Y axes.
  ///
  /// Both [x] and [y] default to 1.0 (no scaling).
  /// Use [Stretch.none] for convenience when no scaling is needed.
  ///
  /// ```dart
  /// Stretch(x: 1.5, y: 0.8)
  /// Stretch.none == Stretch(x: 1.0, y: 1.0)
  /// ```
  const Stretch({this.x = 1.0, this.y = 1.0});

  /// Zero scaling (1.0 for both X and Y) - no transformation applied.
  ///
  /// Equivalent to:
  /// ```dart
  /// Stretch(x: 1.0, y: 1.0)
  /// ```
  static const none = Stretch(x: 1.0, y: 1.0);

  @override
  String toString() => 'Stretch(x: $x, y: $y)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Stretch && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);

  /// Linearly interpolates between two [Stretch] values.
  Stretch lerpTo(Stretch? other, double t) {
    if (other == null) {
      return this;
    }
    return Stretch(
      x: lerpDouble(x, other.x, t) ?? 1.0,
      y: lerpDouble(y, other.y, t) ?? 1.0,
    );
  }
}

class _StretchTween extends Tween<Stretch> {
  _StretchTween({required super.begin, required super.end});

  @override
  Stretch lerp(double t) => begin?.lerpTo(end, t) ?? Stretch.none;
}
