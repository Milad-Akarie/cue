part of 'base/act.dart';

/// Animates card-like surface properties: elevation shadow, background color,
/// shadow color, surface tint color, and shape (border radius or arbitrary
/// [ShapeBorder]).
///
/// Unlike Flutter's [Card] widget, this does not provide ink effects or
/// Material theme integration. It uses [PhysicalShape] internally for
/// efficient, externally-driven animation.
///
/// Use [borderRadius] for the common case of animating rounded corners on a
/// rectangle. Use [shape] for arbitrary [ShapeBorder] animations (e.g.
/// [StadiumBorder], [BeveledRectangleBorder]). The two are mutually exclusive.
///
/// **Prefer [CardActor] for simple card-only animations** — it provides better
/// readability than composing [Actor] + [CardAct] directly.
class CardAct extends AnimtableAct<CardProps, CardProps> {
  @override
  final ActKey key = const ActKey('Card');

  final Clip clipBehavior;
  final bool borderOnForeground;
  final AnimatableValue<Color>? color;
  final AnimatableValue<Color> shadowColor;
  final AnimatableValue<Color>? surfaceTintColor;
  final AnimatableValue<double>? elevation;
  final AnimatableValue<BorderRadiusGeometry>? borderRadius;
  final AnimatableValue<EdgeInsetsGeometry>? margin;
  final AnimatableValue<ShapeBorder>? shape;
  final bool semanticContainer;
  final Keyframes<CardProps>? frames;

