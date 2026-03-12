part of 'base/act.dart';

abstract class TranslateAct extends Act {
  const factory TranslateAct({
    required Offset from,
    Offset to,
    CueMotion? motion,
    ReverseBehavior<Offset> reverse,
  }) = _TranslateOffset;

  const factory TranslateAct.keyframes(
    List<Keyframe<Offset>> keyframes, {
     CueMotion? motion,
    ReverseBehavior<Offset> reverse,
  }) = _TranslateOffset.keyframes;

  const factory TranslateAct.fromX({
    double from,
    double to,
     CueMotion? motion,
    ReverseBehavior<double> reverse,
  }) = _AxisTranslate.horizontal;

  const factory TranslateAct.keyframesX(
    List<Keyframe<double>> keyframes, {
     CueMotion? motion,
    ReverseBehavior<double> reverse,
  }) = _AxisTranslate.keyframesX;

  const factory TranslateAct.y({
    double from,
    double to,
    CueMotion? motion,
    ReverseBehavior<double> reverse,
  }) = _AxisTranslate.vertical;

  const factory TranslateAct.keyframesY(
    List<Keyframe<double>> keyframes, {
     CueMotion? motion,
    ReverseBehavior<double> reverse,
  }) = _AxisTranslate.keyframesY;

  const factory TranslateAct.fromGlobal({
    required Offset offset,
    Offset toLocal,
    CueMotion? motion,
  }) = _TranslateFromGlobalEffect.offset;

  const factory TranslateAct.fromGlobalRect(
    Rect rect, {
    AlignmentGeometry alignment,
    Offset toLocal,
     CueMotion? motion,
  }) = _TranslateFromGlobalEffect.fromRect;

  const factory TranslateAct.fromGlobalKey(
    GlobalKey key, {
    AlignmentGeometry alignment,
    Offset toLocal,
     CueMotion? motion,
  }) = _TranslateFromGlobalEffect.fromKey;
}

class _TranslateOffset extends TweenAct<Offset> implements TranslateAct {
  const _TranslateOffset({
    required super.from,
    super.to = Offset.zero,
    super.motion,
    super.reverse,
  });

  const _TranslateOffset.keyframes(
    super.keyframes, {
    super.motion,
    super.reverse,
  }) : super.keyframes();

  @override
  Widget apply(BuildContext context, Animation<Offset> animation, Widget child) {
    return TranslateTransition(
      offset: animation,
      transformHitTests: true,
      child: child,
    );
  }
}

class _AxisTranslate extends TweenActBase<double, Offset> implements TranslateAct {
  final Axis _axis;

  const _AxisTranslate.vertical({
    super.from = 0,
    super.to = 0,
    super.motion,
    super.reverse,
  }) : _axis = Axis.vertical;

  const _AxisTranslate.horizontal({
    super.from = 0,
    super.to = 0,
    super.motion,
    super.reverse,
  }) : _axis = Axis.horizontal;

  const _AxisTranslate.keyframesY(
    super.keyframes, {
    super.motion,
    super.reverse,
  }) : _axis = Axis.vertical,
       super.keyframes();

  const _AxisTranslate.keyframesX(
    super.keyframes, {
    super.motion,
    super.reverse,
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

class _TranslateFromGlobalEffect extends TweenAct<double> implements TranslateAct {
  final Offset? offset;
  final Rect? rect;
  final AlignmentGeometry? alignment;
  final GlobalKey? globalKey;
  final Offset toLocal;

  const _TranslateFromGlobalEffect.offset({
    required Offset this.offset,
    this.toLocal = Offset.zero,
    super.motion,
  }) : rect = null,
       alignment = null,
       globalKey = null,
       super(from: 0, to: 1);

  const _TranslateFromGlobalEffect.fromRect(
    this.rect, {
    this.toLocal = Offset.zero,
    this.alignment = Alignment.center,
    super.motion,
  }) : offset = null,
       globalKey = null,
       super(from: 0, to: 1);

  const _TranslateFromGlobalEffect.fromKey(
    GlobalKey this.globalKey, {
    this.toLocal = Offset.zero,
    this.alignment = Alignment.center,
    super.motion,
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
      final alignment = widget.alignment!.resolve(Directionality.maybeOf(context));
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
    final offsetTween = _deltaTween ?? Tween(begin: Offset.zero, end: widget.toLocal);
    return Visibility(
      key: _key,
      visible: _deltaTween != null && _measured,
      maintainState: true,
      maintainAnimation: true,
      maintainSize: true,
      child: TranslateTransition(
        offset: offsetTween.animate(widget.animation),
        child: widget.child,
      ),
    );
  }
}
