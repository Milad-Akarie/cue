part of 'act.dart';

abstract class ResizeAct extends Act {
  const factory ResizeAct({
    required Size from,
    required Size to,
    Curve? curve,
    Timing? timing,
    AlignmentGeometry? alignment,
    Clip? clipBehavior,
    bool allowOverflow,
  }) = _ResizeAct;

  const factory ResizeAct.keyframes(
    List<Keyframe<Size?>> keyframes, {
    Curve? curve,
    AlignmentGeometry? alignment,
    Clip? clipBehavior,
    bool allowOverflow,
  }) = _ResizeAct.keyframes;

  const factory ResizeAct.fractional({
    Size from,
    Size to,
    Curve? curve,
    Timing? timing,
    AlignmentGeometry alignment,
    Clip? clipBehavior,
    bool? allowOverflow,
  }) = FractionalResizeAct;
}

class _ResizeAct extends TweenAct<double> implements ResizeAct {
  final AlignmentGeometry? alignment;
  final Clip? clipBehavior;
  final bool allowOverflow;
  final Size? _fromSize;
  final Size? _toSize;

  final List<Keyframe<Size?>>? _sizeKeyframes;

  const _ResizeAct({
    Size? from,
    Size? to,
    super.curve,
    super.timing,
    this.alignment,
    this.clipBehavior,
    this.allowOverflow = false,
  }) : _fromSize = from,
       _toSize = to,
       _sizeKeyframes = null,
       super(from: 0, to: 1);

  const _ResizeAct.keyframes(
    List<Keyframe<Size?>> keyframes, {
    super.curve,
    this.alignment,
    this.clipBehavior,
    this.allowOverflow = false,
  }) : _fromSize = null,
       _toSize = null,
       _sizeKeyframes = keyframes,
       super.keyframes(const []);

  @override
  Animation<double> buildAnimation(Animation<double> driver) {
    /// The actual size tween will be built in the apply method
    /// where we have access to the constraints
    return driver;
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

  ({List<Phase<Size?>> phases, Timing? timing}) _buildPhases(Size maxSize) {
    if (_sizeKeyframes == null) {
      assert(_fromSize != null && _toSize != null, 'Begin and end values must be provided when not using keyframes');
      return (
        phases: [
          Phase<Size?>(begin: _normalizeSize(_fromSize, maxSize), end: _normalizeSize(_toSize, maxSize), weight: 100),
        ],
        timing: null,
      );
    } else {
      return Phase.normalize(_sizeKeyframes, (value) => _normalizeSize(value, maxSize));
    }
  }

  Size _calculateMaxSize(List<Phase<Size?>> phases) {
    double maxWidth = 0;
    double maxHeight = 0;

    for (final phase in phases) {
      final begin = phase.begin ?? Size.zero;
      final end = phase.end ?? Size.zero;
      maxWidth = [maxWidth, begin.width, end.width].reduce((a, b) => a > b ? a : b);
      maxHeight = [maxHeight, begin.height, end.height].reduce((a, b) => a > b ? a : b);
    }
    return Size(maxWidth, maxHeight);
  }

  (Animation<Size?>, Size maxSize) _buildAnimation(Animation<double> driver, Size maxConstrains) {
    Timing? timing = this.timing;
    final result = _buildPhases(maxConstrains);
    if (result.timing != null) {
      timing = result.timing;
    }
    final tween = TweenActBase.buildFromPhases<Size?>(result.phases, (begin, end) => SizeTween(begin: begin, end: end));
    final effectiveCurve = timing != null
        ? Interval(timing.start, timing.end, curve: curve ?? Curves.linear)
        : curve ?? Curves.linear;
    return (driver.drive<Size?>(tween.chain(CurveTween(curve: effectiveCurve))), _calculateMaxSize(result.phases));
  }

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final calcResult = _buildAnimation(animation, constraints.biggest);
        return _AutoAnimatedSize(
          sizeAnimation: calcResult.$1,
          maxSize: calcResult.$2,
          alignment: alignment ?? Alignment.center,
          clipBehavior: clipBehavior ?? Clip.hardEdge,
          allowOverflow: allowOverflow,
          child: child,
        );
      },
    );
  }
}

