part of 'base/act.dart';

class SizeAct extends DeferredTweenAct<Size> {
  final AnimatableValue<double>? width;
  final AnimatableValue<double>? height;

  const SizeAct({
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
    this.width,
    this.height,
  }) : super();

  @override
  Widget apply(BuildContext context, covariant DeferredCueAnimation<Size> animation, Widget child) {
    return _OvershootWidget(
      driver: animation,
      child: _AnimatedSizedBox(
        driver: animation,
        width: width,
        height: height,
        child: child,
      ),
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
  });

  final DeferredCueAnimation<Size> driver;
  final AnimatableValue<double>? width;
  final AnimatableValue<double>? height;

  @override
  _AnimtableRenderConstrainedBox createRenderObject(BuildContext context) {
    return _AnimtableRenderConstrainedBox(
      driver: driver,
      widthInput: width,
      heightInput: height,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _AnimtableRenderConstrainedBox renderObject,
  ) {
    renderObject
      ..driver = driver
      ..width = width
      ..height = height;
  }
}

class _AnimtableRenderConstrainedBox extends RenderConstrainedBox {
  _AnimtableRenderConstrainedBox({
    required DeferredCueAnimation<Size> driver,
    AnimatableValue<double>? widthInput,
    AnimatableValue<double>? heightInput,
  }) : _driver = driver,
       _width = widthInput,
       _height = heightInput,
       super(additionalConstraints: BoxConstraints());

  DeferredCueAnimation<Size> _driver;

  set driver(DeferredCueAnimation<Size> newDriver) {
    if (_driver == newDriver) return;
    _driver.removeListener(_onTick);
    newDriver.addListener(_onTick);
    _driver = newDriver;
    markNeedsLayout();
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

  double _normalize(double value, double maxDimention) {
    if (value.isInfinite) {
      assert(maxDimention.isFinite, 'You can not use double.infinity on an unconstrained axis');
      return maxDimention;
    }
    return value;
  }

  BoxConstraints? _lastConstraints;

  void _buildAnimationIfNeeded() {
    if (_driver.hasAnimatable && _lastConstraints == constraints) return;
    final ifrom = _driver.context.implicitFrom as Size?;
    _driver.setAnimatable(
      _ProxySizeTween(
        width: _width?.buildAnimtable(
          _driver.context.copyWith(implicitFrom: ifrom?.width, isBounded: true),
          transform: (ctx, v) => _normalize(v, constraints.maxWidth),
        ),
        height: _height?.buildAnimtable(
          _driver.context.copyWith(implicitFrom: ifrom?.height, isBounded: true),
          transform: (ctx, v) => _normalize(v, constraints.maxHeight),
        ),
      ),
    );
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
  void dispose() {
    _driver.removeListener(_onTick);
    super.dispose();
  }

  @override
  void performLayout() {
    if (child == null) {
      size = constraints.smallest;
      return;
    }

    _buildAnimationIfNeeded();

    final animatedSize = _driver.value;
    final childConstraints = BoxConstraints.tightFor(
      width: animatedSize.width.isFinite ? animatedSize.width : null,
      height: animatedSize.height.isFinite ? animatedSize.height : null,
    ).enforce(constraints);

    child!.layout(childConstraints, parentUsesSize: true);
    size = childConstraints.constrain(child!.size);
  }
}

class _ProxySizeTween extends CueAnimtable<Size> {
  final CueAnimtable<double>? width;
  final CueAnimtable<double>? height;

  @override
  bool shouldNotify(AnimationStatus status) {
    return (width?.shouldNotify(status) ?? false) || (height?.shouldNotify(status) ?? false);
  }

  const _ProxySizeTween({this.width, this.height});

  @override
  Size transform(double t, AnimationStatus status) {
    return Size(
      width?.transform(t, status) ?? double.infinity,
      height?.transform(t, status) ?? double.infinity,
    );
  }
}

class _OvershootWidget extends SingleChildRenderObjectWidget {
  const _OvershootWidget({
    super.child,
    required this.driver,
  });

  final DeferredCueAnimation<Size> driver;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _OvershootScaleRenderBox(driver: driver);
  }

  @override
  void updateRenderObject(BuildContext context, covariant _OvershootScaleRenderBox renderObject) {
    renderObject.driver = driver;
  }
}

class _OvershootScaleRenderBox extends RenderProxyBox {
  _OvershootScaleRenderBox({required DeferredCueAnimation<Size> driver}) : _driver = driver;

  DeferredCueAnimation<Size> _driver;

  set driver(DeferredCueAnimation<Size> value) {
    if (_driver == value) return;
    _driver.removeListener(markNeedsPaint);
    value.addListener(markNeedsPaint);
    _driver = value;
    markNeedsPaint();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _driver.addListener(markNeedsPaint);
  }

  Matrix4? _transfrom;
  Size? _lastSize;

  @override
  void performLayout() {
    super.performLayout();
    _lastSize = size;
  }

  @override
  void markNeedsPaint() {
    if (_driver.hasAnimatable && _lastSize != null) {
      final rawSize = _driver.value;
      // child.size is the clamped layout size
      final scaleX = _lastSize!.width > 0 ? rawSize.width / _lastSize!.width : 1.0;
      final scaleY = _lastSize!.height > 0 ? rawSize.height / _lastSize!.height : 1.0;
      print(scaleX.toStringAsFixed(2));
      _transfrom = Matrix4.diagonal3Values(scaleX * 1.5, scaleY, 1.0);
    } else {
      _transfrom = null;
    }

    super.markNeedsPaint();
  }

  @override
  void detach() {
    _driver.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null || _transfrom == null) {
      super.paint(context, offset);
      return;
    }

    context.pushTransform(
      needsCompositing,
      offset,
      _transfrom!,
      super.paint,
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    if (_transfrom != null) {
      transform.multiply(_transfrom!);
    }
    super.applyPaintTransform(child, transform);
  }
}
