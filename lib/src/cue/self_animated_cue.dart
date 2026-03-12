part of 'cue.dart';

class SelfAnimatedCue extends Cue {
  const SelfAnimatedCue({
    super.key,
    required super.child,
    this.motion = CueMotion.defaultDuration,
    this.reverseMotion,
    super.debugLabel,
    this.loop = false,
    this.reverseOnLoop = false,
    super.act,
  }) : super._();

  final CueMotion motion;
  final CueMotion? reverseMotion;
  final bool loop;
  final bool reverseOnLoop;

  @override
  State<StatefulWidget> createState() => SelfAnimatedCueState();
}

class SelfAnimatedCueState extends SelfAnimatedState<SelfAnimatedCue> {
  @override
  String get debugName => 'SelfAnimatedCue';

  @override
  void onControllerReady() async {
    if (widget.loop) {
      controller.repeat(reverse: widget.reverseOnLoop);
    } else {
      controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant SelfAnimatedCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loop != oldWidget.loop || widget.reverseOnLoop != oldWidget.reverseOnLoop) {
      controller.stop();
      if (widget.loop) {
        controller.repeat(reverse: widget.reverseOnLoop);
      } else {
        controller.forward();
      }
    }
  }
}

abstract class SelfAnimatedState<T extends SelfAnimatedCue> extends _CueState<T> with SingleTickerProviderStateMixin {
  late final CueAnimationController controller;

  CueMotion get motion => widget.motion;

  @override
  bool get isBounded => !controller.usesSimulation;

  @override
Timeline getAnimations(BuildContext context) => controller.animations;

  @override
  void initState() {
    super.initState();
    _createController();
    onControllerReady();
  }

  void _createController() {
    controller = CueAnimationController(
      motion: motion,
      reverseMotion: widget.reverseMotion,
      vsync: this,
      debugLabel: 'Cue Controller',
    );
  }

  @override
  void didUpdateWidget(covariant SelfAnimatedCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.motion != motion) {
      controller.motion = motion;
    }
  }

  void onControllerReady() {}

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
