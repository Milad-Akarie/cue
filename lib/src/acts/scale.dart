part of 'base/act.dart';

class ScaleAct extends TweenAct<double> {
  @override
  final ActKey key = const ActKey('Scale');

  final AlignmentGeometry? alignment;

  const ScaleAct({
    super.from = 1.0,
    super.to = 1.0,
    super.motion,
    super.reverse,
    this.alignment,
    super.delay,
  }) : super.tween();

  const ScaleAct.zoomIn({
    super.from = 0.0,
    super.to = 1.0,
    super.motion,
    super.reverse,
    this.alignment,
    super.delay,
  }) : super.tween();

  const ScaleAct.zoomOut({
    super.from = 1.0,
    super.to = 0.0,
    super.motion,
    super.reverse,
    this.alignment,
    super.delay,
  }) : super.tween();

  const ScaleAct.keyframed({
    required super.frames,
    super.reverse,
    super.delay,
    this.alignment,
  }) : super.keyframed(from: 1.0);

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    final directionality = Directionality.maybeOf(context);
    final effectiveAlignment = alignment?.resolve(directionality) ?? Alignment.center;
    return ScaleTransition(
      scale: animation,
      alignment: effectiveAlignment,
      child: child,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScaleAct && super == other && other.alignment == alignment;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, alignment);
}

class StretchAct extends TweenActBase<Stretch, Matrix4> {
  @override
  final ActKey key = const ActKey('Stretch');

  const StretchAct({
    super.from = Stretch.none,
    super.to = Stretch.none,
    super.motion,
    super.reverse,
    super.delay,
  }) : super.tween();

  const StretchAct.keyframed({
    required super.frames,
    super.reverse,
    super.delay,
  }) : super.keyframed(from: Stretch.none);

  @override
  Matrix4 transform(_, Stretch value) {
    return Matrix4.diagonal3Values(value.x, value.y, 1.0);
  }

  @override
  Animatable<Matrix4> createSingleTween(Matrix4 from, Matrix4 to) {
    return Matrix4Tween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<Matrix4> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform(
          transform: animation.value,
          alignment: Alignment.center,
          child: child,
        );
      },
      child: child,
    );
  }
}

class Stretch {
  final double x;
  final double y;

  const Stretch({this.x = 1.0, this.y = 1.0});

  static const none = Stretch(x: 1.0, y: 1.0);

  @override
  String toString() => 'Stretch(x: $x, y: $y)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Stretch && runtimeType == other.runtimeType && x == other.x && y == other.y;

  @override
  int get hashCode => Object.hash(x, y);
}
