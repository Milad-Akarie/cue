part of 'base/act.dart';

class PaintAct extends TweenAct<double> {
  final EffectPainter painter;
  final bool paintOnTop;

  const PaintAct({
    required this.painter,
    this.paintOnTop = false,
    super.motion,
    super.reverse,
  }) : super.tween(from: 0.0, to: 1.0);

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    final customPainter = _EffectPainterBase(animation, painter);
    return CustomPaint(
      painter: !paintOnTop ? customPainter : null,
      foregroundPainter: paintOnTop ? customPainter : null,
      child: child,
    );
  }
}

class PaintActor extends SingleActorBase<double> {
  final EffectPainter painter;
  final bool paintOnTop;

  const PaintActor({
    super.key,
    required this.painter,
    this.paintOnTop = false,
    required super.child,
    super.motion,
    super.reverse,
  }) : super(from: 0.0, to: 1.0);

  @override
  Act get effect => PaintAct(
    painter: painter,
    paintOnTop: paintOnTop,
    motion: motion,
    reverse: reverse,
  );
}

class _EffectPainterBase extends CustomPainter {
  final Animation<double> animation;
  final EffectPainter painter;
  _EffectPainterBase(this.animation, this.painter) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    painter.paint(canvas, size, animation.value);
  }

  @override
  bool shouldRepaint(covariant _EffectPainterBase oldDelegate) {
    return animation.value != oldDelegate.animation.value;
  }
}

abstract class EffectPainter {
  const EffectPainter();

  void paint(Canvas canvas, Size size, double progress);

  const factory EffectPainter.paint(EffectPainterCallback callback) = _EffectPaintterCallback;
}

typedef EffectPainterCallback = void Function(Canvas canvas, Size size, double progress);

class _EffectPaintterCallback extends EffectPainter {
  final EffectPainterCallback callback;
  const _EffectPaintterCallback(this.callback);

  @override
  void paint(Canvas canvas, Size size, double progress) {
    callback(canvas, size, progress);
  }
}
