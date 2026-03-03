import 'package:cue/cue.dart';
import 'package:cue/src/motion/cue_motion.dart';
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
    this.debugLabel,
  });

  final String? debugLabel;
  final Widget child;

  const factory Cue({
    Key? key,
    String? debugLabel,
    bool isBounded,
    required Animation<double> animation,
    required Widget child,
  }) = _ControlledCue;

  const factory Cue.onTransition({
    Key? key,
    String? debugLabel,
    bool useSecondaryAnimation,
    required Widget child,
  }) = _RouteTransitionStage;

  const factory Cue.onMount({
    Key? key,
    String? debugLabel,
    CueMotion motion,
    Duration? delay,
    bool loop,
    bool reverseOnLoop,
    required Widget child,
  }) = SelfAnimatedCue;

  const factory Cue.onHover({
    Key? key,
    String? debugLabel,
    CueMotion motion,
    MouseCursor cursor,
    bool opaque,
    required Widget child,
  }) = _OnHoverCue;

  const factory Cue.onToggle({
    Key? key,
    String? debugLabel,
    CueMotion motion,
    required bool toggled,
    bool skipFirstAnimation,
    required Widget child,
  }) = _TogglableCue;

  const factory Cue.onChange({
    Key? key,
    CueMotion motion,
    String? debugLabel,
    bool skipFirstAnimation,
    bool fromCurrentValue,
    required Object? value,
    required Widget child,
  }) = _OnChangeCue;

  const factory Cue.indexed({
    Key? key,
    String? debugLabel,
    required IndexedCueController controller,
    required int index,
    required Widget child,
  }) = _IndexedCue;

  const factory Cue.onProgress({
    Key? key,
    String? debugLabel,
    required Listenable notifier,
    required ValueGetter<double> progress,
    required Widget child,
  }) = _ProgressCue;

  // This only works within the nearest scrollable ancestor and is not meant to be used as a general purpose visibility detector.
  // it doesn't support nested scrollables and is not meant to be used as a general purpose visibility detector.

  // if you need a general purpose visibility detector, use the VisibilityDetector package. an trigger Cue animations based on visibility changes using that package and Cue's imperative API.
  const factory Cue.onScrollVisible({
    required Key key,
    String? debugLabel,
    CueMotion motion,
    bool enabled,
    double visibilityThreshold,
    required Widget child,
  }) = _OnScrollVisibleCue;
}

abstract class _CueState<T extends Cue> extends State<Cue> {
  @override
  T get widget => super.widget as T;

  VoidCallback? _deattachDebugOverlay;

  bool get isBounded;

  EventNotifier<bool>? get willReanimateNotifier => null;

  bool get reanimateFromCurrent => false;

  String get debugName;

  late final _debugId = '$debugName-${widget.debugLabel ?? ''}${identityHashCode(widget)}';

  @override
  void didUpdateWidget(covariant Cue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (CueDebugTools.isWrappedByDebugProvider(context)) {
          CueDebugTools.attachDebugTarget(
            context,
            id: _debugId,
            duration: const Duration(seconds: 1),
            curve: Curves.easeOut,
            simulation: const Spring.smooth(),
          );
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
    final animation = getAnimation(context);

    Widget child = RepaintBoundary(
      child: CueScope(
        animation: animation,
        isBounded: isBounded,
        willReanimateNotifier: willReanimateNotifier,
        reanimateFromCurrent: reanimateFromCurrent,
        child: widget.child,
      ),
    );

    if (kDebugMode) {
      if (CueDebugTools.isWrappedByDebugProvider(context)) {
        final scope = CueDebugTools.of(context);
        if (scope.isSelectMode && scope.highlightedTargetId == _debugId) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: IgnorePointer(
              child: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: .2),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: .8),
                  ),
                ),
                child: child,
              ),
            ),
          );
        }
        if (!scope.isMinimized && scope.activeTargetId == _debugId) {
          return CueScope(
            reanimateFromCurrent: false,
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
