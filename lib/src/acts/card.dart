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
class CardAct extends ActImpl<CardProps, CardProps> {
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

  CardAct({
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
  }) : assert(
         shape == null || borderRadius == null,
         'Cannot specify both shape and borderRadius. '
         'Use shape for arbitrary ShapeBorder, or borderRadius for rounded rectangles.',
       );

  @override
  (CueAnimtable<CardProps> animtable, CueAnimtable<CardProps>? reverseAnimtable) buildTweens(ActContext context) {
    final iFrom = context.implicitFrom as CardProps?;
    final from =
        iFrom ??
        CardProps(
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
    return (TweenAnimtable(_CardPropsProxyTween(begin: from, end: to), motion: motion ?? context.motion), null);
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
  );
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

class CardProps {
  final double? elevation;
  final Color? color;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final BorderRadiusGeometry? borderRadius;
  final ShapeBorder? shape;
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

/// A convenience widget that animates card-like surface properties using
/// [CardAct].
///
/// Wraps an [Actor] with a single [CardAct]. For composing multiple effects,
/// use [Actor] directly with [CardAct] in the effects list.
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
  }) : assert(
         shape == null || borderRadius == null,
         'Cannot specify both shape and borderRadius. '
         'Use shape for arbitrary ShapeBorder, or borderRadius for rounded rectangles.',
       );

  @override
  Widget build(BuildContext context) {
    return Actor(
      act: CardAct(
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
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }
}
