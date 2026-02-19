part of 'effect.dart';

class AlignEffect extends TweenEffect<AlignmentGeometry?> {
  const AlignEffect({
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
