part of 'act.dart';

abstract class TranslateAct extends Act {
  const factory TranslateAct({
    required Offset from,
    Offset to,
    Curve? curve,
    Timing? timing,
  }) = _TranslateOffset;

  const factory TranslateAct.keyframes(List<Keyframe<Offset>> keyframes, {Curve? curve}) = _TranslateOffset.keyframes;

  const factory TranslateAct.x({double from, double to, Curve? curve, Timing? timing}) = _AxisTranslate.horizontal;

  const factory TranslateAct.xKeyframes(List<Keyframe<double>> keyframes, {Curve? curve}) = _AxisTranslate.xKeyframes;

  const factory TranslateAct.y({double from, double to, Curve? curve, Timing? timing}) = _AxisTranslate.vertical;

  const factory TranslateAct.yKeyframes(List<Keyframe<double>> keyframes, {Curve? curve}) = _AxisTranslate.yKeyframes;

  const factory TranslateAct.fromGlobal({required Offset offset, Curve? curve, Timing? timing}) = _TranslateFromGlobal;
}

class _TranslateOffset extends TweenAct<Offset> implements TranslateAct {
  const _TranslateOffset({
    required super.from,
    super.to = Offset.zero,
    super.curve,
    super.timing,
  });

  const _TranslateOffset.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Widget apply(AnimationContext context, Widget child) {
    return _TranslateTransition(
      offset: build(context),
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
    super.curve,
    super.timing,
  }) : _axis = Axis.vertical;

  const _AxisTranslate.horizontal({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
  }) : _axis = Axis.horizontal;

  const _AxisTranslate.yKeyframes(super.keyframes, {super.curve}) : _axis = Axis.vertical, super.keyframes();

  const _AxisTranslate.xKeyframes(super.keyframes, {super.curve}) : _axis = Axis.horizontal, super.keyframes();

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
    return _TranslateTransition(
      offset: build(context),
      transformHitTests: true,
      child: child,
    );
  }
}

class _TranslateTransition extends AnimatedWidget {
  final Widget child;
  final Animation<Offset> offset;
  final bool transformHitTests;

  const _TranslateTransition({
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

class _TranslateFromGlobal extends TweenAct<double> implements TranslateAct {
  final Offset offset;

  const _TranslateFromGlobal({
    required this.offset,
    super.curve,
    super.timing,
  }) : super(from: 0, to: 1);

  @override
  Widget apply(AnimationContext context, Widget child) {
    return _TranslateFromGlobalTransition(
      animation: build(context),
      globalTopLeft: offset,
      child: child,
    );
  }
}

class _TranslateFromGlobalTransition extends StatefulWidget {
  final Animation<double> animation;
  final Offset globalTopLeft;
  final Widget child;

  const _TranslateFromGlobalTransition({
    required this.animation,
    required this.globalTopLeft,
    required this.child,
  });

  @override
  State<_TranslateFromGlobalTransition> createState() => _TranslateFromGlobalTransitionState();
}

class _TranslateFromGlobalTransitionState extends State<_TranslateFromGlobalTransition> {
  final _key = GlobalKey();
  Tween<Offset>? _deltaTween;
  bool _measured = false;

  @override
  void initState() {
    super.initState();
    widget.animation.addListener(_onAnimationUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void dispose() {
    widget.animation.removeListener(_onAnimationUpdate);
    super.dispose();
  }

  void _onAnimationUpdate() {
    if (_measured && mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(_TranslateFromGlobalTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animation != widget.animation) {
      oldWidget.animation.removeListener(_onAnimationUpdate);
      widget.animation.addListener(_onAnimationUpdate);
    }
    if (oldWidget.globalTopLeft != widget.globalTopLeft) {
      _measured = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    }
  }

  void _measure() {
    if (!mounted) return;

    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final targetGlobal = renderBox.localToGlobal(Offset.zero);
    final newDelta = widget.globalTopLeft - targetGlobal;

    if (_deltaTween?.begin != newDelta) {
      setState(() {
        _deltaTween = Tween(begin: newDelta, end: Offset.zero);
        _measured = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final offset = _deltaTween == null ? Offset.zero : widget.animation.drive(_deltaTween!).value;
    final isInvisible = _deltaTween == null;
    return Visibility(
      key: _key,
      visible: !isInvisible,
      maintainState: true,
      maintainAnimation: true,
      maintainSize: true,
      child: Transform.translate(
        offset: offset,
        child: widget.child,
      ),
    );
  }
}
