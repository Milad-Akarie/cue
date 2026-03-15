part of 'base/act.dart';

class TextStyleAct extends TweenAct<TextStyle> {
  const TextStyleAct({
    required super.from,
    required super.to,
    super.motion,
    super.reverse,
  }) : super.tween();

  const TextStyleAct.keyframed({
    required super.frames,
    super.reverse,
    super.delay,
  }) : super.keyframed();

  @override
  Animatable<TextStyle> createSingleTween(TextStyle from, TextStyle to) {
    return TextStyleTween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<TextStyle> animation, Widget child) {
    return DefaultTextStyleTransition(style: animation, child: child);
  }
}

class IconThemeAct extends TweenAct<IconThemeData> {
  const IconThemeAct({
    required super.from,
    required super.to,
    super.motion,
    super.reverse,
  }) : super.tween();

  const IconThemeAct.keyframed({
    required super.frames,
    super.delay,
    super.reverse,
  }) : super.keyframed();

  @override
  Animatable<IconThemeData> createSingleTween(IconThemeData from, IconThemeData to) {
    return _IconThemeDataTween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<IconThemeData> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return IconTheme(
          data: animation.value,
          child: child!,
        );
      },
      child: child,
    );
  }
}

class _IconThemeDataTween extends Tween<IconThemeData> {
  _IconThemeDataTween({required super.begin, required super.end});

  @override
  IconThemeData lerp(double t) {
    return IconThemeData.lerp(begin, end, t);
  }
}
