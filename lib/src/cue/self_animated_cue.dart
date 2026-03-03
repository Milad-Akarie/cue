part of 'cue.dart';

class SelfAnimatedCue extends Cue {
  const SelfAnimatedCue({
    super.key,
    required super.child,
    this.motion = CueMotion.defaultDuration,
    super.debugLabel,
    this.loop = false,
    this.reverseOnLoop = false,
    this.delay,
  }) : super._();

  final CueMotion motion;
  final Duration? delay;
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
    if (widget.delay case final delay?) {
      await Future.delayed(delay);
    }
    if (widget.loop) {
      controller.playLoop(reverseOnLoop: widget.reverseOnLoop);
    } else {
      controller.forward();
    }
  }

  @override
  Animation<double> getAnimation(BuildContext context) => animation;

  @override
  void didUpdateWidget(covariant SelfAnimatedCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loop != oldWidget.loop || widget.reverseOnLoop != oldWidget.reverseOnLoop) {
      controller.stop();
      if (widget.loop) {
        controller.playLoop(reverseOnLoop: widget.reverseOnLoop);
      } else {
        controller.forward();
      }
    }
  }
}

abstract class SelfAnimatedState<T extends SelfAnimatedCue> extends _CueState<T> with SingleTickerProviderStateMixin {
  late final CueAnimationController controller;
  Animation<double> _animation = const AlwaysStoppedAnimation(0.0);

  Animation<double> get animation => _animation;

  CueMotion get motion => widget.motion;

  @override
  bool get isBounded => controller.usesSimulation;

  @override
  Animation<double> getAnimation(BuildContext context) => _animation;

  @override
  void initState() {
    super.initState();
    _createController();
    _buildAnimation();
    onControllerReady();
  }

  void _createController() {
    controller = CueAnimationController(
      motion: motion,
      vsync: this,
      debugLabel: 'Cue Controller',
    );
  }

  void _buildAnimation() {
    _animation = switch (motion) {
      TimedMotion m => m.applyCurve(controller),
      SimulationMotion() => controller.view,
    };
  }

  @override
  void didUpdateWidget(covariant SelfAnimatedCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.motion != motion) {
      controller.motion = motion;
      _buildAnimation();
    }
  }

  void onControllerReady() {}

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
