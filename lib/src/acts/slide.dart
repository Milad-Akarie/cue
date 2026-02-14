part of 'act.dart';

abstract class SlideAct extends Act {
  const factory SlideAct({
    Offset from,
    Offset to,
    Curve? curve,
    Timing? timing,
  }) = _SlideAct;

  const factory SlideAct.keyframes(
    List<Keyframe<Offset>> keyframes, {
    Curve? curve,
  }) = _SlideAct.keyframes;

  const factory SlideAct.y({
    double from,
    double to,
    Curve? curve,
    Timing? timing,
  }) = _AxisSlideAct.y;

  const factory SlideAct.yKeyframes(
    List<Keyframe<double>> keyframes, {
    Curve? curve,
  }) = _AxisSlideAct.yKeyframes;

  const factory SlideAct.x({
    double from,
    double to,
    Curve? curve,
    Timing? timing,
  }) = _AxisSlideAct.x;

  const factory SlideAct.xKeyframes(
    List<Keyframe<double>> keyframes, {
    Curve? curve,
  }) = _AxisSlideAct.xKeyframes;
}

class _SlideAct extends TweenAct<Offset> implements SlideAct {
  const _SlideAct({
    super.from = Offset.zero,
    super.to = Offset.zero,
    super.curve,
    super.timing,
  });

  const _SlideAct.keyframes(
    super.keyframes, {
    super.curve,
  }) : super.keyframes();

  @override
  Widget apply(AnimationContext context, Widget child) {
    return SlideTransition(
      position: build(context),
      child: child,
    );
  }
}

class _AxisSlideAct extends TweenActBase<double, Offset> implements SlideAct {
  final Axis _axis;

  const _AxisSlideAct.y({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
  }) : _axis = Axis.vertical;

  const _AxisSlideAct.yKeyframes(
    super.keyframes, {
    super.curve,
  }) : _axis = Axis.vertical,
       super.keyframes();

  const _AxisSlideAct.x({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
  }) : _axis = Axis.horizontal;

  const _AxisSlideAct.xKeyframes(
    super.keyframes, {
    super.curve,
  }) : _axis = Axis.horizontal,
       super.keyframes();

  @override
  Offset transform(_, double value) {
    switch (_axis) {
      case Axis.horizontal:
        return Offset(value, 0);
      case Axis.vertical:
        return Offset(0, value);
    }
  }

  @override
  Widget apply(AnimationContext context, Widget child) {
    return SlideTransition(
      position: build(context),
      child: child,
    );
  }
}
