part of 'base/act.dart';

class ClipSizeAct extends TweenAct<double> {
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;
  final NSize? _fromSize;
  final NSize? _toSize;
  final List<Keyframe<NSize>>? _sizeKeyframes;

  const ClipSizeAct({
    NSize? from = NSize.childSize,
    NSize? to = NSize.childSize,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
    this.alignment,
    this.clipBehavior = Clip.hardEdge,
  }) : _fromSize = from,
       _toSize = to,
       _sizeKeyframes = null,
       super(from: 0, to: 1);

  const ClipSizeAct.keyframes(
    List<Keyframe<NSize>> keyframes, {
    super.curve,
    super.reverseCurve,
    this.alignment,
    this.clipBehavior = Clip.hardEdge,
  }) : _fromSize = null,
       _toSize = null,
       _sizeKeyframes = keyframes,
       super.keyframes(const []);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClipSizeAct &&
          super == other &&
          alignment == other.alignment &&
          clipBehavior == other.clipBehavior &&
          _fromSize == other._fromSize &&
          _toSize == other._toSize &&
          listEquals(_sizeKeyframes, other._sizeKeyframes);

  @override
  int get hashCode =>
      Object.hash(alignment, clipBehavior, _fromSize, _toSize, Object.hashAll(_sizeKeyframes ?? const []));

