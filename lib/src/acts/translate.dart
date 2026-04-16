part of 'base/act.dart';

/// {@template translate_act}
/// Animates widget position using absolute pixel distances.
///
/// [TranslateAct] moves a widget by pixel amounts. An offset of `Offset(100, 0)`
/// translates the widget right by 100 pixels. An offset of `Offset(0, -50)` translates
/// the widget up by 50 pixels.
///
/// Use [Act.translate()] factory to create instances. This is the recommended approach
/// for most translate animations.
///
/// Unlike [SlideAct], which uses fractional sizing relative to the widget itself,
/// [TranslateAct] uses absolute pixel distances.
///
/// ## Basic Translation Animation
///
/// ```dart
/// // Translate right by 100 pixels
/// Actor(
///   acts: [
///     .translate(from: Offset(-100, 0)), // to defaults to Offset.zero
///   ],
///   child: MyWidget(),
/// )
/// ```
///
/// ## Single-Axis Translation
///
/// For animations where only one axis changes:
///
/// ```dart
/// // Only vertical translation
/// Actor(
///   acts: [
///     .translateY(from: -50),
///   ],
///   child: MyWidget(),
/// )
///
/// // Only horizontal translation
/// Actor(
///   acts: [
///     .translateX(from: 100),
///   ],
///   child: MyWidget(),
/// )
/// ```
///
/// ## Global Coordinate Animations
///
/// Translate from a widget's global position to a local position within a container:
/// Useful for hero-type transitions where a widget moves from one part of the screen to another, potentially across different widget trees.
///
/// ```dart
/// // Move from global coordinates
/// Actor(
///   acts: [
///     .translateFromGlobal(offset: globalOffset),
///     .translateFromGlobalRect(globalRect, alignment: Alignment.center), // Align to center of global rect
///   ],
///   child: MyWidget(),
/// )
/// ```
/// {@endtemplate}
abstract class TranslateAct extends Act {
  /// {@template act.translate}
  /// Animates bidirectional translation using absolute pixel offsets.
  ///
  /// Both [from] and [to] are [Offset] values representing pixel distances.
  /// Use [Offset.zero] for no offset.
  ///
  /// ## Basic Usage
  ///
  /// ```dart
  /// // Translate from left to center
  /// Actor(
  ///   acts: [
  ///     .translate(from: Offset(-100, 0)), // 'to' defaults to Offset.zero
  ///   ],
  ///   motion: .smooth(damping: 23),
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## Diagonal Translation
  ///
  /// ```dart
  /// // Translate diagonally
  /// Actor(
  ///   acts: [
  ///     .translate(from: Offset(-50, 50)), // 'to' defaults to Offset.zero
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  /// {@endtemplate}
  const factory TranslateAct({
    Offset from,
    Offset to,
    CueMotion? motion,
    ReverseBehavior<Offset> reverse,
    Duration delay,
  }) = _TranslateOffset;

  /// {@template act.translate.keyframed}
  /// Animates through multiple translation offset keyframes.
  ///
  /// [frames] define multiple [Offset] targets (in pixels) at different times.
  ///
  /// ## Fractional keyframes with shared duration
  ///
  /// ```dart
  /// Act.translate.keyframed(
  ///   frames: Keyframes([
  ///     .key(Offset(-100, 0)),
  ///     .key(Offset.zero),
  ///     .key(Offset(50, 0)),
  ///   ], duration: 800.ms),
  /// )
  /// ```
  ///
  /// ## Per-keyframe motion with override
  ///
  /// ```dart
  /// Act.translate.keyframed(
  ///   frames: Keyframes(
  ///     [
  ///       .key(Offset(-100, 0)),  // Uses default motion
  ///       .key(Offset.zero, motion: Spring.bouncy()),  // Overrides default
  ///       .key(Offset(50, 0), motion: Linear(300.ms)),  // Overrides default
  ///     ],
  ///     motion: Spring.smooth(),  // Default motion
  ///   ),
  /// )
  /// ```
  /// {@endtemplate}
  const factory TranslateAct.keyframed({
    required Keyframes<Offset> frames,
    KFReverseBehavior<Offset> reverse,
    Duration delay,
  }) = _TranslateOffset.keyframed;

