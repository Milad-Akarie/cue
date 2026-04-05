part of 'cue.dart';

/// {@template cue.on_focus}
/// A [Cue] that animates when the widget gains or loses keyboard focus.
///
/// Animates forward on focus gained and reverses on focus lost.
/// Wraps [child] in a [Focus] widget internally.
///
/// Provide a [focusNode] to manage focus externally. If omitted, one is
/// created and disposed automatically.
///
/// ```dart
/// Cue.onFocus(
///   motion: Spring.smooth(damping: 23),
///   acts: [.scale(from: 1.0, to: 1.02)],
///   child: MyTextField(),
/// )
/// ```
/// {@endtemplate}
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
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<FocusNode>('focusNode', focusNode, defaultValue: null));
  }

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
