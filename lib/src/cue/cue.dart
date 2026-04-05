import 'dart:async';

import 'package:cue/cue.dart';
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


/// The core animation widget. Provides a [CueController] through the widget
/// tree so that [Actor] widgets anywhere below can consume it.
///
/// Every [Cue] variant internally publishes its controller via a [CueScope]
/// (an [InheritedWidget]). Any [Actor] descendant — no matter how deep in the
/// subtree — automatically subscribes to that controller and applies its [acts]
/// in sync with the animation. [CueDragScrubber] also reads from the same
/// scope, letting users scrub the animation by dragging without any extra wiring.
///
/// This means you can place a single [Cue] at the top of a complex subtree and
/// animate multiple [Actor]s independently, with different acts and delays:
///
/// ```dart
/// Cue.onToggle(
///   toggled: isExpanded,
///   motion: .smooth(),
///   child: Column(
///     children: [
///       // Actor anywhere in the subtree — no direct wiring needed
///       Actor(
///         acts: [.rotate(to: 180)],
///         child: Icon(Icons.expand_more),
///       ),
///       Actor(
///         acts: [.fadeIn(), .slideY(from: 0.3)],
///         delay: Duration(milliseconds: 50),
///         child: ExpandedContent(),
///       ),
///     ],
///   ),
/// )
/// ```
///
/// ## Applying acts directly
///
/// Every [Cue] accepts an optional [acts] list as a shorthand for wrapping
/// [child] in an [Actor]. The two forms below are identical in effect —
/// prefer the shorthand unless you need multiple [Actor]s with different
/// delays or options:
/// 
/// ```dart
/// // Shorthand
/// Cue.onMount(
///   acts: [.fadeIn(), .slideY(from: 0.5)],
///   child: MyWidget(),
/// )
///
/// // Equivalent explicit form
/// Cue.onMount(
///   child: Actor(
///     acts: [.fadeIn(), .slideY(from: 0.5)],
///     child: MyWidget(),
///   ),
/// )
/// ```
///
/// ## Motion
///
/// Most [Cue] variants accept a `motion` parameter of type [CueMotion] that
/// controls the animation's timing and feel. Spring physics are recommended
/// for most UI — they respond naturally to interruptions and feel alive.
///
/// | Preset | Character |
/// |---|---|
/// | `.smooth()` | Fast, no overshoot — the recommended default |
/// | `.bouncy()` | Underdamped, visible bounce — playful |
/// | `.snappy()` | Near-instant — micro-interactions |
/// | `.gentle()` | Slow, relaxed — ambient / background |
/// | `.spring(duration: 400.ms, bounce: 0.2)` | Custom via duration + bounce |
/// | `.linear(300.ms)` | Fixed duration, no physics |
///
/// All spring constructors use dot-shorthand when the type is inferred:
/// ```dart
/// Cue.onToggle(toggled: flag, motion: .smooth(), child: ...)
/// ```
///
/// Use `reverseMotion` (where available) to apply a different spring when
/// the animation plays backward — e.g. a snappy forward and a slow reverse.
///
/// ## Nested Cues
///
/// [Actor]s always subscribe to the **nearest** [CueScope] ancestor. Nesting
/// one [Cue] inside another is fully supported — the inner [Cue] creates its
/// own scope and its [Actor] descendants are driven independently:
///
/// ```dart
/// Cue.onMount(
///   motion: .smooth(),
///   child: Actor(
///     acts: [.fadeIn()],
///     child: Cue.onHover(
///       motion: .snappy(),
///       child: Actor(
///         acts: [.scale(from: 1.0, to: 1.05)], // driven by hover, not mount
///         child: MyButton(),
///       ),
///     ),
///   ),
/// )
/// ```
///
/// ## Choosing a variant
///
/// | Factory | Trigger |
/// |---|---|
/// | [Cue.onMount] | Widget enters the tree |
/// | [Cue.onToggle] | Boolean state changes |
/// | [Cue.onChange] | Any value changes |
/// | [Cue.onHover] | Mouse enter / exit |
/// | [Cue.onFocus] | Focus gained / lost |
/// | [Cue.onScroll] | Scroll position (progress) |
/// | [Cue.onScrollVisible] | Widget enters the viewport |
/// | [Cue.onProgress] | External listenable progress |
/// | [Cue.indexed] | Staggered / sequenced list |
/// | [Cue] | Fully imperative (external controller) |
///
/// ## DevTools integration
///
/// Wrap your app with [CueDebugTools] to enable the Cue DevTools scrubber.
/// Each [Cue] automatically registers itself with the DevTools when its
/// animation reaches [AnimationStatus.completed] — i.e. when the forward
/// animation finishes. From that point the scrubber can seek the controller
/// back and forth for inspection.
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) {
///     if (kDebugMode) {
///       return CueDebugTools(child: child!);
///     }
///     return child!;
///   },
/// )
/// ```

abstract class Cue extends StatefulWidget {
  const Cue._({
    super.key,
    required this.child,
    this.debugLabel,
    this.acts,
  });

  /// An optional label shown in debug overlays and timeline tools.
  ///
  /// Set this to identify the animation when using [CueDebugProvider].
  final String? debugLabel;
  final Widget child;

  /// A shorthand list of [Act]s to apply directly on this [Cue]'s child.
  ///
  /// Providing [acts] is equivalent to wrapping [child] in an [Actor]:
  /// ```dart
  /// Cue.onMount(
  ///   acts: [.fadeIn(), .slideY(from: 0.3)],
  ///   child: MyWidget(),
  /// )
  /// ```
  final List<Act>? acts;

  /// {@macro cue.controlled}
  const factory Cue({
    Key? key,
    String? debugLabel,
    List<Act>? acts,
    required CueController controller,
    required Widget child,
  }) = _ControlledCue;

  /// {@macro cue.on_mount}
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

  /// {@macro cue.on_hover}
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

  /// {@macro cue.on_focus}
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

  /// {@macro cue.on_toggle}
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

  /// {@macro cue.on_change}
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

  /// {@macro cue.indexed}
  const factory Cue.indexed({
    Key? key,
    String? debugLabel,
    List<Act>? acts,
    required IndexedCueController controller,
    required int index,
    required Widget child,
  }) = IndexedCue;

  /// {@macro cue.on_progress}
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

  /// {@macro cue.on_scroll}
  const factory Cue.onScroll({
    Key? key,
    String? debugLabel,
    List<Act>? acts,
    required Widget child,
  }) = OnScrollCue;

  /// {@macro cue.on_scroll_visible}
  const factory Cue.onScrollVisible({
    Key? key,
    String? debugLabel,
    bool enabled,
    List<Act>? acts,
    required Widget child,
  }) = OnScrollVisibleCue;
}

/// Base [State] class for all [Cue] variants.
///
/// Subclasses provide their own [CueController] (either created internally or
/// supplied externally). [CueState] handles the standard build pipeline:
///
/// 1. Optionally wraps [Cue.child] in an [Actor] when [Cue.acts] is provided.
/// 2. Wraps the result in a [CueScope] so that all [Actor] widgets in the
///    subtree can subscribe to the controller.
/// 3. In debug mode, registers with [CueDebugTools] for animation inspection.
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
                controller: controller,
              );
            });
          }
        }
        controller.removeStatusListener(statusListener);
        controller.addStatusListener(statusListener);
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
    return CueScope(
      controller: controller,
      reanimateFromCurrent: reanimateFromCurrent,
      child: child,
    );
  }

  CueController get controller;
}
