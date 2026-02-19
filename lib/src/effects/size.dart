part of 'effect.dart';

class SizeEffect extends TweenEffect<double> {
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;
  final bool allowOverflow;
  final Size? _fromSize;
  final Size? _toSize;
  final List<Keyframe<Size?>>? _sizeKeyframes;

  const SizeEffect({
    Size? from,
    Size? to,
    super.curve,
    super.timing,
    this.alignment,
    this.clipBehavior = Clip.hardEdge,
    this.allowOverflow = false,
  }) : _fromSize = from,
       _sizeKeyframes = null,
       _toSize = to,
       super(from: 0, to: 1);

  const SizeEffect.keyframes(
    List<Keyframe<Size?>> keyframes, {
    super.curve,
    this.alignment,
    this.clipBehavior = Clip.hardEdge,
    this.allowOverflow = false,
  }) : _fromSize = null,
       _toSize = null,
       _sizeKeyframes = keyframes,
       super.keyframes(const []);

  ({Animatable<double> tween, Timing? timing}) _buildSizeTween({
    List<Keyframe<Size?>>? keyframes,
    Timing? timing,
  }) {
    Animatable<double> animatable = Tween(begin: 0.0, end: 1.0);
    if (keyframes != null) {
      double minStart = 0;
      double maxEnd = 1;
      for (final keyframe in keyframes) {
        if (keyframe.at < minStart) minStart = keyframe.at;
        if (keyframe.at > maxEnd) maxEnd = keyframe.at;
      }
      if (minStart != 0 || maxEnd != 1) {
        timing = Timing(start: minStart, end: maxEnd);
      }
    }

    return (tween: animatable, timing: timing);
  }

  @override
  Animation<double> buildAnimation(Animation<double> driver, AnimationBuildData data) {
    /// The actual size tween will be built in the RenderObject
    /// where we have access to the constraints so we can normalize sizes properly.
    /// Here we just return the driver animation
    ///
    /// we only apply the curve and timing to the driver,
    /// which will be used in the RenderObject to build the size animation.

    final tweenRes = _buildSizeTween(
      keyframes: _sizeKeyframes,
      timing: timing ?? data.timing,
    );

    final animatable = applyCurves(
      tweenRes.tween,
      curve: data.curve,
      timing: tweenRes.timing,
      isBounded: data.isBounded,
    );

    Animatable<double>? reverseAnimtable;
    if (data.reverseCurve != null || data.reverseTiming != null) {
      reverseAnimtable = applyCurves(
        tweenRes.tween,
        curve: data.reverseCurve,
        timing: data.reverseTiming,
        isBounded: data.isBounded,
      );
    }
    return switch (data.role) {
      ActorRole.both =>
        reverseAnimtable != null
            ? DaulAnimation(
                parent: driver,
                forward: animatable,
                reverse: reverseAnimtable,
              )
            : driver.drive(animatable),
      ActorRole.forward => ForwardOrStoppedAnimation(driver).drive(animatable),
      ActorRole.reverse => ReverseOrStoppedAnimation(driver).drive(animatable),
    };
  }

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    return _AnimatedSize(
      driver: animation,
      fromSize: _fromSize,
      toSize: _toSize,
      sizeKeyframes: _sizeKeyframes,
      alignment: alignment ?? Alignment.center,
      clipBehavior: clipBehavior,
      allowOverflow: allowOverflow,
      child: child,
    );
  }
}

class _AnimatedSize extends SingleChildRenderObjectWidget {
  const _AnimatedSize({
    required this.driver,
    required this.fromSize,
    required this.toSize,
    required this.sizeKeyframes,
    this.alignment = Alignment.center,
    this.clipBehavior = Clip.hardEdge,
    this.allowOverflow = true,
    required super.child,
  });

  final Animation<double> driver;
  final Size? fromSize;
  final Size? toSize;
  final List<Keyframe<Size?>>? sizeKeyframes;
  final AlignmentGeometry alignment;
  final Clip clipBehavior;
  final bool allowOverflow;

