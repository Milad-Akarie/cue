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

  const TransformEffect.keyframes(
    super.keyframes, {
    super.curve,
    this.alignment,
    this.origin,
  }) : super.keyframes();

  @internal
  const TransformEffect.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
    this.alignment,
    this.origin,
  }) : super.internal();

  @override
  Animatable<Matrix4> buildSinglePhaseAnimtable(Matrix4 from, Matrix4 to) {
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

class TransformActor extends SingleEffectBase<Matrix4> {
  final AlignmentGeometry? alignment;
  final Offset? origin;

  const TransformActor({
    super.key,
    required super.child,
    required super.from,
    required super.to,
    this.alignment,
    this.origin,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  });

  const TransformActor.keyframes({
    super.key,
    required super.frames,
    required super.child,
    this.alignment,
    this.origin,
    super.curve,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : super.keyframes();

  @override
  Effect get effect => TransformEffect.internal(
    from: from,
    to: to,
    keyframes: frames,
    alignment: alignment,
    origin: origin,
  );
}
