part of 'effect.dart';

abstract class SlideEffect extends Effect {
  const factory SlideEffect({
    Offset from,
    Offset to,
    Curve? curve,
    Timing? timing,
  }) = _SlideEffect;

  const factory SlideEffect.keyframes(
    List<Keyframe<Offset>> keyframes, {
    Curve? curve,
  }) = _SlideEffect.keyframes;

  const factory SlideEffect.y({
    double from,
    double to,
    Curve? curve,
    Timing? timing,
  }) = _AxisSlideEffect.y;

  const factory SlideEffect.yKeyframes(
    List<Keyframe<double>> keyframes, {
    Curve? curve,
  }) = _AxisSlideEffect.yKeyframes;

  const factory SlideEffect.x({
    double from,
    double to,
    Curve? curve,
    Timing? timing,
  }) = _AxisSlideEffect.x;

  const factory SlideEffect.xKeyframes(
    List<Keyframe<double>> keyframes, {
    Curve? curve,
  }) = _AxisSlideEffect.xKeyframes;
}

class _SlideEffect extends TweenEffect<Offset> implements SlideEffect {
  const _SlideEffect({
    super.from = Offset.zero,
    super.to = Offset.zero,
    super.curve,
    super.timing,
  });

  const _SlideEffect.keyframes(
    super.keyframes, {
    super.curve,
  }) : super.keyframes();

  @override
  Widget apply(
    BuildContext context,
    Animation<Offset> animation,
    Widget child,
  ) {
    return SlideTransition(
      position: animation,
      child: child,
    );
  }
}

class _AxisSlideEffect extends TweenEffectBase<double, Offset> implements SlideEffect {
  final Axis _axis;

  const _AxisSlideEffect.y({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
  }) : _axis = Axis.vertical;

  const _AxisSlideEffect.yKeyframes(
    super.keyframes, {
    super.curve,
  }) : _axis = Axis.vertical,
       super.keyframes();

  const _AxisSlideEffect.x({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
  }) : _axis = Axis.horizontal;

  const _AxisSlideEffect.xKeyframes(
    super.keyframes, {
    super.curve,
  }) : _axis = Axis.horizontal,
       super.keyframes();

  @override
  Offset transform(double value) {
    switch (_axis) {
      case Axis.horizontal:
        return Offset(value, 0);
      case Axis.vertical:
        return Offset(0, value);
    }
  }

  @override
  Widget apply(
    BuildContext context,
    Animation<Offset> animation,
    Widget child,
  ) {
    return SlideTransition(
      position: animation,
      child: child,
    );
  }
}
