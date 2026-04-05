part of 'base/act.dart';

/// Animates box decoration properties (color, border, shadow, radius, gradient).
///
/// Allows selective animation of individual decoration properties while keeping
/// others fixed. Each property (color, borderRadius, border, boxShadow, gradient)
/// can be independently animated or fixed using `AnimatableValue.fixed()`.
class DecoratedBoxAct extends AnimtableAct<Decoration, Decoration> {
  @override
  final ActKey key = const ActKey('DecoratedBox');

  /// {@template act.decorate}
  /// Animates box decoration properties.
  ///
  /// Each property is optional and can be animated (via `AnimatableValue.tween()`)
  /// or fixed (via `AnimatableValue.fixed()`). Unspecified properties use defaults.
  ///
  /// **Animation Properties** (all optional):
  /// - [color]: Animate background color
  /// - [borderRadius]: Animate border radius
  /// - [border]: Animate border
  /// - [boxShadow]: Animate shadow
  /// - [gradient]: Animate gradient overlay
  ///
  /// Use `AnimatableValue.tween(from, to)` for animated properties.
  /// Use `AnimatableValue.fixed(value)` to keep a property constant.
  ///
  /// ## Basic color animation
  ///
  /// ```dart
  /// Actor(
  ///   acts: [
  ///     .decorate(
  ///       color: .tween(Colors.red, Colors.blue),
  ///     ),
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## Multi-property animation
  ///
  /// ```dart
  /// .decorate(
  ///   color: .tween(Colors.red, Colors.blue),
  ///   borderRadius: .tween(
  ///     BorderRadius.circular(0),
  ///     BorderRadius.circular(12),
  ///   ),
  ///   boxShadow: .tween(
  ///     [BoxShadow(blurRadius: 0)],
  ///     [BoxShadow(blurRadius: 8)],
  ///   ),
  /// )
  /// ```
  ///
  /// ## Mixed: animate some, fix others
  ///
  /// ```dart
  /// .decorate(
  ///   color: .tween(Colors.transparent, Colors.white),
  ///   borderRadius: .fixed(BorderRadius.circular(12)),
  ///   boxShadow: .fixed([BoxShadow(blurRadius: 4)]),
  /// )
  /// ```
  /// {@endtemplate}

  /// Animates background color. Use `.tween(from, to)` or `.fixed(value)`.
  final AnimatableValue<Color>? color;

  /// Animates border radius. Use `.tween(from, to)` or `.fixed(value)`.
  final AnimatableValue<BorderRadiusGeometry>? borderRadius;

  /// Animates border. Use `.tween(from, to)` or `.fixed(value)`.
  final AnimatableValue<BoxBorder>? border;

  /// Animates box shadow. Use `.tween(from, to)` or `.fixed(value)`.
  final AnimatableValue<List<BoxShadow>>? boxShadow;

  /// Animates gradient overlay. Use `.tween(from, to)` or `.fixed(value)`.
  final AnimatableValue<Gradient>? gradient;
  final BoxShape shape;
  final DecorationPosition position;
  final Keyframes<Decoration>? frames;
  final DecorationImage? image;

  /// {@macro act.decorate}
  const DecoratedBoxAct({
    this.color,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.gradient,
    super.motion,
    this.image,
    ReverseBehavior<Decoration> super.reverse = const ReverseBehavior.mirror(),
    this.position = DecorationPosition.background,
    this.shape = BoxShape.rectangle,
    super.delay,
  }) : frames = null;

  /// {@template act.decorate.keyframed}
  /// Animates decoration through multiple keyframe states.
  ///
  /// [frames] defines the animation keyframes (type `Keyframes<Decoration>`).
  /// All properties are derived from the keyframe decorations.
  ///
  /// ## Fractional keyframes with global duration
  ///
  /// ```dart
  /// .keyframed(
  ///   frames: Keyframes.fractional([
  ///     .key(BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(0)), at: 0.0),
  ///     .key(BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.circular(6)), at: 0.5),
  ///     .key(BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)), at: 1.0),
  ///   ], duration: 700.ms, curve: Curves.easeInOut),
  /// )
  /// ```
  ///
  /// ## Motion per keyframe
  ///
  /// ```dart
  /// .keyframed(
  ///   frames: Keyframes([
  ///     .key(BoxDecoration(color: Colors.red)),
  ///     .key(BoxDecoration(color: Colors.yellow)),
  ///     .key(BoxDecoration(color: Colors.blue), motion: .smooth()),
  ///   ], motion: .easeInOut(500.ms)),
  /// )
  /// ```
  /// {@endtemplate}
  const DecoratedBoxAct.keyframed({
    required Keyframes<Decoration> this.frames,
    KFReverseBehavior<Decoration> super.reverse = const KFReverseBehavior.mirror(),
    super.delay,
    this.position = DecorationPosition.background,
    this.shape = BoxShape.rectangle,
    this.image,
  }) : color = null,
       borderRadius = null,
       border = null,
       boxShadow = null,
       gradient = null;

