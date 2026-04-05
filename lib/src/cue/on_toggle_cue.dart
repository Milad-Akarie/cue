part of 'cue.dart';

/// {@template cue.on_toggle}
/// A [Cue] driven by a boolean [toggled] value.
///
/// Animates forward when [toggled] becomes `true` and reverses when it
/// becomes `false`. The natural fit for any UI component with two states:
///
/// - expand / collapse
/// - open / close
/// - on / off
/// - selected / unselected
/// - visible / hidden
///
/// [skipFirstAnimation] (defaults to `true`) makes the controller jump to the
/// correct end state on the first build without playing the animation.
///
/// ```dart
/// Cue.onToggle(
///   toggled: isExpanded,
///   motion: .smooth(),
///   acts: [.rotate(to: 180), .fadeIn()],
///   child: Icon(Icons.expand_more),
/// )
/// ```
/// {@endtemplate}
class OnToggleCue extends SelfAnimatedCue {
  /// Default constructor.
  const OnToggleCue({
    super.key,
    required super.child,
    super.debugLabel,
    super.onEnd,
    super.motion,
    super.reverseMotion,
    required this.toggled,
    this.skipFirstAnimation = true,
    super.acts,
  }) : super();

  /// Whether the cue is toggled on (animate forward) or off (animate reverse).
  final bool toggled;

  /// Whether to skip the first animation and jump straight to the correct end state on the first build. Defaults to `true`.
  final bool skipFirstAnimation;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('toggled', value: toggled, ifTrue: 'toggled', ifFalse: 'not toggled'));
    properties.add(FlagProperty('skipFirstAnimation', value: skipFirstAnimation, ifTrue: 'skipFirstAnimation'));
  }

  @override
  State<StatefulWidget> createState() => _ToggledStageState();
}

class _ToggledStageState extends SelfAnimatedCueState<OnToggleCue> {
  @override
  String get debugName => 'ToggledCue';

  @override
  void initState() {
    super.initState();
    if (widget.skipFirstAnimation) {
      controller.value = widget.toggled ? 1.0 : 0.0;
    } else {
      _toggle(true);
    }
  }

  @override
  void didUpdateWidget(covariant OnToggleCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.toggled != oldWidget.toggled) {
      _toggle();
    }
  }

  void _toggle([bool force = false]) async {
    if (widget.toggled && (!controller.isCompleted || force)) {
      controller.forward();
    } else if (!widget.toggled && (!controller.isDismissed || force)) {
      controller.reverse();
    }
  }
}
