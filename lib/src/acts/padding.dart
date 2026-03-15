part of 'base/act.dart';

class PaddingAct extends TweenAct<EdgeInsetsGeometry> {
  const PaddingAct({
    super.from = EdgeInsets.zero,
    super.to = EdgeInsets.zero,
    super.motion,
    super.reverse,
  }) : super.tween();

  const PaddingAct.keyframed({
    required super.frames,
    super.delay,
    super.reverse,
  }) : super.keyframed();

  @override
  Animatable<EdgeInsetsGeometry> createSingleTween(EdgeInsetsGeometry from, EdgeInsetsGeometry to) {
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
