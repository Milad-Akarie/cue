part of 'base/effect.dart';

abstract class SlideEffect extends Effect {
  const factory SlideEffect({
    required Offset from,
    required Offset to,
    Curve? curve,
    Timing? timing,
  }) = _SlideEffect;

  const factory SlideEffect.tween({
    required Offset from,
    Offset to,
    Curve? curve,
    Timing? timing,
  }) = _SlideEffect.tween;

  const factory SlideEffect.fromBottom({
    Curve? curve,
    Timing? timing,
  }) = _SlideEffect.fromBottom;

  const factory SlideEffect.fromTop({
    Curve? curve,
    Timing? timing,
  }) = _SlideEffect.fromTop;

  const factory SlideEffect.fromLeading({
    Curve? curve,
    Timing? timing,
  }) = _SlideEffect.fromLeading;

  const factory SlideEffect.fromTrailing({
    Curve? curve,
    Timing? timing,
  }) = _SlideEffect.fromTrailing;

  const factory SlideEffect.keyframes(
    List<Keyframe<Offset>> keyframes, {
    Curve? curve,
  }) = _SlideEffect.keyframes;

  const factory SlideEffect.tweenY({
    required double from,
    double to,
    Curve? curve,
    Timing? timing,
  }) = _AxisSlideEffect.tweenY;

  const factory SlideEffect.keyframesY(
    List<Keyframe<double>> keyframes, {
    Curve? curve,
  }) = _AxisSlideEffect.keyframesY;

  const factory SlideEffect.tweenX({
    required double from,
    double to,
    Curve? curve,
    Timing? timing,
  }) = _AxisSlideEffect.tweenX;

  const factory SlideEffect.keyframesX(
    List<Keyframe<double>> keyframes, {
    Curve? curve,
  }) = _AxisSlideEffect.keyframesX;
}

class _SlideEffect extends TweenEffect<Offset> implements SlideEffect {
  const _SlideEffect({
    super.from = Offset.zero,
    super.to = Offset.zero,
    super.curve,
    super.timing,
  });

  const _SlideEffect.tween({
    required super.from,
    super.to = Offset.zero,
    super.curve,
    super.timing,
  });

  const _SlideEffect.fromBottom({
    super.curve,
    super.timing,
  }) : super(
         from: const Offset(0, 1),
         to: Offset.zero,
       );

  const _SlideEffect.fromTop({
    super.curve,
    super.timing,
  }) : super(
         from: const Offset(0, -1),
         to: Offset.zero,
       );

  const _SlideEffect.fromLeading({
    super.curve,
    super.timing,
  }) : super(
         from: const Offset(-1, 0),
         to: Offset.zero,
       );

  const _SlideEffect.fromTrailing({
    super.curve,
    super.timing,
  }) : super(
         from: const Offset(1, 0),
         to: Offset.zero,
       );

  const _SlideEffect.keyframes(
    super.keyframes, {
    super.curve,
  }) : super.keyframes();

  const _SlideEffect.internal({
    super.from,
    super.to,
    super.keyframes,
  }) : super.internal();

  @override
  Widget apply(BuildContext context, Animation<Offset> animation, Widget child) {
    return SlideTransition(position: animation, child: child);
  }
}

class _AxisSlideEffect extends TweenEffectBase<double, Offset> implements SlideEffect {
  final Axis _axis;

  const _AxisSlideEffect.tweenX({
    required super.from,
    super.to = 0,
    super.curve,
    super.timing,
  }) : _axis = Axis.horizontal;

  const _AxisSlideEffect.tweenY({
    required super.from,
    super.to = 0,
    super.curve,
    super.timing,
  }) : _axis = Axis.vertical;

  const _AxisSlideEffect.keyframesX(
    super.keyframes, {
    super.curve,
  }) : _axis = Axis.horizontal,
       super.keyframes();

  const _AxisSlideEffect.keyframesY(
    super.keyframes, {
    super.curve,
  }) : _axis = Axis.vertical,
       super.keyframes();

  const _AxisSlideEffect.internal({
    required super.from,
    required super.to,
    required super.keyframes,
    required Axis axis,
  }) : _axis = axis,
       super.internal();

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

class SlideActor extends SingleEffectBase<Offset> {
  final double? _axisFrom;
  final double? _axisTo;
  final Axis? _axis;
  final List<Keyframe<double>>? _axisKeyframes;

  const SlideActor({
    super.key,
    required super.from,
    super.to = Offset.zero,
    required super.child,
    super.curve,
    super.reverseCurve,
    super.reverseTiming,
    super.timing,
    super.role,
  }) : _axis = null,
       _axisFrom = null,
       _axisTo = null,
       _axisKeyframes = null;

  const SlideActor.keyframes({
    super.key,
    required super.frames,
    required super.child,
    super.curve,
    super.reverseCurve,
    super.reverseTiming,
    super.role,
  }) : _axis = null,
       _axisFrom = null,
       _axisTo = null,
       _axisKeyframes = null,
       super.keyframes();

  const SlideActor.x({
    super.key,
    required double from,
    double to = 0,
    required super.child,
    super.role,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
  }) : _axis = Axis.horizontal,
       _axisFrom = from,
       _axisTo = to,
       _axisKeyframes = null,
       super(from: Offset.zero, to: Offset.zero);

  const SlideActor.xKeyframes({
    super.key,
    required List<Keyframe<double>> frames,
    required super.child,
    super.role,
    super.curve,
    super.reverseCurve,
    super.reverseTiming,
  }) : _axis = Axis.horizontal,
       _axisFrom = null,
       _axisTo = null,
       _axisKeyframes = frames,
       super.keyframes(frames: const []);

  const SlideActor.y({
    super.key,
    required double from,
    double to = 0,
    required super.child,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
    super.role,
  }) : _axisFrom = from,
       _axisTo = to,
       _axisKeyframes = null,
       _axis = Axis.vertical,
       super(from: Offset.zero, to: Offset.zero);

  const SlideActor.yKeyframes({
    super.key,
    required List<Keyframe<double>> frames,
    required super.child,
    super.curve,
    super.reverseCurve,
    super.reverseTiming,
    super.role,
  }) : _axisFrom = null,
       _axisTo = null,
       _axisKeyframes = frames,
       _axis = Axis.vertical,
       super.keyframes(frames: const []);

  @override
  Effect get effect {
    if (_axis != null) {
      return _AxisSlideEffect.internal(
        from: _axisFrom,
        to: _axisTo,
        keyframes: _axisKeyframes,
        axis: _axis,
      );
    }
    return _SlideEffect.internal(
      from: from,
      to: to,
      keyframes: frames,
    );
  }
}
