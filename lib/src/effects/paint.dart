part of 'base/effect.dart';

class PaintEffect extends TweenEffect<double> {
  final EffectPainter painter;
  final bool paintOnTop;

  PaintEffect({
    required this.painter,
    this.paintOnTop = false,
    super.curve,
    super.timing,
  }) : super(from: 0.0, to: 1.0);

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

class PaintActor extends SingleEffectBase<double> {
  final EffectPainter painter;
  final bool paintOnTop;

  const PaintActor({
    super.key,
    required this.painter,
    this.paintOnTop = false,
    required super.child,
    super.curve,
    super.timing,
  }) : super(from: 0.0, to: 1.0);

  @override
  Effect get effect => PaintEffect(
    painter: painter,
    paintOnTop: paintOnTop,
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