  /// {@template act.card}
  /// Animates card surface properties like elevation, color, radius, and shadow.
  ///
  /// Wraps the child in a [PhysicalShape] that renders elevation shadows,
  /// background color, and an optional border radius or custom shape.
  ///
  /// Multiple properties can be animated simultaneously by providing
  /// [AnimatableValue] (tween) or [Keyframes] (keyframed) for each:
  /// - [elevation] — shadow depth
  /// - [color] — background fill color
  /// - [shadowColor] — shadow tint
  /// - [surfaceTintColor] — Material 3 surface tint
  /// - [borderRadius] — corner rounding (mutually exclusive with [shape])
  /// - [shape] — arbitrary [ShapeBorder]
  /// - [margin] — spacing around the card
  ///
  /// Use `AnimatableValue.tween()` to animate a property, or
  /// `AnimatableValue.fixed()` to keep it constant (not animated).
  ///
  /// ## Basic usage
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     CardAct(
  ///       elevation: .fixed(2), // this value will not animate, stays at 2
  ///       color: .tween(Colors.grey[100], Colors.blue[50]),
  ///       borderRadius: .tween(
  ///         .circular(4),
  ///         .circular(12),
  ///       ),
  ///     ),
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## Elevation only
  ///
  /// ```dart
  /// CardAct(
  ///   elevation: .tween(2, 12),
  /// )
  /// ```
  ///
  /// ## Color and shadow tint
  ///
  /// ```dart
  /// CardAct(
  ///   color: .tween(Colors.white, Colors.blue[50]),
  ///   shadowColor: .tween(Colors.grey, Colors.blue),
  /// )
  /// ```
  ///
  /// ## Mixed: animate some, fix others
  ///
  /// ```dart
  /// CardAct(
  ///   elevation: .tween(2, 8),
  ///   color: .fixed(Colors.white),  // stays white, does not animate
  ///   borderRadius: .tween(
  ///     BorderRadius.circular(8),
  ///     BorderRadius.circular(16),
  ///   ),
  /// )
  /// ```
  /// {@endtemplate}
  const CardAct({
    super.motion,
    ReverseBehavior<CardProps> super.reverse = const ReverseBehavior.mirror(),
    this.color,
    this.borderRadius,
    this.shadowColor = const AnimatableValue.fixed(Color(0xFF000000)),
    this.margin,
    this.shape,
    this.elevation,
    this.surfaceTintColor,
    this.clipBehavior = Clip.none,
    this.borderOnForeground = true,
    this.semanticContainer = true,
    super.delay,
  }) : frames = null,
       assert(
         shape == null || borderRadius == null,
         'Cannot specify both shape and borderRadius. '
         'Use shape for arbitrary ShapeBorder, or borderRadius for rounded rectangles.',
       );

  /// {@template act.card.keyframed}
  /// Animates card properties through a sequence of keyframes.
  ///
  /// Use when the card needs to transition through multiple states, with
  /// each step having its own motion curve. Pass a [Keyframes] containing
  /// a sequence of [CardProps] values.
  ///
  /// ```dart
  /// CardAct.keyframed(
  ///   frames: Keyframes(
  ///     motion: Spring.smooth(),
  ///     frames: [
  ///       KeyFrame(
  ///         CardProps(
  ///           elevation: 2,
  ///           color: Colors.white,
  ///           borderRadius: BorderRadius.circular(4),
  ///         ),
  ///       ),
  ///       KeyFrame(
  ///         CardProps(
  ///           elevation: 8,
  ///           color: Colors.blue[50],
  ///           borderRadius: BorderRadius.circular(12),
  ///         ),
  ///         motion: Spring.bouncy(),
  ///       ),
  ///       KeyFrame(
  ///         CardProps(
  ///           elevation: 2,
  ///           color: Colors.white,
  ///           borderRadius: BorderRadius.circular(4),
  ///         ),
  ///       motion: .bouncy()),
  ///       ),
  ///     ],
  ///     motion: .smooth(), // default motion for all frames without specific motion
  ///   ),
  /// )
  /// ```
  /// {@endtemplate}
  const CardAct.keyframed({
    required Keyframes<CardProps> this.frames,
    super.delay,
    KFReverseBehavior<CardProps> super.reverse = const KFReverseBehavior.mirror(),
  }) : color = null,
       shadowColor = const AnimatableValue.fixed(Color(0xFF000000)),
       surfaceTintColor = null,
       elevation = null,
       borderRadius = null,
       shape = null,
       margin = null,
       clipBehavior = Clip.none,
       borderOnForeground = true,
       semanticContainer = true;

  @override
  (CueAnimtable<CardProps>, CueAnimtable<CardProps>?) buildTweens(ActContext context) {
    final from = CardProps(
      elevation: elevation?.from,
      color: color?.from,
      shadowColor: shadowColor.from,
      surfaceTintColor: surfaceTintColor?.from,
      borderRadius: borderRadius?.from,
      shape: shape?.from,
      margin: margin?.from,
    );
    final to = CardProps(
      elevation: elevation?.to,
      color: color?.to,
      shadowColor: shadowColor.to,
      surfaceTintColor: surfaceTintColor?.to,
      borderRadius: borderRadius?.to,
      shape: shape?.to,
      margin: margin?.to,
    );
    final builder = CueTweenBuildHelper(
      from: from,
      to: to,
      frames: frames,
      reverse: reverse,
      tweenBuilder: (begin, end) => _CardPropsProxyTween(begin: begin, end: end),
    );
    return builder.buildTweens(context);
  }

  @override
  Widget apply(BuildContext context, covariant Animation<CardProps> animation, Widget child) {
    final textDirection = Directionality.maybeOf(context);

    // Local function closes over textDirection, avoiding repeated argument passing.
    ({ShapeBorderClipper clipper, _ShapeBorderPainter? painter, bool hasBorderStroke}) resolveShape(
      CardProps props,
    ) {
      final resolvedShape =
          props.shape ??
          (props.borderRadius != null
              ? RoundedRectangleBorder(borderRadius: props.borderRadius!)
              : const RoundedRectangleBorder());
      final hasBorderStroke = !resolvedShape.preferPaintInterior;
      return (
        clipper: ShapeBorderClipper(shape: resolvedShape, textDirection: textDirection),
        painter: hasBorderStroke ? _ShapeBorderPainter(resolvedShape, textDirection) : null,
        hasBorderStroke: hasBorderStroke,
      );
    }

    // When shape/borderRadius is constant (not animating), pre-build the shape
    // objects once outside the builder to avoid per-frame allocations.
    final isShapeConstant = (shape?.isConstant ?? true) && (borderRadius?.isConstant ?? true);
    final cached = isShapeConstant ? resolveShape(animation.value) : null;
    final CardThemeData cardTheme = CardTheme.of(context);
    return Semantics(
      container: semanticContainer,
      child: AnimatedBuilder(
        animation: animation,
        child: Semantics(explicitChildNodes: !semanticContainer, child: child),
        builder: (context, child) {
          final props = animation.value;
          final (:clipper, :painter, :hasBorderStroke) = cached ?? resolveShape(props);
          final effectiveElevation = props.elevation ?? cardTheme.elevation ?? 1.0;
          return Padding(
            padding: props.margin ?? cardTheme.margin ?? EdgeInsets.zero,
            child: PhysicalShape(
              clipper: clipper,
              elevation: effectiveElevation,
              color: ElevationOverlay.applySurfaceTint(
                props.color ?? cardTheme.color ?? const Color(0xFFFFFFFF),
                props.surfaceTintColor ?? cardTheme.surfaceTintColor,
                effectiveElevation,
              ),
              shadowColor: props.shadowColor ?? cardTheme.shadowColor ?? const Color(0xFF000000),
              clipBehavior: clipBehavior,
              child: hasBorderStroke
                  ? CustomPaint(
                      foregroundPainter: borderOnForeground ? painter : null,
                      painter: borderOnForeground ? null : painter,
                      child: child,
                    )
                  : child!,
            ),
          );
        },
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is CardAct &&
        other.color == color &&
        other.shadowColor == shadowColor &&
        other.surfaceTintColor == surfaceTintColor &&
        other.elevation == elevation &&
        other.borderRadius == borderRadius &&
        other.shape == shape &&
        other.margin == margin &&
        other.semanticContainer == semanticContainer &&
        other.frames == frames &&
        other.clipBehavior == clipBehavior &&
        other.borderOnForeground == borderOnForeground;
  }

  @override
  int get hashCode => Object.hash(
    color,
    shadowColor,
    surfaceTintColor,
    elevation,
    borderRadius,
    shape,
    clipBehavior,
    borderOnForeground,
    semanticContainer,
    margin,
    frames,
  );

  @override
  ActContext resolve(ActContext context) {
    return TweenActBase.resolveMotion(
      context,
      motion: motion,
      delay: delay,
      frames: frames,
      reverse: reverse,
    );
  }
}

class _ShapeBorderPainter extends CustomPainter {
  _ShapeBorderPainter(this.border, this.textDirection);
  final ShapeBorder border;
  final TextDirection? textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    border.paint(canvas, Offset.zero & size, textDirection: textDirection);
  }

  @override
  bool shouldRepaint(_ShapeBorderPainter oldDelegate) {
    return oldDelegate.border != border;
  }
}

/// A snapshot of card surface properties at a specific point in animation.
///
/// [CardProps] holds the current values of [elevation], [color], [shadowColor],
/// [surfaceTintColor], [borderRadius], [shape], and [margin]. Used internally
/// by [CardAct] to animate between different card states via tweening and
/// keyframing.
///
/// Values are nullable except [shadowColor], which defaults to opaque black.
class CardProps {
  /// Shadow depth. Non-null indicates an elevation value is animating.
  final double? elevation;

  /// Background fill color. Null means use theme default.
  final Color? color;

  /// Color of the elevation shadow. Defaults to [Color(0xFF000000)].
  final Color? shadowColor;

  /// Material 3 surface tint overlay color. Null means no tint.
  final Color? surfaceTintColor;

  /// Border radius for rounded corners. Mutually exclusive with [shape].
  final BorderRadiusGeometry? borderRadius;

  /// Arbitrary shape border (e.g., stadium, beveled). Mutually exclusive with [borderRadius].
  final ShapeBorder? shape;

  /// Spacing around the card. Null means no margin.
  final EdgeInsetsGeometry? margin;

  const CardProps({
    this.elevation = 0,
    this.color,
    this.borderRadius,
    this.shape,
    this.shadowColor = const Color(0xFF000000),
    this.surfaceTintColor,
    this.margin,
  }) : assert(
         shape == null || borderRadius == null,
         'Cannot specify both shape and borderRadius.',
       );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is CardProps &&
        other.elevation == elevation &&
        other.color == color &&
        other.shadowColor == shadowColor &&
        other.surfaceTintColor == surfaceTintColor &&
        other.borderRadius == borderRadius &&
        other.shape == shape &&
        other.margin == margin;
  }

  @override
  int get hashCode => Object.hash(
    elevation,
    color,
    shadowColor,
    surfaceTintColor,
    borderRadius,
    shape,
    margin,
  );

  static CardProps lerp(CardProps a, CardProps b, double t) {
    return CardProps(
      elevation: lerpDouble(a.elevation, b.elevation, t),
      color: Color.lerp(a.color, b.color, t),
      shadowColor: Color.lerp(a.shadowColor, b.shadowColor, t),
      surfaceTintColor: Color.lerp(a.surfaceTintColor, b.surfaceTintColor, t),
      borderRadius: BorderRadiusGeometry.lerp(a.borderRadius, b.borderRadius, t),
      shape: ShapeBorder.lerp(a.shape, b.shape, t),
      margin: EdgeInsetsGeometry.lerp(a.margin, b.margin, t),
    );
  }
}

class _CardPropsProxyTween extends Tween<CardProps> {
  _CardPropsProxyTween({super.begin, super.end});

