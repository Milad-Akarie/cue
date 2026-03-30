part of 'base/act.dart';

class TransformAct extends TweenAct<Matrix4> {
  @override
  final ActKey key = const ActKey('Transform');

  TransformAct({
    Matrix4? from,
    required super.to,
    super.motion,
    super.reverse,
    this.alignment,
    this.origin,
    super.delay,
  }) : super.tween(from: from ?? Matrix4.identity());

  final AlignmentGeometry? alignment;
  final Offset? origin;

  TransformAct.keyframed({
    required super.frames,
    super.reverse,
    this.alignment,
    this.origin,
    super.delay,
  }) : super.keyframed(from: Matrix4.identity());

  @override
  Animatable<Matrix4> createSingleTween(Matrix4 from, Matrix4 to) {
    return Matrix4Tween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<Matrix4> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Transform(
          transform: animation.value,
          alignment: alignment,
          origin: origin,
          child: child,
        );
      },
    );
  }
}

class SkewAct extends TweenActBase<Skew, Matrix4> {
  @override
  ActKey get key => const ActKey('Transform:Skew');

  final AlignmentGeometry? alignment;
  final Offset? origin;

  const SkewAct({
    this.alignment,
    this.origin,
    super.delay,
    super.motion,
    super.from = Skew.zero,
    super.to = Skew.zero,
    super.reverse = const ReverseBehavior.mirror(),
  });

  const SkewAct.keyframed({
    required super.frames,
    super.reverse = const KFReverseBehavior.mirror(),
    this.alignment,
    this.origin,
    super.delay,
  }) : super.keyframed();

  @override
  Matrix4 transform(_, Skew value) => Matrix4.skew(value.x, value.y);

  @override
  Animatable<Matrix4> createSingleTween(Matrix4 from, Matrix4 to) {
    return Matrix4Tween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<Matrix4> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Transform(
          transform: animation.value,
          alignment: alignment,
          origin: origin,
          child: child,
        );
      },
    );
  }
}

class Skew {
  final double x;
  final double y;

  const Skew({this.x = 0, this.y = 0});

  static const Skew zero = Skew(x: 0, y: 0);

  const Skew.symmetric(double value) : x = value, y = value;

  @override
  String toString() => 'Skew(x: $x, y: $y)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Skew && runtimeType == other.runtimeType && x == other.x && y == other.y;
  @override
  int get hashCode => Object.hash(x, y);
}