  @override
  _RenderAnimatedSize createRenderObject(BuildContext context) {
    return _RenderAnimatedSize(
      driver: driver,
      fromSize: fromSize,
      toSize: toSize,
      sizeKeyframes: sizeKeyframes,
      alignment: alignment,
      textDirection: Directionality.maybeOf(context),
      clipBehavior: clipBehavior,
      allowOverflow: allowOverflow,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderAnimatedSize renderObject,
  ) {
    renderObject
      ..driver = driver
      ..fromSize = fromSize
      ..toSize = toSize
      ..sizeKeyframes = sizeKeyframes
      ..alignment = alignment
      ..textDirection = Directionality.maybeOf(context)
      ..clipBehavior = clipBehavior
      ..allowOverflow = allowOverflow;
  }
}

class _RenderAnimatedSize extends RenderAligningShiftedBox {
  _RenderAnimatedSize({
    required Animation<double> driver,
    required Size? fromSize,
    required Size? toSize,
    required List<Keyframe<Size?>>? sizeKeyframes,
    super.alignment,
    super.textDirection,
    Clip clipBehavior = Clip.hardEdge,
    bool allowOverflow = true,
  }) : _driver = driver,
       _fromSize = fromSize,
       _toSize = toSize,
       _sizeKeyframes = sizeKeyframes,
       _clipBehavior = clipBehavior,
       _allowOverflow = allowOverflow;

  Animation<double> _driver;

  Animation<double> get driver => _driver;

  set driver(Animation<double> value) {
    if (_driver == value) return;
    _sizeAnimation?.removeListener(_onAnimationUpdate);
    _sizeAnimation = null;
    _driver = value;
    markNeedsLayout();
  }

  Size? _fromSize;

  Size? get fromSize => _fromSize;

  set fromSize(Size? value) {
    if (_fromSize == value) return;
    _fromSize = value;
    _invalidateAnimationCache();
  }

  Size? _toSize;

  Size? get toSize => _toSize;

  set toSize(Size? value) {
    if (_toSize == value) return;
    _toSize = value;
    _invalidateAnimationCache();
  }

  List<Keyframe<Size?>>? _sizeKeyframes;

  List<Keyframe<Size?>>? get sizeKeyframes => _sizeKeyframes;

  set sizeKeyframes(List<Keyframe<Size?>>? value) {
    if (_sizeKeyframes == value) return;
    _sizeKeyframes = value;
    _invalidateAnimationCache();
  }

  Curve? _curve;

  Curve? get curve => _curve;

  set curve(Curve? value) {
    if (_curve == value) return;
    _curve = value;
    _invalidateAnimationCache();
  }

  Timing? _timing;

  Timing? get timing => _timing;

  set timing(Timing? value) {
    if (_timing == value) return;
    _timing = value;
    _invalidateAnimationCache();
  }

  bool _hasVisualOverflow = false;

  Clip _clipBehavior;

  Clip get clipBehavior => _clipBehavior;

  set clipBehavior(Clip value) {
    if (_clipBehavior == value) return;
    _clipBehavior = value;
    markNeedsPaint();
  }

  bool _allowOverflow;

  bool get allowOverflow => _allowOverflow;

  set allowOverflow(bool value) {
    if (_allowOverflow == value) return;
    _allowOverflow = value;
    markNeedsLayout();
  }

  final LayerHandle<ClipRectLayer> _clipRectLayer = LayerHandle<ClipRectLayer>();

  // Cached animation and related state
  Animation<Size?>? _sizeAnimation;
  Size? _cachedMaxSize;
  Size? _lastConstraintSize;

  void _invalidateAnimationCache() {
    _sizeAnimation?.removeListener(_onAnimationUpdate);
    _sizeAnimation = null;
    _cachedMaxSize = null;
    markNeedsLayout();
  }

  Size? _normalizeSize(Size? size, Size maxSize) {
    if (size == null) return null;
    double normalize(double value, double max) {
      if (value.isInfinite) return max;
      return value;
    }

    return Size(
      normalize(size.width, maxSize.width),
      normalize(size.height, maxSize.height),
    );
  }

  List<Phase<Size?>> _buildPhases(
    Size maxSize, {
    List<Keyframe<Size?>>? keyframes,
    Size? from,
    Size? to,
  }) {
    if (_sizeKeyframes == null) {
      assert(
        from != null && to != null,
        'Begin and end values must be provided when not using keyframes',
      );
      return [
        Phase<Size?>(
          begin: _normalizeSize(from, maxSize),
          end: _normalizeSize(to, maxSize),
          weight: 100,
        ),
      ];
    } else {
      return Phase.normalize(
        keyframes!,
        (value) => _normalizeSize(value, maxSize),
      ).phases;
    }
  }

  Size _calculateMaxSize(List<Phase<Size?>> phases) {
    double maxWidth = 0;
    double maxHeight = 0;
    for (final phase in phases) {
      final begin = phase.begin ?? Size.zero;
      final end = phase.end ?? Size.zero;
      maxWidth = [
        maxWidth,
        begin.width,
        end.width,
      ].reduce((a, b) => a > b ? a : b);
      maxHeight = [
        maxHeight,
        begin.height,
        end.height,
      ].reduce((a, b) => a > b ? a : b);
    }
    return Size(maxWidth, maxHeight);
  }

