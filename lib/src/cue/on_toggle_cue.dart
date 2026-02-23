part of 'cue.dart';

class _TogglableCue extends _SelfAnimatedCue {
  const _TogglableCue({
    super.key,
    required super.child,
    super.curve,
    super.debugLabel,
    super.simulation,
    super.duration = const Duration(milliseconds: 300),
    super.reverseDuration,
    required this.toggled,
    this.skipFirstAnimation = true,
  }) : super();

  final bool toggled;
  final bool skipFirstAnimation;

  @override
  State<StatefulWidget> createState() => _ToggledStageState();
}

class _ToggledStageState extends _SelfAnimatedState<_TogglableCue> {
  @override
  Curve? get curve => widget.curve;

  @override
  Duration get duration => widget.duration;

  @override
  Duration? get reverseDuration => widget.reverseDuration;

  @override
  CueSimulation? get simulation => widget.simulation;

  @override
  Animation<double> getAnimation(BuildContext context) => animation;

  @override
  void initState() {
    super.initState();
    if (widget.skipFirstAnimation) {
      controller.value = widget.toggled ? 1.0 : 0.0;
    } else {
      _animate();
    }
  }

  @override
  void didUpdateWidget(covariant _TogglableCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.toggled != oldWidget.toggled) {
      _animate();
    }
  }

  void _animate() {
    if (widget.toggled) {
      if (simulation != null) {
        controller.animateWith(_createSimulation(true));
      } else {
        controller.forward();
      }
    } else {
      if (simulation != null) {
        controller.animateBackWith(_createSimulation(false));
      } else {
        controller.reverse();
      }
    }
  }
}
