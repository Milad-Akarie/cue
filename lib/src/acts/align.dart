part of 'act.dart';

class AlignAct extends TweenAct<AlignmentGeometry?> {
  const AlignAct({
    super.from,
    super.to,
    super.curve,
    super.timing,
  });

  @override
  Animatable<AlignmentGeometry?> buildSinglePhaseTween(
    AlignmentGeometry? from,
    AlignmentGeometry? to,
  ) {
    return AlignmentGeometryTween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<AlignmentGeometry?> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Align(
          alignment: animation.value ?? Alignment.center,
          child: child,
        );
      },
      child: child,
    );
  }
}
