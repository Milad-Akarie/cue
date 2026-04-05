part of 'base/act.dart';

/// {@template transform_act}
/// Animates arbitrary 3D transformations using Matrix4.
///
/// [TransformAct] applies 2D and 3D transformations to widgets by animating a [Matrix4].
/// This provides low-level control for complex transformations that can't be achieved
/// with other acts like scale, rotate, or translate.
///
/// Use [Act.transform()] factory to create instances.
///
/// ## Basic Matrix Transform
///
/// ```dart
/// // Animate a custom matrix transformation
/// Actor(
///   acts: [
///     .transform(
///       from: Matrix4.identity(),
///       to: Matrix4.diagonal4Values(1.2, 1.2, 1, 1),
///     ),
///   ],
///   motion: .smooth(damping: 23),
///   child: MyWidget(),
/// )
/// ```
///
/// ## Transform with Alignment
///
/// ```dart
/// // Apply transformation from a specific point
/// Actor(
///   acts: [
///     .transform(
///       to: Matrix4.rotationZ(0.5),
///       alignment: Alignment.center,
///     ),
///   ],
///   motion: .smooth(damping: 23),
///   child: MyWidget(),
/// )
/// ```
///
/// ## Transform with Origin Offset
///
/// ```dart
/// // Apply transformation relative to a specific origin
/// Actor(
///   acts: [
///     .transform(
///       to: Matrix4.skew(0.1, 0),
///       origin: Offset(50, 50),
///     ),
///   ],
///   motion: .smooth(damping: 23),
///   child: MyWidget(),
/// )
/// ```
/// {@endtemplate}
class TransformAct extends TweenAct<Matrix4> {
  /// {@template act.transform}
  /// Animates between two matrix transformations.
  ///
  /// [from] is the starting [Matrix4] (defaults to identity) and [to] is the target transformation.
  /// [alignment] controls the pivot point for the transformation (defaults to no specific alignment).
  /// [origin] specifies a pixel-based offset from the alignment point.
  ///
  /// ## Basic Usage
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .transform(
  ///       to: Matrix4.diagonal4Values(1.5, 1.5, 1, 1),
  ///     ),
  ///   ],
  ///   motion: .smooth(damping: 23),
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## With Alignment and Origin
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .transform(
  ///       from: Matrix4.identity(),
  ///       to: Matrix4.rotationZ(3.14159 / 4),  // ~45 degrees
  ///       alignment: Alignment.center,
  ///       origin: Offset(0, -20),
  ///     ),
  ///   ],
  ///   motion: .smooth(damping: 23),
  ///   child: MyWidget(),
  /// )
  /// ```
  /// {@endtemplate}
  @override
  final ActKey key = const ActKey('Transform');

  TransformAct({
    Matrix4? from,
    required super.to,
    super.motion,
    super.reverse,
    this.alignment,
    this.origin,
    super.delay,
  }) : super.tween(from: from ?? Matrix4.identity());

  final AlignmentGeometry? alignment;
  final Offset? origin;

  /// {@template act.transform.keyframed}
  /// Animates through multiple matrix transformation keyframes.
  ///
  /// [frames] define multiple [Matrix4] targets at different times.
  ///
  /// ## Keyframed Transform Animation
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     TransformAct.keyframed(
  ///       frames: Keyframes.fractional([
  ///         .key(Matrix4.identity(), at: 0.0),
  ///         .key(Matrix4.diagonal4Values(1.2, 1.2, 1, 1), at: 0.5),
  ///         .key(Matrix4.identity(), at: 1.0),
  ///       ], duration: 800.ms),
  ///       alignment: Alignment.center,
  ///     ),
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## With Motion Override
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     TransformAct.keyframed(
  ///       frames: Keyframes([
  ///         .key(Matrix4.identity()),
  ///         .key(
  ///           Matrix4.rotationZ(3.14159 / 2),
  ///           motion: Spring.bouncy(),
  ///         ),
  ///       ], motion: Spring.smooth()),
  ///       alignment: Alignment.center,
  ///     ),
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  /// {@endtemplate}
  TransformAct.keyframed({
    required super.frames,
    super.reverse,
    this.alignment,
    this.origin,
    super.delay,
  }) : super.keyframed(from: Matrix4.identity());

  @override
  Animatable<Matrix4> createSingleTween(Matrix4 from, Matrix4 to) {
    return Matrix4Tween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<Matrix4> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Transform(
          transform: animation.value,
          alignment: alignment,
          origin: origin,
          child: child,
        );
      },
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransformAct &&
          runtimeType == other.runtimeType && super == (other) &&
          alignment == other.alignment &&
          origin == other.origin;

  @override
  int get hashCode => Object.hash(super.hashCode, alignment, origin);
}

/// {@template skew_act}
/// Animates skew transformations on the X and Y axes.
///
/// [SkewAct] applies skew effects to widgets by animating [Skew] values.
/// Skew distorts the widget by slanting it along the X and/or Y axes.
///
/// Use [Act.skew()] factory to create instances.
///
/// ## Basic Skew Animation
///
/// ```dart
/// // Skew along X axis
/// Actor(
///   acts: [
///     .skew(from: Skew.zero, to: Skew(x: 0.3, y: 0)),
///   ],
///   motion: .smooth(damping: 23),
///   child: MyWidget(),
/// )
/// ```
///
/// ## Skew Both Axes
///
/// ```dart
/// // Skew diagonally
/// Actor(
///   acts: [
///     .skew(from: Skew.zero, to: Skew(x: 0.2, y: 0.2)),
///   ],
///   motion: .smooth(damping: 23),
///   child: MyWidget(),
/// )
/// ```
///
/// ## Skew with Custom Origin
///
/// ```dart
/// // Skew from a specific point
/// Actor(
///   acts: [
///     .skew(
///       to: Skew(x: 0.3),
///       alignment: Alignment.center,
///       origin: Offset(0, -30),
///     ),
///   ],
///   motion: .smooth(damping: 23),
///   child: MyWidget(),
/// )
/// ```
/// {@endtemplate}
class SkewAct extends TweenActBase<Skew, Matrix4> {
  /// {@template act.skew}
  /// Animates skew distortion on one or both axes.
  ///
  /// [from] is the starting [Skew] (defaults to zero) and [to] is the target skew.
  /// [alignment] controls the pivot point for the skew transformation.
  /// [origin] specifies a pixel-based offset from the alignment point.
  ///
  /// ## Basic Usage
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .skew(to: Skew(x: 0.25, y: 0)),
  ///   ],
  ///   motion: .smooth(damping: 23),
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## Symmetric Skew
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .skew(to: Skew.symmetric(0.15)),
  ///   ],
  ///   motion: .smooth(damping: 23),
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## With Alignment
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .skew(
  ///       to: Skew(x: 0.3, y: 0.1),
  ///       alignment: Alignment.topLeft,
  ///     ),
  ///   ],
  ///   motion: .smooth(damping: 23),
  ///   child: MyWidget(),
  /// )
  /// ```
  /// {@endtemplate}
  @override
  ActKey get key => const ActKey('Transform:Skew');

  final AlignmentGeometry? alignment;
  final Offset? origin;

  const SkewAct({
    this.alignment,
    this.origin,
    super.delay,
    super.motion,
    super.from = Skew.zero,
    super.to = Skew.zero,
    super.reverse = const ReverseBehavior.mirror(),
  });

  /// {@template act.skew.keyframed}
  /// Animates through multiple skew keyframes.
  ///
  /// [frames] define multiple [Skew] targets at different times.
  ///
  /// ## Keyframed Skew Animation
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     SkewAct.keyframed(
  ///       frames: Keyframes.fractional([
  ///         .key(Skew.zero, at: 0.0),
  ///         .key(Skew(x: 0.2, y: 0.1), at: 0.5),
  ///         .key(Skew.zero, at: 1.0),
  ///       ], duration: 800.ms),
  ///     ),
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## With Motion Override
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     SkewAct.keyframed(
  ///       frames: Keyframes([
  ///         .key(Skew.zero),
  ///         .key(Skew.symmetric(0.3), motion: Spring.bouncy()),
  ///       ], motion: Spring.smooth()),
  ///       alignment: Alignment.center,
  ///     ),
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  /// {@endtemplate}
  const SkewAct.keyframed({
    required super.frames,
    super.reverse = const KFReverseBehavior.mirror(),
    this.alignment,
    this.origin,
    super.delay,
  }) : super.keyframed();

  @override
  Matrix4 transform(_, Skew value) => Matrix4.skew(value.x, value.y);

  @override
  Animatable<Matrix4> createSingleTween(Matrix4 from, Matrix4 to) {
    return Matrix4Tween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<Matrix4> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Transform(
          transform: animation.value,
          alignment: alignment,
          origin: origin,
          child: child,
        );
      },
    );
  }
}

class Skew {
  final double x;
  final double y;

  const Skew({this.x = 0, this.y = 0});

  static const Skew zero = Skew(x: 0, y: 0);

  const Skew.symmetric(double value) : x = value, y = value;

  @override
  String toString() => 'Skew(x: $x, y: $y)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Skew && runtimeType == other.runtimeType && x == other.x && y == other.y;
  @override
  int get hashCode => Object.hash(x, y);
}
