part of 'base/act.dart';

/// Animates fractional sizing (width/height as fractions of parent).
///
/// Animates a widget to a fraction of its parent's size on one or both axes.
/// Both widthFactor and heightFactor are optional and can be independently
/// animated (via `AnimatableValue.tween()`) or fixed (via `AnimatableValue.fixed()`).
class FractionalSizeAct extends AnimtableAct<FractionalSize, FractionalSize> {

  @override
  final ActKey key = const ActKey('FractionalSize');

  /// {@template act.fractional_size}
  /// Animates fractional sizing factors.
  ///
  /// [widthFactor] and [heightFactor] are fractions (0 = no size, 1 = full parent size).
  /// Both are optional. [alignment] controls positioning within the parent
  /// (defaults to `Alignment.center`).
  ///
  /// Use `.tween(from, to)` for animated properties.
  /// Use `.fixed(value)` to keep a property constant.
  ///
  /// ## Animate width only
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .fractionalSize(
  ///       widthFactor: .tween(0, 1),
  ///     ),
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## Animate both width and height
  ///
  /// ```dart
  /// .fractionalSize(
  ///   widthFactor: .tween(0.5, 1),
  ///   heightFactor: .tween(0.5, 1),
  ///   alignment: .fixed(Alignment.center),
  /// )
  /// ```
  ///
  /// ## Animate with alignment change
  ///
  /// ```dart
  /// .fractionalSize(
  ///   widthFactor: .tween(0, 1),
  ///   heightFactor: .tween(0, 1),
  ///   alignment: .tween(.topLeft, .bottomRight),
  /// )
  /// ```
  /// {@endtemplate}
  final AnimatableValue<double>? widthFactor;

  /// Animates height factor. Use `.tween(from, to)` or `.fixed(value)`.
  final AnimatableValue<double>? heightFactor;

  /// Animates alignment within parent. Use `.tween(from, to)` or `.fixed(value)`.
  /// Defaults to `Alignment.center` if not specified.
  final AnimatableValue<AlignmentGeometry>? alignment;
  final Keyframes<FractionalSize>? frames;

  /// {@macro act.fractional_size}
  const FractionalSizeAct({
    super.motion,
    super.delay,
    this.widthFactor,
    this.heightFactor,
    this.alignment = const AnimatableValue.fixed(Alignment.center),
    ReverseBehavior<FractionalSize> super.reverse = const ReverseBehavior.mirror(),
  }) : frames = null;

  /// {@template act.fractional_size.keyframed}
  /// Animates fractional sizing through multiple keyframe states.
  ///
  /// [frames] defines the animation keyframes (type `Keyframes<FractionalSize>`).
  /// Each keyframe specifies widthFactor, heightFactor, and alignment.
  ///
  /// ## Fractional keyframes with global duration
  ///
  /// ```dart
  /// .keyframed(
  ///   frames: Keyframes.fractional([
  ///     .key(FractionalSize(widthFactor: 0.5, heightFactor: 0.5), at: 0.0),
  ///     .key(FractionalSize(widthFactor: 1.0, heightFactor: 0.5), at: 0.5),
  ///     .key(FractionalSize(widthFactor: 1.0, heightFactor: 1.0), at: 1.0),
  ///   ], duration: 600.ms, curve: Curves.easeInOut),
  /// )
  /// ```
  ///
  /// ## Motion per keyframe
  ///
  /// ```dart
  /// .keyframed(
  ///   frames: Keyframes([
  ///     .key(FractionalSize(widthFactor: 0.5, heightFactor: 0.5)),
  ///     .key(FractionalSize(widthFactor: 1.0, heightFactor: 0.5), motion: .easeOut(200.ms)),
  ///     .key(FractionalSize(widthFactor: 1.0, heightFactor: 1.0), motion: .smooth()),
  ///   ], motion: .smooth()), // default motion for all frames without specific motion
  /// )
  /// ```
  /// {@endtemplate}
  const FractionalSizeAct.keyframed({
    required Keyframes<FractionalSize> this.frames,
    super.delay,
    ReverseBehavior<FractionalSize> super.reverse = const ReverseBehavior.mirror(),
  }) : widthFactor = null,
       heightFactor = null,
       alignment = null;

  @override
  Widget apply(BuildContext context, Animation<FractionalSize> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final props = animation.value;
        return FractionallySizedBox(
          widthFactor: props.widthFactor,
          heightFactor: props.heightFactor,
          alignment: props.alignment ?? Alignment.center,
          child: child,
        );
      },
    );
  }

  @override
  (CueAnimtable<FractionalSize>, CueAnimtable<FractionalSize>?) buildTweens(ActContext context) {
    final builder = CueTweenBuildHelper<FractionalSize>(
      from: FractionalSize(
        widthFactor: widthFactor?.from,
        heightFactor: heightFactor?.from,
        alignment: alignment?.from,
      ),
      to: FractionalSize(
        widthFactor: widthFactor?.to,
        heightFactor: heightFactor?.to,
        alignment: alignment?.to,
      ),
      frames: frames,
      reverse: reverse,
      tweenBuilder: (from, to) => _FractionalSizeTween(begin: from, end: to),
    );
    return builder.buildTweens(context);
  }

  @override
  ActContext resolve(ActContext context) {
    return TweenActBase.resolveMotion(
      context,
      motion: motion,
      delay: delay,
      reverse: reverse,
      frames: frames,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FractionalSizeAct && super == other &&
          runtimeType == other.runtimeType &&
          widthFactor == other.widthFactor &&
          heightFactor == other.heightFactor &&
          alignment == other.alignment &&
          frames == other.frames;

  @override
  int get hashCode => Object.hash(super.hashCode, widthFactor, heightFactor, alignment, frames);
}

/// Data class representing fractional sizing state.
///
/// Stores the width factor, height factor, and alignment for a [FractionallySizedBox].
/// Factors range from 0 (no size) to 1 (full parent size) and beyond.
/// Used internally by [FractionalSizeAct] to interpolate between sizing keyframes.
class FractionalSize {
  /// Width as a fraction of parent (0 = no width, 1 = full width).
  final double? widthFactor;

  /// Height as a fraction of parent (0 = no height, 1 = full height).
  final double? heightFactor;

  /// Alignment within parent bounds.
  final AlignmentGeometry? alignment;

  /// Creates a fractional size snapshot.
  FractionalSize({this.widthFactor, this.heightFactor, this.alignment});

  /// Interpolates between two fractional sizes.
  ///
  /// Linearly interpolates [widthFactor], [heightFactor], and [alignment]
  /// based on progress `t` (0 = `a`, 1 = `b`).
  static FractionalSize lerp(FractionalSize a, FractionalSize b, double t) {
    return FractionalSize(
      widthFactor: lerpDouble(a.widthFactor, b.widthFactor, t),
      heightFactor: lerpDouble(a.heightFactor, b.heightFactor, t),
      alignment: AlignmentGeometry.lerp(a.alignment, b.alignment, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FractionalSize &&
          runtimeType == other.runtimeType &&
          widthFactor == other.widthFactor &&
          heightFactor == other.heightFactor &&
          alignment == other.alignment;

  @override
  int get hashCode => Object.hash(widthFactor, heightFactor, alignment);
}

/// Internal tween implementation for fractional sizing.
///
/// Interpolates between [FractionalSize] states by lerping individual factors
/// and alignment. Used internally by [FractionalSizeAct].
class _FractionalSizeTween extends Tween<FractionalSize> {
  /// Creates a tween between [begin] and [end] fractional sizes.
  _FractionalSizeTween({super.begin, super.end});

  @override
  FractionalSize lerp(double t) => FractionalSize.lerp(begin!, end!, t);
}
