part of 'cue.dart';

class _TogglableCue extends SelfAnimatedCue {
  const _TogglableCue({
    super.key,
    required super.child,
    super.debugLabel,
    super.motion,
    required this.toggled,
    this.skipFirstAnimation = true,
  }) : super();

  final bool toggled;
  final bool skipFirstAnimation;

  @override
  State<StatefulWidget> createState() => _ToggledStageState();
}

class _ToggledStageState extends SelfAnimatedState<_TogglableCue> {
  @override
  Animation<double> getAnimation(BuildContext context) => animation;

  @override
  String get debugName => 'ToggledCue';

  @override
  void initState() {
    super.initState();
    if (widget.skipFirstAnimation) {
      controller.value = widget.toggled ? 1.0 : 0.0;
    } else {
      _toggle();
    }
  }

  @override
  void didUpdateWidget(covariant _TogglableCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.toggled != oldWidget.toggled) {
      _toggle();
    }
  }

  void _toggle() {
    if (widget.toggled) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }
}
