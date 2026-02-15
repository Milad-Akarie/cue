part of 'act.dart';

class ScaleAct extends TweenAct<double> {
  const ScaleAct({
    super.from = 0.0,
    super.to = 1.0,
    super.curve,
    super.timing,
    this.alignment,
  });

  final AlignmentGeometry? alignment;

  const ScaleAct.up({super.from = 0.0, super.curve, super.timing, this.alignment}) : super(to: 1.0);

  const ScaleAct.down({super.to = 0.0, super.curve, super.timing, this.alignment}) : super(from: 1.0);

  const ScaleAct.keyframes(super.keyframes, {super.curve, this.alignment}) : super.keyframes();

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    final effectiveAlignment = alignment?.resolve(Directionality.maybeOf(context)) ?? Alignment.center;
    return ScaleTransition(
      scale: animation,
      alignment: effectiveAlignment,
      child: child,
    );
  }
}
