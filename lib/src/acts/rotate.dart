part of 'base/act.dart';

class RotateAct extends TweenAct<double> {
  final AlignmentGeometry alignment;
  final RotateUnit unit;
  final RotateAxis axis;

  const RotateAct({
    super.from = 0,
    super.to = 0,
    super.motion,
    super.reverse,
    this.axis = RotateAxis.z,
    this.alignment = Alignment.center,
    this.unit = RotateUnit.degrees,
  });

  const RotateAct.flipX({
    super.motion,
    super.reverse,
    this.alignment = Alignment.center,
  }) : unit = RotateUnit.radians,
       axis = RotateAxis.x,
       super(from: 0, to: math.pi);

  const RotateAct.flipY({
    super.motion,
    super.reverse,
    this.alignment = Alignment.center,
  }) : unit = RotateUnit.radians,
       axis = RotateAxis.y,
       super(from: 0, to: math.pi);

  const RotateAct.keyframes(
    super.keyframes, {
    super.motion,
    super.reverse,
    this.alignment = Alignment.center,
    this.axis = RotateAxis.z,
    this.unit = RotateUnit.radians,
  }) : super.keyframes();

  const RotateAct.radians({
    super.from = 0,
    super.to = 0,
    super.motion,
    super.reverse,
    this.axis = RotateAxis.z,
    this.alignment = Alignment.center,
  }) : unit = RotateUnit.radians;

  const RotateAct.degrees({
    super.from = 0,
    super.to = 0,
    super.motion,
    super.reverse,
    this.alignment = Alignment.center,
    this.axis = RotateAxis.z,
  }) : unit = RotateUnit.degrees;

  const RotateAct.turns({
    super.from = 0,
    super.to = 0,
    super.motion,
    super.reverse,
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
