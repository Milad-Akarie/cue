part of 'cue.dart';

class SelfAnimatedCue extends Cue {
  const SelfAnimatedCue({
    super.key,
    required super.child,
    this.motion = CueMotion.defaultTime,
    this.reverseMotion,
    super.debugLabel,
    this.loop = false,
    this.reverseOnLoop = false,
    this.loopCount,
    super.acts,
  }) : super._();

  final CueMotion motion;
  final CueMotion? reverseMotion;
  final bool loop;
  final int? loopCount;
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
      controller.repeat(reverse: widget.reverseOnLoop, count: widget.loopCount);
    } else {
      controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant SelfAnimatedCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loop != oldWidget.loop ||
        widget.reverseOnLoop != oldWidget.reverseOnLoop ||
        widget.loopCount != oldWidget.loopCount) {
      controller.stop();
      if (widget.loop) {
        controller.repeat(reverse: widget.reverseOnLoop, count: widget.loopCount);
      } else {
        controller.forward();
      }
    }
  }
}

abstract class SelfAnimatedState<T extends SelfAnimatedCue> extends _CueState<T> with SingleTickerProviderStateMixin {
  late final CueController controller;

  CueMotion get motion => widget.motion;

  CueMotion? get reverseMotion => widget.reverseMotion;

  @override
  CueTimeline get timeline => controller.timeline;

  @override
  void initState() {
    super.initState();
    _createController();
    onControllerReady();
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
