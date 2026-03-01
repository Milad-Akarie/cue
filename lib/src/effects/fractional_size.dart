part of 'base/effect.dart';

class FractionalSizeEffect extends TweenEffect<Size> {
  const FractionalSizeEffect({
    super.from = Size.zero,
    super.to = Size.zero,
    super.curve,
    super.timing,
    this.alignment = Alignment.center,
  });

  const FractionalSizeEffect.tween({
    required super.from,
    required super.to,
    super.curve,
    super.timing,
    this.alignment = Alignment.center,
  });

  const FractionalSizeEffect.keyframes(
    super.keyframes, {
    super.curve,
    this.alignment = Alignment.center,
  }) : super.keyframes();

  const FractionalSizeEffect.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
    this.alignment = Alignment.center,
  }) : super.internal();

  final AlignmentGeometry alignment;

  @override
  Widget apply(BuildContext context, Animation<Size> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return FractionallySizedBox(
          widthFactor: animation.value.width,
          heightFactor: animation.value.height,
          alignment: alignment,
          child: child,
        );
      },
    );
  }
}

class FractionalSizeActor extends SingleEffectBase<Size> {
  final Axis? _axis;
  final double? _axisFrom;
  final double? _axisTo;
  final AlignmentGeometry alignment;

  const FractionalSizeActor({
    super.key,
    required super.from,
    required super.to,
    this.alignment = Alignment.center,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : _axis = null,
       _axisFrom = null,
       _axisTo = null;

  const FractionalSizeActor.keyframes({
    super.key,
    required super.frames,
    this.alignment = Alignment.center,
    required super.child,
    super.curve,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : _axis = null,
       _axisFrom = null,
       _axisTo = null,
       super.keyframes();

  const FractionalSizeActor.width({
    super.key,
    required double from,
    required double to,
    this.alignment = Alignment.center,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : _axis = Axis.horizontal,
       _axisFrom = from,
       _axisTo = to,
       super(from: Size.zero, to: Size.zero);

  const FractionalSizeActor.height({
    super.key,
    required double from,
    required double to,
    this.alignment = Alignment.center,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : _axis = Axis.vertical,
       _axisFrom = from,
       _axisTo = to,
       super(from: Size.zero, to: Size.zero);

  @override
  Effect get effect {
    Size from = this.from ?? Size.infinite;
    Size to = this.to ?? Size.infinite;
    if (_axis != null) {
      from = switch (_axis) {
        Axis.horizontal => Size.fromWidth(_axisFrom!),
        Axis.vertical => Size.fromHeight(_axisFrom!),
      };
      to = switch (_axis) {
        Axis.horizontal => Size.fromWidth(_axisTo!),
        Axis.vertical => Size.fromHeight(_axisTo!),
      };
    }
    return FractionalSizeEffect.internal(
      from: from,
      to: to,
      alignment: alignment,
      keyframes: frames,
    );
  }
}
