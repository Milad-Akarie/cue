part of 'base/act.dart';

class ColorTintAct extends TweenAct<Color?> {

  @override
  final ActKey key = const ActKey('ColorTint');
  
  const ColorTintAct({
    required super.from,
    required super.to,
    super.motion,
    super.reverse,
    this.blendMode = BlendMode.srcIn,
    super.delay,
  }) : super.tween();

  final BlendMode blendMode;

  const ColorTintAct.keyframed({
    required super.frames,
    super.reverse,
    super.delay,
    this.blendMode = BlendMode.srcIn,
  }) : super.keyframed();

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
