part of 'effect.dart';

class DecorateEffect extends TweenEffect<Decoration> {
  const DecorateEffect({
    super.from = const BoxDecoration(),
    super.to = const BoxDecoration(),
    super.curve,
    super.timing,
  });

  const DecorateEffect.keyframes(
    super.keyframes, {
    super.curve,
  }) : super.keyframes();

  @override
  Animatable<Decoration> buildSinglePhaseTween(Decoration from, Decoration to) {
    return DecorationTween(begin: from, end: to);
  }

  @override
  Widget apply(
    BuildContext context,
    Animation<Decoration> animation,
    Widget child,
  ) {
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
  const ColorEffect.keyframes(super.keyframes, {super.curve, this.blendMode = BlendMode.srcIn}) : super.keyframes();

  @override
  Animatable<Color?> buildSinglePhaseTween(Color? from, Color? to) {
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
