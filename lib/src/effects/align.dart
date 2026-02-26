part of 'effect.dart';

class AlignEffect extends TweenEffect<AlignmentGeometry?> {
  const AlignEffect({
    super.from,
    super.to,
    super.curve,
    super.timing,
  });

  const AlignEffect.keyframes(
    super.keyframes, {
    super.curve,
  }) : super.keyframes();

  const AlignEffect.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
  }) : super.internal();

  @override
  Animatable<AlignmentGeometry?> buildSinglePhaseAnimtable(
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

class AlignActor extends SingleEffectBase<AlignmentGeometry?> {
  const AlignActor({
    required super.child,
    super.key,
    super.from,
    super.to,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  });

  const AlignActor.keyframes({
    required super.child,
    required super.frames,
    super.key,
    super.role,
    super.curve,
  }) : super.keyframes();

  @override
  Effect get effect => AlignEffect.internal(
    from: from,
    to: to,
    keyframes: frames,
    curve: curve,
    timing: timing,
  );
}
