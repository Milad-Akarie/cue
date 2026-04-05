part of 'base/act.dart';

/// {@template sized_clip_act}
/// Animates widget size with clipping and optional rounding.
///
/// [SizedClipAct] animates between two sizes while clipping the child content to the
/// animated bounds. This is useful for expanding/collapsing animations where children
/// should be clipped rather than reflowed.
///
/// Uses [NSize] for flexible sizing:
/// - `null` → use child's natural size for that axis
/// - fixed value (e.g., 200) → fixed pixel size
/// - `double.infinity` → fill available bounded constraint
///
/// Use [Act.sizedClip()] factory to create instances.
///
/// ## Infinite Dimension Support
///
/// [SizedClipAct] supports using `double.infinity` because values are resolved at
/// animation time based on available constraints. Like [SizedBox], when using
/// `double.infinity`, the widget must be inside a bounded constraint. An assertion
/// error will be thrown if the constraint is unbounded.
///
/// ## Basic Clip Animation
///
/// ```dart
/// // Slide and clip content
/// Actor(
///   acts: [
///     .sizedClip(
///       from: NSize.childSize,
///       to: NSize(w: 200, h: 100),
///     ),
///   ],
///   motion: .smooth(damping: 23),
///   child: MyWidget(),
/// )
/// ```
///
/// ## Rounded Clipping
///
/// ```dart
/// // Expand with rounded corners
/// Actor(
///   acts: [
///     .sizedClip(
///       from: NSize(w: 100, h: 50),
///       to: NSize(w: 300, h: 200),
///       clipGeometry: ClipGeometry.rrect(BorderRadius.circular(16)),
///     ),
///   ],
///   motion: .smooth(damping: 23),
///   child: MyWidget(),
/// )
/// ```
///
/// ## Fill Available Space
///
/// ```dart
/// // Animate from fixed size to filling available bounded space
/// Actor(
///   acts: [
///     .sizedClip(
///       from: NSize(w: 80, h: 60),
///       to: NSize(w: double.infinity, h: double.infinity),
///     ),
///   ],
///   motion: .smooth(damping: 23),
///   child: MyWidget(),
/// )
/// ```
/// {@endtemplate}
class SizedClipAct extends DeferredTweenAct<Size?> {
  
  @override
  final ActKey key = const ActKey('SizedClip');

  final AlignmentGeometry? alignment;
  final Clip clipBehavior;
  final NSize? from;
  final NSize? to;
  final Keyframes<NSize>? frames;
  final ReverseBehaviorBase<NSize> _reverse;
  final ClipGeometry clipGeometry;
  
