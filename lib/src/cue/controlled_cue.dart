part of 'cue.dart';

class _ControlledCue extends Cue {
  const _ControlledCue({
    super.key,
    required super.child,
    this.isBounded = true,
    super.debugLabel,
    required this.timeline,
    super.act,
  }) : super._();

  final CueTimeline timeline;
  final bool isBounded;

  @override
  State<StatefulWidget> createState() => _ControlledCueState();
}

class _ControlledCueState extends _CueState<_ControlledCue> {

  @override
  String get debugName => 'ControlledCue';

  @override
  CueTimeline get timeline => widget.timeline;
}
