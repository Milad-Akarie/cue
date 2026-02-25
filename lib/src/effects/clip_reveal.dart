part of 'effect.dart';

abstract class ClipEffect extends Effect {
  const factory ClipEffect({
    Size fromSize,
    BorderRadiusGeometry borderRadius,
    AlignmentGeometry alignment,
    Curve? curve,
    Timing? timing,
  }) = _ClipEffect;

  const factory ClipEffect.circular({
    Size fromSize,
    AlignmentGeometry alignment,
    Curve? curve,
    Timing? timing,
  }) = _ClipEffect.circular;

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
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
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

  const _ClipEffect.circular({
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final toSize = constraints.biggest;
        final minWidthFactor = fromSize.width / toSize.width;
        final minHeightFactor = fromSize.height / toSize.height;
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final clampedValue = animation.value.clamp(0.0, 1.0);
            return Align(
              alignment: effectiveAlignment,
              widthFactor: clampedValue.clamp(minWidthFactor, 1),
              heightFactor: clampedValue.clamp(minHeightFactor, 1),
              child: ClipPath(
                clipper: ExpandingPathClipper(
                  progress: clampedValue,
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
      },
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

class ClipActor extends SingleEffectProxy<Size> {
  final double? _fromAxisSize;
  final double? _toAxisSize;
  final BorderRadiusGeometry? borderRadius;
  final AlignmentGeometry alignment;
  final Axis? _axis;

  const ClipActor({
    super.key,
    Size fromSize = Size.zero,
    BorderRadiusGeometry this.borderRadius = BorderRadius.zero,
    this.alignment = Alignment.center,
    required super.child,
    super.role,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
  }) : _axis = null,
       _fromAxisSize = null,
       _toAxisSize = null,
       super(from: fromSize, to: Size.zero);

  const ClipActor.circular({
    super.key,
    Size fromSize = Size.zero,
    this.alignment = Alignment.center,
    required super.child,
    super.role,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
  }) : _axis = null,
       _fromAxisSize = null,
       _toAxisSize = null,
       borderRadius = null,
       super(from: fromSize, to: Size.zero);

  const ClipActor.horizontal({
    super.key,
    double from = 0,
    double to = 1,
    this.alignment = AlignmentDirectional.centerStart,
    required super.child,
    super.curve,
    super.role,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
  }) : _axis = Axis.horizontal,
       _fromAxisSize = from,
       _toAxisSize = to,
       borderRadius = BorderRadius.zero,
       super(from: Size.zero, to: Size.zero);

  const ClipActor.vertical({
    super.key,
    double from = 0,
    double to = 1,
    this.alignment = AlignmentDirectional.topCenter,
    required super.child,
    super.curve,
    super.role,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
  }) : _axis = Axis.vertical,
       _toAxisSize = to,
       _fromAxisSize = from,
       borderRadius = BorderRadius.zero,
       super(from: Size.zero, to: Size.zero);

  @override
  Effect get effect => switch (_axis) {
    Axis.horizontal => ClipEffect.horizontal(
      from: _fromAxisSize!,
      to: _toAxisSize!,
      alignment: alignment,
      curve: curve,
      timing: timing,
    ),
    Axis.vertical => ClipEffect.vertical(
      from: _fromAxisSize!,
      to: _toAxisSize!,
      alignment: alignment,
      curve: curve,
      timing: timing,
    ),
    _ when borderRadius != null => ClipEffect(
      fromSize: from!,
      alignment: alignment,
      borderRadius: borderRadius!,
      curve: curve,
      timing: timing,
    ),
    _ => ClipEffect.circular(
      fromSize: from!,
      alignment: alignment,
      curve: curve,
      timing: timing,
    ),
  };
}
