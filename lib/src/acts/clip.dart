part of 'base/act.dart';

abstract class ClipAct extends Act {
  const factory ClipAct({
    BorderRadiusGeometry borderRadius,
    AlignmentGeometry alignment,
    bool useSuperellipse,
     CueMotion? motion,
  }) = _ClipEffect;

  const factory ClipAct.circular({
    AlignmentGeometry alignment,
      CueMotion? motion,
  }) = _ClipEffect.circular;

  const factory ClipAct.width({
    double from,
    double to,
    AlignmentGeometry alignment,
     CueMotion? motion,
  }) = _AxisClipEffect.horizontal;

  const factory ClipAct.height({
    double from,
    double to,
    AlignmentGeometry alignment,
      CueMotion? motion,
  }) = _AxisClipEffect.vertical;
}

class _AxisClipEffect extends TweenAct<double> implements ClipAct {
  final Axis _axis;
  final AlignmentGeometry alignment;

  const _AxisClipEffect.horizontal({
    super.from = 0,
    super.to = 1,
    this.alignment = AlignmentDirectional.centerStart,
    super.motion,
  }) : _axis = Axis.horizontal,
       super.tween();

  const _AxisClipEffect.vertical({
    super.from = 0,
    super.to = 1,
    this.alignment = AlignmentDirectional.topCenter,
    super.motion,
  }) : _axis = Axis.vertical,
       super.tween();

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

class _ClipEffect extends TweenAct<double> implements ClipAct {
  final BorderRadiusGeometry? borderRadius;
  final AlignmentGeometry? alignment;
  final bool useSuperellipse;

  const _ClipEffect({
    BorderRadiusGeometry this.borderRadius = BorderRadius.zero,
    this.alignment,
    super.motion,
    this.useSuperellipse = false,
    super.from = 0,
    super.to = 1,
  }) : super.tween();

  const _ClipEffect.circular({
    this.alignment,
    super.motion,
    super.from = 0,
    super.to = 1,
  }) : borderRadius = null,
       useSuperellipse = false,
       super.tween();

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
        final clampedValue = animation.value.clamp(0.0, 1.0);
        return Align(
          alignment: effectiveAlignment,
          widthFactor: clampedValue,
          heightFactor: clampedValue,
          child: ClipPath(
            clipper: ExpandingPathClipper(
              progress: clampedValue,
              borderRadius: effectiveBorderRadius,
              alignment: effectiveAlignment,
              useSuperellipse: useSuperellipse,
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
  final BorderRadius? borderRadius;
  final Alignment alignment;
  final bool useSuperellipse;

  ExpandingPathClipper({
    required this.progress,
    this.borderRadius,
    required this.alignment,
    this.useSuperellipse = false,
  });

  @override
  Path getClip(Size size) {
    final currentWidth = size.width * progress;
    final currentHeight = size.height * progress;
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
      if (useSuperellipse) {
        return Path()..addRSuperellipse(borderRadius!.toRSuperellipse(rect));
      }
      return Path()..addRRect(borderRadius!.toRRect(rect));
    }
  }

  @override
  bool shouldReclip(covariant ExpandingPathClipper oldClipper) {
    return oldClipper.progress != progress ||
        oldClipper.borderRadius != borderRadius ||
        oldClipper.alignment != alignment;
  }
}
