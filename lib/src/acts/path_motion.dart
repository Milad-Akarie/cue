part of 'base/act.dart';

class PathMotionAct extends AnimtableAct<Matrix4, Matrix4> {
  @override
  final ActKey key = const ActKey('PathMotionAct');

  final Path path;
  final bool autoRotate;
  final AlignmentGeometry alignment;
  final double _startAngle;

  const PathMotionAct({
    required this.path,
    this.autoRotate = false,
    this.alignment = Alignment.center,
    super.motion,
    super.delay,
  }) : _startAngle = 0.0,
       super(reverse: const ReverseBehavior.mirror());

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
    return other is PathMotionAct && super == other &&
        other.path == path &&
        other.autoRotate == autoRotate &&
        other.alignment == alignment &&
        other._startAngle == _startAngle;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, path, autoRotate, alignment, _startAngle, motion, delay);
}

class _AnimtablePath extends Animatable<Matrix4> {
  final PathMetric metric;
  final bool autoRotate;
  final double startAngle;

  _AnimtablePath(this.metric, {this.autoRotate = false, this.startAngle = 0.0});

  @override
  Matrix4 transform(double t) {
    final angleOffset = startAngle / (2 * math.pi);
    final effectiveT = (t + angleOffset) % 1.0;
    final tangent = metric.getTangentForOffset(metric.length * effectiveT);
    final pos = tangent?.position ?? Offset.zero;
    final matrix = Matrix4.translationValues(pos.dx, pos.dy, 0.0);
    if (autoRotate) {
      matrix.rotateZ(tangent?.angle ?? 0.0);
    }
    return matrix;
  }
}