  @override
  ({Animatable<double> tween, Timing? timing}) resolveTween(ActContext context) {
    Timing? timing;
    Animatable<double> animatable = Tween(begin: 0.0, end: 1.0);
    if (_sizeKeyframes != null) {
      double? minStart;
      double? maxEnd;
      for (final keyframe in _sizeKeyframes!) {
        if (minStart == null || keyframe.at < minStart) minStart = keyframe.at;
        if (maxEnd == null || keyframe.at > maxEnd) maxEnd = keyframe.at;
      }
      if ((minStart != null && minStart != 0) || (maxEnd != null && maxEnd != 1)) {
        timing = Timing(start: minStart ?? 0, end: maxEnd ?? 1);
      }
    } else if (context.implicitFrom case final iFrom? when iFrom is double) {
      animatable = Tween(begin: iFrom, end: to);
    }
    return (tween: animatable, timing: timing);
  }

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    return _AnimatedSizeClip(
      driver: animation,
      fromSize: _fromSize,
      toSize: _toSize,
      sizeKeyframes: _sizeKeyframes,
      alignment: alignment ?? Alignment.center,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

class _AnimatedSizeClip extends SingleChildRenderObjectWidget {
  const _AnimatedSizeClip({
    required this.driver,
    required this.fromSize,
    required this.toSize,
    required this.sizeKeyframes,
    this.alignment = Alignment.center,
    this.clipBehavior = Clip.hardEdge,
    required super.child,
  });

  final Animation<double> driver;
  final NSize? fromSize;
  final NSize? toSize;
  final List<Keyframe<NSize>>? sizeKeyframes;
  final AlignmentGeometry alignment;
  final Clip clipBehavior;

  @override
  _RenderAnimatedSizeClip createRenderObject(BuildContext context) {
    return _RenderAnimatedSizeClip(
      driver: driver,
      fromSize: fromSize,
      toSize: toSize,
      sizeKeyframes: sizeKeyframes,
      alignment: alignment,
      textDirection: Directionality.maybeOf(context),
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderAnimatedSizeClip renderObject,
  ) {
    renderObject
      ..driver = driver
      ..fromSize = fromSize
      ..toSize = toSize
      ..sizeKeyframes = sizeKeyframes
      ..alignment = alignment
      ..textDirection = Directionality.maybeOf(context)
      ..clipBehavior = clipBehavior;
  }
}

class _RenderAnimatedSizeClip extends RenderAligningShiftedBox {
  _RenderAnimatedSizeClip({
    required Animation<double> driver,
    required NSize? fromSize,
    required NSize? toSize,
    required List<Keyframe<NSize>>? sizeKeyframes,
    super.alignment,
    super.textDirection,
    Clip clipBehavior = Clip.hardEdge,
  }) : _driver = driver,
       _fromSize = fromSize,
       _toSize = toSize,
       _sizeKeyframes = sizeKeyframes,
       _clipBehavior = clipBehavior {
    _addintionalConstrains = _calculateAddintionalContrains();
  }

  Animation<double> _driver;

  Animation<double> get driver => _driver;

  set driver(Animation<double> value) {
    if (_driver == value) return;
    _sizeAnimation?.removeListener(_onAnimationUpdate);
    _sizeAnimation = null;
    _driver = value;
    markNeedsLayout();
  }

  NSize? _fromSize;

  NSize? get fromSize => _fromSize;

  set fromSize(NSize? value) {
    if (_fromSize == value) return;
    _fromSize = value;
    _invalidateAnimationCache();
  }

  NSize? _toSize;

  NSize? get toSize => _toSize;

  set toSize(NSize? value) {
    if (_toSize == value) return;
    _toSize = value;
    _invalidateAnimationCache();
  }

  List<Keyframe<NSize>>? _sizeKeyframes;

  List<Keyframe<NSize>>? get sizeKeyframes => _sizeKeyframes;

  set sizeKeyframes(List<Keyframe<NSize>>? value) {
    if (_sizeKeyframes == value) return;
    _sizeKeyframes = value;
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

  final LayerHandle<ClipRectLayer> _clipRectLayer = LayerHandle<ClipRectLayer>();

  // Cached animation and related state
  Animation<Size?>? _sizeAnimation;
  Size? _cachedMaxSize;
  Size? _lastConstraintSize;
  BoxConstraints _addintionalConstrains = BoxConstraints();
  Size? _lastChildNaturalSize;

  void _invalidateAnimationCache() {
    _sizeAnimation?.removeListener(_onAnimationUpdate);
    _sizeAnimation = null;
    _cachedMaxSize = null;
    _addintionalConstrains = _calculateAddintionalContrains();
    markNeedsLayout();
  }

  /// Resolves an [NSize] to a concrete [Size] given the max constraint and
  /// the child's natural (unconstrained) size.
  ///
  /// - `null` axis → use the corresponding axis of [childSize]
  /// - `double.infinity` axis → use the corresponding axis of [maxConstraint]
  /// - any other value → use as-is
  Size _resolveSize(NSize nsize, Size maxConstraint, Size childSize) {
    double resolveAxis(double? value, double max, double child) {
      if (value == null) return child;
      if (value.isInfinite) {
        assert(max.isFinite, 'Max constraint must be finite when using infinity for axis');
        return max;
      }
      return value;
    }

    return Size(
      resolveAxis(nsize.w, maxConstraint.width, childSize.width),
      resolveAxis(nsize.h, maxConstraint.height, childSize.height),
    );
  }

  List<Phase<Size?>> _buildPhases(
    Size maxConstraint,
    Size childNaturalSize, {
    List<Keyframe<NSize>>? keyframes,
    NSize? from,
    NSize? to,
  }) {
    if (_sizeKeyframes == null) {
      assert(
        from != null && to != null,
        'Begin and end values must be provided when not using keyframes',
      );
      return [
        Phase<Size?>(
          begin: _resolveSize(from!, maxConstraint, childNaturalSize),
          end: _resolveSize(to!, maxConstraint, childNaturalSize),
          weight: 100,
        ),
      ];
    } else {
      return Phase.normalize(
        keyframes!,
        (value) => _resolveSize(value, maxConstraint, childNaturalSize),
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

  void _buildAnimationIfNeeded(Size constraintSize, Size childNaturalSize) {
    // Check if we need to rebuild the animation
    if (_sizeAnimation != null && _lastConstraintSize == constraintSize && _lastChildNaturalSize == childNaturalSize) {
      return; // Animation is already built and neither constraints nor child size changed
    }
    // Remove old animation listener if it exists
    _sizeAnimation?.removeListener(_onAnimationUpdate);

    // Build phases with resolved sizes
    final phases = _buildPhases(
      constraintSize,
      childNaturalSize,
      keyframes: sizeKeyframes,
      from: fromSize,
      to: toSize,
    );
    // Build the tween from phases
    final animtable = buildFromPhases<Size?>(
      phases,
      (begin, end) => SizeTween(begin: begin, end: end),
    );

    // Build and cache the animation
    _sizeAnimation = _driver.drive(animtable);
    _cachedMaxSize = _calculateMaxSize(phases);
    _lastConstraintSize = constraintSize;
    _lastChildNaturalSize = childNaturalSize;

    // Add listener to the new animation
    _sizeAnimation!.addListener(_onAnimationUpdate);
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

  BoxConstraints _calculateAddintionalContrains() {
    double? maxWidth;
    double? maxHeight;

    void checkNSize(NSize? ns) {
      if (ns == null) return;
      if (ns.w != null) {
        if (maxWidth == null || ns.w! > maxWidth!) {
          maxWidth = ns.w;
        }
      } else {
        maxWidth = null;
      }
      if (ns.h != null) {
        if (maxHeight == null || ns.h! > maxHeight!) {
          maxHeight = ns.h;
        }
      } else {
        maxHeight = null;
      }
    }

    if (_sizeKeyframes != null) {
      for (final kf in _sizeKeyframes!) {
        checkNSize(kf.value);
      }
    } else {
      checkNSize(_fromSize);
      checkNSize(_toSize);
    }
    return BoxConstraints.tightFor(width: maxWidth, height: maxHeight);
  }

  @override
  void performLayout() {
    _hasVisualOverflow = false;

    if (child == null) {
      size = constraints.smallest;
      return;
    }

    child!.layout(_addintionalConstrains.enforce(constraints), parentUsesSize: true);

    // Build animation based on current constraints and child natural size
    _buildAnimationIfNeeded(constraints.biggest, child!.size);
    assert(_sizeAnimation != null);
    final maxSize = _cachedMaxSize ?? Size.zero;
    final animatedSize = _sizeAnimation!.value!;

    size = constraints.constrain(animatedSize);

    final constrainedMaxSize = constraints.constrain(maxSize);

    // Align the child within our bounds
    alignChild();
    // Check if child is larger than our animated size (causes overflow)
    if (constrainedMaxSize.width > size.width || constrainedMaxSize.height > size.height) {
      _hasVisualOverflow = true;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && _hasVisualOverflow && clipBehavior != Clip.none) {
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
