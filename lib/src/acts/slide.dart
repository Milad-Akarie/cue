part of 'base/act.dart';

abstract class SlideAct extends Act {
  const factory SlideAct({
    Offset from,
    Offset to,
    CueMotion? motion,
    ReverseBehavior<Offset> reverse,
    Duration delay,
  }) = _SlideEffect;

  const factory SlideAct.up({
    CueMotion? motion,
    ReverseBehavior<Offset> reverse,
    Duration delay,
  }) = _SlideEffect.fromBottom;

  const factory SlideAct.down({
    CueMotion? motion,
    ReverseBehavior<Offset> reverse,
    Duration delay,
  }) = _SlideEffect.fromTop;

  const factory SlideAct.fromLeading({
    CueMotion? motion,
    ReverseBehavior<Offset> reverse,
    Duration delay,
  }) = _SlideEffect.fromLeading;

  const factory SlideAct.fromTrailing({
    CueMotion? motion,
    ReverseBehavior<Offset> reverse,
    Duration delay,
  }) = _SlideEffect.fromTrailing;

  const factory SlideAct.keyframed({
    required Keyframes<Offset> frames,
    KFReverseBehavior<Offset> reverse,
    Duration delay,
  }) = _SlideEffect.keyframed;

  const factory SlideAct.y({
    double from,
    double to,
    CueMotion? motion,
    ReverseBehavior<double> reverse,
    Duration delay,
  }) = _AxisSlideEffect.tweenY;

  const factory SlideAct.keyframedY({
    required Keyframes<double> frames,
    KFReverseBehavior<double> reverse,
    Duration delay,
  }) = _AxisSlideEffect.keyframedY;

  const factory SlideAct.fromX({
    double from,
    double to,
    CueMotion? motion,
    ReverseBehavior<double> reverse,
    Duration delay,
  }) = _AxisSlideEffect.tweenX;

  const factory SlideAct.keyframedX({
    required Keyframes<double> frames,
    KFReverseBehavior<double> reverse,
    Duration delay,
  }) = _AxisSlideEffect.keyframedX;
}

class _SlideEffect extends TweenAct<Offset> implements SlideAct {
  @override
  final ActKey key = const ActKey('Slide');

  const _SlideEffect({
    super.from = Offset.zero,
    super.to = Offset.zero,
    super.motion,
    super.reverse,
    super.delay,
  }) : super.tween();

  const _SlideEffect.fromBottom({
    super.motion,
    super.reverse,
    super.delay,
  }) : super.tween(
         from: const Offset(0, 1),
         to: Offset.zero,
       );

  const _SlideEffect.fromTop({
    super.motion,
    super.reverse,
    super.delay,
  }) : super.tween(
         from: const Offset(0, -1),
         to: Offset.zero,
       );

  const _SlideEffect.fromLeading({
    super.motion,
    super.reverse,
    super.delay,
  }) : super.tween(
         from: const Offset(-1, 0),
         to: Offset.zero,
       );

  const _SlideEffect.fromTrailing({
    super.motion,
    super.reverse,
    super.delay,
  }) : super.tween(
         from: const Offset(1, 0),
         to: Offset.zero,
       );

  const _SlideEffect.keyframed({
    required super.frames,
    super.reverse,
    super.delay,
  }) : super.keyframed(from: Offset.zero);

  @override
  Widget apply(BuildContext context, Animation<Offset> animation, Widget child) {
    return SlideTransition(position: animation, child: child);
  }
}

class _AxisSlideEffect extends TweenActBase<double, Offset> implements SlideAct {
  @override
  final ActKey key = const ActKey('Slide');

  final Axis _axis;

  const _AxisSlideEffect.tweenX({
    super.from = 0,
    super.to = 0,
    super.motion,
    super.reverse,
    super.delay,
  }) : _axis = Axis.horizontal,
       super.tween();

  const _AxisSlideEffect.tweenY({
    super.from = 0,
    super.to = 0,
    super.motion,
    super.reverse,
    super.delay,
  }) : _axis = Axis.vertical,
       super.tween();

  const _AxisSlideEffect.keyframedX({
    required super.frames,
    super.reverse,
    super.delay,
  }) : _axis = Axis.horizontal,
       super.keyframed(from: 0);

  const _AxisSlideEffect.keyframedY({
    required super.frames,
    super.reverse,
    super.delay,
  }) : _axis = Axis.vertical,
       super.keyframed(from: 0);

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _AxisSlideEffect && super == other && other._axis == _axis;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, _axis);
}
