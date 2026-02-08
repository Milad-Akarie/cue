import 'package:cue/src/cue/cue_debug_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class Cue extends StatefulWidget {
  const Cue({super.key, required this.child, this.curve = Curves.linear, this.debug = false});

  final bool debug;
  final Curve curve;
  final Widget child;

  const factory Cue.onTransition({Key? key, required Widget child, Curve curve, bool debug}) = _RouteTransitionStage;

  const factory Cue.animated({
    Key? key,
    required Widget child,
    Curve curve,
    bool debug,
    Duration duration,
    Duration? reverseDuration,
    Duration? delay,
    bool loop,
    bool reverseOnLoop,
  }) = _SelfAnimatedStage;

  const factory Cue.onHover({
    Key? key,
    required Widget child,
    Curve curve,
    bool debug,
    Duration duration,
    Duration? reverseDuration,
    MouseCursor cursor,
    bool opaque,
  }) = _OnHoverStage;

  const factory Cue.controlled({
    Key? key,
    required Widget child,
    Curve curve,
    bool debug,
    required Animation<double> animation,
  }) = _ControlledStage;

  const factory Cue.toggled({
    Key? key,
    required Widget child,
    Curve curve,
    bool debug,
    Duration duration,
    Duration? reverseDuration,
    required bool toggled,
    bool skipFirstAnimation,
  }) = _ToggledStage;

  const factory Cue.indexed({
    Key? key,
    required Widget child,
    Curve curve,
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
    bool debug,
    required PageController controller,
    required int targetIndex,
    IndexDistanceCalculator? calculator,
  }) = _IndexedStage.fromPageController;
}

class _RouteTransitionStageState extends _CueState<_RouteTransitionStage> {
  @override
  Animation<double> getAnimation(BuildContext context) {
    return ModalRoute.of(context)!.animation!;
  }
}

abstract class _CueState<T extends Cue> extends State<Cue> {
  @override
  T get widget => super.widget as T;

  VoidCallback? _deattachDebugOverlay;

  @override
  void initState() {
    super.initState();
    if (kDebugMode && widget.debug) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (CueDebugProvider.isWrappedByDebugProvider(context)) {
          _deattachDebugOverlay = CueDebugProvider.showDebugOverlay(context);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant Cue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kDebugMode && widget.debug && !oldWidget.debug) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (CueDebugProvider.isWrappedByDebugProvider(context)) {
          _deattachDebugOverlay = CueDebugProvider.showDebugOverlay(context);
        }
      });
    } else if (kDebugMode && !widget.debug && oldWidget.debug) {
      _deattachDebugOverlay?.call();
      _deattachDebugOverlay = null;
    }
  }

  @override
  void dispose() {
    _deattachDebugOverlay?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode && widget.debug) {
      if (CueDebugProvider.isWrappedByDebugProvider(context)) {
        return CueScope(animation: CueDebugProvider.animationOf(context), child: widget.child);
      } else {
        return CueDebugProvider(
          child: Builder(
            builder: (context) {
              return CueScope(animation: CueDebugProvider.animationOf(context), child: widget.child);
            },
          ),
        );
      }
    }
    return CueScope(animation: getAnimation(context), child: widget.child);
  }

  Animation<double> getAnimation(BuildContext context);
}

class _RouteTransitionStage extends Cue {
  const _RouteTransitionStage({super.key, required super.child, super.curve, super.debug});

  @override
  State<StatefulWidget> createState() => _RouteTransitionStageState();
}

class _SelfAnimatedStage extends Cue {
  const _SelfAnimatedStage({
    super.key,
    required super.child,
    super.curve,
    super.debug,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration,
    this.loop = false,
    this.reverseOnLoop = false,
    this.delay,
  });

  final Duration duration;
  final Duration? reverseDuration;
  final Duration? delay;
  final bool loop;
  final bool reverseOnLoop;

  @override
  State<Cue> createState() => _SelfAnimatedStageState();
}

