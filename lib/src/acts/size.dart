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
    return _AnimatedSizedBox(
      driver: animation,
      widthInput: width,
      heightInput: height,
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
    this.widthInput,
    this.heightInput,
  });

  final DeferredCueAnimation<Size> driver;
  final AnimatableValue<double>? widthInput;
  final AnimatableValue<double>? heightInput;

  @override
  _AnimtableRenderConstrainedBox createRenderObject(BuildContext context) {
    return _AnimtableRenderConstrainedBox(
      driver: driver,
      widthInput: widthInput,
      heightInput: heightInput,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _AnimtableRenderConstrainedBox renderObject,
  ) {
    renderObject
      ..driver = driver
      ..widthInput = widthInput
      ..heightInput = heightInput;
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

  // ── driver ──────────────────────────────────────────────────────────────────

  DeferredCueAnimation<Size> _driver;

  DeferredCueAnimation<Size> get driver => _driver;

  set driver(DeferredCueAnimation<Size> newDriver) {
    if (_driver == newDriver) return;
    _driver.removeListener(markNeedsLayout);
    newDriver.addListener(markNeedsLayout);
    _driver = newDriver;
    markNeedsLayout();
  }

  // ── widthInput ──────────────────────────────────────────────────────────────

  AnimatableValue<double>? _width;

  AnimatableValue<double>? get widthInput => _width;

  set widthInput(AnimatableValue<double>? value) {
    if (_width == value) return;
    _width = value;
    _invalidateAnimationCache();
  }

  // ── heightInput ─────────────────────────────────────────────────────────────

  AnimatableValue<double>? _height;

  AnimatableValue<double>? get heightInput => _height;

  set heightInput(AnimatableValue<double>? value) {
    if (_height == value) return;
    _height = value;
    _invalidateAnimationCache();
  }

  // ── animation cache ─────────────────────────────────────────────────────────

  BoxConstraints? _lastConstraints;

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

  void _buildAnimationIfNeeded() {
    if (_driver.hasAnimatable && _lastConstraints == constraints) return;

    final ifrom = _driver.context.implicitFrom as Size?;
    _driver.setAnimatable(
      _ProxySizeTween(
        width: _width?.buildAnimtable(
          _driver.context.copyWith(implicitFrom: ifrom?.width),
          transform: (ctx, v) => _normalize(v, constraints.maxWidth),
        ),
        height: _height?.buildAnimtable(
          _driver.context.copyWith(implicitFrom: ifrom?.height),
          transform: (ctx, v) => _normalize(v, constraints.maxHeight),
        ),
      ),
    );
    _lastConstraints = constraints;
  }

  // ── lifecycle ────────────────────────────────────────────────────────────────

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _driver.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _driver.removeListener(markNeedsLayout);
    super.detach();
  }

  @override
  void dispose() {
    _driver.removeListener(markNeedsLayout);
    super.dispose();
  }

  // ── layout ───────────────────────────────────────────────────────────────────

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
