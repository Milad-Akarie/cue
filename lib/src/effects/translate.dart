part of 'base/effect.dart';

abstract class TranslateEffect extends Effect {
  const factory TranslateEffect({
    required Offset from,
    Offset to,
    Curve? curve,
    Timing? timing,
  }) = _TranslateOffset;

  const factory TranslateEffect.tween({
    required Offset from,
    required Offset to,
    Curve? curve,
    Timing? timing,
  }) = _TranslateOffset;

  const factory TranslateEffect.keyframes(
    List<Keyframe<Offset>> keyframes, {
    Curve? curve,
  }) = _TranslateOffset.keyframes;

  const factory TranslateEffect.tweenX({
    double from,
    double to,
    Curve? curve,
    Timing? timing,
  }) = _AxisTranslate.horizontal;

  const factory TranslateEffect.keyframesX(
    List<Keyframe<double>> keyframes, {
    Curve? curve,
  }) = _AxisTranslate.keyframesX;

  const factory TranslateEffect.tweenY({
    double from,
    double to,
    Curve? curve,
    Timing? timing,
  }) = _AxisTranslate.vertical;

  const factory TranslateEffect.keyframesY(
    List<Keyframe<double>> keyframes, {
    Curve? curve,
  }) = _AxisTranslate.keyframesY;

  const factory TranslateEffect.fromGlobal({
    required Offset offset,
    Offset toLocal,
    Curve? curve,
    Timing? timing,
  }) = _TranslateFromGlobalEffect.offset;

  const factory TranslateEffect.fromGlobalRect(
    Rect rect, {
    AlignmentGeometry alignment,
    Offset toLocal,
    Curve? curve,
    Timing? timing,
  }) = _TranslateFromGlobalEffect.fromRect;

  const factory TranslateEffect.fromGlobalKey(
    GlobalKey key, {
    AlignmentGeometry alignment,
    Offset toLocal,
    Curve? curve,
    Timing? timing,
  }) = _TranslateFromGlobalEffect.fromKey;
}

class _TranslateOffset extends TweenEffect<Offset> implements TranslateEffect {
  const _TranslateOffset({
    required super.from,
    super.to = Offset.zero,
    super.curve,
    super.timing,
  });

  const _TranslateOffset.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  const _TranslateOffset.internal({
    super.from,
    super.to,
    super.keyframes,
  }) : super.internal();

  @override
  Widget apply(BuildContext context, Animation<Offset> animation, Widget child) {
    return TranslateTransition(
      offset: animation,
      transformHitTests: true,
      child: child,
    );
  }
}

class _AxisTranslate extends TweenEffectBase<double, Offset> implements TranslateEffect {
  final Axis _axis;

  const _AxisTranslate.vertical({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
  }) : _axis = Axis.vertical;

  const _AxisTranslate.horizontal({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
  }) : _axis = Axis.horizontal;

  const _AxisTranslate.internal({
    super.from,
    super.to,
    super.keyframes,
    required Axis axis,
  }) : _axis = axis,
       super.internal();

  const _AxisTranslate.keyframesY(super.keyframes, {super.curve}) : _axis = Axis.vertical, super.keyframes();

  const _AxisTranslate.keyframesX(super.keyframes, {super.curve}) : _axis = Axis.horizontal, super.keyframes();

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
    return TranslateTransition(
      offset: animation,
      transformHitTests: true,
      child: child,
    );
  }
}

class TranslateTransition extends AnimatedWidget {
  final Widget child;
  final Animation<Offset> offset;
  final bool transformHitTests;

  const TranslateTransition({
    super.key,
    required this.child,
    required this.offset,
    this.transformHitTests = true,
  }) : super(listenable: offset);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      transformHitTests: transformHitTests,
      offset: offset.value,
      child: child,
    );
  }
}

class _TranslateFromGlobalEffect extends TweenEffect<double> implements TranslateEffect {
  final Offset? offset;
  final Rect? rect;
  final AlignmentGeometry? alignment;
  final GlobalKey? globalKey;
  final Offset toLocal;

  const _TranslateFromGlobalEffect.internal({
    this.offset,
    this.rect,
    this.alignment,
    this.globalKey,
    this.toLocal = Offset.zero,
  }) : super.internal();

  const _TranslateFromGlobalEffect.offset({
    required Offset this.offset,
    this.toLocal = Offset.zero,
    super.curve,
    super.timing,
  }) : rect = null,
       alignment = null,
       globalKey = null,
       super(from: 0, to: 1);

  const _TranslateFromGlobalEffect.fromRect(
    this.rect, {
    this.toLocal = Offset.zero,
    this.alignment = Alignment.center,
    super.curve,
    super.timing,
  }) : offset = null,
       globalKey = null,
       super(from: 0, to: 1);

