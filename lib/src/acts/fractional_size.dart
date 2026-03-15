part of 'base/act.dart';

class FractionalSizeAct extends ActImpl<FractionaSizeProps, FractionaSizeProps> {
  final AnimatableValue<double>? widthFactor;
  final AnimatableValue<double>? heightFactor;
  final AnimatableValue<AlignmentGeometry>? alignment;

  const FractionalSizeAct({
    super.motion,
    this.widthFactor,
    this.heightFactor,
    this.alignment = const AnimatableValue.fixed(Alignment.center),
    ReverseBehavior<FractionaSizeProps> super.reverse = const ReverseBehavior.mirror(),
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
  (CueAnimtable<FractionaSizeProps> animtable, CueAnimtable<FractionaSizeProps>? reverseAnimtable) buildTweens(
    ActContext context, {
    ValueTransformer<FractionaSizeProps, FractionaSizeProps>? transform,
  }) {
    //TODL: handle reverse motion
    final iFrom = context.implicitFrom as FractionaSizeProps?;
    final from =
        iFrom ??
        FractionaSizeProps(
          widthFactor: widthFactor?.from,
          heightFactor: heightFactor?.from,
          alignment: alignment?.from,
        );
    final tween = _FractionalSizeTween(
      begin: from,
      end: FractionaSizeProps(
        widthFactor: widthFactor?.to,
        heightFactor: heightFactor?.to,
        alignment: alignment?.to,
      ),
    );
    return (TweenAnimtable(tween, motion: motion ?? context.motion), null);
  }
}

class FractionaSizeProps {
  final double? widthFactor;
  final double? heightFactor;
  final AlignmentGeometry? alignment;

  FractionaSizeProps({this.widthFactor, this.heightFactor, this.alignment});

  static FractionaSizeProps lerp(FractionaSizeProps a, FractionaSizeProps b, double t) {
    return FractionaSizeProps(
      widthFactor: lerpDouble(a.widthFactor, b.widthFactor, t),
      heightFactor: lerpDouble(a.heightFactor, b.heightFactor, t),
      alignment: AlignmentGeometry.lerp(a.alignment, b.alignment, t),
    );
  }
}

class _FractionalSizeTween extends Tween<FractionaSizeProps> {
  _FractionalSizeTween({super.begin, super.end});

  @override
  FractionaSizeProps lerp(double t) => FractionaSizeProps.lerp(begin!, end!, t);
}
