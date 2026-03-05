part of 'base/act.dart';

class FractionalResizeAct extends MulitTweenAct<FractionaSizeProps> {
  final DoubleProp? widthFactor;
  final DoubleProp? heightFactor;
  final AlignmentProp alignment;

  const FractionalResizeAct({
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
    this.widthFactor,
    this.heightFactor,
    this.alignment = const AlignmentProp.fixed(Alignment.center),
  });

  @override
  Widget apply(BuildContext context, Animation<FractionaSizeProps> animation, Widget child) {
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
  Animatable<FractionaSizeProps> buildTween(ActContext context) {
    final iFrom = context.implicitFrom as FractionaSizeProps?;
    ActContext withFrom(Object? from) {
      return context.copyWith(implicitFrom: from);
    }

    return _FractionalSizeTween(
      widthFactor: widthFactor?.asAnimtable(withFrom(iFrom?.widthFactor)),
      heightFactor: heightFactor?.asAnimtable(withFrom(iFrom?.heightFactor)),
      alignment: alignment.asAnimtable(withFrom(iFrom?.alignment)),
    );
  }
}

@internal
class FractionaSizeProps {
  final double? widthFactor;
  final double? heightFactor;
  final Alignment? alignment;

  FractionaSizeProps(this.widthFactor, this.heightFactor, this.alignment);
}

class _FractionalSizeTween extends Animatable<FractionaSizeProps> {
  final Animatable<double>? widthFactor;
  final Animatable<double>? heightFactor;
  final Animatable<Alignment?> alignment;

  _FractionalSizeTween({
    this.widthFactor,
    this.heightFactor,
    required this.alignment,
  });

  @override
  FractionaSizeProps transform(double t) {
    return FractionaSizeProps(
      widthFactor?.transform(t),
      heightFactor?.transform(t),
      alignment.transform(t),
    );
  }
}
