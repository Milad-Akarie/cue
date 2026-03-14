part of 'base/act.dart';

// class PathMotionAct extends Act {
//   final Path path;
//   final bool autoRotate;
//   final AlignmentGeometry alignment;
//   final CueMotion? motion;

//   const PathMotionAct({
//     required this.path,
//     this.autoRotate = false,
//     this.alignment = Alignment.center,
//     this.motion,
//   });

//   PathMotionAct.circular({
//     this.autoRotate = false,
//     this.alignment = Alignment.center,
//     required double radius,
//     Offset center = Offset.zero,
//     this.motion,
//   }) : path = Path()..addOval(Rect.fromCircle(center: center, radius: radius));

//   PathMotionAct.arc({
//     required double radius,
//     Offset center = Offset.zero,
//     required double startAngle,
//     required double sweepAngle,
//     this.autoRotate = false,
//     this.alignment = Alignment.center,
//     this.motion,
//   }) : path = Path()
//          ..addArc(
//            Rect.fromCircle(center: center, radius: radius),
//            startAngle * math.pi / 180,
//            sweepAngle * math.pi / 180,
//          );

//   @override
//   List<(Act, ActContext)> resolve(ActContext context) {
//     return [(this, context)];
//   }

//   @override
//   CueAnimation<Matrix4> buildAnimation(CueTimeline timline, ActContext context) {
//     final driver = timline.animationFor(AnimationConfig(motion: motion ?? context.motion));
//     final metrics = path.computeMetrics().toList();
//     if (metrics.isEmpty) {
//       throw Exception('Path must have one metric');
//     } else if (metrics.length > 1) {
//       throw Exception('Path must have only one metric');
//     }
//     // //TODO: finish this
//     // final animatble = applyCurves<Matrix4>(
//     //   _AnimtablePath(metrics.first, autoRotate: autoRotate),
//     //   motion: motion ?? context.motion,
//     //   isBounded: context.isBounded,
//     // );
//     return  CueAnimationImpl(parent: driver, animtable: DualAnimatable(forward: _AnimtablePath(metrics.first, autoRotate: autoRotate), reverse: null));
//   }

//   @override
//   Widget build(BuildContext context, covariant CueAnimation<Matrix4> animation, Widget child) {
//     return AnimatedBuilder(
//       animation: animation,
//       child: child,
//       builder: (context, child) {
//         return Transform(
//           transform: animation.value,
//           transformHitTests: true,
//           alignment: alignment,
//           child: child,
//         );
//       },
//     );
//   }
// }

// class _AnimtablePath extends Animatable<Matrix4> {
//   final PathMetric metric;
//   final bool autoRotate;
//   _AnimtablePath(this.metric, {this.autoRotate = false});

//   @override
//   Matrix4 transform(double t) {
//     final tangent = metric.getTangentForOffset(metric.length * t);
//     final pos = tangent?.position ?? Offset.zero;
//     final matrix = Matrix4.translationValues(pos.dx, pos.dy, 0.0);
//     if (autoRotate) {
//       matrix.rotateZ(tangent?.angle ?? 0.0);
//     }
//     return matrix;
//   }
// }