  /// {@template act.translate.x}
  /// Animates horizontal translation only (X-axis).
  ///
  /// [from] and [to] are horizontal offsets in pixels.
  /// Negative values translate left, positive values translate right.
  /// Vertical position remains unchanged.
  ///
  /// ## Horizontal Translation
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .translateX(from: -100),
  ///   ],
  ///   motion: .smooth(damping: 23),
  ///   child: MyWidget(),
  /// )
  /// ```
  /// {@endtemplate}
  const factory TranslateAct.fromX({
    double from,
    double to,
    CueMotion? motion,
    ReverseBehavior<double> reverse,
    Duration delay,
  }) = _AxisTranslate.horizontal;

  /// {@template act.translate.keyframedX}
  /// Animates through multiple horizontal translation keyframes.
  ///
  /// [frames] define multiple horizontal offsets (in pixels) at different times.
  ///
  /// ## Horizontal Keyframes
  ///
  /// ```dart
  /// TranslateAct.keyframedX(
  ///   frames: Keyframes([
  ///     .key(-100),
  ///     .key(0),
  ///     .key(50),
  ///   ], duration: 1000.ms),
  /// )
  /// ```
  /// {@endtemplate}
  const factory TranslateAct.keyframedX({
    required Keyframes<double> frames,
    KFReverseBehavior<double> reverse,
    Duration delay,
  }) = _AxisTranslate.keyframedX;

  /// {@template act.translate.y}
  /// Animates vertical translation only (Y-axis).
  ///
  /// [from] and [to] are vertical offsets in pixels.
  /// Negative values translate up, positive values translate down.
  /// Horizontal position remains unchanged.
  ///
  /// ## Vertical Translation
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .translateY(from: -50), // 'to' defaults to 0
  ///   ],
  ///   motion: .smooth(damping: 23),
  ///   child: MyWidget(),
  /// )
  /// ```
  /// {@endtemplate}
  const factory TranslateAct.y({
    double from,
    double to,
    CueMotion? motion,
    ReverseBehavior<double> reverse,
    Duration delay,
  }) = _AxisTranslate.vertical;

  /// {@template act.translate.keyframedY}
  /// Animates through multiple vertical translation keyframes.
  ///
  /// [frames] define multiple vertical offsets (in pixels) at different times.
  ///
  /// ## Vertical Keyframes
  ///
  /// ```dart
  /// TranslateAct.keyframedY(
  ///   frames: Keyframes([
  ///     .key(-50),
  ///     .key(0),
  ///     .key(25),
  ///   ], motion: .smooth()),
  /// )
  /// ```
  /// {@endtemplate}
  const factory TranslateAct.keyframedY({
    required Keyframes<double> frames,
    KFReverseBehavior<double> reverse,
    Duration delay,
  }) = _AxisTranslate.keyframedY;

  /// {@template act.translate.fromGlobal}
  /// Translates a widget from its current global position to a local position.
  ///
  /// Captures the widget's current position in global coordinates and animates
  /// it to [toLocal] within the local coordinate space of its container.
  /// Useful for animated transitions of widgets being repositioned.
  ///
  /// [offset] is the target global coordinate position.
  /// [toLocal] is the final local coordinate (defaults to [Offset.zero]).
  ///
  /// ## Global Position Animation
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .translateFromGlobal(offset: Offset(200, 150)),
  ///   ],
  ///   motion: .smooth(damping: 23),
  ///   child: MyWidget(),
  /// )
  /// ```
  /// {@endtemplate}
  const factory TranslateAct.fromGlobal({
    required Offset offset,
    Offset toLocal,
    CueMotion? motion,
    Duration delay,
  }) = _TranslateFromGlobalAct.offset;