class _SelfAnimatedStageState extends _AnimatedStageState<_SelfAnimatedStage> {
  @override
  Curve get curve => widget.curve;

  @override
  Duration get duration => widget.duration;

  @override
  Duration? get reverseDuration => widget.reverseDuration;

  @override
  void onControllerReady() async {
    if (widget.delay case final delay?) {
      await Future.delayed(delay);
    }
    play(loop: widget.loop, reverseOnLoop: widget.reverseOnLoop);
  }

  @override
  Animation<double> getAnimation(BuildContext context) => animation;
}

abstract class _AnimatedStageState<T extends Cue> extends _CueState<T> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  Curve get curve;

  Duration get duration;

  Duration? get reverseDuration => null;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: duration, reverseDuration: reverseDuration);
    animation = CurvedAnimation(parent: controller, curve: curve);
    onControllerReady();
  }

  @override
  void didUpdateWidget(covariant Cue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (duration != controller.duration) {
      controller.duration = duration;
    }
    if (reverseDuration != controller.reverseDuration) {
      controller.reverseDuration = reverseDuration;
    }
    if (curve != oldWidget.curve) {
      animation = CurvedAnimation(parent: controller, curve: curve);
    }
  }

  void onControllerReady() {}

  void play({bool loop = false, bool reverseOnLoop = false}) {
    if (mounted) {
      if (loop) {
        controller.repeat(reverse: reverseOnLoop);
      } else {
        controller.forward();
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _OnHoverStage extends Cue {
  const _OnHoverStage({
    super.key,
    required super.child,
    super.curve,
    super.debug,
    this.duration = const Duration(milliseconds: 200),
    this.reverseDuration,
    this.cursor = MouseCursor.defer,
    this.opaque = false,
  });

  final Duration duration;
  final Duration? reverseDuration;
  final MouseCursor cursor;
  final bool opaque;

  @override
  State<StatefulWidget> createState() => _OnHoverStageState();
}

class _OnHoverStageState extends _AnimatedStageState<_OnHoverStage> {
  @override
  Curve get curve => widget.curve;

  @override
  Duration get duration => widget.duration;

  @override
  Duration? get reverseDuration => widget.reverseDuration;

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

class _ToggledStage extends Cue {
  const _ToggledStage({
    super.key,
    required super.child,
    super.curve,
    super.debug,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration,
    required this.toggled,
    this.skipFirstAnimation = true,
  });

  final Duration duration;
  final Duration? reverseDuration;
  final bool toggled;
  final bool skipFirstAnimation;

  @override
  State<StatefulWidget> createState() => _ToggledStageState();
}

class _ToggledStageState extends _AnimatedStageState<_ToggledStage> {
  @override
  Curve get curve => widget.curve;

  @override
  Duration get duration => widget.duration;

  @override
  Duration? get reverseDuration => widget.reverseDuration;

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
  void didUpdateWidget(covariant _ToggledStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.toggled != oldWidget.toggled) {
      _animate();
    }
  }

  void _animate() {
    if (widget.toggled) {
      controller.forward(from: 0);
    } else {
      controller.reverse(from: 1);
    }
  }
}

class _ControlledStage extends Cue {
  const _ControlledStage({super.key, required super.child, super.curve, super.debug, required this.animation});

  final Animation<double> animation;

  @override
  State<StatefulWidget> createState() => _ControlledStageState();
}

class _ControlledStageState extends _CueState<_ControlledStage> {
  @override
  Animation<double> getAnimation(_) => widget.animation;
}

class CueScope extends InheritedWidget {
  const CueScope({super.key, required super.child, required this.animation});

  final Animation<double> animation;

  static CueScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CueScope>();
    assert(scope != null, 'No AnimationScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant CueScope oldWidget) {
    return animation != oldWidget.animation;
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
    required super.child,
    required this.listenable,
    required this.getOffset,
    required this.targetIndex,
    this.calculator,
  });

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
