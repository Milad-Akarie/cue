part of 'cue.dart';

class OnToggleCue extends OnMountCue {
  const OnToggleCue({
    super.key,
    required super.child,
    super.debugLabel,
    super.motion,
    super.reverseMotion,
    required this.toggled,
    this.skipFirstAnimation = true,
    super.acts,
  }) : super();

  final bool toggled;
  final bool skipFirstAnimation;

  @override
  State<StatefulWidget> createState() => _ToggledStageState();
}

class _ToggledStageState extends SelfAnimatedState<OnToggleCue> {
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
  void didUpdateWidget(covariant OnToggleCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.toggled != oldWidget.toggled) {
      _toggle();
    }
  }

  void _toggle() async {
    if (widget.toggled) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }
}
