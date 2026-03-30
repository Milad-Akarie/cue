part of 'base/act.dart';

class AlignAct extends TweenActBase<AlignmentGeometry?, Alignment?> {
  
  @override
  final ActKey key = const ActKey('Align');

  const AlignAct({
    super.from = Alignment.center,
    super.to = Alignment.center,
    super.motion,
    super.reverse,
    super.delay,
  }) : super.tween();

  const AlignAct.keyframed({
    required super.frames,
    super.reverse,
    super.delay,
  }) : super.keyframed();

  @override
  Alignment? transform(ActContext ctx, AlignmentGeometry? value) {
    return value?.resolve(ctx.textDirection);
  }

  @override
  Animatable<Alignment?> createSingleTween(Alignment? from, Alignment? to) {
    return AlignmentTween(begin: from, end: to);
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
