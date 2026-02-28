part of 'base/effect.dart';

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

class ColorTintActor extends SingleEffectBase<Color?> {
  const ColorTintActor({
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

  const ColorTintActor.keyframes({
    super.key,
    required super.frames,
    required super.child,
    super.curve,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : super.keyframes();

  @override
  Effect get effect => ColorEffect.internal(from: from, to: to, keyframes: frames);
}
