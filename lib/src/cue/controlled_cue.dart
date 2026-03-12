part of 'cue.dart';

class _ControlledCue extends Cue {
  const _ControlledCue({
    super.key,
    required super.child,
    this.isBounded = true,
    super.debugLabel,
    required this.animations,
    super.act,
  }) : super._();

  final Timeline animations;
  final bool isBounded;

  @override
  State<StatefulWidget> createState() => _ControlledCueState();
}

class _ControlledCueState extends _CueState<_ControlledCue> {
  @override
  bool get isBounded => widget.isBounded;

  @override
  String get debugName => 'ControlledCue';

  @override
  Timeline getAnimations(_) => widget.animations;
}
