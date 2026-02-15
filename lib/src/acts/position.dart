part of 'act.dart';

class PositionAct extends TweenAct<Position> {
  const PositionAct({
    required super.from,
    required super.to,
    super.curve,
    super.timing,
  });

  const PositionAct.keyframes(super.keyframes, {super.curve}) : super.keyframes();

  @override
  Widget apply(BuildContext context, Animation<Position> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final pos = animation.value;
        return PositionedDirectional(
          top: pos.top,
          start: pos.start,
          end: pos.end,
          bottom: pos.bottom,
          width: pos.width,
          height: pos.height,
          child: child!,
        );
      },
      child: child,
    );
  }
}

class Position {
  final double? top;
  final double? start;
  final double? end;
  final double? bottom;
  final double? width;
  final double? height;

  const Position({
    this.start,
    this.top,
    this.end,
    this.bottom,
    this.width,
    this.height,
  }) : assert(start == null || end == null || width == null),
       assert(top == null || bottom == null || height == null);

  const Position.fill() : this(top: 0, start: 0, end: 0, bottom: 0);

  static Position lerp(Position a, Position b, double t) {
    return Position(
      top: _lerpNullable(a.top, b.top, t),
      start: _lerpNullable(a.start, b.start, t),
      end: _lerpNullable(a.end, b.end, t),
      bottom: _lerpNullable(a.bottom, b.bottom, t),
      width: _lerpNullable(a.width, b.width, t),
      height: _lerpNullable(a.height, b.height, t),
    );
  }

  static double? _lerpNullable(double? a, double? b, double t) {
    if (a == null && b == null) return null;
    return (a ?? 0) + ((b ?? 0) - (a ?? 0)) * t;
  }
}