  /// {@template act.translate.fromGlobalRect}
  /// Translates a widget from a global [Rect] to its current local position.
  ///
  /// Captures the target position from a global rectangle and animates the widget
  /// to align with the specified [alignment] point within that rectangle.
  /// Useful for animating widgets from external coordinate spaces.
  ///
  /// [rect] is the target global rectangle.
  /// [alignment] specifies which point of the rectangle to animate towards (defaults to center).
  /// [toLocal] is the final local coordinate (defaults to [Offset.zero]).
  ///
  /// ## Rectangle-based Global Animation
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .translateFromGlobalRect(
  ///       globalRect,
  ///       alignment: Alignment.center,
  ///     ),
  ///   ],
  ///   motion: .smooth(damping: 23),
  ///   child: MyWidget(),
  /// )
  /// ```
  /// {@endtemplate}
  const factory TranslateAct.fromGlobalRect(
    Rect rect, {
    AlignmentGeometry alignment,
    Offset toLocal,
    CueMotion? motion,
    Duration delay,
  }) = _TranslateFromGlobalAct.fromRect;

  /// {@template act.translate.fromGlobalKey}
  /// Translates a widget from another widget's global position (identified by key).
  ///
  /// Uses a [GlobalKey] to find the target widget's position in global coordinates,
  /// then animates the current widget to align with the specified [alignment] point
  /// within that target widget's bounds.
  ///
  /// [key] is the [GlobalKey] of the widget to animate from.
  /// [alignment] specifies which point of the target widget to animate towards (defaults to center).
  /// [toLocal] is the final local coordinate (defaults to [Offset.zero]).
  ///
  /// ## Key-based Global Animation
  ///
  /// ```dart
  /// final targetKey = GlobalKey();
  ///
  /// // In build:
  /// Column(
  ///   children: [
  ///     Target(key: targetKey),
  ///     Actor(
  ///       acts: [
  ///         .translateFromGlobalKey(targetKey),
  ///       ],
  ///       motion: .smooth(damping: 23),
  ///       child: MyWidget(),
  ///     ),
  ///   ],
  /// )
  /// ```
  /// {@endtemplate}
  const factory TranslateAct.fromGlobalKey(
    GlobalKey key, {
    AlignmentGeometry alignment,
    Offset toLocal,
    CueMotion? motion,
    Duration delay,
  }) = _TranslateFromGlobalAct.fromKey;
}

class _TranslateOffset extends TweenAct<Offset> implements TranslateAct {
  @override
  final ActKey key = const ActKey('Translate');

  const _TranslateOffset({
    super.from = Offset.zero,
    super.to = Offset.zero,
    super.motion,
    super.reverse,
    super.delay,
  }) : super.tween();

  const _TranslateOffset.keyframed({
    required super.frames,
    super.reverse,
    super.delay,
  }) : super.keyframed(from: Offset.zero);

  @override
  Widget apply(BuildContext context, CueAnimation<Offset> animation, Widget child) {
    return TranslateTransition(offset: animation, child: child);
  }
}

class _AxisTranslate extends TweenActBase<double, Offset> implements TranslateAct {
  @override
  final ActKey key = const ActKey('Translate');

  final Axis _axis;

  const _AxisTranslate.vertical({
    super.from = 0,
    super.to = 0,
    super.motion,
    super.reverse,
    super.delay,
  }) : _axis = Axis.vertical,
       super.tween();

  const _AxisTranslate.horizontal({
    super.from = 0,
    super.to = 0,
    super.motion,
    super.reverse,
    super.delay,
  }) : _axis = Axis.horizontal,
       super.tween();

  const _AxisTranslate.keyframedY({
    required super.frames,
    super.delay,
    super.reverse,
  }) : _axis = Axis.vertical,
       super.keyframed(from: 0);

