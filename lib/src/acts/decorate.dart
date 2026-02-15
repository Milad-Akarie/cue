part of 'act.dart';

class DecorateAct extends TweenAct<Decoration> {
  const DecorateAct({
    super.from = const BoxDecoration(),
    super.to = const BoxDecoration(),
    super.curve,
    super.timing,
  });

  const DecorateAct.keyframes(
    super.keyframes, {
    super.curve,
  }) : super.keyframes();

  @override
  Animatable<Decoration> buildSinglePhaseTween(Decoration from, Decoration to) {
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

class ColorAct extends TweenAct<Color> {
  const ColorAct({
    required super.from,
    required super.to,
    super.curve,
    super.timing,
  });

  const ColorAct.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Animatable<Color> buildSinglePhaseTween(Color from, Color to) {
    return ColorTween(begin: from, end: to) as Animatable<Color>;
  }

  @override
  Widget apply(BuildContext context, Animation<Color> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return ColoredBox(color: animation.value, child: child!);
      },
    );
  }
}