  /// {@template act.sized_clip}
  /// Animates between two sizes with content clipping.
  ///
  /// [from] and [to] are [NSize] specifications supporting:
  /// - `null` for each axis → use child's natural size
  /// - fixed values → constrain to those pixel dimensions
  /// - `double.infinity` → fill available bounded constraints
  ///
  /// [alignment] controls child positioning within the clipped bounds (defaults to center).
  /// [clipBehavior] controls how clipping is applied (defaults to hardEdge).
  /// [clipGeometry] specifies the clipping shape - rectangular, rounded, or super-ellipse
  /// (defaults to rectangular).
  ///
  /// All infinite dimensions are resolved at animation time based on parent constraints.
  /// The widget must be within bounded constraints if using `double.infinity`.
  ///
  /// ## Width Animation with Child Height
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .sizedClip(
  ///       from: NSize.width(100),  // Fixed width, child height
  ///       to: NSize.width(300),
  ///       clipGeometry: .rrect(BorderRadius.circular(12)),
  ///     ),
  ///   ],
  ///   motion: .smooth(damping: 23),
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## Both Dimensions with Custom Alignment
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .sizedClip(
  ///       from: NSize(w: 80, h: 60),
  ///       to: NSize(w: 200, h: 150),
  ///       alignment: Alignment.topLeft,
  ///       clipGeometry: .superEllipse(
  ///         BorderRadius.circular(16),
  ///       ),
  ///     ),
  ///   ],
  ///   motion: .smooth(damping: 23),
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## To Infinity
  ///
  /// ```dart
  /// // Must be inside a bounded parent
  /// Actor(
  ///   acts: [
  ///     .sizedClip(
  ///       to: NSize.infinity,  // Resolved to parent's constraints
  ///       clipGeometry: .rrect(BorderRadius.circular(20)),
  ///     ),
  ///   ],
  ///   motion: .smooth(damping: 23),
  ///   child: MyWidget(),
  /// )
  /// ```
  /// {@endtemplate}
  const SizedClipAct({
    this.from = NSize.childSize,
    this.to = NSize.childSize,
    super.motion,
    this.alignment,
    this.clipBehavior = Clip.hardEdge,
    this.clipGeometry = const ClipGeometry.rect(),
    super.delay,
    ReverseBehavior<NSize> reverse = const ReverseBehavior.mirror(),
  }) : frames = null,
       _reverse = reverse;

  /// {@template act.sized_clip.keyframed}
  /// Animates through multiple size keyframes with clipping.
  ///
  /// [frames] define multiple [NSize] targets at different times, each supporting
  /// the same resolution rules as the standard constructor:
  /// - `null` → child's natural size
  /// - fixed values → pixel dimensions
  /// - `double.infinity` → fill bounded constraints (resolved at runtime)
  ///
  /// [alignment] controls child positioning within clipped bounds (defaults to center).
  /// [clipBehavior] controls clipping strategy (defaults to hardEdge).
  /// [clipGeometry] specifies the clipping shape (defaults to rectangle).
  ///
  /// ## Keyframed Clip Animation
  ///
  /// Using fractional keyframes with a shared duration:
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     SizedClipAct.keyframed(
  ///       frames: Keyframes.fractional([
  ///         .key(NSize(w: 100, h: 50), at: 0.0),
  ///         .key(NSize(w: 200, h: 100), at: 0.5),
  ///         .key(NSize(w: 150, h: 75), at: 1.0),
  ///       ], duration: 800.ms),
  ///       clipGeometry: .rrect(BorderRadius.circular(12)),
  ///     ),
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## With Infinity Keyframe
  ///
  /// ```dart
  /// // Width animates, height fills available space at last keyframe
  /// Actor(
  ///   acts: [
  ///     SizedClipAct.keyframed(
  ///       frames: Keyframes([
  ///         .key(NSize(w: 100, h: 50)),
  ///         .key(NSize(w: double.infinity, h: double.infinity), motion: Spring.bouncy()),
  ///       ], motion: Spring.smooth()),
  ///       alignment: Alignment.center,
  ///       clipGeometry: .rrect(BorderRadius.circular(16)),
  ///     ),
  ///   ],
  ///   motion: .smooth(damping: 23),
  ///   child: MyWidget(),
  /// )
  /// ```
  /// {@endtemplate}
  const SizedClipAct.keyframed({
    required Keyframes<NSize> this.frames,
    super.delay,
    this.alignment,
    this.clipBehavior = Clip.hardEdge,
    this.clipGeometry = const ClipGeometry.rect(),
    KFReverseBehavior<NSize> reverse = const KFReverseBehavior.mirror(),
  }) : _reverse = reverse,
       from = null,
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
          clipGeometry == other.clipGeometry &&
          frames == other.frames &&
          delay == other.delay &&
          _reverse == other._reverse;

  @override
  int get hashCode => Object.hash(alignment, clipBehavior, from, to, delay, _reverse, frames, clipGeometry);

  @override
  CueAnimation<Size?> buildAnimation(CueTimeline timline, ActContext context) {
    final trackConfig = TrackConfig(
      motion: context.motion,
      reverseMotion: context.reverseMotion,
      reverseType: reverse.type,
    );
    final (track, token) = timline.obtainTrack(trackConfig);
    return DeferredCueAnimation<Size?>(parent: track, token: token, context: context);
  }

  @override
  Widget apply(BuildContext context, DeferredCueAnimation<Size?> animation, Widget child) {
    return _AnimatedSizeClip(
      driver: animation,
      from: from,
      to: to,
      frames: frames,
      reverse: _reverse,
      alignment: alignment ?? Alignment.center,
      clipBehavior: clipBehavior,
      clipGeometry: clipGeometry,
      child: child,
    );
  }

  @override
  ActContext resolve(ActContext context) {
    return TweenActBase.resolveMotion(
      context,
      motion: motion,
      delay: delay,
      reverse: _reverse,
      frames: frames,
    );
  }
}

class _AnimatedSizeClip extends SingleChildRenderObjectWidget {
  const _AnimatedSizeClip({
    required this.driver,
    required this.from,
    required this.to,
    required this.frames,
    required this.reverse,
    this.alignment = Alignment.center,
    this.clipBehavior = Clip.hardEdge,
    required this.clipGeometry,
    required super.child,
  });

  final DeferredCueAnimation<Size?> driver;
  final ReverseBehaviorBase<NSize> reverse;
  final ClipGeometry clipGeometry;
  final NSize? from;
  final NSize? to;
  final Keyframes<NSize>? frames;
  final AlignmentGeometry alignment;
  final Clip clipBehavior;

  @override
  _RenderAnimatedSizeClip createRenderObject(BuildContext context) {
    return _RenderAnimatedSizeClip(
      driver: driver,
      fromSize: from,
      toSize: to,
      frames: frames,
      reverse: reverse,
      alignment: alignment,
      textDirection: Directionality.maybeOf(context),
      clipBehavior: clipBehavior,
      clipGeometry: clipGeometry,
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
      ..frames = frames
      ..reverse = reverse
      ..alignment = alignment
      ..clipBehavior = clipBehavior
      ..textDirection = Directionality.maybeOf(context)
      ..clipGeometry = clipGeometry;
  }
}

class _RenderAnimatedSizeClip extends RenderAligningShiftedBox {
  _RenderAnimatedSizeClip({
    required DeferredCueAnimation<Size?> driver,
    required NSize? fromSize,
    required NSize? toSize,
    required Keyframes<NSize>? frames,
    required ReverseBehaviorBase<NSize> reverse,
    required ClipGeometry clipGeometry,
    super.alignment,
    super.textDirection,
    Clip clipBehavior = Clip.hardEdge,
  }) : _driver = driver,
       _from = fromSize,
       _to = toSize,
       _frames = frames,
       _reverse = reverse,
       _clipBehavior = clipBehavior,
       _clipGeometry = clipGeometry {
    _addintionalConstrains = _calculateAddintionalConstrains();
    _buildClipHandler(clipGeometry);
  }

  DeferredCueAnimation<Size?> _driver;

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

  Keyframes<NSize>? _frames;

  set frames(Keyframes<NSize>? value) {
    if (_frames == value) return;
    _frames = value;
    _invalidateAnimationCache();
  }

  ReverseBehaviorBase<NSize> _reverse;
  set reverse(ReverseBehaviorBase<NSize> value) {
    if (_reverse == value) return;
    _reverse = value;
    _invalidateAnimationCache();
  }

  bool _hasVisualOverflow = false;

  Clip _clipBehavior;

  set clipBehavior(Clip value) {
    if (_clipBehavior == value) return;
    _clipBehavior = value;
    markNeedsPaint();
  }

  ClipGeometry _clipGeometry;

  set clipGeometry(ClipGeometry value) {
    if (_clipGeometry == value) return;
    _clipGeometry = value;
    _clipGeometryHandler.invalidate();
    _buildClipHandler(value);
    markNeedsPaint();
  }

  void _buildClipHandler(ClipGeometry value) {
    switch ((value.borderRadius, value.useSuperEllipse)) {
      case (null, _):
        _clipGeometryHandler = _ClipRectGeometry();
      case (final borderRadius, false):
        _clipGeometryHandler = _ClipRRectGeometry(borderRadius!.resolve(textDirection));
      case (final borderRadius, true):
        _clipGeometryHandler = _ClipSuperEllipseGeometry(borderRadius!.resolve(textDirection));
    }
  }

  _ClipGeometryHandler _clipGeometryHandler = _ClipRectGeometry();

  // Cached animation and related state
  Size? _cachedMaxSize;
  Size? _lastConstraintSize;
  BoxConstraints _addintionalConstrains = BoxConstraints();
  Size? _lastChildNaturalSize;

  void _invalidateAnimationCache() {
    _driver.setAnimatable(null);
    _cachedMaxSize = null;
    _addintionalConstrains = _calculateAddintionalConstrains();
    markNeedsLayout();
  }

  BoxConstraints _calculateAddintionalConstrains() {
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

    if (_frames != null) {
      for (final value in _frames!.values) {
        checkNSize(value);
      }
      if (_reverse.frames != null) {
        for (final value in _reverse.frames!.values) {
          checkNSize(value);
        }
      }
    } else {
      checkNSize(_from);
      checkNSize(_to);
      checkNSize(_reverse.to);
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

  Size _calculateMaxSize(CueTweenBuildHelper<Size?> builder) {
    final allValues = [
      builder.from,
      builder.to,
      ...?builder.frames?.values,
      ...?builder.reverse.frames?.values,
      builder.reverse.to,
    ].whereType<Size>();

    double maxWidth = 0;
    double maxHeight = 0;
    for (final size in allValues) {
      if (size.width > maxWidth) {
        maxWidth = size.width;
      }
      if (size.height > maxHeight) {
        maxHeight = size.height;
      }
    }
    return Size(maxWidth, maxHeight);
  }

  void _buildAnimationIfNeeded(Size maxConstrains, Size childSize) {
    // Check if we need to rebuild the animation
    if (_driver.hasAnimatable && _lastConstraintSize == maxConstrains && _lastChildNaturalSize == childSize) {
      return; // Animation is already built and neither constraints nor child size changed
    }

    final iFrom = _driver.context.implicitFrom as Size?;
    final from = iFrom ?? _resolveSize(_from, maxConstrains, childSize);
    final to = _resolveSize(_to, maxConstrains, childSize);
    final tween = SizeTween(begin: from, end: to);

    // // Build the tween from phases
    final builder = CueTweenBuildHelper<Size?>(
      from: _resolveSize(_from, maxConstrains, childSize),
      to: _resolveSize(_to, maxConstrains, childSize),
      frames: _frames?.mapValues((v) => _resolveSize(v, maxConstrains, childSize)),
      reverse: _reverse.mapValues((v) => _resolveSize(v, maxConstrains, childSize)),
      tweenBuilder: (begin, end) => SizeTween(begin: begin, end: end),
    );
    
    _driver.setAnimatable(builder.buildAnimtable(_driver.context));
    // Build and cache the animation
    _cachedMaxSize = tween.end ?? Size.zero;
    _cachedMaxSize = _calculateMaxSize(builder);
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
    if (child != null && (_hasVisualOverflow || _clipGeometry.borderRadius != null) && _clipBehavior != Clip.none) {
      // When allowOverflow is true, always clip the overflow
      final Rect rect = Offset.zero & size;
      _clipGeometryHandler.push(
        context,
        needsCompositing: needsCompositing,
        offset: offset,
        painter: super.paint,
        rect: rect,
        clipBehavior: _clipBehavior,
      );
    } else {
       _clipGeometryHandler.invalidate();
      super.paint(context, offset);
    }
  }

  @override
  void dispose() {
    _driver.removeListener(markNeedsLayout);
    _clipGeometryHandler.invalidate();
    super.dispose();
  }
}

abstract class _ClipGeometryHandler<L extends Layer> {
  final LayerHandle<L> _handler = LayerHandle<L>();
  void push(
    PaintingContext context, {
    required bool needsCompositing,
    required Offset offset,
    required void Function(PaintingContext, Offset) painter,
    required Rect rect,
    required Clip clipBehavior,
  });

  void invalidate() => _handler.layer = null;
}

class _ClipRectGeometry extends _ClipGeometryHandler<ClipRectLayer> {
  @override
  void push(
    PaintingContext context, {
    required bool needsCompositing,
    required Offset offset,
    required void Function(PaintingContext, Offset) painter,
    required Rect rect,
    required Clip clipBehavior,
  }) {
    _handler.layer = context.pushClipRect(
      needsCompositing,
      offset,
      rect,
      painter,
      clipBehavior: clipBehavior,
      oldLayer: _handler.layer,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _ClipRectGeometry && runtimeType == other.runtimeType;
  @override
  int get hashCode => runtimeType.hashCode;
}

class _ClipRRectGeometry extends _ClipGeometryHandler<ClipRRectLayer> {
  final BorderRadius borderRadius;

  _ClipRRectGeometry(this.borderRadius);

  @override
  void push(
    PaintingContext context, {
    required bool needsCompositing,
    required Offset offset,
    required void Function(PaintingContext, Offset) painter,
    required Rect rect,
    required Clip clipBehavior,
  }) {
    _handler.layer = context.pushClipRRect(
      needsCompositing,
      offset,
      rect,
      borderRadius.toRRect(rect),
      painter,
      clipBehavior: clipBehavior,
      oldLayer: _handler.layer,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ClipRRectGeometry && runtimeType == other.runtimeType && borderRadius == other.borderRadius;

  @override
  int get hashCode => Object.hash(runtimeType, borderRadius);
}

class _ClipSuperEllipseGeometry extends _ClipGeometryHandler<ClipRSuperellipseLayer> {
  final BorderRadius borderRadius;

  _ClipSuperEllipseGeometry(this.borderRadius);

  @override
  void push(
    PaintingContext context, {
    required bool needsCompositing,
    required Offset offset,
    required void Function(PaintingContext, Offset) painter,
    required Rect rect,
    required Clip clipBehavior,
  }) {
    _handler.layer = context.pushClipRSuperellipse(
      needsCompositing,
      offset,
      rect,
      borderRadius.toRSuperellipse(rect),
      painter,
      clipBehavior: clipBehavior,
      oldLayer: _handler.layer,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _ClipSuperEllipseGeometry && runtimeType == other.runtimeType && borderRadius == other.borderRadius;

  @override
  int get hashCode => Object.hash(runtimeType, borderRadius);
}

class ClipGeometry {
  final BorderRadiusGeometry? borderRadius;
  final bool useSuperEllipse;

  const ClipGeometry.rect() : borderRadius = null, useSuperEllipse = false;
  const ClipGeometry.rrect(BorderRadiusGeometry this.borderRadius) : useSuperEllipse = false;
  const ClipGeometry.superEllipse(BorderRadiusGeometry this.borderRadius) : useSuperEllipse = true;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClipGeometry &&
          runtimeType == other.runtimeType &&
          borderRadius == other.borderRadius &&
          useSuperEllipse == other.useSuperEllipse;

  @override
  int get hashCode => Object.hash(runtimeType, borderRadius, useSuperEllipse);
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
