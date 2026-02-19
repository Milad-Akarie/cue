import 'package:cue/cue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class Cue extends StatefulWidget {
  const Cue._({
    super.key,
    required this.child,
    this.curve,
    this.debug = false,
    this.effects,
  });

  final bool debug;
  final Curve? curve;
  final Widget child;
  final List<Effect>? effects;

  const factory Cue({
    Key? key,
    required Widget child,
    Curve curve,
    bool debug,
    List<Effect>? effects,
    bool isBounded,
    required Animation<double> animation,
  }) = _ControlledCue;

  const factory Cue.onTransition({
    Key? key,
    required Widget child,
    Curve curve,
    bool debug,
    List<Effect>? effects,
  }) = _RouteTransitionStage;

  const factory Cue.onMount({
    Key? key,
    required Widget child,
    Curve curve,
    bool debug,
    List<Effect>? effects,
    Duration duration,
    Duration? reverseDuration,
    CueSimulation? simulation,
    Duration? delay,
    bool loop,
    bool reverseOnLoop,
  }) = _SelfAnimatedCue;

  const factory Cue.onHover({
    Key? key,
    required Widget child,
    Curve curve,
    bool debug,
    List<Effect>? effects,
    Duration duration,
    CueSimulation? simulation,
    Duration? reverseDuration,
    MouseCursor cursor,
    bool opaque,
  }) = _OnHoverCue;

  const factory Cue.onToggle({
    Key? key,
    required Widget child,
    Curve curve,
    bool debug,
    List<Effect>? effects,
    Duration duration,
    Duration? reverseDuration,
    CueSimulation? simulation,
    required bool toggled,
    bool skipFirstAnimation,
  }) = _TogglableCue;

  const factory Cue.indexed({
    Key? key,
    required Widget child,
    Curve curve,
    List<Effect>? effects,
    bool debug,
    required Listenable listenable,
    required ValueGetter<double> getOffset,
    required int targetIndex,
    IndexDistanceCalculator? calculator,
  }) = _IndexedStage;

  factory Cue.paged({
    Key? key,
    required Widget child,
    Curve curve,
    List<Effect>? effects,
    bool debug,
    required PageController controller,
    required int targetIndex,
    IndexDistanceCalculator? calculator,
  }) = _IndexedStage.fromPageController;
}

class _RouteTransitionStageState extends _CueState<_RouteTransitionStage> {
  @override
  bool get isBounded => true;

  @override
  Animation<double> getAnimation(BuildContext context) {
    return ModalRoute.of(context)!.animation!;
  }
}

abstract class _CueState<T extends Cue> extends State<Cue> {
  @override
  T get widget => super.widget as T;

  VoidCallback? _deattachDebugOverlay;

  bool get isBounded;

  @override
  void initState() {
    super.initState();
    if (kDebugMode && widget.debug) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (CueDebugTools.isWrappedByDebugProvider(context)) {
          _deattachDebugOverlay = CueDebugTools.showDebugOverlay(context);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant Cue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kDebugMode) {
      if (widget.debug && !oldWidget.debug) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (CueDebugTools.isWrappedByDebugProvider(context)) {
            _deattachDebugOverlay = CueDebugTools.showDebugOverlay(context);
          }
        });
      } else if (!widget.debug && oldWidget.debug) {
        _deattachDebugOverlay?.call();
        _deattachDebugOverlay = null;
      }
    }
  }

  @override
  void dispose() {
    _deattachDebugOverlay?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;
    if (widget.effects case final acts?) {
      child = Actor(effects: acts, child: child);
    }
    if (kDebugMode && widget.debug) {
      if (CueDebugTools.isWrappedByDebugProvider(context)) {
        final debugAnimation = CueDebugTools.animationOf(context);
        if (debugAnimation != null) {
          return CueScope(
            animation: debugAnimation,
            isBounded: isBounded,
            child: child,
          );
        }
      } else {
        return CueDebugTools(
          global: false,
          child: Builder(
            builder: (context) {
              final debugAnimation = CueDebugTools.animationOf(context);
              if (debugAnimation != null) {
                return CueScope(animation: debugAnimation, isBounded: isBounded, child: child);
              }
              return CueScope(animation: getAnimation(context), isBounded: isBounded, child: child);
            },
          ),
        );
      }
    }
    return CueScope(animation: getAnimation(context), isBounded: true, child: child);
  }

  Animation<double> getAnimation(BuildContext context);
}

class _RouteTransitionStage extends Cue {
  const _RouteTransitionStage({
    super.key,
    required super.child,
    super.curve,
    super.debug,
    super.effects,
  }) : super._();

  @override
  State<StatefulWidget> createState() => _RouteTransitionStageState();
}

