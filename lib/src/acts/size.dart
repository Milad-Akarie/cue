part of 'base/act.dart';

class SizeAct extends DeferredTweenAct<Size?> {
  final AnimatableValue<double>? width;
  final AnimatableValue<double>? height;
  final AlignmentGeometry alignment;

  const SizeAct({
    super.motion,
    super.delay,
    this.width,
    this.height,
    this.alignment = Alignment.center,
  });

  @override
  Widget apply(BuildContext context, covariant DeferredCueAnimation<Size?> animation, Widget child) {
    return _AnimatedSizedBox(
      driver: animation,
      width: width,
      height: height,
      alignment: alignment,
      child: child,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SizeAct && super == other && width == other.width && height == other.height;

  @override
  int get hashCode => Object.hash(super.hashCode, width, height);
}

class _AnimatedSizedBox extends SingleChildRenderObjectWidget {
  const _AnimatedSizedBox({
    super.child,
    required this.driver,
    this.width,
    this.height,
    this.alignment = Alignment.center,
  });

  final AlignmentGeometry alignment;
  final DeferredCueAnimation<Size?> driver;
  final AnimatableValue<double>? width;
  final AnimatableValue<double>? height;

  @override
  _AnimtableRenderConstrainedBox createRenderObject(BuildContext context) {
    return _AnimtableRenderConstrainedBox(
      driver: driver,
      widthInput: width,
      heightInput: height,
      alignment: alignment.resolve(Directionality.maybeOf(context)),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _AnimtableRenderConstrainedBox renderObject,
  ) {
    renderObject
      ..driver = driver
      ..alignment = alignment.resolve(Directionality.maybeOf(context))
      ..width = width
      ..height = height;
  }
}

class _AnimtableRenderConstrainedBox extends RenderConstrainedBox {
  _AnimtableRenderConstrainedBox({
    required DeferredCueAnimation<Size?> driver,
    AnimatableValue<double>? widthInput,
    AnimatableValue<double>? heightInput,
    Alignment alignment = Alignment.center,
  }) : _driver = driver,
       _alignment = alignment,
       _width = widthInput,
       _height = heightInput,
       super(additionalConstraints: BoxConstraints());

  DeferredCueAnimation<Size?> _driver;

  set driver(DeferredCueAnimation<Size?> newDriver) {
    if (_driver == newDriver) return;
    _driver.removeListener(_onTick);
    newDriver.addListener(_onTick);
    _driver = newDriver;
    markNeedsLayout();
  }

  Alignment _alignment;

  set alignment(Alignment value) {
    if (_alignment == value) return;
    _alignment = value;
    markNeedsPaint();
  }

  AnimatableValue<double>? _width;

  set width(AnimatableValue<double>? value) {
    if (_width == value) return;
    _width = value;
    _invalidateAnimationCache();
  }

  AnimatableValue<double>? _height;

  set height(AnimatableValue<double>? value) {
    if (_height == value) return;
    _height = value;
    _invalidateAnimationCache();
  }

  void _invalidateAnimationCache() {
    _driver.setAnimatable(null);
    _lastConstraints = null;
    markNeedsLayout();
  }

  double _normalize(double? value, double maxDimention) {
    if (value == null || value.isInfinite) {
      assert(maxDimention.isFinite, 'You can not use double.infinity on an unconstrained axis');
      return maxDimention;
    }
    return value;
  }

  BoxConstraints? _lastConstraints;

  void _buildAnimationIfNeeded(BoxConstraints constrains) {
    if (_driver.hasAnimatable && _lastConstraints == constraints) return;
    final ifrom = _driver.context.implicitFrom as Size?;

    final from =
        ifrom ??
        Size(
          _normalize(_width?.from, constraints.maxWidth),
          _normalize(_height?.from, constraints.maxHeight),
        );

    final to = Size(
      _normalize(_width?.to, constraints.maxWidth),
      _normalize(_height?.to, constraints.maxHeight),
    );

    _driver.setAnimatable(TweenAnimtable<Size?>(SizeTween(begin: from, end: to), motion: _driver.context.motion));
    _lastConstraints = constraints;
  }

  void _onTick() {
    markNeedsLayout();
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

    _buildAnimationIfNeeded(constraints);

    final animatedSize = _driver.value;

    final animatedConstrains = BoxConstraints.tightFor(
      width: animatedSize?.width.isFinite == true ? animatedSize?.width : null,
      height: animatedSize?.height.isFinite == true ? animatedSize?.height : null,
    );

    child!.layout(animatedConstrains, parentUsesSize: true);
    size = animatedConstrains.enforce(constraints).constrain(child!.size);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final aligned = _alignment.alongSize(size);
    final childAligned = _alignment.alongSize(child!.size);
    final childOffset = offset + aligned - childAligned;
    context.paintChild(child!, childOffset);
  }
}

 