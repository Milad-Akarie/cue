part of 'act.dart';

class Decorate extends TweenAct<Decoration> {
  const Decorate({
    super.begin = const BoxDecoration(),
    super.end = const BoxDecoration(),
    super.curve,
    super.timing,
  });

  const Decorate.keyframes(
    super.keyframes, {
    super.curve,
  }) : super.keyframes();

  @override
  Widget wrapWidget(AnimationContext context, Widget child) {
    return DecoratedBoxTransition(
      decoration: build(
        context,
        tweenBuilder: (begin, end) {
          return DecorationTween(begin: begin, end: end);
        },
      ),
      child: child,
    );
  }
}