  const _TranslateFromGlobalEffect.fromKey(
    GlobalKey this.globalKey, {
    this.toLocal = Offset.zero,
    this.alignment = Alignment.center,
    super.curve,
    super.timing,
  }) : offset = null,
       rect = null,
       super(from: 0, to: 1);

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    return _TranslateFromGlobalTranstion(
      animation: animation,
      globalOffset: offset,
      globalRect: rect,
      globalKey: globalKey,
      alignment: alignment,
      toLocal: toLocal,
      child: child,
    );
  }
}

abstract class TranslateActor extends Widget {
  const factory TranslateActor({
    Key? key,
    Offset from,
    Offset to,
    required Widget child,
    Curve? curve,
    Timing? timing,
    Curve? reverseCurve,
    Timing? reverseTiming,
    ActorRole role,
  }) = _TranslateActor;

  const factory TranslateActor.keyframes({
    Key? key,
    required List<Keyframe<Offset>> frames,
    required Widget child,
    Curve? curve,
    Curve? reverseCurve,
    ActorRole role,
  }) = _TranslateActor.keyframes;

  const factory TranslateActor.x({
    Key? key,
    double from,
    double to,
    required Widget child,
    Curve? curve,
    Timing? timing,
    Curve? reverseCurve,
    Timing? reverseTiming,
    ActorRole role,
  }) = _TranslateActor.x;

  const factory TranslateActor.xKeyframes({
    Key? key,
    required List<Keyframe<double>> frames,
    required Widget child,
    Curve? curve,
    Curve? reverseCurve,
    ActorRole role,
  }) = _TranslateActor.xKeyframes;

  const factory TranslateActor.y({
    Key? key,
    double from,
    double to,
    required Widget child,
    Curve? curve,
    Timing? timing,
    Curve? reverseCurve,
    Timing? reverseTiming,
    ActorRole role,
  }) = _TranslateActor.y;

  const factory TranslateActor.yKeyframes({
    Key? key,
    required List<Keyframe<double>> frames,
    required Widget child,
    Curve? curve,
    Curve? reverseCurve,
    ActorRole role,
  }) = _TranslateActor.yKeyframes;

  const factory TranslateActor.fromGlobal({
    required Offset offset,
    Key? key,
    Offset toLocal,
    required Widget child,
  }) = _TranslateFromGlobalActor.offset;

  const factory TranslateActor.fromGlobalRect({
    required Rect rect,
    Key? key,
    AlignmentGeometry alignment,
    Offset toLocal,
    required Widget child,
  }) = _TranslateFromGlobalActor.fromRect;

  const factory TranslateActor.fromGlobalKey({
    required GlobalKey globalKey,
    Key? key,
    AlignmentGeometry alignment,
    Offset toLocal,
    required Widget child,
  }) = _TranslateFromGlobalActor.fromKey;
}

class _TranslateActor extends SingleEffectBase<Offset> implements TranslateActor {
  final double? _axisFrom;
  final double? _axisTo;
  final List<Keyframe<double>>? _axisKeyframes;
  final Axis? _axis;

