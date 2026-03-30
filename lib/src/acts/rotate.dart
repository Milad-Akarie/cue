part of 'base/act.dart';

class RotateAct extends TweenAct<double> {
  @override
  final ActKey key = const ActKey('Rotate');

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
    super.delay,
  }) : super.tween();

  const RotateAct.flipX({
    super.motion,
    super.reverse,
    this.alignment = Alignment.center,
  }) : unit = RotateUnit.radians,
       axis = RotateAxis.x,
       super.tween(from: 0, to: math.pi);

  const RotateAct.flipY({
    super.motion,
    super.reverse,
    this.alignment = Alignment.center,
  }) : unit = RotateUnit.radians,
       axis = RotateAxis.y,
       super.tween(from: 0, to: math.pi);

  const RotateAct.keyframed({
    required super.frames,
    super.reverse,
    super.delay,
    this.alignment = Alignment.center,
    this.axis = RotateAxis.z,
    this.unit = RotateUnit.radians,
  }) : super.keyframed(from: 0);

  const RotateAct.radians({
    super.from = 0,
    super.to = 0,
    super.motion,
    super.reverse,
    this.axis = RotateAxis.z,
    this.alignment = Alignment.center,
  }) : unit = RotateUnit.radians,
       super.tween();

  const RotateAct.degrees({
    super.from = 0,
    super.to = 0,
    super.motion,
    super.reverse,
    this.alignment = Alignment.center,
    this.axis = RotateAxis.z,
  }) : unit = RotateUnit.degrees,
       super.tween();

  const RotateAct.turns({
    super.from = 0,
    super.to = 0,
    super.motion,
    super.reverse,
    this.axis = RotateAxis.z,
    this.alignment = Alignment.center,
  }) : unit = RotateUnit.quarterTurns,
       super.tween();

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
      alignment: alignment.resolve(Directionality.maybeOf(context)),
      onTransform: switch (axis) {
        RotateAxis.x => Matrix4.rotationX,
        RotateAxis.y => Matrix4.rotationY,
        RotateAxis.z => Matrix4.rotationZ,
      },
      child: child,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is RotateAct &&
          super == other &&
          alignment == other.alignment &&
          unit == other.unit &&
          axis == other.axis;

  @override
  int get hashCode => Object.hash(super.hashCode, alignment, unit, axis);
}

class Rotate3DAct extends TweenAct<Rotation3D> {
  @override
  final ActKey key = const ActKey('Rotate3D');

  final AlignmentGeometry alignment;
  final double perspective;
  final Rotate3DUnit unit;

  const Rotate3DAct({
    super.from = Rotation3D.zero,
    super.to = Rotation3D.zero,
    this.alignment = Alignment.center,
    this.perspective = 0.001,
    super.motion,
    super.reverse,
    super.delay,
    this.unit = Rotate3DUnit.degrees,
  }) : super.tween();

  const Rotate3DAct.keyframed({
    required super.frames,
    super.reverse,
    super.delay,
    this.alignment = Alignment.center,
    this.perspective = 0.001,
    this.unit = Rotate3DUnit.degrees,
  }) : super.keyframed(from: Rotation3D.zero);

  @override
  Rotation3D transform(_, Rotation3D value) {
    switch (unit) {
      case Rotate3DUnit.degrees:
        return Rotation3D(
          x: value.x * math.pi / 180,
          y: value.y * math.pi / 180,
          z: value.z * math.pi / 180,
        );
      case Rotate3DUnit.radians:
        return value;
    }
  }

  @override
  Animatable<Rotation3D> createSingleTween(Rotation3D from, Rotation3D to) {
    return _Rotation3DTween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<Rotation3D> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, perspective)
          ..rotateX(animation.value.x)
          ..rotateY(animation.value.y)
          ..rotateZ(animation.value.z);
        return Transform(
          transform: matrix,
          alignment: alignment.resolve(Directionality.maybeOf(context)),
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Rotate3DAct &&
          super == other &&
          alignment == other.alignment &&
          perspective == other.perspective &&
          unit == other.unit;

  @override
  int get hashCode => Object.hash(super.hashCode, alignment, perspective, unit);
}

class Rotation3D {
  final double x;
  final double y;
  final double z;

  const Rotation3D({
    this.x = 0,
    this.y = 0,
    this.z = 0,
  });

  static const zero = Rotation3D();

  @override
  String toString() => 'Rotation3D(x: $x, y: $y, z: $z)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Rotation3D && runtimeType == other.runtimeType && x == other.x && y == other.y && z == other.z;

  @override
  int get hashCode => Object.hash(x, y, z);

  Rotation3D lerpTo(Rotation3D other, double t) {
    return Rotation3D(
      x: x + (other.x - x) * t,
      y: y + (other.y - y) * t,
      z: z + (other.z - z) * t,
    );
  }

  static Rotation3D? lerp(Rotation3D? a, Rotation3D? b, double t) {
    if (a == null && b == null) return null;
    a ??= zero;
    b ??= zero;
    return a.lerpTo(b, t);
  }
}

class _Rotation3DTween extends Tween<Rotation3D> {
  _Rotation3DTween({super.begin, super.end});

  @override
  Rotation3D lerp(double t) => Rotation3D.lerp(begin, end, t)!;
}

enum RotateAxis { x, y, z }

enum RotateUnit { degrees, radians, quarterTurns }

enum Rotate3DUnit { degrees, radians }



      //         Cue.onToggle(
      //           motion: .linear(500.ms),
      //           toggled: _checked,
      //           child: Stack(
      //             children: [
      //               Actor(
      //                 acts: [
      //                   .rotate3D(
      //                     from: .zero,
      //                     to: Rotation3D(y: 180),
      //                     perspective: 0.005,
      //                   ),
      //                   .fadeOut(motion: .curved(500.ms, curve: Threshold(0.5))),
      //                 ],
      //                 child: Box(
      //                   size: Size(80, 80),
      //                   color: Colors.blue,
      //                 ),
      //               ),
      //               Actor(
      //                 acts: [
      //                   .rotate3D(
      //                     from: Rotation3D(y: -180),
      //                     to: .zero,
      //                     perspective: 0.005,
      //                   ),
      //                   .fadeIn(motion: .curved(500.ms, curve: Threshold(0.5))),
      //                 ],
      //                 child: Box(
      //                   size: Size(80, 80),
      //                   color: Colors.red.withValues(alpha: .8),
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),