  const _AxisTranslate.keyframedX({
    required super.frames,
    super.delay,
    super.reverse,
  }) : _axis = Axis.horizontal,
       super.keyframed(from: 0);

  @override
  Offset transform(_, double value) {
    switch (_axis) {
      case Axis.horizontal:
        return Offset(value, 0);
      case Axis.vertical:
        return Offset(0, value);
    }
  }

  @override
  Widget apply(BuildContext context, CueAnimation<Offset> animation, Widget child) {
    return TranslateTransition(offset: animation, child: child);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is _AxisTranslate && super == (other) && _axis == other._axis;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, _axis);
}

/// A widget that applies a translate transform based on an animation.
class TranslateTransition extends AnimatedWidget {
  /// The child widget to transform.
  final Widget child;

  /// The animation that provides the offset values.
  final Animation<Offset> offset;

  /// Whether to transform hit tests to match the visual translation.
  final bool transformHitTests;

  /// Creates a TranslateTransition with the given configuration.
  const TranslateTransition({
    super.key,
    required this.child,
    required this.offset,
    this.transformHitTests = true,
  }) : super(listenable: offset);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      transformHitTests: transformHitTests,
      offset: offset.value,
      child: child,
    );
  }
}

class _TranslateFromGlobalAct extends DeferredTweenAct<Offset> implements TranslateAct {
  @override
  final ActKey key = const ActKey('Translate');

  final Offset? offset;
  final Rect? rect;
  final AlignmentGeometry? alignment;
  final GlobalKey? globalKey;
  final Offset toLocal;

  const _TranslateFromGlobalAct.offset({
    required Offset this.offset,
    this.toLocal = Offset.zero,
    super.delay,
    super.motion,
  }) : rect = null,
       alignment = null,
       globalKey = null;

  const _TranslateFromGlobalAct.fromRect(
    this.rect, {
    this.toLocal = Offset.zero,
    this.alignment = Alignment.center,
    super.motion,
    super.delay,
  }) : offset = null,
       globalKey = null;

  const _TranslateFromGlobalAct.fromKey(
    GlobalKey this.globalKey, {
    this.toLocal = Offset.zero,
    this.alignment = Alignment.center,
    super.motion,
    super.delay,
  }) : offset = null,
       rect = null;

  @override
  Widget apply(BuildContext context, DeferredCueAnimation<Offset> animation, Widget child) {
    return _TranslateFromGlobalTransition(
      driver: animation,
      globalOffset: offset,
      globalRect: rect,
      globalKey: globalKey,
      alignment: alignment,
      toLocal: toLocal,
      child: child,
    );
  }

  @override
  ActContext resolve(ActContext context) {
    return TweenActBase.resolveMotion(
      context,
      reverse: reverse,
      motion: motion,
    );
  }
}

class _TranslateFromGlobalTransition extends SingleChildRenderObjectWidget {
  final Offset? globalOffset;
  final Rect? globalRect;
  final AlignmentGeometry? alignment;
  final Offset toLocal;
  final GlobalKey? globalKey;
  final DeferredCueAnimation<Offset> driver;