  const _TranslateActor({
    super.key,
    super.from = Offset.zero,
    super.to = Offset.zero,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : _axis = null,
       _axisFrom = null,
       _axisTo = null,
       _axisKeyframes = null,
       super();

  const _TranslateActor.keyframes({
    super.key,
    required super.frames,
    required super.child,
    super.curve,
    super.role,
    super.reverseCurve,
  }) : _axis = null,
       _axisFrom = null,
       _axisTo = null,
       _axisKeyframes = null,
       super.keyframes();

  const _TranslateActor.x({
    super.key,
    double from = 0,
    double to = 0,
    required super.child,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
    super.role,
  }) : _axis = Axis.horizontal,
       _axisFrom = from,
       _axisTo = to,
       _axisKeyframes = null,
       super(from: Offset.zero, to: Offset.zero);

  const _TranslateActor.xKeyframes({
    super.key,
    required List<Keyframe<double>> frames,
    required super.child,
    super.curve,
    super.reverseCurve,
    super.role,
  }) : _axis = Axis.horizontal,
       _axisFrom = null,
       _axisTo = null,
       _axisKeyframes = frames,
       super.keyframes(frames: const []);

  const _TranslateActor.y({
    super.key,
    double from = 0,
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

  const _TranslateActor.yKeyframes({
    super.key,
    required List<Keyframe<double>> frames,
    required super.child,
    super.curve,
    super.reverseCurve,
    super.role,
  }) : _axis = Axis.vertical,
       _axisFrom = null,
       _axisTo = null,
       _axisKeyframes = frames,
       super.keyframes(frames: const []);

  @override
  Effect get effect => switch (_axis) {
    .horizontal => _AxisTranslate.internal(
      from: _axisFrom!,
      to: _axisTo!,
      axis: Axis.horizontal,
      keyframes: _axisKeyframes,
    ),
    .vertical => _AxisTranslate.internal(
      from: _axisFrom!,
      to: _axisTo!,
      axis: Axis.vertical,
      keyframes: _axisKeyframes,
    ),
    _ => _TranslateOffset.internal(from: from, to: to, keyframes: frames),
  };
}

class _TranslateFromGlobalActor extends SingleEffectBase<Offset> implements TranslateActor {
  final Offset? _globalOffset;
  final Rect? _globalRect;
  final AlignmentGeometry? _alignment;
  final Offset toLocal;
  final GlobalKey? _globalKey;

  const _TranslateFromGlobalActor.offset({
    required Offset offset,
    super.key,
    this.toLocal = Offset.zero,
    required super.child,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
    super.role,
  }) : _globalOffset = offset,
       _globalRect = null,
       _alignment = null,
       _globalKey = null,
       super(from: Offset.zero, to: Offset.zero);

  const _TranslateFromGlobalActor.fromRect({
    required Rect rect,
    Key? key,
    AlignmentGeometry alignment = Alignment.center,
    this.toLocal = Offset.zero,
    required super.child,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
    super.role,
  }) : _globalOffset = null,
       _globalRect = rect,
       _alignment = alignment,
       _globalKey = null,
       super(from: Offset.zero, to: Offset.zero);

  const _TranslateFromGlobalActor.fromKey({
    required GlobalKey globalKey,
    Key? key,
    AlignmentGeometry alignment = Alignment.center,
    this.toLocal = Offset.zero,
    required super.child,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
    super.role,
  }) : _globalOffset = null,
       _globalRect = null,
       _alignment = alignment,
       _globalKey = globalKey,
       super(from: Offset.zero, to: Offset.zero);

  @override
  Effect get effect => _TranslateFromGlobalEffect.internal(
    offset: _globalOffset,
    rect: _globalRect,
    alignment: _alignment,
    globalKey: _globalKey,
    toLocal: toLocal,
  );
}

class _TranslateFromGlobalTranstion extends StatefulWidget {
  final Offset? globalOffset;
  final Rect? globalRect;
  final AlignmentGeometry? alignment;
  final Offset toLocal;
  final GlobalKey? globalKey;
  final Widget child;
  final Animation<double> animation;

  const _TranslateFromGlobalTranstion({
    this.globalOffset,
    this.globalRect,
    this.alignment,
    this.globalKey,
    required this.animation,
    this.toLocal = Offset.zero,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _TranslateFromGlobalTranstionState();
}

class _TranslateFromGlobalTranstionState extends State<_TranslateFromGlobalTranstion> {
  final _key = GlobalKey();
  Tween<Offset>? _deltaTween;
  bool _measured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(_TranslateFromGlobalTranstion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.globalOffset != widget.globalOffset || oldWidget.globalRect != widget.globalRect) {
      _measured = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    }
  }

  void _measure() {
    if (!mounted) return;
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;
    final targetGlobal = renderBox.localToGlobal(Offset.zero);

    if (widget.globalOffset case final global?) {
      final newDelta = global - targetGlobal;
      if (_deltaTween?.begin != newDelta) {
        setState(() {
          _deltaTween = Tween(begin: newDelta, end: widget.toLocal);
          _measured = true;
        });
      }
    } else {
      final rect = widget.globalRect ?? _rectFor(widget.globalKey!);
      final alignment = widget.alignment!.resolve(Directionality.of(context));
      final targetRect = alignment.inscribe(renderBox.size, rect);
      final newDelta = targetRect.topLeft - targetGlobal;
      if (_deltaTween?.begin != newDelta) {
        setState(() {
          _deltaTween = Tween(begin: newDelta, end: widget.toLocal);
          _measured = true;
        });
      }
    }
  }

  Rect _rectFor(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      throw FlutterError(
        'Could not determine global rect for translation. Ensure the target widget has been rendered and has a size.',
      );
    }
    final targetGlobal = renderBox.localToGlobal(Offset.zero);
    return targetGlobal & renderBox.size;
  }

  @override
  Widget build(BuildContext context) {
    final animation = widget.animation;
    final offsetTween = _deltaTween ?? Tween(begin: Offset.zero, end: widget.toLocal);
    return Visibility(
      key: _key,
      visible: _deltaTween != null && _measured,
      maintainState: true,
      maintainAnimation: true,
      maintainSize: true,
      child: TranslateTransition(
        offset: offsetTween.animate(animation),
        child: widget.child,
      ),
    );
  }
}
