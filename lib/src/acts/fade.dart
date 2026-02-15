part of 'act.dart';

class FadeAct extends TweenAct<double> {
  const FadeAct({
    super.from = 0.0,
    super.to = 1.0,
    super.curve,
    super.timing,
  });

  const FadeAct.out({super.from = 1.0, super.curve, super.timing}) : super(to: 0);

  const FadeAct.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
