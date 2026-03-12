part of 'base/act.dart';

class OpacityAct extends TweenAct<double> {
  const OpacityAct({
    super.from = 0.0,
    super.to = 1.0,
    super.motion,
    super.reverse,
  });

  const OpacityAct.fadeIn({
    super.from = 0.0,
    super.to = 1.0,
    super.motion,
    super.reverse,
  });
  const OpacityAct.fadeOut({
    super.from = 1.0,
    super.to = 0.0,
    super.motion,
    super.reverse,
  });

  const OpacityAct.keyframes(
    super.keyframes, {
    super.motion,
    super.reverse,
  }) : super.keyframes();

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }
}
