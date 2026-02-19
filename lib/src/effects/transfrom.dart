part of 'effect.dart';

class TransformEffect extends TweenEffect<Matrix4> {
  const TransformEffect({
    required super.from,
    required super.to,
    super.curve,
    super.timing,
    this.alignment,
    this.origin,
  });

  final AlignmentGeometry? alignment;
  final Offset? origin;

  const TransformEffect.keyframes(super.keyframes, {super.curve, this.alignment, this.origin}) : super.keyframes();

  @override
  Animatable<Matrix4> buildSinglePhaseTween(Matrix4 from, Matrix4 to) {
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