  void _buildAnimationIfNeeded(Size constraintSize) {
    // Check if we need to rebuild the animation
    if (_sizeAnimation != null && _lastConstraintSize == constraintSize) {
      return; // Animation is already built and constraints haven't changed
    }

    // Remove old animation listener if it exists
    _sizeAnimation?.removeListener(_onAnimationUpdate);

    // Build phases with normalized sizes
    final phases = _buildPhases(constraintSize, keyframes: sizeKeyframes, from: fromSize, to: toSize);
    // Build the tween from phases
    final animtable = TweenEffectBase.buildFromPhases<Size?>(
      phases,
      (begin, end) => SizeTween(begin: begin, end: end),
    );

    // Build and cache the animation
    _sizeAnimation = _driver.drive(animtable);
    _cachedMaxSize = _calculateMaxSize(phases);
    _lastConstraintSize = constraintSize;

    // Add listener to the new animation
    _sizeAnimation!.addListener(_onAnimationUpdate);
  }

  Size? _maxSize(Size? a, Size? b) {
    if (a == null) return b;
    if (b == null) return a;
    return Size(
      a.width > b.width ? a.width : b.width,
      a.height > b.height ? a.height : b.height,
    );
  }

  void _onAnimationUpdate() {
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _sizeAnimation?.addListener(_onAnimationUpdate);
  }

  @override
  void detach() {
    _sizeAnimation?.removeListener(_onAnimationUpdate);
    super.detach();
  }

  @override
  void performLayout() {
    _hasVisualOverflow = false;

    final BoxConstraints constraints = this.constraints;
    if (child == null) {
      size = constraints.smallest;
      return;
    }

    // Build animation based on current constraints
    _buildAnimationIfNeeded(constraints.biggest);

    final maxSize = _cachedMaxSize ?? Size.zero;
    final sizeAnimation = _sizeAnimation;

    if (_allowOverflow) {
      // Layout child at maxSize (allowing it to be at its biggest size)
      final constrainedMaxSize = constraints.constrain(maxSize);
      child!.layout(
        BoxConstraints.tight(constrainedMaxSize),
        parentUsesSize: true,
      );

      // Get the animated size from the animation
      final animatedSize = sizeAnimation?.value ?? constrainedMaxSize;

      // Our size is the animated size, constrained by parent
      size = constraints.constrain(animatedSize);

      // Align the child within our bounds
      alignChild();

      // Check if child is larger than our animated size (causes overflow)
      if (constrainedMaxSize.width > size.width || constrainedMaxSize.height > size.height) {
        _hasVisualOverflow = true;
      }
    } else {
      // Behave like a normal sizing widget
      final animatedSize = sizeAnimation?.value;

      if (animatedSize == null) {
        // No animation value, layout child normally
        child!.layout(constraints.loosen(), parentUsesSize: true);
        size = constraints.constrain(child!.size);
      } else {
        // Our size is the animated size, constrained by parent
        size = constraints.constrain(animatedSize);

        // Constrain child to our animated size (no overflow)
        child!.layout(BoxConstraints.tight(size), parentUsesSize: true);
      }

      // Align the child within our bounds
      alignChild();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && _allowOverflow && _hasVisualOverflow) {
      // When allowOverflow is true, always clip the overflow
      final Rect rect = Offset.zero & size;
      _clipRectLayer.layer = context.pushClipRect(
        needsCompositing,
        offset,
        rect,
        super.paint,
        clipBehavior: clipBehavior,
        oldLayer: _clipRectLayer.layer,
      );
    } else {
      _clipRectLayer.layer = null;
      super.paint(context, offset);
    }
  }

  @override
  void dispose() {
    _sizeAnimation?.removeListener(_onAnimationUpdate);
    _clipRectLayer.layer = null;
    super.dispose();
  }
}

class FractionalSizeEffect extends TweenEffect<Size> {
  const FractionalSizeEffect({
    super.from = Size.zero,
    super.to = Size.zero,
    super.curve,
    super.timing,
    this.alignment = Alignment.center,
  });

  const FractionalSizeEffect.keyframes(
    super.keyframes, {
    super.curve,
    this.alignment = Alignment.center,
  }) : super.keyframes();

  final AlignmentGeometry alignment;

  @override
  Widget apply(BuildContext context, Animation<Size> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return FractionallySizedBox(
          widthFactor: animation.value.width,
          heightFactor: animation.value.height,
          alignment: alignment,
          child: child,
        );
      },
    );
  }
}
