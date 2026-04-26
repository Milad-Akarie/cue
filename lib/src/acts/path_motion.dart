part of 'base/act.dart';

/// Animates a widget along a custom path.
///
/// Moves the child widget along a [Path] from start to end as the animation
/// progresses from 0 to 1. Optionally rotates the widget to follow the path
/// tangent (useful for direction-aware animations like arrows or vehicles).
///
/// The widget follows the path's geometry exactly, making this ideal for
/// complex curved motions, orbital patterns, and scenic animations.
class PathMotionAct extends AnimtableAct<Matrix4, Matrix4> {
  @override
  final ActKey key = const ActKey('PathMotionAct');

  /// The path the widget will follow during animation.
  ///
  /// Must contain exactly one path metric (single continuous path).
  /// The widget moves from the path's start (progress 0) to end (progress 1).
  ///
  /// Examples: straight line, bezier curve, circle outline, complex shape.
  final Path path;

  /// Whether to rotate the widget to match the path tangent.
  ///
  /// When true, the widget rotates to face the direction it's moving along
  /// the path. Useful for direction-aware graphics (arrows, vehicles, etc.).
  ///
  /// Defaults to false (no automatic rotation).
  final bool autoRotate;

  /// The pivot point for rotation and positioning.
  ///
  /// Controls which point of the widget aligns with the path.
  /// Defaults to [Alignment.center] (rotate around center).
  ///
  /// Change to [Alignment.bottomCenter] for objects that should point forward.
  final AlignmentGeometry alignment;

  final double _startAngle;

  /// {@template act.path_motion}
  /// Animates an object along a custom path.
  ///
  /// [path] defines the motion path. [autoRotate] controls whether the widget
  /// rotates to follow the path direction. [alignment] sets the rotation pivot.
  /// Default reverse uses [ReverseBehavior.mirror] to animate back.
  ///
  /// ## Basic straight line motion
  ///
  /// ```dart
  /// final path = Path()
  ///   ..moveTo(0, 0)
  ///   ..lineTo(200, 0);
  ///
  /// Actor(
  ///   acts: [
  ///     PathMotionAct(path: path),
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## Curved path with auto-rotation
  ///
  /// ```dart
  /// final path = Path()
  ///   ..moveTo(0, 0)
  ///   ..quadraticBezierTo(100, -50, 200, 0);
  ///
  /// PathMotionAct(
  ///   path: path,
  ///   autoRotate: true,
  ///   alignment: Alignment.bottomCenter,
  /// )
  /// ```
  ///
  /// ## Circular motion
  ///
  /// ```dart
  /// PathMotionAct.circular(
  ///   radius: 100,
  ///   autoRotate: true,
  /// )
  /// ```
  ///
  /// ## Arc motion (90° arc)
  ///
  /// ```dart
  /// PathMotionAct.arc(
  ///   radius: 100,
  ///   sweepAngle: 90,
  ///   autoRotate: true,
  /// )
  /// ```
  /// {@endtemplate}
  const PathMotionAct({
    required this.path,
    this.autoRotate = false,
    this.alignment = Alignment.center,
    super.motion,
    super.delay,
  }) : _startAngle = 0.0,
       super(reverse: const ReverseBehavior.mirror());

  /// {@template act.path_motion.circular}
  /// Animates circular motion with optional rotation.
  ///
  /// Creates a circular path with the given [radius] centered at [center].
  /// [startAngle] controls where on the circle the animation begins (in degrees).
  ///
  /// Perfect for orbital animations, spinning wheels, or circular progress.
  /// {@endtemplate}
  PathMotionAct.circular({
    this.autoRotate = false,
    this.alignment = Alignment.center,
    required double radius,
    Offset center = Offset.zero,
    double startAngle = 0.0,
    super.motion,
    super.delay,
  }) : _startAngle = startAngle,
       path = Path()
         ..addOval(
           Rect.fromCircle(center: center, radius: radius),
         ),
       super(reverse: const ReverseBehavior.mirror());

  /// {@template act.path_motion.arc}
  /// Animates motion along an arc segment.
  ///
  /// Creates an arc path with the given [radius] centered at [center].
  /// [startAngle] is where the arc begins (in degrees).
  /// [sweepAngle] is how far the arc extends (in degrees).
  ///
  /// Useful for partial circular motions like pendulum swings or door opening.
  /// {@endtemplate}
  PathMotionAct.arc({
    required double radius,
    Offset center = Offset.zero,
    double startAngle = 0.0,
    double startOffset = 0.0,
    required double sweepAngle,
    this.autoRotate = false,
    this.alignment = Alignment.center,
    super.motion,
    super.delay,
  }) : _startAngle = startOffset,
       path = Path()
         ..addArc(
           Rect.fromCircle(center: center, radius: radius),
           startAngle * math.pi / 180,
           sweepAngle * math.pi / 180,
         ),
       super(reverse: const ReverseBehavior.mirror());

  @override
  ActContext resolve(ActContext context) {
    return TweenActBase.resolveMotion(
      context,
      motion: motion,
      delay: delay,
      reverse: const ReverseBehavior.mirror(),
    );
  }

  @override
  Widget apply(BuildContext context, covariant CueAnimation<Matrix4> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Transform(
          transform: animation.value,
          transformHitTests: true,
          alignment: alignment,
          child: child,
        );
      },
    );
  }

  @override
  (CueAnimtable<Matrix4>, CueAnimtable<Matrix4>?) buildTweens(ActContext context) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) {
      throw Exception('Path must have one metric');
    } else if (metrics.length > 1) {
      throw Exception('Path must have only one metric');
    }
    return (
      TweenAnimtable(
        _AnimtablePath(
          metrics.first,
          autoRotate: autoRotate,
          startAngle: _startAngle * math.pi / 180,
        ),
      ),
      null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is PathMotionAct &&
        super == other &&
        other.path == path &&
        other.autoRotate == autoRotate &&
        other.alignment == alignment &&
        other._startAngle == _startAngle;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, path, autoRotate, alignment, _startAngle, motion, delay);
}

/// Internal animatable that computes positions and rotations along a path.
///
/// Converts animation progress (0 to 1) to Matrix4 transform by:
/// - Looking up position along path using progress * path.length
/// - Extracting tangent angle if autoRotate is enabled
/// - Building Matrix4 with translation and optional rotation
class _AnimtablePath extends Animatable<Matrix4> {
  /// Path metric extracted from the animated path.
  final PathMetric metric;

  /// Whether to include rotation based on path tangent.
  final bool autoRotate;

  /// Starting rotation angle in radians.
  ///
  /// Allows offsetting where rotation begins on the path.
  final double startAngle;

  /// Creates path animatable.
  ///
  /// [startAngle] is in radians, allowing offset rotation start position.
  _AnimtablePath(this.metric, {this.autoRotate = false, this.startAngle = 0.0});

  /// Computes position and rotation matrix at animation progress [t].
  ///
  /// [t] ranges from 0 (path start) to 1 (path end).
  /// Returns a Matrix4 with translation to path position and optional rotation.
@override
Matrix4 transform(double t) {
  final tangent = metric.getTangentForOffset(metric.length * t);
  final pos = tangent?.position ?? Offset.zero;
  final matrix = Matrix4.translationValues(pos.dx, pos.dy, 0.0);
  if (autoRotate) {
    matrix.rotateZ(tangent?.angle ?? 0.0);
  }
  return matrix;
}
}
