part of 'cue.dart';

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
  State<StatefulWidget> createState() => _ProgressCueState();
}

class _ProgressCueState extends _CueState<_ProgressCue> {
  final _progresstimeline = CueTimelineImpl.fromMotion(.none, progressDriven: true);

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
    super.dispose();
  }

  void _updateAnimation() {
    final progress = widget.progress();
    final value = ((progress - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);
    final forward = switch (value) {
      1.0 => true,
      0.0 => false,
      _ => value > _progresstimeline.progress ? true : false,
    };

    _progresstimeline.setProgress(value, forward: forward);
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
  CueTimeline get timeline => _progresstimeline;
}
