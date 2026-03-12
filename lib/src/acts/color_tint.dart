part of 'base/act.dart';

class ColorTintAct extends TweenAct<Color?> {
  const ColorTintAct({
    required super.from,
    required super.to,
    super.motion,
    super.reverse,
    this.blendMode = BlendMode.srcIn,
  });

  final BlendMode blendMode;

  const ColorTintAct.keyframes(
    super.keyframes, {
    super.motion,
    super.reverse,
    this.blendMode = BlendMode.srcIn,
  }) : super.keyframes();

  @override
  Animatable<Color?> createSingleTween(Color? from, Color? to) {
    return ColorTween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<Color?> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return ColorFiltered(
          colorFilter: ColorFilter.mode(
            animation.value ?? Colors.transparent,
            blendMode,
          ),
          child: child,
        );
      },
    );
  }
}
