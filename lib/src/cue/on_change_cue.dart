part of 'cue.dart';

class OnChangeCue extends OnMountCue {
  const OnChangeCue({
    super.key,
    required super.child,
    super.motion,
    super.debugLabel,
    this.value,
    this.skipFirstAnimation = true,
    this.fromCurrentValue = false,
    super.acts,
  });

  final Object? value;
  final bool skipFirstAnimation;
  final bool fromCurrentValue;

  @override
  State<StatefulWidget> createState() => _OnChangeCueState();
}

class _OnChangeCueState extends SelfAnimatedState<OnChangeCue> {


  @override
  String get debugName => 'OnChangeCue';

  @override
  bool get reanimateFromCurrent => widget.fromCurrentValue;

  @override
  void onControllerReady() {
    if (widget.skipFirstAnimation) {
      controller.value = 1.0;
    } else {
      controller.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant OnChangeCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      controller.forward(from: 0.0);
    }
  }
}
