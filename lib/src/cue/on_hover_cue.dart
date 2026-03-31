part of 'cue.dart';

class OnHoverCue extends OnMountCue {
  const OnHoverCue({
    super.key,
    required super.child,
    super.debugLabel,
    super.motion = .defaultTime,
    this.cursor = MouseCursor.defer,
    this.opaque = false,
    super.acts,
  }) : super();

  final MouseCursor cursor;
  final bool opaque;

  @override
  State<StatefulWidget> createState() => _OnHoverStageState();
}

class _OnHoverStageState extends SelfAnimatedCueState<OnHoverCue> {
  @override
  String get debugName => 'OnHoverCue';

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
