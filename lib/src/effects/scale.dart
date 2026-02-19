part of 'effect.dart';

class ScaleEffect extends TweenEffect<double> {
  const ScaleEffect({
    super.from = 0.0,
    super.to = 1.0,
    super.curve,
    super.timing,
    this.alignment,
  });

  final AlignmentGeometry? alignment;

  const ScaleEffect.keyframes(
    super.keyframes, {
    super.curve,
    this.alignment,
  }) : super.keyframes();

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
