part of 'base/effect.dart';

class DecoratedBoxEffect extends MulitTweenEffect<BoxDecoration> {
  final ColorProp? color;
  final BorderRadiusProp? borderRadius;
  final BoxBorderProp? border;
  final BoxShadowProp? boxShadow;
  final GradientProp? gradient;
  final BoxShape shape;
  final DecorationPosition position;

  DecoratedBoxEffect({
    this.color,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.gradient,
    super.timing,
    super.curve,
    this.position = DecorationPosition.background,
    this.shape = BoxShape.rectangle,
  });

  @override
  Animatable<BoxDecoration> buildTween(ActorContext context) {
    final ctx = context.copyWith(timing: timing, curve: curve);
    return _DecorationProxyTween(
      color: color?.asAnimtable(ctx),
      borderRadius: borderRadius?.asAnimtable(ctx),
      border: border?.asAnimtable(ctx),
      boxShadow: boxShadow?.asAnimtable(ctx),
      gradient: gradient?.asAnimtable(ctx),
      shape: shape,
    );
  }

  @override
  Widget apply(BuildContext context, covariant Animation<BoxDecoration> animation, Widget child) {
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
    return other is DecoratedBoxEffect &&
        other.color == color &&
        other.borderRadius == borderRadius &&
        other.border == border &&
        other.boxShadow == boxShadow &&
        other.gradient == gradient &&
        other.shape == shape &&
        other.position == position;
  }

  @override
  int get hashCode => Object.hash(color, borderRadius, border, boxShadow, gradient, shape, position);
}

class _DecorationProxyTween extends Animatable<BoxDecoration> {
  final Animatable<Color?>? color;
  final Animatable<BorderRadiusGeometry?>? borderRadius;
  final Animatable<BoxBorder?>? border;
  final Animatable<List<BoxShadow>?>? boxShadow;
  final Animatable<Gradient?>? gradient;
  final BoxShape shape;

  _DecorationProxyTween({
    this.color,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.gradient,
    this.shape = BoxShape.rectangle,
  });

  @override
  BoxDecoration transform(double t) {
    return BoxDecoration(
      shape: shape,
      color: color?.transform(t),
      borderRadius: borderRadius?.transform(t),
      border: border?.transform(t),
      boxShadow: boxShadow?.transform(t),
      gradient: gradient?.transform(t),
    );
  }
}

class DecoratedBoxActor extends StatelessWidget {
  final ColorProp? color;
  final BorderRadiusProp? borderRadius;
  final BoxBorderProp? border;
  final BoxShadowProp? boxShadow;
  final GradientProp? gradient;
  final BoxShape shape;
  final Widget? child;
  final Timing? timing;
  final Timing? reverseTiming;
  final Curve? curve;
  final Curve? reverseCurve;
  final ActorRole role;
  final DecorationPosition position;

  const DecoratedBoxActor({
    super.key,
    this.color,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.gradient,
    this.shape = BoxShape.rectangle,
    this.child,
    this.timing,
    this.reverseTiming,
    this.curve,
    this.reverseCurve,
    this.role = ActorRole.both,
    this.position = DecorationPosition.background,
  });

  @override
  Widget build(BuildContext context) {
    return RawActor(
      curve: curve,
      timing: timing,
      reverseCurve: reverseCurve,
      reverseTiming: reverseTiming,
      role: role,
      effects: [
        DecoratedBoxEffect(
          color: color,
          borderRadius: borderRadius,
          border: border,
          boxShadow: boxShadow,
          gradient: gradient,
          shape: shape,
          position: position,
        ),
      ],
      child: child ?? const SizedBox.shrink(),
    );
  }
}
