part of 'base/effect.dart';

class BlurEffect extends TweenEffect<double> {
  const BlurEffect({
    super.from = 0.0,
    super.to = 0.0,
    super.curve,
    super.timing,
  });

  const BlurEffect.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  const BlurEffect.tween({
    super.from = 0.0,
    super.to = 0.0,
    super.curve,
    super.timing,
  });

  const BlurEffect.focus({
    super.from = 10.0,
    super.to = 0.0,
    super.curve,
    super.timing,
  });

  const BlurEffect.unfocus({
    super.from = 0.0,
    super.to = 10.0,
    super.curve,
    super.timing,
  });

  @internal
  const BlurEffect.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
  }) : super.internal();

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final blurValue = animation.value;
        return ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: blurValue,
            sigmaY: blurValue,
          ),
          child: child,
        );
      },
    );
  }
}

class BackdropBlurEffect extends TweenEffect<double> {
  const BackdropBlurEffect({
    super.from = 0.0,
    super.to = 0.0,
    super.curve,
    super.timing,
    this.blendMode = BlendMode.srcOver,
  });

  final BlendMode blendMode;

  const BackdropBlurEffect.keyframes(
    super.keyframes, {
    super.curve,
    this.blendMode = BlendMode.srcOver,
  }) : super.keyframes();

  const BackdropBlurEffect.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
    this.blendMode = BlendMode.srcOver,
  }) : super.internal();

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final blurValue = animation.value;
        return BackdropFilter(
          blendMode: blendMode,
          filter: ImageFilter.blur(
            sigmaX: blurValue,
            sigmaY: blurValue,
          ),
          child: child,
        );
      },
    );
  }
}

class BlurActor extends SingleEffectBase<double> {
  const BlurActor({
    super.key,
    required super.from,
    super.to = 0.0,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  });

  const BlurActor.keyframes({
    required super.child,
    super.key,
    required super.frames,
    super.curve,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : super.keyframes();

  @override
  Effect get effect => BlurEffect.internal(from: from, to: to, keyframes: frames);
}

class BackdropBlurActor extends SingleEffectBase<double> {
  final BlendMode blendMode;

  const BackdropBlurActor({
    super.key,
    required super.from,
    required super.to,
    this.blendMode = BlendMode.srcOver,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  });

  @override
  Effect get effect => BackdropBlurEffect.internal(
    from: from,
    to: to,
    keyframes: frames,
    blendMode: blendMode,
  );
}
