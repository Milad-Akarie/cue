part of 'act.dart';

class BlurAct extends TweenAct<double> {
  const BlurAct({
    super.from = 0.0,
    super.to = 0.0,
    super.curve,
    super.timing,
  });

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
