part of 'effect.dart';

class SizeEffect extends TweenEffect<double> {
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;
  final bool allowOverflow;
  final NSize? _fromSize;
  final NSize? _toSize;
  final List<Keyframe<NSize?>>? _sizeKeyframes;

  const SizeEffect({
    NSize? from,
    NSize? to,
    super.curve,
    super.timing,
    this.alignment,
    this.clipBehavior = Clip.hardEdge,
    this.allowOverflow = false,
  }) : _fromSize = from,
       _toSize = to,
       _sizeKeyframes = null,
       super(from: 0, to: 1);

  const SizeEffect.keyframes(
    List<Keyframe<NSize?>> keyframes, {
    super.curve,
    this.alignment,
    this.clipBehavior = Clip.hardEdge,
    this.allowOverflow = false,
  }) : _fromSize = null,
       _toSize = null,
       _sizeKeyframes = keyframes,
       super.keyframes(const []);

  @internal
  const SizeEffect.internal({
    NSize? from,
    NSize? to,
    List<Keyframe<NSize?>>? keyframes,
    super.curve,
    super.timing,
    this.alignment,
    this.clipBehavior = Clip.hardEdge,
    this.allowOverflow = false,
  }) : _fromSize = from,
       _toSize = to,
       _sizeKeyframes = keyframes,
       super.internal();

