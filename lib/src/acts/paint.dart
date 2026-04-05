part of 'base/act.dart';

/// Animates custom painted content on a widget.
///
/// Provides a progress value (0 to 1) to a custom [Painter] which can render
/// anything on a Canvas. Useful for complex graphics, progress indicators,
/// or animated shapes that aren't available as built-in acts.
class PaintAct extends TweenAct<double> {
  @override
  final ActKey key = const ActKey('Paint');

  /// {@template act.paint}
  /// Animates a progress value passed to a custom painter.
  ///
  /// [painter] receives the animated progress (0 = start, 1 = end) and must
  /// implement [Painter.paint] to render on Canvas. [paintOnTop] controls
  /// whether the painter renders as background (false) or foreground (true).
  ///
  /// ## Basic usage
  ///
  /// ```dart
  /// class MyPainter extends Painter {
  ///   @override
  ///   void paint(Canvas canvas, Size size, double progress) {
  ///     // Draw based on progress
  ///     canvas.drawCircle(
  ///       Offset(size.width / 2, size.height / 2),
  ///       size.width / 2 * progress,
  ///       Paint()..color = Colors.blue,
  ///     );
  ///   }
  /// }
  ///
  /// Actor(
  ///   acts: [
  ///     .paint(painter: MyPainter()),
  ///   ],
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## Inline painter
  ///
  /// ```dart
  /// .paint(
  ///   painter: .paint((canvas, size, progress) {
  ///     canvas.drawLine(
  ///       Offset.zero,
  ///       Offset(size.width * progress, 0),
  ///       Paint()..strokeWidth = 2,
  ///     );
  ///   }),
  /// )
  /// ```
  ///
  /// ## Foreground painter
  ///
  /// ```dart
  /// .paint(
  ///   painter: MyPainter(),
  ///   paintOnTop: true,  // renders on foreground
  /// )
  /// ```
  /// {@endtemplate}
  final Painter painter;
  final bool paintOnTop;

  /// {@macro act.paint}
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

/// Convenience widget for custom paint animations.
///
/// Pre-composes an [Actor] with a [PaintAct], eliminating boilerplate for
/// custom paint animations. Use this instead of wrapping [PaintAct] in [Actor]
/// for better readability.
class PaintActor extends SingleActorBase<double> {
  /// {@template actor.paint}
  /// Creates a custom paint animation widget.
  ///
  /// [painter] receives the animated progress (0 → 1) and renders on Canvas.
  /// [paintOnTop] controls rendering as background (false) or foreground (true).
  ///
  /// ## Simple painter
  ///
  /// ```dart
  /// PaintActor(
  ///   painter: MyCirclePainter(),
  ///   child: MyWidget(),
  /// )
  /// ```
  ///
  /// ## Inline painter
  ///
  /// ```dart
  /// PaintActor(
  ///   painter: Painter.paint((canvas, size, progress) {
  ///     canvas.drawRect(
  ///       Rect.fromLTWH(0, 0, size.width * progress, size.height),
  ///       Paint()..color = Colors.blue,
  ///     );
  ///   }),
  ///   child: MyWidget(),
  /// )
  /// ```
  /// {@endtemplate}
  final Painter painter;
  final bool paintOnTop;

  /// {@macro actor.paint}
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

/// Base interface for custom painters used by [PaintAct] and [PaintActor].
///
/// Implement [paint] to render on Canvas using the provided progress value.
/// The progress value ranges from 0 (animation start) to 1 (animation end).
///
/// ## Implementing a custom painter
///
/// ```dart
/// class CircleProgressPainter extends Painter {
///   final Color color;
///
///   CircleProgressPainter({this.color = Colors.blue});
///
///   @override
///   void paint(Canvas canvas, Size size, double progress) {
///     final paint = Paint()..color = color;
///     canvas.drawCircle(
///       Offset(size.width / 2, size.height / 2),
///       size.width / 2 * progress,
///       paint,
///     );
///   }
/// }
/// ```
///
/// Use with [PaintActor]:
///
/// ```dart
/// PaintActor(
///   painter: CircleProgressPainter(color: Colors.blue),
///   child: SizedBox(width: 100, height: 100),
/// )
/// ```
///
/// Or use the inline callback constructor:
///
/// ```dart
/// PaintActor(
///   painter: Painter.paint((canvas, size, progress) {
///     canvas.drawCircle(
///       Offset(size.width / 2, size.height / 2),
///       size.width / 2 * progress,
///       Paint()..color = Colors.blue,
///     );
///   }),
///   child: SizedBox(width: 100, height: 100),
/// )
/// ```
abstract class Painter {
  const Painter();

  /// Renders on [canvas] based on animation progress.
  ///
  /// [progress] ranges from 0 (start) to 1 (end). Use this value to update
  /// paint properties, positions, or any other rendering parameters.
  void paint(Canvas canvas, Size size, double progress);

  /// Creates a painter from an inline callback function.
  ///
  /// Useful for simple paint logic without defining a full class.
  const factory Painter.paint(PaintaerCallback callback) = _PaintterCallback;
}

/// Callback signature for inline custom painters.
///
/// Used by [Painter.paint] factory for defining paint logic without a class.
///
/// Parameters:
/// - [canvas]: The canvas to paint on
/// - [size]: The size available for painting
/// - [progress]: Animation progress from 0 (start) to 1 (end)
typedef PaintaerCallback = void Function(Canvas canvas, Size size, double progress);

/// Internal painter implementation for callback functions.
///
/// Used by [Painter.paint] factory to wrap inline paint callbacks.
class _PaintterCallback extends Painter {
  final PaintaerCallback callback;

  /// Creates a painter from a paint callback function.
  const _PaintterCallback(this.callback);

  @override
  void paint(Canvas canvas, Size size, double progress) {
    callback(canvas, size, progress);
  }
}
