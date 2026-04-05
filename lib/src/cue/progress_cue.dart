part of 'cue.dart';

/// {@template cue.on_progress}
/// A [Cue] that maps an external numeric progress value to animation progress.
///
/// Listens to [listenable] and reads [progress] on every notification,
/// clamping the result between [min] and [max] and mapping it to the 0–1
/// animation range. [Actor]s always receive a normalized 0–1 value regardless
/// of the input range.
///
/// [min] and [max] define the **input range** of the external value. For
/// example, setting `max: 0.8` means the animation reaches fully complete
/// (1.0) when the external progress hits `0.8` — values above that are
/// clamped to 1.0. This lets you map any numeric range onto the full
/// animation without pre-normalizing the value yourself.
///
/// Useful for driving animations from scroll controllers, page controllers,
/// draggable sheet controllers, or any other listenable that exposes a
/// numeric position.
///
/// ## Scrub mode vs. play mode
///
/// This [Cue] keeps the controller in **scrub mode** at all times: each
/// notification sets the value directly, like seeking through a pre-baked
/// animation. This means motion specs (spring, duration) have no effect
/// while the progress is being driven externally.
///
/// [Actor] delays still apply — they shift when each element appears within
/// the normalized 0–1 range, so staggered reveals work exactly as expected.
///
/// ```dart
/// Cue.onProgress(
///   listenable: draggableSheetController,
///   progress: () => draggableSheetController.isAttached
///       ? draggableSheetController.size
///       : 0.0,
///   min: 0,
///   max: 0.8, // animation is fully complete when sheet size reaches 0.8
///   acts: [.fadeIn()],
///   child: MyWidget(),
/// )
/// ```
/// {@endtemplate}
class _ProgressCue extends Cue {
  const _ProgressCue({
    super.key,
    super.debugLabel,
    required super.child,
    required this.listenable,
    required this.progress,
    this.min = 0.0,
    this.max = 1.0,
    super.acts,
  }) : super._();

  final double min;
  final double max;
  final Listenable listenable;
  final ValueGetter<double> progress;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('min', min, defaultValue: 0.0));
    properties.add(DoubleProperty('max', max, defaultValue: 1.0));
  }

  @override
  State<StatefulWidget> createState() => _ProgressCueState();
}

class _ProgressCueState extends CueState<_ProgressCue> with SingleTickerProviderStateMixin {
  late final _controller = CueController(vsync: this, motion: .linear(500.ms));

  @override
  String get debugName => 'ProgressCue';

  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_updateAnimation);
    _updateAnimation();
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_updateAnimation);
    _controller.dispose();
    super.dispose();
  }

  void _updateAnimation() {
    final progress = widget.progress();
    final value = ((progress - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);
    _controller.setProgress(value, forward: true);
  }

  @override
  void didUpdateWidget(covariant _ProgressCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.listenable != oldWidget.listenable) {
      oldWidget.listenable.removeListener(_updateAnimation);
      widget.listenable.addListener(_updateAnimation);
      _updateAnimation();
    }
  }

  @override
  CueController get controller => _controller;
}
