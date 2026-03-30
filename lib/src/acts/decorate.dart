part of 'base/act.dart';

class DecoratedBoxAct extends AnimtableAct<Decoration, Decoration> {
  @override
  final ActKey key = const ActKey('DecoratedBox');

  final AnimatableValue<Color>? color;
  final AnimatableValue<BorderRadiusGeometry>? borderRadius;
  final AnimatableValue<BoxBorder>? border;
  final AnimatableValue<List<BoxShadow>>? boxShadow;
  final AnimatableValue<Gradient>? gradient;
  final BoxShape shape;
  final DecorationPosition position;
  final Keyframes<Decoration>? frames;

  const DecoratedBoxAct({
    this.color,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.gradient,
    super.motion,
    ReverseBehavior<Decoration> super.reverse = const ReverseBehavior.mirror(),
    this.position = DecorationPosition.background,
    this.shape = BoxShape.rectangle,
    super.delay,
  }) : frames = null;

  const DecoratedBoxAct.keyframed({
    required Keyframes<Decoration> this.frames,
    KFReverseBehavior<Decoration> super.reverse = const KFReverseBehavior.mirror(),
    super.delay,
    this.position = DecorationPosition.background,
  }) : color = null,
       borderRadius = null,
       border = null,
       boxShadow = null,
       gradient = null,
       shape = BoxShape.rectangle;

  @override
  (CueAnimtable<Decoration>, CueAnimtable<Decoration>?) buildTweens(ActContext context) {
    final from = BoxDecoration(
      color: color?.from,
      borderRadius: borderRadius?.from,
      border: border?.from,
      boxShadow: boxShadow?.from,
      gradient: gradient?.from,
      shape: shape,
    );
    final to = BoxDecoration(
      color: color?.to,
      borderRadius: borderRadius?.to,
      border: border?.to,
      boxShadow: boxShadow?.to,
      gradient: gradient?.to,
      shape: shape,
    );
    final builder = TweensBuildHelper<Decoration>(
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
        other.position == position;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, color, borderRadius, border, boxShadow, gradient, shape, position);

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

class DecoratedBoxActor extends StatelessWidget {
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
        ),
      ],
      child: child ?? const SizedBox.shrink(),
    );
  }
}
