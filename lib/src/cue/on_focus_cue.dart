part of 'cue.dart';

class OnFocusCue extends SelfAnimatedCue {
  const OnFocusCue({
    super.key,
    super.debugLabel,
    super.motion,
    super.reverseMotion,
    this.focusNode,
    super.acts,
    super.onEnd,
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
  void didUpdateWidget(covariant OnFocusCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
    }
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
