part of 'base/effect.dart';

class OpacityEffect extends TweenEffect<double> {
  const OpacityEffect({
    super.from = 0.0,
    super.to = 1.0,
    super.curve,
    super.timing,
  });

  const OpacityEffect.fadeIn({super.from = 0.0, super.to = 1.0, super.curve, super.timing});
  const OpacityEffect.fadeOut({super.from = 1.0, super.to = 0.0, super.curve, super.timing});

  const OpacityEffect.tween({
    required super.from,
    required super.to,
    super.curve,
    super.timing,
  });

  const OpacityEffect.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @internal
  const OpacityEffect.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
  }) : super.internal();

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }
}

class FadeActor extends SingleEffectBase<double> {
  const FadeActor({
    super.key,
    super.from = 1,
    super.to = 0,
    required super.child,
    super.role,
    super.curve,
    super.timing,
  });

  const FadeActor.keyframes({
    required super.child,
    required super.frames,
    super.key,
    super.role,
    super.curve,
  }) : super.keyframes();

  @override
  Effect get effect => OpacityEffect.internal(
    from: from,
    to: to,
    keyframes: frames,
    curve: curve,
    timing: timing,
  );
}
