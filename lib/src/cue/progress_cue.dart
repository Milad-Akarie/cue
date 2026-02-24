part of 'cue.dart';

class _ProgressCue extends Cue {
  const _ProgressCue({
    super.key,
    super.curve,
    super.debugLabel,
    required super.child,
    required this.notifier,
    required this.progress,
  }) : super._();

  final Listenable notifier;
  final ValueGetter<double> progress;

  @override
  State<StatefulWidget> createState() => _ProgressCueState();
}

class _ProgressCueState extends _CueState<_ProgressCue> {
  final _animation = ProgressAnimation(value: 0.0);

  @override
  bool get isBounded => true;

  @override
  void initState() {
    super.initState();
    widget.notifier.addListener(_updateAnimation);
    _updateAnimation();
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_updateAnimation);
    super.dispose();
  }

  void _updateAnimation() {
    final value = widget.progress().clamp(0.0, 1.0);
    final status = switch (value) {
      1.0 => AnimationStatus.completed,
      0.0 => AnimationStatus.dismissed,
      _ => value > _animation.value ? AnimationStatus.forward : AnimationStatus.reverse,
    };

    _animation.update(value, status: status);
  }

  @override
  void didUpdateWidget(covariant _ProgressCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.notifier != oldWidget.notifier) {
      oldWidget.notifier.removeListener(_updateAnimation);
      widget.notifier.addListener(_updateAnimation);
      _updateAnimation();
    }
  }

  @override
  Animation<double> getAnimation(BuildContext context) => _animation;
}
