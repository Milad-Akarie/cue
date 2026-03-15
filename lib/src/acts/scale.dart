part of 'base/act.dart';

class ScaleAct extends TweenAct<double> {
  final AlignmentGeometry? alignment;

  const ScaleAct({
    super.from = 1.0,
    super.to = 1.0,
    super.motion,
    super.reverse,
    this.alignment,
  }) : super.tween();

  const ScaleAct.zoomIn({
    super.from = 0.0,
    super.to = 1.0,
    super.motion,
    super.reverse,
    this.alignment,
  }) : super.tween();

  const ScaleAct.zoomOut({
    super.from = 1.0,
    super.to = 0.0,
    super.motion,
    super.reverse,
    this.alignment,
  }) : super.tween();

  const ScaleAct.keyframed({
    required super.frames,
    super.reverse,
    super.delay,
    this.alignment,
  }) : super.keyframed();

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    final directionality = Directionality.maybeOf(context);
    final effectiveAlignment = alignment?.resolve(directionality) ?? Alignment.center;
    return ScaleTransition(
      scale: animation,
      alignment: effectiveAlignment,
      child: child,
    );
  }
}
