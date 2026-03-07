part of 'base/act.dart';

class DecoratedBoxAct extends MulitTweenAct<BoxDecoration> {
  final AnimtableColor? color;
  final AnimtableBorderRadius? borderRadius;
  final AnimtableBoxBorder? border;
  final AnimtableBoxShadow? boxShadow;
  final AnimtableGradient? gradient;
  final BoxShape shape;
  final DecorationPosition position;

  const DecoratedBoxAct({
    this.color,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.gradient,
    super.timing,
    super.reverseTiming,
    super.reverseCurve,
    super.curve,
    this.position = DecorationPosition.background,
    this.shape = BoxShape.rectangle,
  });

  @override
  CueAnimtable<BoxDecoration> buildTween(ActContext context) {
    final iFrom = context.implicitFrom as BoxDecoration?;

    ActContext withFrom(Object? from) {
      return context.copyWith(implicitFrom: from);
    }

    return _DecorationTweenProxy(
      color: color?.buildAnimtable(withFrom(iFrom?.color)),
      borderRadius: borderRadius?.buildAnimtable(withFrom(iFrom?.borderRadius)),
      border: border?.buildAnimtable(withFrom(iFrom?.border)),
      boxShadow: boxShadow?.buildAnimtable(withFrom(iFrom?.boxShadow)),
      gradient: gradient?.buildAnimtable(withFrom(iFrom?.gradient)),
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
    return other is DecoratedBoxAct &&
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

class _DecorationTweenProxy extends CueAnimtable<BoxDecoration> {
  final CueAnimtable<Color?>? color;
  final CueAnimtable<BorderRadiusGeometry?>? borderRadius;
  final CueAnimtable<BoxBorder?>? border;
  final CueAnimtable<List<BoxShadow>?>? boxShadow;
  final CueAnimtable<Gradient?>? gradient;
  final BoxShape shape;

  @override
  bool shouldNotify(AnimationStatus status) {
    return (color?.shouldNotify(status) ?? false) ||
        (borderRadius?.shouldNotify(status) ?? false) ||
        (border?.shouldNotify(status) ?? false) ||
        (boxShadow?.shouldNotify(status) ?? false) ||
        (gradient?.shouldNotify(status) ?? false);
  }

  _DecorationTweenProxy({
    this.color,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.gradient,
    this.shape = BoxShape.rectangle,
  });

  @override
  BoxDecoration transform(double t, AnimationStatus status) {
    return BoxDecoration(
      shape: shape,
      color: color?.transform(t, status),
      borderRadius: borderRadius?.transform(t, status),
      border: border?.transform(t, status),
      boxShadow: boxShadow?.transform(t, status),
      gradient: gradient?.transform(t, status),
    );
  }
}

class DecoratedBoxActor extends StatelessWidget {
  final AnimtableColor? color;
  final AnimtableBorderRadius? borderRadius;
  final AnimtableBoxBorder? border;
  final AnimtableBoxShadow? boxShadow;
  final AnimtableGradient? gradient;
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
    return Actor(
      role: role,
      act: DecoratedBoxAct(
        color: color,
        borderRadius: borderRadius,
        border: border,
        boxShadow: boxShadow,
        gradient: gradient,
        shape: shape,
        position: position,
        curve: curve,
        timing: timing,
        reverseCurve: reverseCurve,
        reverseTiming: reverseTiming,
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }
}
