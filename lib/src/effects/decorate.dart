part of 'effect.dart';

class DecoratationEffect extends TweenEffect<Decoration> {
  const DecoratationEffect({
    super.from = const BoxDecoration(),
    super.to = const BoxDecoration(),
    super.curve,
    super.timing,
  });

  const DecoratationEffect.keyframes(
    super.keyframes, {
    super.curve,
  }) : super.keyframes();

  @internal
  const DecoratationEffect.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
  }) : super.internal();

  @override
  Animatable<Decoration> buildSinglePhaseAnimtable(Decoration from, Decoration to) {
    return DecorationTween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<Decoration> animation, Widget child) {
    return DecoratedBoxTransition(
      decoration: animation,
      child: child,
    );
  }
}

class ColorEffect extends TweenEffect<Color?> {
  const ColorEffect({
    required super.from,
    required super.to,
    super.curve,
    super.timing,
    this.blendMode = BlendMode.srcIn,
  });

  final BlendMode blendMode;
  const ColorEffect.keyframes(
    super.keyframes, {
    super.curve,
    this.blendMode = BlendMode.srcIn,
  }) : super.keyframes();

  @internal
  const ColorEffect.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
    this.blendMode = BlendMode.srcIn,
  }) : super.internal();

  @override
  Animatable<Color?> buildSinglePhaseAnimtable(Color? from, Color? to) {
    return ColorTween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<Color?> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return ColorFiltered(
          colorFilter: ColorFilter.mode(animation.value ?? Colors.transparent, blendMode),
          child: child,
        );
      },
    );
  }
}

class DecorationActor extends SingleEffectBase<Decoration> {
  const DecorationActor({
    super.key,
    required super.from,
    required super.to,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  });

  @override
  Effect get effect => DecoratationEffect.internal(
    from: from,
    to: to,
    keyframes: frames,
  );
}

class ColorActor extends SingleEffectBase<Color?> {
  const ColorActor({
    super.key,
    required super.from,
    required super.to,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  });

  const ColorActor.keyframes({
    super.key,
    required super.frames,
    required super.child,
    super.curve,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : super.keyframes();

  @override
  Effect get effect => ColorEffect.internal(
    from: from,
    to: to,
    keyframes: frames,
  );
}
