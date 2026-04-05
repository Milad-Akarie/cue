part of 'base/act.dart';

/// Animates clipping regions on a widget.
///
/// Provides multiple clipping strategies: expanding/contracting within a border
/// radius or circular path, or sliding clipping along horizontal/vertical axes.
/// All variants animate from a factor of 0 (fully clipped) to 1 (fully visible).
abstract class ClipAct extends Act {
  /// {@template act.clip}
  /// Animates an expanding or contracting clip path with optional border radius.
  ///
  /// Clips the child using [ClipPath] and [Align], growing from the specified
  /// alignment point outward. [borderRadius] defaults to `BorderRadius.zero`
  /// (rectangular clipping). Set [borderRadius] to null for circular clipping,
  /// or to a custom value for rounded corners. Use [useSuperellipse] for smooth
  /// super-ellipse clipping curves (optional optimization).
  ///
  /// ## Basic usage
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .clip(borderRadius: BorderRadius.circular(12)),
  ///     .clipWidth(), // fromFactor and toFactor default to 0 and 1 respectively
  ///     .clipHeight(), // fromFactor and toFactor default to 0 and 1 respectively
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## Rectangular clipping
  ///
  /// ```dart
  /// .clip(
  ///   borderRadius: BorderRadius.circular(0),  // sharp corners
  /// )
  /// ```
  ///
  /// ## Circular clipping
  ///
  /// Use `.circularClip()` shorthand (or set borderRadius to null):
  ///
  /// ```dart
  /// .circularClip()
  /// ```
  /// {@endtemplate}
  const factory ClipAct({
    BorderRadiusGeometry borderRadius,
    AlignmentGeometry alignment,
    bool useSuperellipse,
    CueMotion? motion,
    Duration delay,
  }) = PathClipAct;

  /// {@template act.clip.circular}
  /// Animates a circular clip expanding from an alignment point.
  ///
  /// Shorthand for `.clip(borderRadius: null)`. Clips the child to an expanding
  /// circle from the specified [alignment] point.
  ///
  /// ## Usage
  ///
  /// ```dart
  /// .circularClip()  // expands from top-left by default
  ///
  /// .circularClip(alignment: Alignment.center)  // expands from center
  /// ```
  ///
  /// ## Keyframed circular clip
  ///
  /// ```dart
  /// .keyframed(
  ///   frames: Keyframes.fractional([
  ///     .key(0.0, at: 0.0),
  ///     .key(0.7, at: 0.5),
  ///     .key(1.0, at: 1.0),
  ///   ], duration: 400.ms),
  /// )
  /// ```
  /// {@endtemplate}
  const factory ClipAct.circular({
    AlignmentGeometry alignment,
    CueMotion? motion,
    Duration delay,
  }) = PathClipAct.circular;

  /// {@template act.clip.width}
  /// Animates a horizontal (left-to-right or right-to-left) sliding clip.
  ///
  /// Clips along the horizontal axis from [fromFactor] to [toFactor], where
  /// 0 = fully clipped (width 0) and 1 = fully visible (full width).
  ///
  /// Default [alignment] is `AlignmentDirectional.centerStart` (left-to-right).
  /// Override to change reveal direction.
  ///
  /// ## Usage
  ///
  /// ```dart
  /// .clipWidth(from: 0, to: 1)  // reveal left-to-right
  ///
  /// .clipWidth(
  ///   from: 0,
  ///   to: 1,
  ///   alignment: AlignmentDirectional.centerEnd,  // reveal right-to-left
  /// )
  /// ```
  /// {@endtemplate}
  const factory ClipAct.width({
    double fromFactor,
    double toFactor,
    AlignmentGeometry alignment,
    CueMotion? motion,
    Duration delay,
  }) = AxisClipAct.horizontal;

  /// {@template act.clip.height}
  /// Animates a vertical (top-to-bottom or bottom-to-top) sliding clip.
  ///
  /// Clips along the vertical axis from [fromFactor] to [toFactor], where
  /// 0 = fully clipped (height 0) and 1 = fully visible (full height).
  ///
  /// Default [alignment] is `AlignmentDirectional.topCenter` (top-to-bottom).
  /// Override to change reveal direction.
  ///
  /// ## Usage
  ///
  /// ```dart
  /// .clipHeight()  // reveal top-to-bottom
  ///
  /// .clipHeight(
  ///   alignment: Alignment.bottomCenter,  // reveal bottom-to-top
  /// )
  /// ```
  /// {@endtemplate}
  const factory ClipAct.height({
    double fromFactor,
    double toFactor,
    AlignmentGeometry alignment,
    CueMotion? motion,
    Duration delay,
  }) = AxisClipAct.vertical;
}

/// Animates sliding clip along a single axis (horizontal or vertical).
class AxisClipAct extends TweenAct<double> implements ClipAct {
  @override
  ActKey get key => const ActKey('Clip');

  final Axis _axis;
  final AlignmentGeometry alignment;

  /// {@macro act.clip.width}
  const AxisClipAct.horizontal({
    double fromFactor = 0,
    double toFactor = 1,
    this.alignment = AlignmentDirectional.centerStart,
    super.motion,
    super.delay,
  }) : _axis = Axis.horizontal,
       super.tween(from: fromFactor, to: toFactor);

  /// {@macro act.clip.height}
  const AxisClipAct.vertical({
    double fromFactor = 0,
    double toFactor = 1,
    this.alignment = AlignmentDirectional.topCenter,
    super.motion,
    super.delay,
  }) : _axis = Axis.vertical,
       super.tween(from: fromFactor, to: toFactor);

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

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        super == other &&
            other is AxisClipAct &&
            super == other &&
            _axis == other._axis &&
            alignment == other.alignment;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, _axis, alignment);
}

/// Animates clipping from an alignment point along an expanding path or circle.
class PathClipAct extends TweenAct<double> implements ClipAct {

  @override
  ActKey get key => const ActKey('Clip');

  final BorderRadiusGeometry? borderRadius;
  final AlignmentGeometry? alignment;
  final bool useSuperellipse;

  /// {@macro act.clip}
  const PathClipAct({
    BorderRadiusGeometry this.borderRadius = BorderRadius.zero,
    this.alignment,
    super.motion,
    this.useSuperellipse = false,
    super.from = 0,
    super.to = 1,
    super.delay,
  }) : super.tween();

  /// {@macro act.clip.circular}
  const PathClipAct.circular({
    this.alignment,
    super.motion,
    super.from = 0,
    super.to = 1,
    super.delay,
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

 @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        super == other &&
            other is PathClipAct &&
            super == other &&
            borderRadius == other.borderRadius &&
            alignment == other.alignment &&
            useSuperellipse == other.useSuperellipse;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, borderRadius, alignment, useSuperellipse);

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
        oldClipper.alignment != alignment ||
        oldClipper.useSuperellipse != useSuperellipse;
  }
}