class _SelfAnimatedCue extends Cue {
  const _SelfAnimatedCue({
    super.key,
    required super.child,
    super.curve,
    super.debug,
    super.effects,
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
  Curve? get curve => widget.curve;

  @override
  Duration get duration => widget.duration;

  @override
  Duration? get reverseDuration => widget.reverseDuration;

  @override
  CueSimulation? get simulation => widget.simulation;

  @override
  bool get isBounded => widget.simulation == null;

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

class _OnHoverCue extends _SelfAnimatedCue {
  const _OnHoverCue({
    super.key,
    required super.child,
    super.curve,
    super.debug,
    super.effects,
    super.simulation,
    super.duration = const Duration(milliseconds: 200),
    super.reverseDuration,
    this.cursor = MouseCursor.defer,
    this.opaque = false,
  }) : super();

  final MouseCursor cursor;
  final bool opaque;

  @override
  State<StatefulWidget> createState() => _OnHoverStageState();
}

class _OnHoverStageState extends _SelfAnimatedState<_OnHoverCue> {
  @override
  Animation<double> getAnimation(BuildContext context) => animation;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.cursor,
      opaque: widget.opaque,
      onEnter: (_) => controller.forward(),
      onExit: (_) => controller.reverse(),
      child: super.build(context),
    );
  }
}

class _TogglableCue extends _SelfAnimatedCue {
  const _TogglableCue({
    super.key,
    required super.child,
    super.curve,
    super.debug,
    super.effects,
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

class _ControlledCue extends Cue {
  const _ControlledCue({
    super.key,
    required super.child,
    this.isBounded = true,
    super.effects,
    super.curve,
    super.debug,
    required this.animation,
  }) : super._();

  final Animation<double> animation;
  final bool isBounded;

  @override
  State<StatefulWidget> createState() => _ControlledCueState();
}

class _ControlledCueState extends _CueState<_ControlledCue> {
  @override
  bool get isBounded => widget.isBounded;

  @override
  Animation<double> getAnimation(_) => widget.animation;
}

class CueScope extends InheritedWidget {
  const CueScope({
    super.key,
    required super.child,
    required this.animation,
    required this.isBounded,
  });

  final Animation<double> animation;
  final bool isBounded;

  static CueScope of(BuildContext context) {
    final cue = context.dependOnInheritedWidgetOfExactType<CueScope>();
    assert(cue != null, 'No Cue found in context, make sure to wrap your widget tree with a Cue widget.');
    return cue!;
  }

  @override
  bool updateShouldNotify(covariant CueScope oldWidget) {
    return animation != oldWidget.animation || isBounded != oldWidget.isBounded;
  }
}

/// Calculates the animation value based on the distance between current and target index.
/// Returns a value typically between 0.0 and 1.0.
typedef IndexDistanceCalculator = double Function(double offset, int targetIndex);

class _IndexedStage extends Cue {
  const _IndexedStage({
    super.key,
    super.curve,
    super.debug,
    super.effects,
    required super.child,
    required this.listenable,
    required this.getOffset,
    required this.targetIndex,
    this.calculator,
  }) : super._();

  final Listenable listenable;
  final ValueGetter<double> getOffset;
  final int targetIndex;
  final IndexDistanceCalculator? calculator;

  @override
  State<StatefulWidget> createState() => _IndexedStageState();

  factory _IndexedStage.fromPageController({
    Key? key,
    required Widget child,
    Curve curve = Curves.linear,
    bool debug = false,
    List<Effect>? effects,
    required PageController controller,
    required int targetIndex,
    IndexDistanceCalculator? calculator,
  }) {
    return _IndexedStage(
      key: key,
      curve: curve,
      debug: debug,
      listenable: controller,
      getOffset: () {
        if (!controller.hasClients) return 0.0;
        return controller.page ?? controller.initialPage.toDouble();
      },
      targetIndex: targetIndex,
      calculator: calculator,
      child: child,
    );
  }
}

class _IndexedStageState extends _CueState<_IndexedStage> {
  Animation<double> _animation = AlwaysStoppedAnimation(0.0);

  @override
  bool get isBounded => true;

  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_updateAnimation);
    _updateAnimation();
  }

  /// Default calculator that provides linear fade within 1 index distance.
  /// Returns 1.0 at exact target index, fades to 0.0 at ±1.0 distance.
  double _defaultIndexDistanceCalculator(double currentIndex, int targetIndex) {
    final distance = (currentIndex - targetIndex).abs();
    // Only animate if within 1 index distance
    if (distance >= 1.0) return 0.0;

    // Check if this target is the previous, current, or next index
    final roundedCurrent = currentIndex.round();
    final isPreviousOrNext =
        (targetIndex == roundedCurrent - 1) || (targetIndex == roundedCurrent) || (targetIndex == roundedCurrent + 1);

    if (!isPreviousOrNext) return 0.0;

    return 1.0 - distance;
  }

  void _updateAnimation() {
    final currentIndex = widget.getOffset();
    final calculator = widget.calculator ?? _defaultIndexDistanceCalculator;
    final value = calculator(currentIndex, widget.targetIndex);
    setState(() {
      _animation = AlwaysStoppedAnimation(value);
    });
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_updateAnimation);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _IndexedStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.listenable != oldWidget.listenable) {
      oldWidget.listenable.removeListener(_updateAnimation);
      widget.listenable.addListener(_updateAnimation);
      _updateAnimation();
    }
  }

  @override
  Animation<double> getAnimation(BuildContext context) => _animation;
}
