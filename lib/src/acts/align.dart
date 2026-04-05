part of 'base/act.dart';

/// Animates the alignment of a widget within its parent.
///
/// Wraps the child in an [Align] widget and interpolates between two
/// [AlignmentGeometry] values using [AlignmentTween]. Supports both tween
/// and keyframed modes. See [AlignAct.new] and [AlignAct.keyframed].
class AlignAct extends TweenActBase<AlignmentGeometry?, Alignment> {
  @override
  final ActKey key = const ActKey('Align');

  /// {@template act.align}
  /// Animates alignment from [from] to [to] using [AlignmentTween].
  ///
  /// Useful for sliding a child to a different anchor point within a
  /// fixed-size parent without affecting its layout dimensions.
  ///
  /// Both [from] and [to] default to [Alignment.center]. Omitting [from]
  /// means the animation starts from center regardless of the widget's
  /// natural position. Omitting [to] means the animation ends at center.
  ///
  /// ## Usage
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .align(from: .centerLeft, to: .centerRight),
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## Reverse behavior
  ///
  /// ```dart
  /// .align(
  ///   from: .topLeft,
  ///   to: .bottomRight,
  ///   reverse: .to(.center),
  /// )
  /// ```
  /// {@endtemplate}
  const AlignAct({
    super.from = Alignment.center,
    super.to = Alignment.center,
    super.motion,
    super.reverse,
    super.delay,
  }) : super.tween();

  /// {@template act.align.keyframed}
  /// Animates alignment through a sequence of keyframes.
  ///
  /// Use [AlignAct.keyframed] when the alignment needs to pass through more
  /// than two positions, or when each step requires its own motion curve.
  ///
  /// ## Fractional keyframes with global duration
  ///
  /// ```dart
  /// AlignAct.keyframed(
  ///   frames: Keyframes.fractional([
  ///     .key(Alignment.topLeft, at: 0.0),
  ///     .key(Alignment.center, at: 0.5),
  ///     .key(Alignment.bottomRight, at: 1.0),
  ///   ], duration: 600.ms, curve: Curves.easeInOut),
  /// )
  /// ```
  ///
  /// ## Motion per keyframe
  ///
  /// ```dart
  /// AlignAct.keyframed(
  ///   frames: Keyframes([
  ///     .key(Alignment.topLeft),
  ///     .key(Alignment.center),
  ///     .key(Alignment.bottomRight, motion: .easeInOut(300.ms)),
  ///   ], motion: .smooth()), // default motion for all frames without specific motion
  /// )
  /// ```
  /// {@endtemplate}
  const AlignAct.keyframed({
    required super.frames,
    super.reverse,
    super.delay,
  }) : super.keyframed();

  @override
  Alignment transform(ActContext ctx, AlignmentGeometry? value) {
    return value?.resolve(ctx.textDirection) ?? Alignment.center;
  }

  @override
  Animatable<Alignment> createSingleTween(Alignment from, Alignment to) {
    return AlignmentTween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<AlignmentGeometry> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Align(
          alignment: animation.value,
          child: child,
        );
      },
      child: child,
    );
  }
}
