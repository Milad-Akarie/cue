part of 'base/effect.dart';

class ScaleEffect extends TweenEffect<double> {
  final AlignmentGeometry? alignment;

  const ScaleEffect({
    required super.from,
    required super.to,
    super.curve,
    super.timing,
    this.alignment,
  });

  const ScaleEffect.tween({
    required super.from,
    required super.to,
    super.curve,
    super.timing,
    this.alignment,
  });

  const ScaleEffect.zoomIn({
    super.from = 0.0,
    super.to = 1.0,
    super.curve,
    super.timing,
    this.alignment,
  });

  const ScaleEffect.zoomOut({
    super.from = 1.0,
    super.to = 0.0,
    super.curve,
    super.timing,
    this.alignment,
  });

  const ScaleEffect.keyframes(
    super.keyframes, {
    super.curve,
    this.alignment,
  }) : super.keyframes();

  @internal
  const ScaleEffect.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
    this.alignment,
  }) : super.internal();

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

class ScaleActor extends SingleEffectBase<double> {
  final AlignmentGeometry? alignment;

  const ScaleActor({
    super.key,
    required super.from,
    super.to = 1.0,
    required super.child,
    this.alignment,
    super.curve,
    super.timing,
    super.role,
  });

  const ScaleActor.keyframes({
    super.key,
    required super.frames,
    required super.child,
    this.alignment,
    super.curve,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : super.keyframes();

  @override
  Effect get effect => ScaleEffect.internal(
    from: from,
    to: to,
    keyframes: frames,
    alignment: alignment,
  );
}
