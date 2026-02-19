part of 'effect.dart';

class BlurEffect extends TweenEffect<double> {
  const BlurEffect({
    super.from = 0.0,
    super.to = 0.0,
    super.curve,
    super.timing,
  });

  const BlurEffect.keyframes(super.keyframes, {super.curve}) : super.keyframes();

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
