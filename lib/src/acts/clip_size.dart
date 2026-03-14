part of 'base/act.dart';

class SizedClipAct extends DeferredTweenAct<Size?> {
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;
  final NSize? from;
  final NSize? to;
  final List<KeyframeBase<NSize>>? keyframes;

  const SizedClipAct({
    this.from = NSize.childSize,
    this.to = NSize.childSize,
    super.motion,
    super.reverse,
    this.alignment,
    this.clipBehavior = Clip.hardEdge,
  }) : keyframes = null;

  const SizedClipAct.keyframes(
    List<KeyframeBase<NSize>> this.keyframes, {
    super.motion,
    super.reverse,
    this.alignment,
    this.clipBehavior = Clip.hardEdge,
  }) : from = null,
       to = null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SizedClipAct &&
          super == other &&
          alignment == other.alignment &&
          clipBehavior == other.clipBehavior &&
          from == other.from &&
          to == other.to &&
          listEquals(keyframes, other.keyframes);

  @override
  int get hashCode => Object.hash(alignment, clipBehavior, from, to, Object.hashAll(keyframes ?? const []));

  @override
  Widget apply(BuildContext context, DeferredCueAnimation<Size?> animation, Widget child) {
    return _AnimatedSizeClip(
      driver: animation,
      from: from,
      to: to,
      sizeKeyframes: keyframes,
      alignment: alignment ?? Alignment.center,
      clipBehavior: clipBehavior,
      child: child,
    );
  }
}

class _AnimatedSizeClip extends SingleChildRenderObjectWidget {
  const _AnimatedSizeClip({
    required this.driver,
    required this.from,
    required this.to,
    required this.sizeKeyframes,
    this.alignment = Alignment.center,
    this.clipBehavior = Clip.hardEdge,
    required super.child,
  });

  final DeferredCueAnimation<Size?> driver;
  final NSize? from;
  final NSize? to;
  final List<KeyframeBase<NSize>>? sizeKeyframes;
  final AlignmentGeometry alignment;
  final Clip clipBehavior;

  @override
  _RenderAnimatedSizeClip createRenderObject(BuildContext context) {
    return _RenderAnimatedSizeClip(
      driver: driver,
      fromSize: from,
      toSize: to,
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
      ..fromSize = from
      ..toSize = to
      ..keyframes = sizeKeyframes
      ..alignment = alignment
      ..textDirection = Directionality.maybeOf(context)
      ..clipBehavior = clipBehavior;
  }
}

class _RenderAnimatedSizeClip extends RenderAligningShiftedBox {
  _RenderAnimatedSizeClip({
    required DeferredCueAnimation<Size?> driver,
    required NSize? fromSize,
    required NSize? toSize,
    required List<KeyframeBase<NSize>>? sizeKeyframes,
    super.alignment,
    super.textDirection,
    Clip clipBehavior = Clip.hardEdge,
  }) : _driver = driver,
       _from = fromSize,
       _to = toSize,
       _keyframes = sizeKeyframes,
       _clipBehavior = clipBehavior {
    _addintionalConstrains = _calculateAddintionalContrains();
  }

  DeferredCueAnimation<Size?> _driver;

  DeferredCueAnimation<Size?> get driver => _driver;

  set driver(DeferredCueAnimation<Size?> newDriver) {
    if (_driver == newDriver) return;
    _driver.removeListener(markNeedsLayout);
    _driver = newDriver;
    _driver.addListener(markNeedsLayout);
    markNeedsLayout();
  }

  NSize? _from;

  set fromSize(NSize? value) {
    if (_from == value) return;
    _from = value;
    _invalidateAnimationCache();
  }

  NSize? _to;

  set toSize(NSize? value) {
    if (_to == value) return;
    _to = value;
    _invalidateAnimationCache();
  }

  List<KeyframeBase<NSize>>? _keyframes;