  @override
  CardProps transform(double t) {
    return CardProps.lerp(begin!, end!, t);
  }
}

/// A convenience widget that animates card-like surface properties.
///
/// [CardActor] is a pre-composed widget that wraps [Actor] + [CardAct] for
/// simple cases where only card properties (elevation, color, radius, shadow)
/// need animation.
///
/// For more complex animations combining card properties with other acts
/// (scale, blur, etc.), use [Actor] directly with [CardAct] in the acts list.
///
/// ## Usage
///
/// ```dart
/// CardActor(
///   elevation: .tween(2, 8),
///   color: .tween(Colors.white, Colors.blue[50]),
///   borderRadius: .tween(
///     BorderRadius.circular(4),
///     BorderRadius.circular(12),
///   ),
///   child: MyCard(),
/// )
/// ```
///
/// ## Animation control
///
/// Control animation timing with [motion], [delay], and [reverse]:
///
/// ```dart
/// CardActor(
///   elevation: .tween(2, 8),
///   motion: .smooth(),
///   delay: 100.ms,
///   reverse: .exclusive(),
///   child: MyCard(),
/// )
/// ```
///
/// ## Fixed properties
///
/// Use `AnimatableValue.fixed()` for properties that should not animate:
///
/// ```dart
/// CardActor(
///   elevation: .tween(2, 8),
///   color: .fixed(Colors.white),  // stays constant
///   borderRadius: .tween(
///     BorderRadius.circular(8),
///     BorderRadius.circular(16),
///   ),
///   child: MyCard(),
/// )
/// ```
///
/// ## Combining with other acts
///
/// For card animation + other effects (scale, fade, blur), use [Actor]
/// directly instead of [CardActor]:
///
/// ```dart
/// Actor(
///   acts: [
///     CardAct(elevation: .tween(2, 8)),
///     .scale(from: 0.9, to: 1.0),
///     .fadeIn(),
///   ],
///   child: MyCard(),
/// )
/// ```
class CardActor extends StatelessWidget {
  final AnimatableValue<Color>? color;
  final AnimatableValue<Color> shadowColor;
  final AnimatableValue<Color>? surfaceTintColor;
  final AnimatableValue<double>? elevation;
  final AnimatableValue<BorderRadiusGeometry>? borderRadius;
  final AnimatableValue<ShapeBorder>? shape;
  final AnimatableValue<EdgeInsetsGeometry>? margin;
  final Clip clipBehavior;
  final bool borderOnForeground;
  final Widget? child;
  final CueMotion? motion;
  final ReverseBehavior<CardProps> reverse;
  final Duration delay;

  const CardActor({
    super.key,
    this.color,
    this.shadowColor = const AnimatableValue.fixed(Color(0xFF000000)),
    this.surfaceTintColor,
    this.elevation,
    this.borderRadius,
    this.shape,
    this.clipBehavior = Clip.none,
    this.borderOnForeground = true,
    this.margin,
    this.child,
    this.motion,
    this.reverse = const ReverseBehavior.mirror(),
    this.delay = Duration.zero,
  }) : assert(
         shape == null || borderRadius == null,
         'Cannot specify both shape and borderRadius. '
         'Use shape for arbitrary ShapeBorder, or borderRadius for rounded rectangles.',
       );

  @override
  Widget build(BuildContext context) {
    return Actor(
      acts: [
        CardAct(
          color: color,
          shadowColor: shadowColor,
          surfaceTintColor: surfaceTintColor,
          elevation: elevation,
          borderRadius: borderRadius,
          shape: shape,
          clipBehavior: clipBehavior,
          borderOnForeground: borderOnForeground,
          margin: margin,
          motion: motion,
          reverse: reverse,
          delay: delay,
        ),
      ],
      child: child ?? const SizedBox.shrink(),
    );
  }
}
