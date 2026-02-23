part of 'cue.dart';

class _OnHoverCue extends _SelfAnimatedCue {
  const _OnHoverCue({
    super.key,
    required super.child,
    super.curve,
    super.debugLabel,
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
