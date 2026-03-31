part of 'cue.dart';

class OnMountCue extends Cue {
  const OnMountCue({
    super.key,
    required super.child,
    this.motion = CueMotion.defaultTime,
    this.reverseMotion,
    super.debugLabel,
    this.repeat = false,
    this.reverseOnRepeat = false,
    this.repeatCount,
    super.acts,
  }) : super._();

  final CueMotion motion;
  final CueMotion? reverseMotion;
  final bool repeat;
  final int? repeatCount;
  final bool reverseOnRepeat;

  @override
  State<StatefulWidget> createState() => OnMountCueState();
}

class OnMountCueState extends SelfAnimatedState<OnMountCue> {
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

  bool _devToolControlled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (kDebugMode) {
      final devToolScope = CueDebugTools.maybeOf(context);
      final isDevToolControlled = devToolScope?.activeTargetId == _debugId && devToolScope?.isMinimized == false;
      if (!_devToolControlled && isDevToolControlled) {
        controller.stop();
      } else if (_devToolControlled && !isDevToolControlled && widget.repeat) {
        controller.repeat(reverse: widget.reverseOnRepeat, count: widget.repeatCount);
      }
      _devToolControlled = isDevToolControlled;
    }
  }
}

abstract class SelfAnimatedState<T extends OnMountCue> extends CueState<T> with SingleTickerProviderStateMixin {
  late final CueController controller;

  CueMotion get motion => widget.motion;

  CueMotion? get reverseMotion => widget.reverseMotion;

  @override
  CueTimeline get timeline => controller.timeline;

  AnimationStatusListener? _statusListener;

  @override
  void initState() {
    super.initState();
    _createController();
    _updateStatusListener();
    onControllerReady();
  }

  void _updateStatusListener() {
    if (_statusListener != null) {
      controller.removeStatusListener(_statusListener!);
    }
    _statusListener = (status) {
      if (status.isCompleted) {
        onAnimationEnd(true);
      } else if (status.isDismissed) {
        onAnimationEnd(false);
      }
    };
    controller.addStatusListener(_statusListener!);
  }

  void _createController() {
    controller = CueController(
      motion: motion,
      reverseMotion: widget.reverseMotion,
      vsync: this,
      debugLabel: 'Cue Controller for ${widget.debugLabel ?? widget.runtimeType}',
    );
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.motion != motion || oldWidget.reverseMotion != reverseMotion) {
      controller.updateMotion(motion, newReverseMotion: reverseMotion);
      if (kDebugMode) {
        final debugToolScope = CueDebugTools.maybeOf(context);
        if (debugToolScope != null) {
          debugToolScope.timeline.resetTracks(
            TrackConfig(
              motion: motion,
              reverseMotion: reverseMotion ?? motion,
            ),
          );
        }
      }
    }
  }

  void onControllerReady() {}

  void onAnimationEnd(bool forward) {}

  @override
  void dispose() {
    if (_statusListener != null) {
      controller.removeStatusListener(_statusListener!);
    }
    controller.dispose();
    super.dispose();
  }
}
