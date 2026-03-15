part of 'base/act.dart';

class SizedBoxAct extends DeferredTweenAct<Size> {
  final AnimatableValue<double>? width;
  final AnimatableValue<double>? height;
  final AlignmentGeometry alignment;
  final Keyframes<Size>? frames;

  const SizedBoxAct({
    super.motion,
    super.delay,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    ReverseBehavior<Size> super.reverse = const ReverseBehavior.mirror(),
  }) : frames = null;

  const SizedBoxAct.keyframed({
    required Keyframes<Size> this.frames,
    super.delay,
    this.alignment = Alignment.center,
    KFReverseBehavior<Size> super.reverse = const KFReverseBehavior.mirror(),
  }) : width = null,
       height = null;

  @override
  (CueAnimtable<Size>, CueAnimtable<Size>?) buildTweens(ActContext context) {
    // We build fake tweens here just to extract the motion and other parameters from the context.
    // The actual tween will be built later in the render object when we have the constraints.
    final builder = _SizeActBuilder(
      motion: motion,
      delay: delay,
      from: Size.zero,
      to: Size.infinite,
      frames: frames,
      reverse: reverse,
    );
    return builder.buildTweens(context);
  }

  @override
  CueAnimation<Size> buildAnimation(CueTimeline timline, ActContext context) {
    final superDriver = super.buildAnimation(timline, context);
    return DeferredCueAnimation<Size>(parent: superDriver.parent, context: context);
  }

  @override
  Widget apply(BuildContext context, covariant DeferredCueAnimation<Size> animation, Widget child) {
    return _AnimatedSizedBox(
      driver: animation,
      width: width,
      height: height,
      alignment: alignment,
      keyframes: frames,
      reverse: reverse,
      child: child,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SizedBoxAct &&
          super == other &&
          width == other.width &&
          height == other.height &&
          alignment == other.alignment &&
          frames == other.frames &&
          reverse == other.reverse;

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    width,
    height,
    alignment,
    frames,
    reverse,
  );
}

class _AnimatedSizedBox extends SingleChildRenderObjectWidget {
  const _AnimatedSizedBox({
    super.child,
    required this.driver,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.keyframes,
    required this.reverse,
  });

  final AlignmentGeometry alignment;
  final DeferredCueAnimation<Size> driver;
  final AnimatableValue<double>? width;
  final AnimatableValue<double>? height;
  final Keyframes<Size>? keyframes;
  final ReverseBehaviorBase<Size> reverse;

  @override
  _AnimtableRenderConstrainedBox createRenderObject(BuildContext context) {
    return _AnimtableRenderConstrainedBox(
      driver: driver,
      widthInput: width,
      heightInput: height,
      alignment: alignment.resolve(Directionality.maybeOf(context)),
      keyframes: keyframes,
      reverse: reverse,
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
      ..height = height
      ..keyframes = keyframes
      ..reverse = reverse;
  }
}

class _AnimtableRenderConstrainedBox extends RenderConstrainedBox {
  _AnimtableRenderConstrainedBox({
    required DeferredCueAnimation<Size> driver,
    AnimatableValue<double>? widthInput,
    AnimatableValue<double>? heightInput,
    Alignment alignment = Alignment.center,
    Keyframes<Size>? keyframes,
    required ReverseBehaviorBase<Size> reverse,
  }) : _driver = driver,
       _alignment = alignment,
       _width = widthInput,
       _height = heightInput,
       _keyframes = keyframes,
       _reverse = reverse,
       super(additionalConstraints: BoxConstraints());

  DeferredCueAnimation<Size?> _driver;

  set driver(DeferredCueAnimation<Size> newDriver) {
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

  Keyframes<Size>? _keyframes;

  set keyframes(Keyframes<Size>? value) {
    if (_keyframes == value) return;
    _keyframes = value;
  }

  List<FractionalKeyframe<Size>>? _fractionalKeyframes;

  set fractionalKeyframes(List<FractionalKeyframe<Size>>? value) {
    if (_fractionalKeyframes == value) return;
    _fractionalKeyframes = value;
  }

  Duration? _fractionalKeyframesDuration;

  set fractionalKeyframesDuration(Duration? value) {
    if (_fractionalKeyframesDuration == value) return;
    _fractionalKeyframesDuration = value;
  }

  ReverseBehaviorBase<Size> _reverse;

  set reverse(ReverseBehaviorBase<Size> value) {
    if (_reverse == value) return;
    _reverse = value;
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

  Size _normalizeSize(Size size, BoxConstraints constraints) {
    return Size(
      _normalize(size.width, constraints.maxWidth),
      _normalize(size.height, constraints.maxHeight),
    );
  }

  BoxConstraints? _lastConstraints;

  void _buildAnimationIfNeeded(BoxConstraints constrains) {
    if (_driver.hasAnimatable && _lastConstraints == constraints) return;

    Size? from, to;

    if (_width != null || _height != null) {
      final ifrom = _driver.context.implicitFrom as Size?;
      from =
          ifrom ??
          Size(
            _normalize(_width?.from, constrains.maxWidth),
            _normalize(_height?.from, constrains.maxHeight),
          );
      to = Size(
        _normalize(_width?.to, constrains.maxWidth),
        _normalize(_height?.to, constrains.maxHeight),
      );
    }

    final actBuilder = _SizeActBuilder(
      motion: _driver.context.motion,
      delay: _driver.context.delay,
      from: from,
      to: to,
      frames: _keyframes?.mapValues((v) => _normalizeSize(v, constraints)),
      reverse: _reverse.mapValues((v) => _normalizeSize(v, constraints)),
    );

    final (animtable, reverseAnimtable) = actBuilder.buildTweens(_driver.context);

    final effectiveAnimatable = reverseAnimtable == null
        ? animtable
        : DualAnimatable(forward: animtable, reverse: reverseAnimtable);

    _driver.setAnimatable(effectiveAnimatable);
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

class _SizeActBuilder extends TweenAct<Size> {
  const _SizeActBuilder({
    super.motion,
    super.delay,
    super.from,
    super.to,
    super.frames,
    super.reverse,
  }) : super();

  @override
  Animatable<Size> createSingleTween(Size from, Size to) {
    return _SizeTween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, covariant CueAnimation<Size> animation, Widget child) {
    throw UnimplementedError(
      'This class is only used to build the animatable for SizeAct and should never be built itself.',
    );
  }
}

class _SizeTween extends Tween<Size> {
  _SizeTween({required Size begin, required Size end}) : super(begin: begin, end: end);

  @override
  Size lerp(double t) {
    return Size(
      lerpDouble(begin!.width, end!.width, t)!,
      lerpDouble(begin!.height, end!.height, t)!,
    );
  }
}
