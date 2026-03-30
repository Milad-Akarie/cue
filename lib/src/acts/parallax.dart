part of 'base/act.dart';

class ParallaxAct extends DeferredTweenAct<Offset> {
  @override
  ActKey get key => const ActKey('Parallax');

  final double slide;
  final Axis axis;
  final ReverseBehavior<double> _reverse;

  const ParallaxAct({
    super.motion,
    super.delay,
    required this.slide,
    this.axis = Axis.horizontal,
    ReverseBehavior<double> reverse = const ReverseBehavior.mirror(),
  }) : _reverse = reverse;

  @override
  ActContext resolve(ActContext context) {
    return TweenActBase.resolveMotion(
      context,
      motion: motion,
      delay: delay,
      reverse: _reverse,
    );
  }

  @override
  CueAnimation<Offset> buildAnimation(CueTimeline timline, ActContext context) {
    final trackConfig = TrackConfig(
      motion: context.motion,
      reverseMotion: context.reverseMotion,
      reverseType: reverse.type,
    );
    final (track, token) = timline.trackFor(trackConfig);
    return DeferredCueAnimation<Offset>(parent: track, token: token, context: context);
  }

  @override
  Widget apply(BuildContext context, covariant DeferredCueAnimation<Offset> animation, Widget child) {
    return _AnimatedParallax(
      driver: animation,
      slide: slide,
      axis: axis,
      reverse: _reverse,
      child: child,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParallaxAct &&
          super == other &&
          slide == other.slide &&
          axis == other.axis &&
          _reverse == other._reverse;

  @override
  int get hashCode => Object.hash(super.hashCode, slide, axis, _reverse);
}

class _AnimatedParallax extends SingleChildRenderObjectWidget {
  const _AnimatedParallax({
    super.child,
    required this.driver,
    required this.slide,
    required this.axis,
    required this.reverse,
  });

  final DeferredCueAnimation<Offset> driver;
  final double slide;
  final Axis axis;
  final ReverseBehavior<double> reverse;

  @override
  _ParallaxRenderTransform createRenderObject(BuildContext context) {
    return _ParallaxRenderTransform(
      driver: driver,
      slide: slide,
      axis: axis,
      reverse: reverse,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _ParallaxRenderTransform renderObject,
  ) {
    renderObject
      ..driver = driver
      ..slide = slide
      ..axis = axis
      ..reverse = reverse;
  }
}

class _ParallaxRenderTransform extends RenderProxyBox {
  _ParallaxRenderTransform({
    required DeferredCueAnimation<Offset> driver,
    required double slide,
    required Axis axis,
    required ReverseBehavior<double> reverse,
  }) : _driver = driver,
       _slide = slide,
       _axis = axis,
       _reverse = reverse;

  DeferredCueAnimation<Offset> _driver;

  set driver(DeferredCueAnimation<Offset> newDriver) {
    if (_driver == newDriver) return;
    _driver.removeListener(_onTick);
    newDriver.addListener(_onTick);
    _driver = newDriver;
    markNeedsLayout();
  }

  double _slide;

  set slide(double value) {
    if (_slide == value) return;
    _slide = value;
    _invalidateAnimationCache();
  }

  Axis _axis;

  set axis(Axis value) {
    if (_axis == value) return;
    _axis = value;
    _invalidateAnimationCache();
  }

  ReverseBehavior<double> _reverse;

  set reverse(ReverseBehavior<double> value) {
    if (_reverse == value) return;
    _reverse = value;
    _invalidateAnimationCache();
  }

  Size? _lastChildSize;
  Offset _offset = Offset.zero;

  void _invalidateAnimationCache() {
    _driver.setAnimatable(null);
    _lastChildSize = null;
    markNeedsLayout();
  }

  void _buildAnimationIfNeeded(Size childSize, BoxConstraints constraints) {
    if (_driver.hasAnimatable && _lastChildSize == childSize) return;

    final parentMain = _axis == Axis.horizontal ? constraints.maxWidth : constraints.maxHeight;
    final childMain = _axis == Axis.horizontal ? childSize.width : childSize.height;

    // Avoid division by zero in pathological layouts
    if (childMain == 0) {
      _driver.setAnimatable(const AlwaysStoppedAnimatable(Offset.zero));
      _lastChildSize = childSize;
      return;
    }

    // Parallax logic:
    // - Child is oversized: childMain = parentMain * (1 + |slide|)
    // - At progress 0.5: child is centered (no empty space)
    // - Slide range: [-slideDistance/2, +slideDistance/2] where slideDistance = slide * parentMain
    final slideDistance = _slide * parentMain;
    final extraSpace = childMain - parentMain;
    final startOffset = -extraSpace / 2 - slideDistance / 2;
    final endOffset = -extraSpace / 2 + slideDistance / 2;

    Offset buildOffset(double t) {
      final offset = startOffset + t * (endOffset - startOffset);
      return _axis == Axis.horizontal ? Offset(offset, 0) : Offset(0, offset);
    }

    final builder = TweensBuildHelper<Offset>(
      from: buildOffset(0),
      to: buildOffset(1.0),
      reverse: _reverse.mapValues(buildOffset),
      tweenBuilder: (begin, end) => Tween<Offset>(begin: begin, end: end),
    );

    final (animatable, reverseAnimatable) = builder.buildTweens(_driver.context);

    _driver.setAnimatable(
      reverseAnimatable == null
          ? animatable
          : DualAnimatable(
              forward: animatable,
              reverse: reverseAnimatable,
            ),
    );
    _lastChildSize = childSize;
  }

  void _onTick() {
    _offset = _driver.value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _driver.addListener(_onTick);
  }

  @override
  void detach() {
    _driver.removeListener(_onTick);
    super.detach();
  }

  @override
  void performLayout() {
    if (child == null) {
      size = constraints.smallest;
      return;
    }

    // Expand child constraints along slide axis to allow parallax effect
    final expandedSize = _axis == Axis.horizontal
        ? constraints.maxWidth * (1 + _slide.abs())
        : constraints.maxHeight * (1 + _slide.abs());

    final expandedConstraints = _axis == Axis.horizontal
        ? BoxConstraints(
            minWidth: expandedSize,
            maxWidth: expandedSize,
            minHeight: constraints.minHeight,
            maxHeight: constraints.maxHeight,
          )
        : BoxConstraints(
            minWidth: constraints.minWidth,
            maxWidth: constraints.maxWidth,
            minHeight: expandedSize,
            maxHeight: expandedSize,
          );

    child!.layout(expandedConstraints, parentUsesSize: true);
    size = constraints.constrain(child!.size);
    print(
      'ParallaxAct: child size = ${child!.size}, parent constraints = $constraints, final size = $size',
    ); // Debug print

    _buildAnimationIfNeeded(child!.size, constraints);
    _onTick();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    super.paint(context, offset + _offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (child == null) return false;
    return child!.hitTest(result, position: position - _offset);
  }
}
