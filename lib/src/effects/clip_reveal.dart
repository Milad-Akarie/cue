part of 'effect.dart';

abstract class ClipEffect extends Effect {
  const factory ClipEffect({
    Size fromSize,
    BorderRadiusGeometry borderRadius,
    AlignmentGeometry alignment,
    Curve? curve,
    Timing? timing,
  }) = _ClipEffect;

  const factory ClipEffect.circluar({
    Size fromSize,
    AlignmentGeometry alignment,
    Curve? curve,
    Timing? timing,
  }) = _ClipEffect.circluar;

  const factory ClipEffect.horizontal({
    double from,
    double to,
    AlignmentGeometry alignment,
    Curve? curve,
    Timing? timing,
  }) = _AxisClipEffect.horizontal;

  const factory ClipEffect.vertical({
    double from,
    double to,
    AlignmentGeometry alignment,
    Curve? curve,
    Timing? timing,
  }) = _AxisClipEffect.vertical;
}

class _AxisClipEffect extends TweenEffect<double> implements ClipEffect {
  final Axis _axis;
  final AlignmentGeometry alignment;

  const _AxisClipEffect.horizontal({
    super.from = 0,
    super.to = 1,
    this.alignment = AlignmentDirectional.centerStart,
    super.curve,
    super.timing,
  }) : _axis = Axis.horizontal,
       super();

  const _AxisClipEffect.vertical({
    super.from = 0,
    super.to = 1,
    this.alignment = AlignmentDirectional.topCenter,
    super.curve,
    super.timing,
  }) : _axis = Axis.vertical,
       super();

  @override
  Widget apply(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) {
    final directionality = Directionality.of(context);
    final effectiveAlignment = alignment.resolve(directionality);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            alignment: effectiveAlignment,
            widthFactor: _axis == Axis.horizontal ? animation.value.clamp(0, 1) : null,
            heightFactor: _axis == Axis.vertical ? animation.value.clamp(0, 1) : null,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _ClipEffect extends TweenEffect<double> implements ClipEffect {
  final Size fromSize;
  final BorderRadiusGeometry? borderRadius;
  final AlignmentGeometry? alignment;

  const _ClipEffect({
    this.fromSize = Size.zero,
    BorderRadiusGeometry this.borderRadius = BorderRadius.zero,
    this.alignment,
    super.curve,
    super.timing,
  }) : super(from: 0, to: 1);

  const _ClipEffect.circluar({
    this.fromSize = Size.zero,
    this.alignment,
    super.curve,
    super.timing,
  }) : borderRadius = null,
       super(from: 0, to: 1);

  @override
  Widget apply(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  ) {
    final directionality = Directionality.of(context);
    final effectiveAlignment = alignment?.resolve(directionality) ?? Alignment.topLeft;
    final effectiveBorderRadius = borderRadius?.resolve(directionality);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Align(
          alignment: effectiveAlignment,
          widthFactor: animation.value.clamp(0, 1.0),
          heightFactor: animation.value.clamp(0, 1.0),
          child: ClipPath(
            clipper: ExpandingPathClipper(
              progress: animation.value,
              minSize: fromSize,
              borderRadius: effectiveBorderRadius,
              alignment: effectiveAlignment,
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class ExpandingPathClipper extends CustomClipper<Path> {
  final double progress;
  final Size minSize;
  final BorderRadius? borderRadius;
  final Alignment alignment;

  ExpandingPathClipper({
    required this.progress,
    required this.minSize,
    this.borderRadius,
    required this.alignment,
  });

  @override
  Path getClip(Size size) {
    double minWidth = minSize.width;
    if (minWidth.isInfinite) {
      minWidth = size.width;
    }
    double minHeight = minSize.height;
    if (minHeight.isInfinite) {
      minHeight = size.height;
    }

    final animatableWidth = size.width - minWidth;
    final animatableHeight = size.height - minHeight;
    final currentWidth = minWidth + animatableWidth * progress;
    final currentHeight = minHeight + animatableHeight * progress;
    // Calculate the alignment point within the available size
    final alignmentOffset = alignment.alongSize(size);
    // Calculate the alignment point within the clipped rect
    final rectAlignmentOffset = alignment.alongSize(
      Size(currentWidth, currentHeight),
    );
    // Position the rect so its alignment point matches the size's alignment point
    final left = alignmentOffset.dx - rectAlignmentOffset.dx;
    final top = alignmentOffset.dy - rectAlignmentOffset.dy;

    final rect = Rect.fromLTWH(left, top, currentWidth, currentHeight);

    // null border radius means we want a circle
    if (borderRadius == null) {
      return Path()..addOval(rect);
    } else if (borderRadius == BorderRadius.zero) {
      // optimize for zero border radius case
      return Path()..addRect(rect);
    } else {
      return Path()..addRRect(borderRadius!.toRRect(rect));
    }
  }

  @override
  bool shouldReclip(covariant ExpandingPathClipper oldClipper) {
    return oldClipper.progress != progress || oldClipper.minSize != minSize;
  }
}
