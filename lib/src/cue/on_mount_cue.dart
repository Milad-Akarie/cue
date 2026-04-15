part of 'cue.dart';

/// {@template cue.on_mount}
/// A [Cue] that plays its animation when the widget is first inserted into the tree.
///
/// Animates forward once at mount. Supports looping via [repeat], ping-pong
/// via [reverseOnRepeat], and a finite loop count via [repeatCount].
///
/// ## Page entrance animations
///
/// For page-level entrance animations, prefer a **single** [Cue.onMount] at
/// the root of the page rather than one per element. Place multiple [Actor]s
/// with staggered [Actor.delay]s inside it — they all share the same
/// controller and play in a coordinated sequence:
///
/// ```dart
/// Cue.onMount(
///   motion: .smooth(),
///   child: Column(
///     children: [
///       Actor(acts: [.fadeIn(), .slideY(from: 0.2)], child: Title()),
///       Actor(acts: [.fadeIn(), .slideY(from: 0.2)], delay: 80.ms, child: Subtitle()),
///       Actor(acts: [.fadeIn(), .slideY(from: 0.2)], delay: 160.ms, child: Body()),
///     ],
///   ),
/// )
/// ```
///
/// Using many separate [Cue.onMount] widgets (one per element) works but is
/// harder to coordinate, produces more overhead, and makes debugging harder —
/// the Cue DevTools scrubber controls one controller at a time, so a single
/// root [Cue.onMount] lets you scrub the entire entrance sequence at once.
///
/// ```dart
/// Cue.onMount(
///   motion: .smooth(),
///   acts: [.fadeIn(), .slideY(from: 0.5)],
///   child: MyWidget(),
/// )
/// ```
/// {@endtemplate}
class OnMountCue extends SelfAnimatedCue {
  /// Default constructor.
  const OnMountCue({
    super.key,
    required super.child,
    super.motion = CueMotion.defaultTime,
    super.reverseMotion,
    super.debugLabel,
    super.repeat = false,
    super.reverseOnRepeat = false,
    super.repeatCount,
    super.onEnd,
    super.acts,
  });

  @override
  State<StatefulWidget> createState() => OnMountCueState();
}

/// State class for [OnMountCue].
class OnMountCueState extends SelfAnimatedCueState<OnMountCue> {
  @override
  String get debugName => 'OnMountCue';

  @override
  void onControllerReady() async {
    if (widget.repeat) {
      controller.repeat(reverse: widget.reverseOnRepeat, count: widget.repeatCount);
    } else {
      controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant OnMountCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.repeat != oldWidget.repeat ||
        widget.reverseOnRepeat != oldWidget.reverseOnRepeat ||
        widget.repeatCount != oldWidget.repeatCount) {
      controller.stop();
      if (widget.repeat) {
        controller.repeat(reverse: widget.reverseOnRepeat, count: widget.repeatCount);
      } else {
        controller.forward();
      }
    }
  }
}
