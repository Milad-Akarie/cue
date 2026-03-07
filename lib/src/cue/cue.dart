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
    this.act,
  });

  final String? debugLabel;
  final Widget child;
  final Act? act;

  const factory Cue({
    Key? key,
    String? debugLabel,
    bool isBounded,
    Act? act,
    required Animation<double> animation,
    required Widget child,
  }) = _ControlledCue;

  const factory Cue.onTransition({
    Key? key,
    String? debugLabel,
    required Widget child,
    Act? act,
  }) = _RouteTransitionStage;

  const factory Cue.onMount({
    Key? key,
    String? debugLabel,
    CueMotion motion,
    Duration? delay,
    bool loop,
    bool reverseOnLoop,
    Act? act,
    required Widget child,
  }) = SelfAnimatedCue;

  const factory Cue.onHover({
    Key? key,
    String? debugLabel,
    CueMotion motion,
    MouseCursor cursor,
    bool opaque,
    Act? act,
    required Widget child,
  }) = _OnHoverCue;

  const factory Cue.onToggle({
    Key? key,
    String? debugLabel,
    CueMotion motion,
    required bool toggled,
    bool skipFirstAnimation,
    required Widget child,
    Act? act,
  }) = _TogglableCue;

  const factory Cue.onChange({
    Key? key,
    CueMotion motion,
    String? debugLabel,
    bool skipFirstAnimation,
    bool fromCurrentValue,
    Act? act,
    required Object? value,
    required Widget child,
  }) = _OnChangeCue;

  const factory Cue.indexed({
    Key? key,
    String? debugLabel,
    Act? act,
    required IndexedCueController controller,
    required int index,
    required Widget child,
  }) = _IndexedCue;

  const factory Cue.onProgress({
    Key? key,
    String? debugLabel,
    Act? act,
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
    bool enabled,
    Act? act,
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (kDebugMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (CueDebugTools.isWrappedByDebugProvider(context)) {
          _deattachDebugOverlay = CueDebugTools.attachDebugTarget(
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
    Widget child = widget.child;
    if (widget.act != null) {
      child = Actor(
        act: widget.act!,
        child: child,
      );
    }

    final animation = getAnimation(context);
    if (kDebugMode) {
      final debugToolsScope = CueDebugTools.maybeOf(context);
      if (debugToolsScope != null) {
        final isActive = debugToolsScope.activeTargetId == _debugId;
        final useDebugAnimation = !debugToolsScope.isMinimized && isActive;
        return DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: isActive && debugToolsScope.isSelectMode
              ? BoxDecoration(
                  color: Colors.amber.withValues(alpha: .2),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: .8),
                  ),
                )
              : const BoxDecoration(),
          child: CueScope(
            reanimateFromCurrent: reanimateFromCurrent,
            animation: useDebugAnimation ? debugToolsScope.animation : animation,
            willReanimateNotifier: willReanimateNotifier,
            isBounded: isBounded,
            child: child,
          ),
        );
      }
    }
    return CueScope(
      animation: animation,
      isBounded: isBounded,
      willReanimateNotifier: willReanimateNotifier,
      reanimateFromCurrent: reanimateFromCurrent,
      child: child,
    );
  }

  Animation<double> getAnimation(BuildContext context);
}
