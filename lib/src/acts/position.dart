part of 'act.dart';

class PositionEffect extends TweenEffect<Position> {
  final bool _relative;
  const PositionEffect({
    required super.from,
    required super.to,
    super.curve,
    super.timing,
  }) : _relative = false;

  @internal
  const PositionEffect.internal({
    required super.from,
    required super.to,
    required bool relative,
    super.curve,
    super.timing,
  }) : _relative = relative;

  const PositionEffect.keyframes(
    super.keyframes, {
    super.curve,
    bool relative = false,
  }) : _relative = relative,
       super.keyframes();

  const PositionEffect.relative({
    required super.from,
    required super.to,
    super.curve,
    super.timing,
  }) : _relative = true;

  @override
  Widget apply(
    BuildContext context,
    Animation<Position> animation,
    Widget child,
  ) {
    if (_relative) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return _AnimatedPostion(
            postion: animation,
            child: child,
            transform: (p) => p._relativeTo(constraints.biggest),
          );
        },
      );
    } else {
      return _AnimatedPostion(
        postion: animation,
        child: child,
        transform: (p) => p,
      );
    }
  }
}

class _AnimatedPostion extends AnimatedWidget {
  final Animation<Position> postion;
  final Widget child;
  final Function(Position) transform;

  const _AnimatedPostion({
    required this.postion,
    required this.child,
    required this.transform,
  }) : super(listenable: postion);

  @override
  Widget build(BuildContext context) {
    final pos = transform(postion.value);
    return PositionedDirectional(
      top: pos.top,
      start: pos.start,
      end: pos.end,
      bottom: pos.bottom,
      width: pos.width,
      height: pos.height,
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

  Position _relativeTo(Size size) {
    return Position(
      top: top != null ? top! * size.height : null,
      start: start != null ? start! * size.width : null,
      end: end != null ? end! * size.width : null,
      bottom: bottom != null ? bottom! * size.height : null,
      width: width != null ? width! * size.width : null,
      height: height != null ? height! * size.height : null,
    );
  }

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
