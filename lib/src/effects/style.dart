part of 'base/effect.dart';

class TextStyleEffect extends TweenEffect<TextStyle> {
  const TextStyleEffect({
    required super.from,
    required super.to,
    super.curve,
    super.timing,
  });

  const TextStyleEffect.keyframes(
    super.keyframes, {
    super.curve,
  }) : super.keyframes();

  @internal
  const TextStyleEffect.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
  }) : super.internal();

  @override
  Animatable<TextStyle> buildSinglePhaseAnimtable(TextStyle from, TextStyle to) {
    return TextStyleTween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<TextStyle> animation, Widget child) {
    return DefaultTextStyleTransition(style: animation, child: child);
  }
}

class IconThemeEffect extends TweenEffect<IconThemeData> {
  const IconThemeEffect({
    required super.from,
    required super.to,
    super.curve,
    super.timing,
  });

  const IconThemeEffect.keyframes(
    super.keyframes, {
    super.curve,
  }) : super.keyframes();

  @internal
  const IconThemeEffect.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
  }) : super.internal();

  @override
  Animatable<IconThemeData> buildSinglePhaseAnimtable(
    IconThemeData from,
    IconThemeData to,
  ) {
    return _IconThemeDataTween(begin: from, end: to);
  }

  @override
  Widget apply(
    BuildContext context,
    Animation<IconThemeData> animation,
    Widget child,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return IconTheme(data: animation.value, child: child!);
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

class TextStyleActor extends SingleEffectBase<TextStyle> {
  const TextStyleActor({
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

  const TextStyleActor.keyframes({
    super.key,
    required super.frames,
    required super.child,
    super.curve,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : super.keyframes();

  @override
  Effect get effect => TextStyleEffect.internal(
    from: from,
    to: to,
    keyframes: frames,
  );
}

class IconThemeActor extends SingleEffectBase<IconThemeData> {
  const IconThemeActor({
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

  const IconThemeActor.keyframes({
    super.key,
    required super.frames,
    required super.child,
    super.curve,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : super.keyframes();

  @override
  Effect get effect => IconThemeEffect.internal(
    from: from,
    to: to,
    keyframes: frames,
  );
}
