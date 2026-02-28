part of 'base/effect.dart';

class PaddingEffect extends TweenEffect<EdgeInsetsGeometry> {
  const PaddingEffect({
    super.from = EdgeInsets.zero,
    super.to = EdgeInsets.zero,
    super.curve,
    super.timing,
  });

  const PaddingEffect.keyframes(
    super.keyframes, {
    super.curve,
  }) : super.keyframes();

  const PaddingEffect.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
  }) : super.internal();

  @override
  Animatable<EdgeInsetsGeometry> buildSinglePhaseAnimtable(
    EdgeInsetsGeometry from,
    EdgeInsetsGeometry to,
  ) {
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

class PaddingActor extends SingleEffectBase<EdgeInsetsGeometry> {
  const PaddingActor({
    super.key,
    super.from = EdgeInsets.zero,
    required super.to,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  });

  const PaddingActor.keyframes({
    required super.frames,
    super.key,
    required super.child,
    super.curve,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : super.keyframes();

  @override
  Effect get effect => PaddingEffect.internal(
    from: from,
    to: to,
    keyframes: frames,
  );
}
