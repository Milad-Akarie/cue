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
class CardAct extends MulitTweenAct<CardProps> {
  final Clip clipBehavior;
  final bool borderOnForeground;
  final AnimtableColor? color;
  final AnimtableColor shadowColor;
  final AnimtableColor? surfaceTintColor;
  final AnimatableValue<double>? elevation;
  final AnimtableBorderRadius? borderRadius;
  final AnimtableEdgeInsets? margin;
  final AnimtableShapeBorder? shape;
  final bool semanticContainer;

  CardAct({
    this.color,
    this.borderRadius,
    this.shape,
    this.elevation,
    this.surfaceTintColor,
    this.clipBehavior = Clip.none,
    this.borderOnForeground = true,
    this.shadowColor = const AnimtableColor.fixed(Color(0xFF000000)),
    super.motion,
    super.reverseMotion,
    this.semanticContainer = true,
    this.margin,
  }) : assert(
         shape == null || borderRadius == null,
         'Cannot specify both shape and borderRadius. '
         'Use shape for arbitrary ShapeBorder, or borderRadius for rounded rectangles.',
       );

  @override
  CueAnimtable<CardProps> buildTween(ActContext context) {
    final iFrom = context.implicitFrom as CardProps?;
    ActContext withFrom(Object? from) {
      return context.copyWith(implicitFrom: from);
    }

    return _CardPropsProxyTween(
      elevation: elevation?.buildAnimtable(withFrom(iFrom?.elevation)),
      color: color?.buildAnimtable(withFrom(iFrom?.color)),
      shadowColor: shadowColor.buildAnimtable(withFrom(iFrom?.shadowColor)),
      surfaceTintColor: surfaceTintColor?.buildAnimtable(withFrom(iFrom?.surfaceTintColor)),
      borderRadius: borderRadius?.buildAnimtable(withFrom(iFrom?.borderRadius)),
      shape: shape?.buildAnimtable(withFrom(iFrom?.shape)),
      margin: margin?.buildAnimtable(withFrom(iFrom?.margin)),
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

class _CardPropsProxyTween extends CueAnimtable<CardProps> {
  final CueAnimtable<double>? elevation;
  final CueAnimtable<Color?>? color;
  final CueAnimtable<Color?>? shadowColor;
  final CueAnimtable<Color?>? surfaceTintColor;
  final CueAnimtable<BorderRadius?>? borderRadius;
  final CueAnimtable<ShapeBorder?>? shape;
  final CueAnimtable<EdgeInsets?>? margin;

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
  bool shouldNotify(AnimationStatus status) {
    return (elevation?.shouldNotify(status) ?? false) ||
        (color?.shouldNotify(status) ?? false) ||
        (shadowColor?.shouldNotify(status) ?? false) ||
        (surfaceTintColor?.shouldNotify(status) ?? false) ||
        (borderRadius?.shouldNotify(status) ?? false) ||
        (shape?.shouldNotify(status) ?? false) ||
        (margin?.shouldNotify(status) ?? false);
  }

  @override
  CardProps transform(double t, AnimationStatus status) {
    return CardProps(
      elevation: elevation?.transform(t, status) ?? 0,
      color: color?.transform(t, status),
      shadowColor: shadowColor?.transform(t, status),
      surfaceTintColor: surfaceTintColor?.transform(t, status),
      borderRadius: borderRadius?.transform(t, status),
      margin: margin?.transform(t, status),
      shape: shape?.transform(t, status),
    );
  }
}

/// A convenience widget that animates card-like surface properties using
/// [CardAct].
///
/// Wraps an [Actor] with a single [CardAct]. For composing multiple effects,
/// use [Actor] directly with [CardAct] in the effects list.
class CardActor extends StatelessWidget {
  final AnimtableColor? color;
  final AnimtableColor? shadowColor;
  final AnimtableColor? surfaceTintColor;
  final AnimatableValue<double>? elevation;
  final AnimtableBorderRadius? borderRadius;
  final AnimtableShapeBorder? shape;
  final AnimtableEdgeInsets? margin;
  final Clip clipBehavior;
  final bool borderOnForeground;
  final Widget? child;
  final CueMotion? motion;
  final CueMotion? reverseMotion;

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
    this.motion,
    this.reverseMotion,
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
        shadowColor: shadowColor ?? const AnimtableColor.fixed(Color(0xFF000000)),
        surfaceTintColor: surfaceTintColor,
        elevation: elevation,
        borderRadius: borderRadius,
        shape: shape,
        clipBehavior: clipBehavior,
        borderOnForeground: borderOnForeground,
        margin: margin,
        motion: motion,
        reverseMotion: reverseMotion,
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }
}
