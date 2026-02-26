part of 'effect.dart';

class PhyscialModalEffect extends TweenEffect<ModalProps> {
  const PhyscialModalEffect({
    super.from = const ModalProps(),
    super.to = const ModalProps(),
    super.curve,
    super.timing,
    this.clipBehavior = Clip.none,
  });

  final Clip clipBehavior;

  const PhyscialModalEffect.keyframes(
    super.keyframes, {
    super.curve,
    this.clipBehavior = Clip.none,
  }) : super.keyframes();

  @internal
  const PhyscialModalEffect.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
    this.clipBehavior = Clip.none,
  }) : super.internal();

  @override
  Animatable<ModalProps> buildSinglePhaseAnimtable(ModalProps from, ModalProps to) {
    return _ModalPropsTween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, covariant Animation<ModalProps> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return PhysicalModel(
          elevation: animation.value.elevation,
          color: animation.value.color,
          shape: animation.value.shape,
          borderRadius: animation.value.borderRadius?.resolve(Directionality.of(context)),
          clipBehavior: clipBehavior,
          shadowColor: animation.value.shadowColor,
          child: child,
        );
      },
    );
  }
}

class ModalProps {
  final double elevation;
  final Color color;
  final Color shadowColor;
  final BorderRadiusGeometry? borderRadius;
  final BoxShape shape;

  const ModalProps({
    this.elevation = 0,
    this.color = const Color(0xFF000000),
    this.borderRadius,
    this.shadowColor = const Color(0xFF000000),
    this.shape = BoxShape.rectangle,
  }) : assert(elevation >= 0.0),
       assert(
         shape != BoxShape.circle || borderRadius == null,
         'borderRadius must be null when shape is BoxShape.circle',
       );

  static ModalProps lerp(ModalProps a, ModalProps b, double t) {
    return ModalProps(
      elevation: lerpDouble(a.elevation, b.elevation, t)!,
      color: Color.lerp(a.color, b.color, t)!,
      borderRadius: BorderRadiusGeometry.lerp(a.borderRadius, b.borderRadius, t),
      shadowColor: Color.lerp(a.shadowColor, b.shadowColor, t)!,
      shape: t < 0.5 ? a.shape : b.shape,
    );
  }
}

class _ModalPropsTween extends Tween<ModalProps> {
  _ModalPropsTween({
    required super.begin,
    required super.end,
  });

  @override
  ModalProps lerp(double t) => ModalProps.lerp(begin!, end!, t);
}

class PhyscialModalActor extends SingleEffectBase<ModalProps> {
  const PhyscialModalActor({
    super.key,
    super.from = const ModalProps(),
    super.to = const ModalProps(),
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
    this.clipBehavior = Clip.none,
  });

  final Clip clipBehavior;

  const PhyscialModalActor.keyframes({
    required super.frames,
    required super.child,
    super.key,
    super.curve,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
    this.clipBehavior = Clip.none,
  }) : super.keyframes();

  @override
  Effect get effect => PhyscialModalEffect.internal(
    from: from,
    to: to,
    timing: timing,
    curve: curve,
    clipBehavior: clipBehavior,
  );
}
