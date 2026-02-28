part of 'base/effect.dart';

class PathMotionEffect extends Effect {
  final Path path;
  final bool autoRotate;
  final AlignmentGeometry alignment;

  const PathMotionEffect({
    required this.path,
    this.autoRotate = false,
    this.alignment = Alignment.center,
    super.curve,
    super.timing,
  });

  PathMotionEffect.circular({
    this.autoRotate = false,
    this.alignment = Alignment.center,
    required double radius,
    Offset center = Offset.zero,
    super.curve,
    super.timing,
  }) : path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));

  PathMotionEffect.arc({
    required double radius,
    Offset center = Offset.zero,
    required double startAngle,
    required double sweepAngle,
    this.autoRotate = false,
    this.alignment = Alignment.center,
    super.curve,
    super.timing,
  }) : path = Path()
         ..addArc(
           Rect.fromCircle(center: center, radius: radius),
           startAngle * math.pi / 180,
           sweepAngle * math.pi / 180,
         );

  @override
  Animation<Matrix4> buildAnimation(Animation<double> driver, ActorContext data) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) {
      throw Exception('Path must have one metric');
    } else if (metrics.length > 1) {
      throw Exception('Path must have only one metric');
    }
    final animatble = applyCurves<Matrix4>(
      _AnimtablePath(metrics.first, autoRotate: autoRotate),
      curve: curve ?? data.curve,
      timing: timing ?? data.timing,
      isBounded: data.isBounded,
    );
    return animatble.animate(driver);
  }

  @override
  Widget build(BuildContext context, covariant Animation<Matrix4> animation, Widget child) {
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
}

class _AnimtablePath extends Animatable<Matrix4> {
  final PathMetric metric;
  final bool autoRotate;
  _AnimtablePath(this.metric, {this.autoRotate = false});

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
