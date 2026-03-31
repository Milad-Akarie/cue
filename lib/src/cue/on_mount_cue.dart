part of 'cue.dart';

class OnMountCue extends SelfAnimatedCue {
  const OnMountCue({
    super.key,
    required super.child,
    super.motion = CueMotion.defaultTime,
    super.reverseMotion,
    super.debugLabel,
    super.repeat = false,
    super.reverseOnRepeat = false,
    super.repeatCount,
    super.acts,
  }) : super();

  @override
  State<StatefulWidget> createState() => OnMountCueState();
}

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
