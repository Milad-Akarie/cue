import 'package:cue/cue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Controls what happens when the user releases the drag.
enum CueDragReleaseMode {
  /// Flings with the finger's velocity using a spring simulation.
  /// Falls back to [snap] when velocity is too low or no [CueController] is available.
  fling,

  /// Snaps forward if progress > 0.5, reverses otherwise.
  snap,

  /// Stays wherever the drag stopped — no completion animation.
  none,
}

enum CueScrubDirection {
  forward,
  reverse,
  auto,
}

/// A widget that scrubs the active [CueController] by dragging.
///
/// The controller is resolved in priority order:
/// 1. The explicit [controller] prop, if provided.
/// 2. The [CueController] from the nearest [CueScope] ancestor.
///
/// Throws if neither is available.
///
/// ```dart
/// Cue(
///   timeline: _controller.timeline,
///   child: CueDragScrubber(
///     distance: 220,           // controller taken from CueScope
///     child: DecoratedBoxActor(...),
///   ),
/// )
/// ```
class CueDragScrubber extends StatefulWidget {
  const CueDragScrubber({
    super.key,
    required this.child,
    required this.distance,
    this.controller,
    this.axis = Axis.vertical,
    this.releaseMode = CueDragReleaseMode.fling,
    this.forceLinearScrubing = true,
    this.hitTestBehavior,
    this.onAnimationEnd,
    this.scrubDirection = CueScrubDirection.auto,
  });
  final ValueChanged<bool>? onAnimationEnd;
  final HitTestBehavior? hitTestBehavior;
  final bool forceLinearScrubing;
  final CueScrubDirection scrubDirection;

  /// The widget below this widget in the tree.
  final Widget child;

  /// The number of logical pixels that map to a full 0→1 progress travel.
  final double distance;

  /// Optional explicit controller. If omitted, the controller is taken from
  /// the nearest [CueScope] ancestor. Throws at runtime if neither is available.
  final CueController? controller;

  /// The axis along which dragging maps to animation progress.
  final Axis axis;

  /// What to do when the user lifts their finger.
  final CueDragReleaseMode releaseMode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('distance', distance));
    properties.add(EnumProperty<Axis>('axis', axis, defaultValue: Axis.vertical));
    properties.add(EnumProperty<CueDragReleaseMode>('releaseMode', releaseMode, defaultValue: CueDragReleaseMode.fling));
    properties.add(EnumProperty<CueScrubDirection>('scrubDirection', scrubDirection, defaultValue: CueScrubDirection.auto));
    properties.add(FlagProperty('forceLinearScrubing', value: forceLinearScrubing, ifTrue: 'forceLinearScrubing'));
    properties.add(DiagnosticsProperty<CueController>('controller', controller, defaultValue: null));
  }

  @override
  State<CueDragScrubber> createState() => _CueDragScrubberState();
}

class _CueDragScrubberState extends State<CueDragScrubber> {
  double _startProgress = 0;
  double _startOffset = 0;

  CueController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = widget.controller ?? CueScope.maybeOf(context)?.controller;
    if (controller == null) {
      throw FlutterError('CueDragScrubber requires either a controller prop or a CueScope ancestor.');
    }
    if (_controller != controller) {
      _controller?.removeStatusListener(_handleAnimationStatus);
      _controller = controller;
      if (widget.onAnimationEnd != null) {
        _controller!.addStatusListener(_handleAnimationStatus);
      }
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status.isCompleted || status.isDismissed) {
      widget.onAnimationEnd?.call(status.isCompleted);
    }
  }

  double _primaryOffset(Offset o) => widget.axis == Axis.vertical ? o.dy : o.dx;
  bool _scrubForward = true;

  void _onDragStart(DragStartDetails d) {
    assert(_controller != null);
    final controller = _controller!;
    _scrubForward = switch (widget.scrubDirection) {
      CueScrubDirection.auto => controller.status.isForwardOrCompleted,
      CueScrubDirection.forward => true,
      CueScrubDirection.reverse => false,
    };
    controller.stop();
    _startProgress = controller.timeline.progress;
    _startOffset = _primaryOffset(d.localPosition);
  }

  void _onDragUpdate(DragUpdateDetails d) {
    assert(_controller != null);
    final controller = _controller!;
    final delta = _primaryOffset(d.localPosition) - _startOffset;
    final progress = (_startProgress + delta / widget.distance).clamp(0.0, 1.0);
    controller.setProgress(
      progress,
      forward: _scrubForward,
      forceLinear: widget.forceLinearScrubing,
    );
  }

  void _onDragEnd(DragEndDetails d) {
    assert(_controller != null);
    final controller = _controller!;
    switch (widget.releaseMode) {
      case CueDragReleaseMode.none:
        break;
      case CueDragReleaseMode.snap:
        _snap(controller);
        break;
      case CueDragReleaseMode.fling:
        final velocity = (d.primaryVelocity ?? 0) / widget.distance;
        if (velocity.abs() > 0.1) {
          controller.fling(velocity: velocity);
        } else {
          _snap(controller);
        }
    }
  }

  void _snap(CueController controller) {
    final value = controller.value;
    if (value == 0.0 || value == 1.0) return;
    if (value > 0.5) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller?.removeStatusListener(_handleAnimationStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVertical = widget.axis == Axis.vertical;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: isVertical ? _onDragStart : null,
      onVerticalDragUpdate: isVertical ? _onDragUpdate : null,
      onVerticalDragEnd: isVertical ? _onDragEnd : null,
      onHorizontalDragStart: isVertical ? null : _onDragStart,
      onHorizontalDragUpdate: isVertical ? null : _onDragUpdate,
      onHorizontalDragEnd: isVertical ? null : _onDragEnd,
      child: widget.child,
    );
  }
}