  ({Animatable<double> tween, Timing? timing}) _buildSizeTween({
    List<Keyframe<NSize?>>? keyframes,
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
            ? DualAnimation(
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
  final NSize? fromSize;
  final NSize? toSize;
  final List<Keyframe<NSize?>>? sizeKeyframes;
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
    required NSize? fromSize,
    required NSize? toSize,
    required List<Keyframe<NSize?>>? sizeKeyframes,
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

  List<Keyframe<NSize?>>? _sizeKeyframes;

  List<Keyframe<NSize?>>? get sizeKeyframes => _sizeKeyframes;

  set sizeKeyframes(List<Keyframe<NSize?>>? value) {
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
  Size? _lastChildNaturalSize;

  void _invalidateAnimationCache() {
    _sizeAnimation?.removeListener(_onAnimationUpdate);
    _sizeAnimation = null;
    _cachedMaxSize = null;
    _lastChildNaturalSize = null;
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
      if (value.isInfinite) return max;
      return value;
    }

    return Size(
      resolveAxis(nsize.width, maxConstraint.width, childSize.width),
      resolveAxis(nsize.height, maxConstraint.height, childSize.height),
    );
  }

  List<Phase<Size?>> _buildPhases(
    Size maxConstraint,
    Size childNaturalSize, {
    List<Keyframe<NSize?>>? keyframes,
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
        (value) => value == null ? null : _resolveSize(value, maxConstraint, childNaturalSize),
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
    final animtable = TweenEffectBase.buildFromPhases<Size?>(
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

  /// Returns whether any axis in any [NSize] value (across from/to/keyframes)
  /// is `null`, meaning the child's natural size is needed for that axis.
  bool get _needsChildNaturalSize {
    bool hasNull(NSize? ns) => ns != null && (ns.width == null || ns.height == null);
    if (_sizeKeyframes != null) {
      return _sizeKeyframes!.any((kf) => hasNull(kf.value));
    }
    return hasNull(_fromSize) || hasNull(_toSize);
  }

  /// Builds [BoxConstraints] for the measurement pass (Pass 1).
  ///
  /// Axes that have at least one `null` value across all [NSize] specs are
  /// loosened (min = 0, max = parent max) so the child can report its natural
  /// size. Axes that are always specified keep the parent's max constraint so
  /// the child measures itself under the correct budget.
  BoxConstraints _measurementNaturalConstrains(BoxConstraints parentConstraints) {
    double? maxWidth;
    double? maxHeight;

    void checkNSize(NSize? ns) {
      if (ns == null) return;
      if (ns.width != null) {
        if (maxWidth == null || ns.width! > maxWidth!) {
          maxWidth = ns.width;
        }
      } else {
        // If any value is null, we need the child's natural size for that axis, so loosen it completely
        maxWidth = null;
      }
      if (ns.height != null) {
        if (maxHeight == null || ns.height! > maxHeight!) {
          maxHeight = ns.height;
        }
      } else {
        // If any value is null, we need the child's natural size for that axis, so loosen it completely
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
    return BoxConstraints.loose(
      Size(
        maxWidth ?? (parentConstraints.hasBoundedWidth ? parentConstraints.maxWidth : double.infinity),
        maxHeight ?? (parentConstraints.hasBoundedHeight ? parentConstraints.maxHeight : double.infinity),
      ),
    );
  }

  @override
  void performLayout() {
    _hasVisualOverflow = false;

    final BoxConstraints constraints = this.constraints;
    if (child == null) {
      size = constraints.smallest;
      return;
    }

    // Pass 1 (conditional): Measure the child's natural size on axes that have
    // null NSize values. Only loosen the axes that need child-size resolution;
    // keep the parent constraint on axes that are always specified so the child
    // measures itself under the correct width/height budget.
    final bool needsMeasure = _needsChildNaturalSize;
    Size childNaturalSize;
    if (needsMeasure) {
      child!.layout(_measurementNaturalConstrains(constraints), parentUsesSize: true);
      childNaturalSize = child!.size;
    } else {
      childNaturalSize = Size.zero; // sentinel — not used when needsMeasure is false
    }

    // Build animation based on current constraints and child natural size
    _buildAnimationIfNeeded(constraints.biggest, childNaturalSize);

    final maxSize = _cachedMaxSize ?? Size.zero;
    final sizeAnimation = _sizeAnimation;

    if (_allowOverflow) {
      // Layout child at maxSize (allowing it to be at its biggest size)
      final constrainedMaxSize = constraints.constrain(maxSize);

      // Only re-layout child if the constrained max size differs from the
      // measurement layout (or if we skipped the measurement pass).
      if (!needsMeasure || constrainedMaxSize != childNaturalSize) {
        child!.layout(
          BoxConstraints.tight(constrainedMaxSize),
          parentUsesSize: true,
        );
      }

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
        // No animation value — lay out child loosely if we haven't already
        if (!needsMeasure) {
          child!.layout(constraints.loosen(), parentUsesSize: true);
        }
        size = constraints.constrain(child!.size);
      } else {
        // Our size is the animated size, constrained by parent
        size = constraints.constrain(animatedSize);

        // Only re-layout child if the animated size differs from the measurement
        // layout (or if we skipped the measurement pass).
        if (!needsMeasure || size != childNaturalSize) {
          child!.layout(BoxConstraints.tight(size), parentUsesSize: true);
        }
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

class SizeActor extends SingleEffectProxy<NSize> {
  final AlignmentGeometry alignment;
  final bool allowOverflow;
  final Clip clipBehavior;

  const SizeActor({
    super.key,
    required super.from,
    required super.to,
    this.alignment = Alignment.center,
    this.allowOverflow = false,
    this.clipBehavior = Clip.hardEdge,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  });

  const SizeActor.keyframes({
    super.key,
    required super.frames,
    this.alignment = Alignment.center,
    this.allowOverflow = false,
    this.clipBehavior = Clip.hardEdge,
    required super.child,
    super.curve,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : super.keyframes();

  @override
  Effect get effect => SizeEffect.internal(
    from: from,
    to: to,
    alignment: alignment,
    allowOverflow: allowOverflow,
    clipBehavior: clipBehavior,
    keyframes: frames,
  );
}

/// A size specification where each axis can be `null` to mean
/// "use the child's natural size for that axis" (no constraint applied).
///
/// `double.infinity` is still supported and means "use the maximum available
/// constraint for that axis".
///
/// Examples:
/// ```dart
/// // Both axes fixed
/// NSize(width: 200, height: 100)
///
/// // Animate width, let height follow child
/// NSize(width: 200, height: null)
///
/// // Both axes follow child (no constraint)
/// NSize.childSize
///
/// // From a Flutter Size (no nulls)
/// NSize.fromSize(Size(200, 100))
/// ```
class NSize {
  /// The width. `null` means use the child's natural width.
  /// `double.infinity` means use the maximum available width constraint.
  final double? width;

  /// The height. `null` means use the child's natural height.
  /// `double.infinity` means use the maximum available height constraint.
  final double? height;

  const NSize([this.width, this.height]);

  /// Both axes follow the child's natural size (no constraint on either axis).
  static const NSize childSize = NSize();

  /// Creates an [NSize] from a Flutter [Size] (no nulls).
  NSize.fromSize(Size size) : width = size.width, height = size.height;

  /// Both axes set to [size] (square).
  const NSize.square(double size) : width = size, height = size;

  /// Fixed [width], child's natural height
  const NSize.fromWidth(double this.width) : height = null;

  /// Fixed [height], child's natural width
  const NSize.fromHeight(double this.height) : width = null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NSize && runtimeType == other.runtimeType && width == other.width && height == other.height;

  @override
  int get hashCode => Object.hash(width, height);

  @override
  String toString() => 'NSize(width: $width, height: $height)';
}
