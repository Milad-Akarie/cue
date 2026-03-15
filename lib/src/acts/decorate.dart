part of 'base/act.dart';

class DecoratedBoxAct extends ActImpl<Decoration, Decoration> {
  final AnimatableValue<Color>? color;
  final AnimatableValue<BorderRadiusGeometry>? borderRadius;
  final AnimatableValue<BoxBorder>? border;
  final AnimatableValue<List<BoxShadow>>? boxShadow;
  final AnimatableValue<Gradient>? gradient;
  final BoxShape shape;
  final DecorationPosition position;

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
  });

  @override
  (CueAnimtable<Decoration> animtable, CueAnimtable<Decoration>? reverseAnimtable) buildTweens(ActContext context) {
    final iFrom = context.implicitFrom as Decoration?;
    final from =
        iFrom ??
        BoxDecoration(
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

    // CueAnimtable<Decoration>? reverseAnimtable;
    // if (reverse.needsReverseTween) {
    //   final rTo = reverse.to;
    //   final effectiveRTo =
    //       rTo ??
    //       BoxDecoration(
    //         color: color?.to,
    //         borderRadius: borderRadius?.to,
    //         border: border?.to,
    //         boxShadow: boxShadow?.to,
    //         gradient: gradient?.to,
    //         shape: shape,
    //       );
    //   if (effectiveRTo != to) {
    //     reverseAnimtable = TweenAnimtable<Decoration>(
    //       DecorationTween(begin: to, end: effectiveRTo),
    //       motion: reverse.motion ?? context.reverseMotion,
    //     );
    //   }
    // }

    return (
      TweenAnimtable(
        DecorationTween(begin: from, end: to),
        motion: motion ?? context.motion,
      ),
      null,
    );
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
  });

  @override
  Widget build(BuildContext context) {
    return Actor(
      act: DecoratedBoxAct(
        color: color,
        borderRadius: borderRadius,
        border: border,
        boxShadow: boxShadow,
        gradient: gradient,
        shape: shape,
        position: position,
        motion: motion,
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }
}