  @override
  (CueAnimtable<Decoration>, CueAnimtable<Decoration>?) buildTweens(ActContext context) {
    final from = BoxDecoration(
      color: color?.from,
      borderRadius: borderRadius?.from,
      border: border?.from,
      boxShadow: boxShadow?.from,
      gradient: gradient?.from,
      shape: shape,
      image: image,
    );
    final to = BoxDecoration(
      color: color?.to,
      borderRadius: borderRadius?.to,
      border: border?.to,
      boxShadow: boxShadow?.to,
      gradient: gradient?.to,
      shape: shape,
      image: image,
    );
    final builder = CueTweenBuildHelper<Decoration>(
      from: from,
      to: to,
      frames: frames,
      reverse: reverse,
      tweenBuilder: (begin, end) => DecorationTween(begin: begin, end: end),
    );
    return builder.buildTweens(context);
  }

  @override
  Widget apply(BuildContext context, covariant Animation<Decoration> animation, Widget child) {
    return DecoratedBoxTransition(
      decoration: animation,
      position: position,
      child: child,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is DecoratedBoxAct &&
        super == other &&
        other.color == color &&
        other.borderRadius == borderRadius &&
        other.border == border &&
        other.boxShadow == boxShadow &&
        other.gradient == gradient &&
        other.shape == shape &&
        other.image == image &&
        other.position == position;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    color,
    borderRadius,
    border,
    boxShadow,
    gradient,
    shape,
    position,
    image,
  );

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
}

/// Convenience widget for decoration animations.
///
/// Pre-composes an [Actor] with a [DecoratedBoxAct], eliminating boilerplate for
/// simple decoration animations. Use this instead of wrapping [DecoratedBoxAct]
/// in [Actor] for better readability.
class DecoratedBoxActor extends StatelessWidget {
  /// {@template actor.decorate}
  /// Creates a decoration animation widget.
  ///
  /// All properties are optional. Unspecified properties use defaults.
  /// Use `AnimatableValue.tween()` to animate a property or
  /// `AnimatableValue.fixed()` to keep it constant.
  ///
  /// ## Simple color animation
  ///
  /// ```dart
  /// DecoratedBoxActor(
  ///   color: .tween(Colors.red, Colors.blue),
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## Multi-property animation
  ///
  /// ```dart
  /// DecoratedBoxActor(
  ///   color: .tween(Colors.white, Colors.grey[100]),
  ///   borderRadius: .tween(
  ///     BorderRadius.circular(0),
  ///     BorderRadius.circular(16),
  ///   ),
  ///   boxShadow: .tween(
  ///     [BoxShadow(blurRadius: 0)],
  ///     [BoxShadow(blurRadius: 12, color: Colors.black26)],
  ///   ),
  ///   shape: BoxShape.rectangle,
  ///   child: MyCard(),
  /// )
  /// ```
  ///
  /// ## Mixed: animate some, fix others
  ///
  /// ```dart
  /// DecoratedBoxActor(
  ///   color: .tween(Colors.transparent, Colors.blue),
  ///   borderRadius: .fixed(BorderRadius.circular(12)),
  ///   boxShadow: .fixed([BoxShadow(blurRadius: 4)]),
  ///   child: MyWidget(),
  /// )
  /// ```
  /// {@endtemplate}
  final AnimatableValue<Color>? color;
  final AnimatableValue<BorderRadiusGeometry>? borderRadius;
  final AnimatableValue<BoxBorder>? border;
  final AnimatableValue<List<BoxShadow>>? boxShadow;
  final AnimatableValue<Gradient>? gradient;
  final BoxShape shape;
  final Widget? child;
  final CueMotion? motion;
  final CueMotion? reverseMotion;
  final DecorationPosition position;
  final Duration delay;
  final ReverseBehavior<Decoration> reverse;
  final DecorationImage? image;

  /// {@macro actor.decorate}
  const DecoratedBoxActor({
    super.key,
    this.color,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.gradient,
    this.shape = BoxShape.rectangle,
    this.child,
    this.motion,
    this.reverseMotion,
    this.position = DecorationPosition.background,
    this.delay = Duration.zero,
    this.image,
    this.reverse = const ReverseBehavior.mirror(),
  });

  @override
  Widget build(BuildContext context) {
    return Actor(
      acts: [
        DecoratedBoxAct(
          color: color,
          borderRadius: borderRadius,
          border: border,
          boxShadow: boxShadow,
          gradient: gradient,
          shape: shape,
          position: position,
          motion: motion,
          delay: delay,
          reverse: reverse,
          image: image,
        ),
      ],
      child: child ?? const SizedBox.shrink(),
    );
  }
}
