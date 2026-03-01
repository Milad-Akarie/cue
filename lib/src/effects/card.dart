part of 'base/effect.dart';

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
class CardEffect extends MulitTweenEffect<CardProps> {
  final Clip clipBehavior;
  final bool borderOnForeground;
  final ColorProp? color;
  final ColorProp shadowColor;
  final ColorProp? surfaceTintColor;
  final DoubleProp? elevation;
  final BorderRadiusProp? borderRadius;
  final EdgeInsetsProp? margin;
  final ShapeBorderProp? shape;
  final bool semanticContainer;

  CardEffect({
    this.color,
    this.borderRadius,
    this.shape,
    this.elevation,
    this.surfaceTintColor,
    this.clipBehavior = Clip.none,
    this.borderOnForeground = true,
    this.shadowColor = const ColorProp.fixed(Color(0xFF000000)),
    super.timing,
    super.curve,
    this.semanticContainer = true,
    this.margin,
  }) : assert(
         shape == null || borderRadius == null,
         'Cannot specify both shape and borderRadius. '
         'Use shape for arbitrary ShapeBorder, or borderRadius for rounded rectangles.',
       );

  @override
  Animatable<CardProps> buildTween(ActorContext context) {
    final ctx = context.copyWith(timing: timing, curve: curve);
    return _CardPropsProxyTween(
      elevation: elevation?.asAnimtable(ctx),
      color: color?.asAnimtable(ctx),
      shadowColor: shadowColor.asAnimtable(ctx),
      surfaceTintColor: surfaceTintColor?.asAnimtable(ctx),
      borderRadius: borderRadius?.asAnimtable(ctx),
      shape: shape?.asAnimtable(ctx),
      margin: margin?.asAnimtable(ctx),
    );
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
    return other is CardEffect &&
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
  final BorderRadius? borderRadius;
  final ShapeBorder? shape;
  final EdgeInsets? margin;

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
}

class _CardPropsProxyTween extends Animatable<CardProps> {
  final Animatable<double>? elevation;
  final Animatable<Color?>? color;
  final Animatable<Color?>? shadowColor;
  final Animatable<Color?>? surfaceTintColor;
  final Animatable<BorderRadius?>? borderRadius;
  final Animatable<ShapeBorder?>? shape;
  final Animatable<EdgeInsets?>? margin;
  const _CardPropsProxyTween({
    this.elevation,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.borderRadius,
    this.margin,
    this.shape,
  });

  @override
  CardProps transform(double t) {
    return CardProps(
      elevation: elevation?.transform(t) ?? 0,
      color: color?.transform(t),
      shadowColor: shadowColor?.transform(t),
      surfaceTintColor: surfaceTintColor?.transform(t),
      borderRadius: borderRadius?.transform(t),
      margin: margin?.transform(t),
      shape: shape?.transform(t),
    );
  }
}

/// A convenience widget that animates card-like surface properties using
/// [CardEffect].
///
/// Wraps an [RawActor] with a single [CardEffect]. For composing multiple effects,
/// use [RawActor] directly with [CardEffect] in the effects list.
class CardActor extends StatelessWidget {
  final ColorProp? color;
  final ColorProp? shadowColor;
  final ColorProp? surfaceTintColor;
  final DoubleProp? elevation;
  final BorderRadiusProp? borderRadius;
  final ShapeBorderProp? shape;
  final EdgeInsetsProp? margin;
  final Clip clipBehavior;
  final bool borderOnForeground;
  final Widget? child;
  final Timing? timing;
  final Timing? reverseTiming;
  final Curve? curve;
  final Curve? reverseCurve;
  final ActorRole role;

  const CardActor({
    super.key,
    this.color,
    this.shadowColor,
    this.surfaceTintColor,
    this.elevation,
    this.borderRadius,
    this.shape,
    this.clipBehavior = Clip.none,
    this.borderOnForeground = true,
    this.margin,
    this.child,
    this.timing,
    this.reverseTiming,
    this.curve,
    this.reverseCurve,
    this.role = ActorRole.both,
  }) : assert(
         shape == null || borderRadius == null,
         'Cannot specify both shape and borderRadius. '
         'Use shape for arbitrary ShapeBorder, or borderRadius for rounded rectangles.',
       );

  @override
  Widget build(BuildContext context) {
    return RawActor(
      curve: curve,
      timing: timing,
      reverseCurve: reverseCurve,
      reverseTiming: reverseTiming,
      role: role,
      effects: [
        CardEffect(
          color: color,
          shadowColor: shadowColor ?? const ColorProp.fixed(Color(0xFF000000)),
          surfaceTintColor: surfaceTintColor,
          elevation: elevation,
          borderRadius: borderRadius,
          shape: shape,
          clipBehavior: clipBehavior,
          borderOnForeground: borderOnForeground,
          margin: margin,
        ),
      ],
      child: child ?? const SizedBox.shrink(),
    );
  }
}
