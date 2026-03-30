part of 'base/act.dart';

class PaintAct extends TweenAct<double> {
  @override
  final ActKey key = const ActKey('Paint');

  final Painter painter;
  final bool paintOnTop;

  const PaintAct({
    required this.painter,
    this.paintOnTop = false,
    super.motion,
    super.reverse,
    super.delay,
  }) : super.tween(from: 0.0, to: 1.0);

  @override
  Widget apply(BuildContext context, Animation<double> animation, Widget child) {
    final customPainter = _PainterBase(animation, painter);
    return CustomPaint(
      painter: !paintOnTop ? customPainter : null,
      foregroundPainter: paintOnTop ? customPainter : null,
      child: child,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaintAct && super == other &&
        other.key == key &&
        other.painter == painter &&
        other.paintOnTop == paintOnTop;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, key, painter, paintOnTop);
}

class PaintActor extends SingleActorBase<double> {
  final Painter painter;
  final bool paintOnTop;

  const PaintActor({
    super.key,
    required this.painter,
    this.paintOnTop = false,
    required super.child,
    super.motion,
    super.reverse,
    super.delay,
  }) : super(from: 0.0, to: 1.0);

  @override
  Act get act => PaintAct(
    painter: painter,
    paintOnTop: paintOnTop,
    motion: motion,
    reverse: reverse,
    delay: delay,
  );
}

class _PainterBase extends CustomPainter {
  final Animation<double> animation;
  final Painter painter;
  _PainterBase(this.animation, this.painter) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    painter.paint(canvas, size, animation.value);
  }

  @override
  bool shouldRepaint(covariant _PainterBase oldDelegate) {
    return animation.value != oldDelegate.animation.value;
  }
}

abstract class Painter {
  const Painter();

  void paint(Canvas canvas, Size size, double progress);

  const factory Painter.paint(PaintaerCallback callback) = _PaintterCallback;
}

typedef PaintaerCallback = void Function(Canvas canvas, Size size, double progress);

class _PaintterCallback extends Painter {
  final PaintaerCallback callback;
  const _PaintterCallback(this.callback);

  @override
  void paint(Canvas canvas, Size size, double progress) {
    callback(canvas, size, progress);
  }
}

  // PaintAct(
  //  paintOnTop: true,
  //  painter: .paint((canvas, size, progress) {
  //    final center = size.center(Offset.zero);
  //    final radius = size.width / 2;
  //    final steps = 60;
  //    if (progress == 0) return;

  //    final path = Path();

  //    for (int i = 0; i <= steps; i++) {
  //      final t = i / steps;
  //      final angle = -pi / 2 + 2 * pi * 1.1 * t;
  //      final wobble = sin(t * 13) * 3.5 + sin(t * 7) * 1.5;
  //      final r = radius + wobble;
  //      final x = center.dx + cos(angle) * r;
  //      final y = center.dy + sin(angle) * r;
  //      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
  //    }
  //    final paint = Paint()
  //      ..color = theme.colorScheme.primary
  //      ..style = PaintingStyle.stroke
  //      ..strokeCap = StrokeCap.round
  //      ..strokeMiterLimit = 2
  //      ..strokeWidth = 2;

  //    final metric = path.computeMetrics().first;
  //    final subPath = metric.extractPath(0, metric.length * progress);
  //    canvas.drawPath(subPath, paint);
  //  }),
  //),