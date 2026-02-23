part of 'cue.dart';

class _SelfAnimatedCue extends Cue {
  const _SelfAnimatedCue({
    super.key,
    required super.child,
    super.curve,
    super.debugLabel,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration,
    this.loop = false,
    this.simulation,
    this.reverseOnLoop = false,
    this.delay,
  }) : super._();

  final CueSimulation? simulation;
  final Duration duration;
  final Duration? reverseDuration;
  final Duration? delay;
  final bool loop;
  final bool reverseOnLoop;

  @override
  State<StatefulWidget> createState() => _SelfAnimatedCueState();
}

class _SelfAnimatedCueState extends _SelfAnimatedState<_SelfAnimatedCue> {
  @override
  void onControllerReady() async {
    if (widget.delay case final delay?) {
      await Future.delayed(delay);
    }
    play(loop: widget.loop, reverseOnLoop: widget.reverseOnLoop);
  }

  @override
  Animation<double> getAnimation(BuildContext context) => animation;

  @override
  void didUpdateWidget(covariant _SelfAnimatedCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loop != oldWidget.loop || widget.reverseOnLoop != oldWidget.reverseOnLoop) {
      controller.stop();
      play(loop: widget.loop, reverseOnLoop: widget.reverseOnLoop);
    }
  }
}

abstract class _SelfAnimatedState<T extends _SelfAnimatedCue> extends _CueState<T> with TickerProviderStateMixin {
  late AnimationController controller;
  Animation<double> _animation = const AlwaysStoppedAnimation(0.0);
  AnimationStatusListener? _statusListener;

  Animation<double> get animation => _animation;

  Curve? get curve => widget.curve;

  Duration get duration => widget.duration;

  Duration? get reverseDuration => widget.reverseDuration;

  CueSimulation? get simulation => widget.simulation;

  @override
  bool get isBounded => widget.simulation == null;

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
    if (simulation == null) {
      controller = AnimationController(
        vsync: this,
        duration: duration,
        reverseDuration: reverseDuration,
        debugLabel: 'Cue Controller',
      );
    } else {
      controller = AnimationController.unbounded(
        vsync: this,
        duration: duration,
        debugLabel: 'Unbounded Cue Controller',
      );
    }
  }

  void _buildAnimation() {
    if (curve case final curve?) {
      _animation = CurvedAnimation(parent: controller, curve: curve);
    } else {
      _animation = controller.view;
    }
  }

  Simulation _createSimulation(bool forward) {
    assert(simulation != null, 'Simulation must be provided to use simulation-based animation.');
    return simulation!.build(
      SimulationBuildData(
        velocity: controller.velocity,
        forward: forward,
        progress: controller.value,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _SelfAnimatedCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool needsReset = false;
    if (duration != oldWidget.duration) {
      controller.duration = duration;
      needsReset = true;
    }
    if (reverseDuration != oldWidget.reverseDuration) {
      controller.reverseDuration = reverseDuration;
      needsReset = true;
    }
    if (curve != oldWidget.curve) {
      controller.reset();
      _buildAnimation();
      needsReset = true;
    }
    if (simulation != oldWidget.simulation) {
      controller.stop();
      controller.dispose();
      _createController();
      _buildAnimation();
      needsReset = true;
    }

    if (needsReset) {
      onControllerReady();
    }
  }

  void onControllerReady() {}

  void play({bool loop = false, bool reverseOnLoop = false}) {
    if (mounted) {
      if (simulation != null) {
        if (loop) {
          _loopWithSimulation(simulation!, reverseOnLoop: reverseOnLoop);
        } else {
          if (_statusListener != null) {
            controller.removeStatusListener(_statusListener!);
          }
          controller.animateWith(_createSimulation(true));
        }
      } else {
        if (loop) {
          controller.repeat(reverse: reverseOnLoop);
        } else {
          controller.forward();
        }
      }
    }
  }

  void _loopWithSimulation(
    CueSimulation simulation, {
    bool reverseOnLoop = false,
  }) {
    if (_statusListener != null) {
      controller.removeStatusListener(_statusListener!);
    }
    _statusListener = (status) {
      if (status == AnimationStatus.completed) {
        if (reverseOnLoop) {
          controller.animateBackWith(_createSimulation(false));
        } else {
          controller.animateWith(_createSimulation(true));
        }
      } else if (status == AnimationStatus.dismissed && reverseOnLoop) {
        controller.animateWith(_createSimulation(false));
      }
    };
    controller.addStatusListener(_statusListener!);
    controller.animateWith(_createSimulation(true));
  }

  @override
  void dispose() {
    if (_statusListener != null) {
      controller.removeStatusListener(_statusListener!);
    }
    controller.dispose();
    super.dispose();
  }
}
