part of 'cue.dart';

class _ControlledCue extends Cue {
  const _ControlledCue({
    super.key,
    required super.child,
    super.debugLabel,
    required this.timeline,
    super.acts,
  }) : super._();

  final CueTimeline timeline;

  @override
  State<StatefulWidget> createState() => _ControlledCueState();
}

class _ControlledCueState extends CueState<_ControlledCue> {

  @override
  String get debugName => 'ControlledCue';

  @override
  CueTimeline get timeline => widget.timeline;
}
