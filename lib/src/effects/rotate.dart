part of 'base/effect.dart';

class RotateEffect extends TweenEffect<double> {
  final AlignmentGeometry alignment;
  final RotateUnit unit;
  final RotateAxis axis;

  @internal
  const RotateEffect.internal({
    super.from = 0,
    super.to = 0,
    super.keyframes,
    super.curve,
    super.timing,
    this.alignment = Alignment.center,
    required this.unit,
    required this.axis,
  }) : super.internal();

  const RotateEffect({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
    this.axis = RotateAxis.z,
    this.alignment = Alignment.center,
  }) : unit = RotateUnit.radians;

  const RotateEffect.flipX({
    super.curve,
    super.timing,
    this.alignment = Alignment.center,
  }) : unit = RotateUnit.radians,
       axis = RotateAxis.x,
       super(from: 0, to: math.pi);

  const RotateEffect.flipY({
    super.curve,
    super.timing,
    this.alignment = Alignment.center,
  }) : unit = RotateUnit.radians,
       axis = RotateAxis.y,
       super(from: 0, to: math.pi);

  const RotateEffect.keyframes(
    super.keyframes, {
    super.curve,
    this.alignment = Alignment.center,
    this.axis = RotateAxis.z,
    this.unit = RotateUnit.radians,
  }) : super.keyframes();

  const RotateEffect.radians({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
    this.axis = RotateAxis.z,
    this.alignment = Alignment.center,
  }) : unit = RotateUnit.radians;

  const RotateEffect.degrees({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
    this.alignment = Alignment.center,
    this.axis = RotateAxis.z,
  }) : unit = RotateUnit.degrees;

  const RotateEffect.turns({
    super.from = 0,
    super.to = 0,
    super.curve,
    super.timing,
    this.axis = RotateAxis.z,
    this.alignment = Alignment.center,
  }) : unit = RotateUnit.quarterTurns;

  @override
  double transform(_, double value) {
    switch (unit) {
      case RotateUnit.degrees:
        return value * math.pi / 180;
      case RotateUnit.quarterTurns:
        return value * math.pi / 2;
      case RotateUnit.radians:
        return value;
    }
  }

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    return MatrixTransition(
      animation: animation,
      alignment: alignment.resolve(Directionality.of(context)),
      onTransform: switch (axis) {
        RotateAxis.x => Matrix4.rotationX,
        RotateAxis.y => Matrix4.rotationY,
        RotateAxis.z => Matrix4.rotationZ,
      },
      child: child,
    );
  }
}

enum RotateAxis { x, y, z }

enum RotateUnit { degrees, radians, quarterTurns }

class RotateActor extends SingleEffectBase<double> {
  final AlignmentGeometry alignment;
  final RotateUnit unit;
  final RotateAxis axis;

  const RotateActor({
    super.key,
    required super.from,
    required super.to,
    required super.child,
    this.alignment = Alignment.center,
    super.curve,
    super.timing,
    this.axis = RotateAxis.z,
  }) : unit = RotateUnit.radians;

  const RotateActor.keyframes({
    required super.frames,
    super.key,
    required super.child,
    this.alignment = Alignment.center,
    this.axis = RotateAxis.z,
    this.unit = RotateUnit.radians,
  }) : super.keyframes();

  const RotateActor.flipX({
    super.key,
    required super.child,
    this.alignment = Alignment.center,
    super.curve,
    super.timing,
  }) : unit = RotateUnit.radians,
       axis = RotateAxis.x,
       super(from: 0, to: math.pi);

  const RotateActor.flipY({
    super.key,
    required super.child,
    this.alignment = Alignment.center,
    super.curve,
    super.timing,
  }) : unit = RotateUnit.radians,
       axis = RotateAxis.y,
       super(from: 0, to: math.pi);

  const RotateActor.turns({
    super.key,
    super.from = 0,
    required super.to,
    required super.child,
    this.alignment = Alignment.center,
    super.curve,
    super.timing,
    this.axis = RotateAxis.z,
  }) : unit = RotateUnit.quarterTurns;

  const RotateActor.degrees({
    super.key,
    super.from = 0,
    required super.to,
    required super.child,
    this.alignment = Alignment.center,
    super.curve,
    super.timing,
    this.axis = RotateAxis.z,
  }) : unit = RotateUnit.degrees;

  @override
  Effect get effect => RotateEffect.internal(
    from: from,
    to: to,
    curve: curve,
    timing: timing,
    alignment: alignment,
    keyframes: frames,
    unit: unit,
    axis: axis,
  );
}
