part of 'base/act.dart';

class PositionAct extends TweenAct<Position> {

  @override
  final ActKey key = const ActKey('Position');
  
  final Size? _relativeTo;

  const PositionAct({
    required super.from,
    required super.to,
    super.motion,
    super.reverse,
    super.delay,
  }) : _relativeTo = null,
       super.tween();

  const PositionAct.relative({
    required super.from,
    required super.to,
    required Size size,
    super.motion,
    super.reverse,
    super.delay,
  }) : _relativeTo = size,
       super.tween();

  @internal
  const PositionAct.internal({
    required super.from,
    required super.to,
    super.motion,
    super.reverse,
    Size? relativeTo,
    super.frames,
    super.delay,
  }) : _relativeTo = relativeTo;

  const PositionAct.keyframed({
    required super.frames,
    super.reverse,
    super.delay,
    Size? relativeTo,
  }) : _relativeTo = relativeTo,
       super.keyframed();

  @override
  Animatable<Position> createSingleTween(Position from, Position to) {
    return _PositionTween(begin: from, end: to);
  }

  @override
  Widget apply(BuildContext context, Animation<Position> animation, Widget child) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final pos = _relativeTo == null ? animation.value : animation.value._relative(_relativeTo);
        return Positioned.directional(
          textDirection: Directionality.of(context),
          top: pos.top,
          start: pos.start,
          end: pos.end,
          bottom: pos.bottom,
          width: pos.width,
          height: pos.height,
          child: child!,
        );
      },
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is PositionAct && super == other
        && other._relativeTo == _relativeTo;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, _relativeTo);
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

  const Position.fill({
    this.start = 0,
    this.top = 0,
    this.end = 0,
    this.bottom = 0,
  }) : width = null,
       height = null;

  Position _relative(Size size) {
    return Position(
      top: top != null ? top! * size.height : null,
      start: start != null ? start! * size.width : null,
      end: end != null ? end! * size.width : null,
      bottom: bottom != null ? bottom! * size.height : null,
      width: width != null ? width! * size.width : null,
      height: height != null ? height! * size.height : null,
    );
  }

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

class _PositionTween extends Tween<Position> {
  _PositionTween({required super.begin, required super.end});

  @override
  Position lerp(double t) => Position.lerp(begin!, end!, t);
}

class PositionActor extends SingleActorBase<Position> {
  final Size? _relativeTo;

  const PositionActor({
    super.key,
    required super.from,
    required super.to,
    required super.child,
    super.motion,
    super.reverseMotion,
    super.delay,
    super.reverseDelay,
    super.reverse,
  }) : _relativeTo = null;

  const PositionActor.keyframed({
    super.key,
    required super.frames,
    required super.child,
    super.reverse,
    Size? relativeTo,
  }) : _relativeTo = relativeTo,
       super.keyframes();

  const PositionActor.relative({
    super.key,
    required super.from,
    required super.to,
    required Size size,
    required super.child,
    super.motion,
    super.reverseMotion,
    super.delay,
    super.reverseDelay,
  }) : _relativeTo = size;

  @override
  Act get act => PositionAct.internal(
    from: from,
    to: to,
    frames: frames,
    relativeTo: _relativeTo,
    motion: motion,
    reverse: reverse,
  );
}
