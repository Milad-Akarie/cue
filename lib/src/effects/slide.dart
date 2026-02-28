part of 'base/effect.dart';

abstract class SlideEffect extends Effect {
  const factory SlideEffect({
    required Offset from,
    required Offset to,
    Curve? curve,
    Timing? timing,
  }) = _SlideEffect;

  const factory SlideEffect.from(
    Offset from, {
    Offset to,
    Curve? curve,
    Timing? timing,
  }) = _SlideEffect.from;

  const factory SlideEffect.keyframes(
    List<Keyframe<Offset>> keyframes, {
    Curve? curve,
  }) = _SlideEffect.keyframes;

  const factory SlideEffect.fromY(
    double from, {
    double to,
    Curve? curve,
    Timing? timing,
  }) = _AxisSlideEffect.fromY;

  const factory SlideEffect.yKeyframes(
    List<Keyframe<double>> keyframes, {
    Curve? curve,
  }) = _AxisSlideEffect.yKeyframes;

  const factory SlideEffect.fromX(
    double from, {
    double to,
    Curve? curve,
    Timing? timing,
  }) = _AxisSlideEffect.fromX;

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

  const _SlideEffect.from(
    Offset from, {
    super.to = Offset.zero,
    super.curve,
    super.timing,
  }) : super(from: from);

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

  const _AxisSlideEffect.yKeyframes(
    super.keyframes, {
    super.curve,
  }) : _axis = Axis.vertical,
       super.keyframes();

  const _AxisSlideEffect.fromX(
    double from, {
    super.to = 0,
    super.curve,
    super.timing,
  }) : _axis = Axis.horizontal,
       super(from: from);

  const _AxisSlideEffect.fromY(
    double from, {
    super.to = 0,
    super.curve,
    super.timing,
  }) : _axis = Axis.vertical,
       super(from: from);

  const _AxisSlideEffect.xKeyframes(
    super.keyframes, {
    super.curve,
  }) : _axis = Axis.horizontal,
       super.keyframes();

  const _AxisSlideEffect.internal({
    required super.from,
    required super.to,
    required super.keyframes,
    required Axis axis,
  }) : _axis = axis,
       super.internal();

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