class FractionalResizeAct extends TweenAct<Size> implements ResizeAct {
  const FractionalResizeAct({
    super.from = Size.zero,
    super.to = Size.zero,
    super.curve,
    super.timing,
    this.alignment = Alignment.center,
    this.clipBehavior,
    this.allowOverflow,
  });

  const FractionalResizeAct.keyframes(
    super.keyframes, {
    super.curve,
    this.alignment = Alignment.center,
    this.clipBehavior,
    this.allowOverflow,
  }) : super.keyframes();

  final AlignmentGeometry alignment;
  final Clip? clipBehavior;
  final bool? allowOverflow;

  @override
  Widget apply(BuildContext context, Animation<Size> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
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

class _RenderAnimatedSize extends RenderAligningShiftedBox {
  _RenderAnimatedSize({
    required Animation<Size?> sizeAnimation,
    required Size maxSize,
    super.alignment,
    super.textDirection,
    super.child,
    Clip clipBehavior = Clip.hardEdge,
    bool allowOverflow = true,
  }) : _sizeAnimation = sizeAnimation,
       _maxSize = maxSize,
       _clipBehavior = clipBehavior,
       _allowOverflow = allowOverflow;

  Animation<Size?> _sizeAnimation;
  Animation<Size?> get sizeAnimation => _sizeAnimation;
  set sizeAnimation(Animation<Size?> value) {
    if (_sizeAnimation == value) return;
    _sizeAnimation.removeListener(_onAnimationUpdate);
    _sizeAnimation = value;
    _sizeAnimation.addListener(_onAnimationUpdate);
    markNeedsLayout();
  }

  Size _maxSize;
  Size get maxSize => _maxSize;
  set maxSize(Size value) {
    if (_maxSize == value) return;
    _maxSize = value;
    markNeedsLayout();
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

  void _onAnimationUpdate() {
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _sizeAnimation.addListener(_onAnimationUpdate);
  }

  @override
  void detach() {
    _sizeAnimation.removeListener(_onAnimationUpdate);
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

    if (_allowOverflow) {
      // Layout child at maxSize (allowing it to be at its biggest size)
      final constrainedMaxSize = constraints.constrain(_maxSize);
      child!.layout(BoxConstraints.tight(constrainedMaxSize), parentUsesSize: true);

      // Get the animated size from the animation
      final animatedSize = _sizeAnimation.value ?? constrainedMaxSize;

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
      final animatedSize = _sizeAnimation.value;

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
    _sizeAnimation.removeListener(_onAnimationUpdate);
    _clipRectLayer.layer = null;
    super.dispose();
  }
}

/// Widget that wraps [_RenderAnimatedSize].
class _AutoAnimatedSize extends SingleChildRenderObjectWidget {
  const _AutoAnimatedSize({
    required this.sizeAnimation,
    required this.maxSize,
    this.alignment = Alignment.center,
    this.clipBehavior = Clip.hardEdge,
    this.allowOverflow = true,
    required super.child,
  });

  final Animation<Size?> sizeAnimation;
  final Size maxSize;
  final AlignmentGeometry alignment;
  final Clip clipBehavior;
  final bool allowOverflow;

  @override
  _RenderAnimatedSize createRenderObject(BuildContext context) {
    return _RenderAnimatedSize(
      sizeAnimation: sizeAnimation,
      maxSize: maxSize,
      alignment: alignment,
      textDirection: Directionality.maybeOf(context),
      clipBehavior: clipBehavior,
      allowOverflow: allowOverflow,
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderAnimatedSize renderObject) {
    renderObject
      ..sizeAnimation = sizeAnimation
      ..maxSize = maxSize
      ..alignment = alignment
      ..textDirection = Directionality.maybeOf(context)
      ..clipBehavior = clipBehavior
      ..allowOverflow = allowOverflow;
  }
}
