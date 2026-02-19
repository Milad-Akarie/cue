part of 'effect.dart';

class PaddingEffect extends TweenEffect<EdgeInsetsGeometry> {
  const PaddingEffect({
    super.from = EdgeInsets.zero,
    super.to = EdgeInsets.zero,
    super.curve,
    super.timing,
  });

  const PaddingEffect.keyframes(
    super.keyframes, {
    super.curve,
  }) : super.keyframes();

  @override
  Animatable<EdgeInsetsGeometry> buildSinglePhaseTween(EdgeInsetsGeometry from, EdgeInsetsGeometry to) {
    return EdgeInsetsGeometryTween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<EdgeInsetsGeometry> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Padding(
          padding: animation.value.clamp(
            EdgeInsets.zero,
            EdgeInsetsGeometry.infinity,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}
