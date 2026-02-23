part of 'cue.dart';

class _ControlledCue extends Cue {
  const _ControlledCue({
    super.key,
    required super.child,
    this.isBounded = true,
    super.curve,
    super.debugLabel,
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
