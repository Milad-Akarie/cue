part of 'base/act.dart';

abstract class SlideAct extends Act {
  const factory SlideAct({
    Offset from,
    Offset to,
    CueMotion? motion,
    ReverseBehavior<Offset> reverse,
  }) = _SlideEffect;

  const factory SlideAct.up({
    CueMotion? motion,
    ReverseBehavior<Offset> reverse,
  }) = _SlideEffect.fromBottom;

  const factory SlideAct.down({
    CueMotion? motion,
    ReverseBehavior<Offset> reverse,
  }) = _SlideEffect.fromTop;

  const factory SlideAct.fromLeading({
    CueMotion? motion,
    ReverseBehavior<Offset> reverse,
  }) = _SlideEffect.fromLeading;

  const factory SlideAct.fromTrailing({
    CueMotion? motion,
    ReverseBehavior<Offset> reverse,
  }) = _SlideEffect.fromTrailing;

  const factory SlideAct.keyframes(
    List<Keyframe<Offset>> keyframes, {
   CueMotion? motion,
  }) = _SlideEffect.keyframes;

  const factory SlideAct.fromY({
    double from,
    double to,
    CueMotion? motion,
    ReverseBehavior<double> reverse,
  }) = _AxisSlideEffect.tweenY;

  const factory SlideAct.keyframesY(
    List<Keyframe<double>> keyframes, {
    CueMotion? motion,
    ReverseBehavior<double> reverse,
  }) = _AxisSlideEffect.keyframesY;

  const factory SlideAct.fromX({
    double from,
    double to,
   CueMotion? motion,
    ReverseBehavior<double> reverse,
  }) = _AxisSlideEffect.tweenX;

  const factory SlideAct.keyframesX(
    List<Keyframe<double>> keyframes, {
    CueMotion? motion,
    ReverseBehavior<double> reverse,
  }) = _AxisSlideEffect.keyframesX;
}

class _SlideEffect extends TweenAct<Offset> implements SlideAct {
  const _SlideEffect({
    super.from = Offset.zero,
    super.to = Offset.zero,
    super.motion,
    super.reverse,
  });

  const _SlideEffect.fromBottom({
    super.motion,
    super.reverse,
  }) : super(
         from: const Offset(0, 1),
         to: Offset.zero,
       );

  const _SlideEffect.fromTop({
    super.motion,
    super.reverse,
  }) : super(
         from: const Offset(0, -1),
         to: Offset.zero,
       );

  const _SlideEffect.fromLeading({
    super.motion,
    super.reverse,
  }) : super(
         from: const Offset(-1, 0),
         to: Offset.zero,
       );

  const _SlideEffect.fromTrailing({
    super.motion,
    super.reverse,
  }) : super(
         from: const Offset(1, 0),
         to: Offset.zero,
       );

  const _SlideEffect.keyframes(
    super.keyframes, {
    super.motion,
    super.reverse,
  }) : super.keyframes();

  @override
  Widget apply(BuildContext context, Animation<Offset> animation, Widget child) {
    return SlideTransition(position: animation, child: child);
  }
}

class _AxisSlideEffect extends TweenActBase<double, Offset> implements SlideAct {
  final Axis _axis;

  const _AxisSlideEffect.tweenX({
    super.from = 0,
    super.to = 0,
    super.motion,
    super.reverse,
  }) : _axis = Axis.horizontal;

  const _AxisSlideEffect.tweenY({
    super.from = 0,
    super.to = 0,
    super.motion,
    super.reverse,
  }) : _axis = Axis.vertical;

  const _AxisSlideEffect.keyframesX(
    super.keyframes, {
    super.motion,
    super.reverse,
  }) : _axis = Axis.horizontal,
       super.keyframes();

  const _AxisSlideEffect.keyframesY(
    super.keyframes, {
    super.motion,
    super.reverse,
  }) : _axis = Axis.vertical,
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
  Widget apply(BuildContext context, Animation<Offset> animation, Widget child) {
    return SlideTransition(position: animation, child: child);
  }
}
