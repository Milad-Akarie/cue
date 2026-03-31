import 'dart:async';

import 'package:cue/cue.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

part 'indexed_cue.dart';
part 'on_change_cue.dart';
part 'self_animated_cue.dart';
part 'on_hover_cue.dart';
part 'on_toggle_cue.dart';
part 'on_scroll_visiable_cue.dart';
part 'controlled_cue.dart';
part 'cue_scope.dart';
part 'progress_cue.dart';
part 'on_scroll_cue.dart';
part 'on_focus_cue.dart';
part 'on_mount_cue.dart';

abstract class Cue extends StatefulWidget {
  const Cue._({
    super.key,
    required this.child,
    this.debugLabel,
    this.acts,
  });

  final String? debugLabel;
  final Widget child;
  final List<Act>? acts;

  const factory Cue({
    Key? key,
    String? debugLabel,
    List<Act>? acts,
    required CueTimeline timeline,
    required Widget child,
  }) = _ControlledCue;

  const factory Cue.onMount({
    Key? key,
    String? debugLabel,
    CueMotion motion,
    CueMotion? reverseMotion,
    bool repeat,
    bool reverseOnRepeat,
    int? repeatCount,
    List<Act>? acts,
    ValueChanged<bool>? onEnd,
    required Widget child,
  }) = OnMountCue;

  const factory Cue.onHover({
    Key? key,
    String? debugLabel,
    CueMotion motion,
    MouseCursor cursor,
    bool opaque,
    List<Act>? acts,
    ValueChanged<bool>? onEnd,
    required Widget child,
  }) = OnHoverCue;

  const factory Cue.onFocus({
    Key? key,
    String? debugLabel,
    CueMotion motion,
    CueMotion? reverseMotion,
    FocusNode? focusNode,
    List<Act>? acts,
    ValueChanged<bool>? onEnd,
    required Widget child,
  }) = OnFocusCue;

  const factory Cue.onToggle({
    Key? key,
    String? debugLabel,
    CueMotion motion,
    CueMotion? reverseMotion,
    required bool toggled,
    bool skipFirstAnimation,
    required Widget child,
    List<Act>? acts,
    ValueChanged<bool>? onEnd,
  }) = OnToggleCue;

  const factory Cue.onChange({
    Key? key,
    CueMotion motion,
    String? debugLabel,
    bool skipFirstAnimation,
    bool fromCurrentValue,
    List<Act>? acts,
    required Object? value,
    required Widget child,
  }) = OnChangeCue;

  const factory Cue.indexed({
    Key? key,
    String? debugLabel,
    List<Act>? acts,
    required IndexedCueController controller,
    required int index,
    required Widget child,
  }) = IndexedCue;

  const factory Cue.onProgress({
    Key? key,
    String? debugLabel,
    List<Act>? acts,
    required Listenable listenable,
    required ValueGetter<double> progress,
    required Widget child,
    double min,
    double max,
  }) = _ProgressCue;

  /// Maps the child's journey through the viewport to a 0-1 progress value.
  ///
  /// Progress is 0 when the child's leading edge enters the viewport,
  /// and 1 when the child's leading edge reaches the viewport top.
  const factory Cue.onScroll({
    Key? key,
    String? debugLabel,
    List<Act>? acts,
    required Widget child,
  }) = OnScrollCue;

  // This only works within the nearest scrollable ancestor and is not meant to be used as a general purpose visibility detector.
  // it doesn't support nested scrollables and is not meant to be used as a general purpose visibility detector.

  // if you need a general purpose visibility detector, use the VisibilityDetector package. an trigger Cue animations based on visibility changes using that package and Cue's imperative API.
  const factory Cue.onScrollVisible({
    Key? key,
    String? debugLabel,
    bool enabled,
    List<Act>? acts,
    required Widget child,
    ScrollAnimationMode mode,
  }) = OnScrollVisibleCue;
}

abstract class CueState<T extends Cue> extends State<Cue> {
  @override
  T get widget => super.widget as T;

  VoidCallback? _deattachDebugOverlay;

  bool get reanimateFromCurrent => false;

  String get debugName;

  late final _debugId = '$debugName-${widget.debugLabel ?? ''}${identityHashCode(widget)}';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (kDebugMode) {
      if (CueDebugTools.isWrappedByDebugProvider(context)) {
        void statusListener(AnimationStatus status) {
          if (status.isCompleted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _deattachDebugOverlay = CueDebugTools.attachDebugTarget(
                context,
                id: _debugId,
                track: timeline.mainTrack,
              );
            });
          }
        }

        timeline.removeStatusListener(statusListener);
        timeline.addStatusListener(statusListener);
      }
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
    if (widget.acts != null) {
      child = Actor(acts: widget.acts!, child: child);
    }
    if (kDebugMode) {
      final debugToolsScope = CueDebugTools.maybeOf(context);
      if (debugToolsScope != null) {
        final isActive = debugToolsScope.activeTargetId == _debugId;
        final useDebugAnimation = !debugToolsScope.isMinimized && isActive;
        final timeline = useDebugAnimation ? debugToolsScope.timeline : this.timeline;
        return CueScope(
          reanimateFromCurrent: reanimateFromCurrent,
          timeline: timeline,
          mainConfig: timeline.mainTrackConfig,
          child: child,
        );
      }
    }
    return CueScope(
      timeline: timeline,
      mainConfig: timeline.mainTrackConfig,
      reanimateFromCurrent: reanimateFromCurrent,
      child: child,
    );
  }

  CueTimeline get timeline;
}