  const _TranslateFromGlobalTransition({
    super.child,
    this.globalOffset,
    this.globalRect,
    this.alignment,
    this.globalKey,
    required this.driver,
    this.toLocal = Offset.zero,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderTranslateFromGlobal(
      driver: driver,
      globalOffset: globalOffset,
      globalRect: globalRect,
      globalKey: globalKey,
      alignment: alignment,
      toLocal: toLocal,
      textDirection: Directionality.maybeOf(context),
    );
  }

  @override
  void updateRenderObject(BuildContext context, _RenderTranslateFromGlobal renderObject) {
    renderObject
      ..driver = driver
      ..globalOffset = globalOffset
      ..globalRect = globalRect
      ..globalKey = globalKey
      ..alignment = alignment
      ..toLocal = toLocal
      ..textDirection = Directionality.maybeOf(context);
  }
}

class _RenderTranslateFromGlobal extends RenderProxyBox {
  _RenderTranslateFromGlobal({
    required DeferredCueAnimation<Offset> driver,
    Offset? globalOffset,
    Rect? globalRect,
    GlobalKey? globalKey,
    AlignmentGeometry? alignment,
    required Offset toLocal,
    TextDirection? textDirection,
  }) : _driver = driver,
       _globalOffset = globalOffset,
       _globalRect = globalRect,
       _globalKey = globalKey,
       _alignment = alignment,
       _toLocal = toLocal,
       _textDirection = textDirection {
    _driver.addListener(markNeedsPaint);
  }

  DeferredCueAnimation<Offset> _driver;
  set driver(DeferredCueAnimation<Offset> value) {
    if (_driver == value) return;
    _driver.removeListener(markNeedsPaint);
    _driver = value;
    _driver.addListener(markNeedsPaint);
    markNeedsLayout();
  }

  Offset? _globalOffset;
  set globalOffset(Offset? value) {
    if (_globalOffset == value) return;
    _globalOffset = value;
    _markNeedsMeasure();
  }

  Rect? _globalRect;
  set globalRect(Rect? value) {
    if (_globalRect == value) return;
    _globalRect = value;
    _markNeedsMeasure();
  }

  GlobalKey? _globalKey;
  set globalKey(GlobalKey? value) {
    if (_globalKey == value) return;
    _globalKey = value;
    _markNeedsMeasure();
  }

  AlignmentGeometry? _alignment;
  set alignment(AlignmentGeometry? value) {
    if (_alignment == value) return;
    _alignment = value;
    _markNeedsMeasure();
  }

  Offset _toLocal;
  set toLocal(Offset value) {
    if (_toLocal == value) return;
    _toLocal = value;
    _markNeedsMeasure();
  }

  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection == value) return;
    _textDirection = value;
    _markNeedsMeasure();
  }

  void _markNeedsMeasure() {
    _driver.setAnimatable(null);
    markNeedsPaint();
  }

  @override
  void detach() {
    _driver.removeListener(markNeedsPaint);
    super.detach();
  }

  Offset _measureOffset() {
    final renderBox = this;
    final targetGlobal = renderBox.localToGlobal(Offset.zero);
    Offset beginOffset;
    if (_globalOffset case final global?) {
      beginOffset = global - targetGlobal;
    } else {
      final rect = _globalRect ?? _rectFor(_globalKey!);
      final alignment = _alignment!.resolve(_textDirection ?? TextDirection.ltr);
      final targetRect = alignment.inscribe(renderBox.size, rect);
      beginOffset = targetRect.topLeft - targetGlobal;
    }
    return beginOffset;
  }

  void _buildAnimation() {
    Offset beginOffset = _measureOffset();
    final builder = CueTweenBuildHelper(
      from: beginOffset,
      to: _toLocal,
      tweenBuilder: (from, to) => Tween<Offset>(begin: from, end: to),
    );
    _driver.setAnimatable(builder.buildAnimtable(_driver.context));
  }

  Rect _rectFor(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) {
      return Rect.zero;
    }
    final targetGlobal = renderBox.localToGlobal(Offset.zero);
    return targetGlobal & renderBox.size;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_driver.hasAnimatable) {
      _buildAnimation();
    }
    final translation = _driver.value;
    super.paint(context, offset + translation);
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {
    Offset offset = Offset.zero;
    if (_driver.hasAnimatable) {
      offset = _driver.value;
    } else  {
      offset = _measureOffset();
    }
    transform.translateByDouble(offset.dx, offset.dy, 0, 1);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (!_driver.hasAnimatable) return false;
    return child!.hitTest(result, position: position - _driver.value);
  }
}
