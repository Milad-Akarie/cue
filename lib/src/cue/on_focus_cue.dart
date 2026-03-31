part of 'cue.dart';

class OnFocusCue extends OnMountCue {
  const OnFocusCue({
    super.key,
    super.debugLabel,
    super.motion,
    super.reverseMotion,
    this.focusNode,
    super.acts,
    required super.child,
  });

  final FocusNode? focusNode;

  @override
  CueState<OnFocusCue> createState() => _OnFocusCueState();
}

class _OnFocusCueState extends SelfAnimatedCueState<OnFocusCue> {
  late final FocusNode _focusNode;

  @override
  String get debugName => 'OnFocusCue';

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      child: super.build(context),
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          controller.forward();
        } else {
          controller.reverse();
        }
      },
    );
  }
}
