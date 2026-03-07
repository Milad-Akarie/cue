part of 'base/act.dart';

class FractionalSizeAct extends MulitTweenAct<FractionaSizeProps> {
  final AnimatableValue<double>? widthFactor;
  final AnimatableValue<double>? heightFactor;
  final AnimtableAlignment alignment;

  const FractionalSizeAct({
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
    this.widthFactor,
    this.heightFactor,
    this.alignment = const AnimtableAlignment.fixed(Alignment.center),
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
  CueAnimtable<FractionaSizeProps> buildTween(ActContext context) {
    final iFrom = context.implicitFrom as FractionaSizeProps?;
    ActContext withFrom(Object? from) {
      return context.copyWith(implicitFrom: from);
    }

    return _FractionalSizeTween(
      widthFactor: widthFactor?.buildAnimtable(withFrom(iFrom?.widthFactor)),
      heightFactor: heightFactor?.buildAnimtable(withFrom(iFrom?.heightFactor)),
      alignment: alignment.buildAnimtable(withFrom(iFrom?.alignment)),
    );
  }
}

class FractionaSizeProps {
  final double? widthFactor;
  final double? heightFactor;
  final Alignment? alignment;

  FractionaSizeProps(this.widthFactor, this.heightFactor, this.alignment);
}

class _FractionalSizeTween extends CueAnimtable<FractionaSizeProps> {
  final CueAnimtable<double>? widthFactor;
  final CueAnimtable<double>? heightFactor;
  final CueAnimtable<Alignment?> alignment;

  @override
  bool shouldNotify(AnimationStatus status) {
    return (widthFactor?.shouldNotify(status) ?? false) ||
        (heightFactor?.shouldNotify(status) ?? false) ||
        (alignment.shouldNotify(status));
  }

  _FractionalSizeTween({
    this.widthFactor,
    this.heightFactor,
    required this.alignment,
  });

  @override
  FractionaSizeProps transform(double t, AnimationStatus status) {
    return FractionaSizeProps(
      widthFactor?.transform(t, status),
      heightFactor?.transform(t, status),
      alignment.transform(t, status),
    );
  }
}
