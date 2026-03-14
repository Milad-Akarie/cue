part of 'cue.dart';

class _OnHoverCue extends SelfAnimatedCue {
  const _OnHoverCue({
    super.key,
    required super.child,
    super.debugLabel,
    super.motion = const CueMotion.linear(Duration(milliseconds: 200)),
    this.cursor = MouseCursor.defer,
    this.opaque = false,
    super.act,
  }) : super();

  final MouseCursor cursor;
  final bool opaque;

  @override
  State<StatefulWidget> createState() => _OnHoverStageState();
}

class _OnHoverStageState extends SelfAnimatedState<_OnHoverCue> {
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