  set keyframes(List<KeyframeBase<NSize>>? value) {
    if (_keyframes == value) return;
    _keyframes = value;
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
  Size? _cachedMaxSize;
  Size? _lastConstraintSize;
  BoxConstraints _addintionalConstrains = BoxConstraints();
  Size? _lastChildNaturalSize;

  void _invalidateAnimationCache() {
    _driver.setAnimatable(null);
    _cachedMaxSize = null;
    _addintionalConstrains = _calculateAddintionalContrains();
    markNeedsLayout();
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

    if (_keyframes != null) {
      for (final kf in _keyframes!) {
        checkNSize(kf.value);
      }
    } else {
      checkNSize(_from);
      checkNSize(_to);
    }
    return BoxConstraints.tightFor(width: maxWidth, height: maxHeight);
  }

  /// Resolves an [NSize] to a concrete [Size] given the max constraint and
  /// the child's natural (unconstrained) size.
  ///
  /// - `null` axis → use the corresponding axis of [childSize]
  /// - `double.infinity` axis → use the corresponding axis of [maxConstraint]
  /// - any other value → use as-is
  Size? _resolveSize(NSize? nsize, Size maxConstraint, Size childSize) {
    if (nsize == null) return null;
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

  // Size _calculateMaxSize(AnimtableSize animtable) {
  //   final allValues = [
  //     animtable.from,
  //     animtable.to,
  //     ...?animtable.keyframes?.map((kf) => kf.value),
  //   ].whereType<Size>();

  //   double maxWidth = 0;
  //   double maxHeight = 0;
  //   for (final size in allValues) {
  //     if (size.width > maxWidth) {
  //       maxWidth = size.width;
  //     }
  //     if (size.height > maxHeight) {
  //       maxHeight = size.height;
  //     }
  //   }
  //   return Size(maxWidth, maxHeight);
  // }

  void _buildAnimationIfNeeded(Size maxConstrains, Size childSize) {
    // Check if we need to rebuild the animation
    if (_driver.hasAnimatable && _lastConstraintSize == maxConstrains && _lastChildNaturalSize == childSize) {
      return; // Animation is already built and neither constraints nor child size changed
    }

    final iFrom = _driver.context.implicitFrom as Size?;
    final from = iFrom ?? _resolveSize(_from, maxConstrains, childSize);
    final to = _resolveSize(_to, maxConstrains, childSize);
    final tween = SizeTween(begin: from, end: to);
    //TODO: handle keyframes and max size calcuation

    // // Build the tween from phases
    // final animtable = AnimtableSize(
    //   from: _resolveSize(_from, maxConstrains, childSize),
    //   to: _resolveSize(_to, maxConstrains, childSize),
    //   keyframes: _keyframes != null
    //       ? [
    //           for (final kf in _keyframes!)
    //             Keyframe<Size?>(
    //               _resolveSize(kf.value, maxConstrains, childSize),
    //               at: kf.at,
    //             ),
    //         ]
    //       : null,
    // );
    // Build and cache the animation
    _driver.setAnimatable(TweenAnimtable(tween, motion: _driver.context.motion));
    _cachedMaxSize = tween.end ?? Size.zero;
    // _cachedMaxSize = _calculateMaxSize(animtable);
    _lastConstraintSize = maxConstrains;
    _lastChildNaturalSize = childSize;
  }

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
  void performLayout() {
    _hasVisualOverflow = false;

    if (child == null) {
      size = constraints.smallest;
      return;
    }

    child!.layout(_addintionalConstrains.enforce(constraints), parentUsesSize: true);

    // Build animation based on current constraints and child natural size
    _buildAnimationIfNeeded(constraints.biggest, child!.size);

    final maxSize = _cachedMaxSize ?? Size.zero;
    final animatedSize = _driver.value ?? maxSize;

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
    _driver.removeListener(markNeedsLayout);
    _clipRectLayer.layer = null;
    super.dispose();
  }
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
  final double? w;

  /// The height. `null` means use the child's natural height.
  /// `double.infinity` means use the maximum available height constraint.
  final double? h;

  const NSize({this.w, this.h});

  /// Both axes follow the child's natural size (no constraint on either axis).
  static const NSize childSize = NSize();
  static const NSize infinity = NSize(w: double.infinity, h: double.infinity);
  static const NSize zero = NSize(w: 0, h: 0);

  /// Creates an [NSize] from a Flutter [Size] (no nulls).
  NSize.size(Size size) : w = size.width, h = size.height;

  /// Both axes set to [size] (square).
  const NSize.square(double size) : w = size, h = size;

  /// Fixed [w], child's natural height
  const NSize.width(double this.w) : h = null;

  /// Fixed [h], child's natural width
  const NSize.height(double this.h) : w = null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is NSize && runtimeType == other.runtimeType && w == other.w && h == other.h;

  @override
  int get hashCode => Object.hash(w, h);

  @override
  String toString() => 'NSize(width: $w, height: $h)';
}
