import 'package:cue/cue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;
part 'indexed_cue.dart';
part 'on_change_cue.dart';
part 'route_transition_cue.dart';
part 'self_animated_cue.dart';
part 'on_hover_cue.dart';
part 'on_toggle_cue.dart';
part 'on_scroll_visiable_cue.dart';
part 'controlled_cue.dart';
part 'cue_scope.dart';
part 'progress_cue.dart';

abstract class Cue extends StatefulWidget {
  const Cue._({
    super.key,
    required this.child,
    this.curve,
    this.debugLabel,
  });

  final String? debugLabel;
  final Curve? curve;
  final Widget child;

  const factory Cue({
    Key? key,
    required Widget child,
    Curve curve,
    String? debugLabel,
    bool isBounded,
    required Animation<double> animation,
  }) = _ControlledCue;

  const factory Cue.onTransition({
    Key? key,
    required Widget child,
    Curve curve,
    String? debugLabel,
    bool useSecondaryAnimation,
  }) = _RouteTransitionStage;

  const factory Cue.onMount({
    Key? key,
    required Widget child,
    Curve curve,
    String? debugLabel,
    Duration duration,
    Duration? reverseDuration,
    CueSimulation? simulation,
    Duration? delay,
    bool loop,
    bool reverseOnLoop,
  }) = _SelfAnimatedCue;

  const factory Cue.onHover({
    Key? key,
    required Widget child,
    Curve curve,
    String? debugLabel,
    Duration duration,
    CueSimulation? simulation,
    Duration? reverseDuration,
    MouseCursor cursor,
    bool opaque,
  }) = _OnHoverCue;

  const factory Cue.onToggle({
    Key? key,
    required Widget child,
    Curve curve,
    String? debugLabel,
    Duration duration,
    Duration? reverseDuration,
    CueSimulation? simulation,
    required bool toggled,
    bool skipFirstAnimation,
  }) = _TogglableCue;

  const factory Cue.onChange({
    Key? key,
    required Widget child,
    Curve? curve,
    String? debugLabel,
    Duration duration,
    Duration? reverseDuration,
    CueSimulation? simulation,
    bool skipFirstAnimation,
    required Object? value,
  }) = _OnChangeCue;

  const factory Cue.indexed({
    Key? key,
    required Widget child,
    Curve curve,
    String? debugLabel,
    required IndexedCueController controller,
    required int targetIndex,
  }) = _IndexedCue;

  const factory Cue.onProgress({
    Key? key,
    required Widget child,
    Curve? curve,
    String? debugLabel,
    required Listenable notifier,
    required ValueGetter<double> progress,
  }) = _ProgressCue;

  // This only works within the nearest scrollable ancestor and is not meant to be used as a general purpose visibility detector.
  // it doesn't support nested scrollables and is not meant to be used as a general purpose visibility detector.

  // if you need a general purpose visibility detector, use the VisibilityDetector package. an trigger Cue animations based on visibility changes using that package and Cue's imperative API.
  const factory Cue.onScrollVisible({
    required Key key,
    required Widget child,
    Curve? curve,
    String? debugLabel,
    Duration duration,
    Duration? reverseDuration,
    CueSimulation? simulation,
    bool enabled,
    double visibilityThreshold,
  }) = _OnScrollVisibleCue;
}

abstract class _CueState<T extends Cue> extends State<Cue> {
  @override
  T get widget => super.widget as T;

  VoidCallback? _deattachDebugOverlay;

  bool get isBounded;

  late final _debugId = 'Cue#${widget.debugLabel ?? ''}-${identityHashCode(widget)}';

  @override
  void didUpdateWidget(covariant Cue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (CueDebugTools.isWrappedByDebugProvider(context)) {
          CueDebugTools.openOverlay(context);
        }
      });
    }
  }

  @override
  void dispose() {
    _deattachDebugOverlay?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = RepaintBoundary(
      child: CueScope(
        animation: getAnimation(context),
        isBounded: isBounded,
        child: widget.child,
      ),
    );

    if (kDebugMode) {
      if (CueDebugTools.isWrappedByDebugProvider(context)) {
        final scope = CueDebugTools.of(context);
        if (scope.isSelectMode) {
          final color = scope.activeTargetId == _debugId ? Colors.blue : Colors.amber;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              CueDebugTools.attachDebugTarget(
                context,
                id: _debugId,
                duration: const Duration(seconds: 1),
                curve: Curves.easeOut,
                simulation: const Spring.smooth(),
              );
            },
            child: IgnorePointer(
              child: Container(
                foregroundDecoration: BoxDecoration(
                  color: color.withValues(alpha: .2),
                  border: Border.all(
                    color: color.withValues(alpha: .8),
                  ),
                ),
                child: child,
              ),
            ),
          );
        }
        if (!scope.isMinimized && scope.activeTargetId == _debugId) {
          return CueScope(
            animation: scope.animation,
            isBounded: isBounded,
            child: widget.child,
          );
        }
      }
    }
    return child;
  }

  Animation<double> getAnimation(BuildContext context);
}
