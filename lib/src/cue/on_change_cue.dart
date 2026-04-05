part of 'cue.dart';

/// {@template cue.on_change}
/// A [Cue] that replays its animation whenever [value] changes.
///
/// Resets to `0` and plays forward on each [value] change. Useful 
///
/// [skipFirstAnimation] (defaults to `true`) completes immediately on the
/// first build without playing. 
///
/// ## Implicit-style animation
///
/// When [fromCurrentValue] is `true`, this behaves similarly to Flutter's
/// implicitly animated widgets (e.g. [AnimatedContainer]) — the animation
/// always drives from wherever it currently is toward the new target. The key
/// difference is that the trigger is a [value] change you control explicitly,
/// not a change to the act parameters themselves.
///
/// ## Watching multiple values
///
/// Pass [Object.hash] to observe several values at once:
///
/// ```dart
/// Cue.onChange(
///   value: Object.hash(selectedTab, isLoggedIn),
///   motion: Spring.smooth(damping: 23),
///   acts: [.fadeIn(), .slideY(from: 0.2)],
///   child: MyWidget(),
/// )
/// ```
///
/// ```dart
/// Cue.onChange(
///   value: selectedItem,
///   motion: Spring.smooth(damping: 23),
///   acts: [.fadeIn(), .slideY(from: 0.2)],
///   child: ItemContent(item: selectedItem),
/// )
/// ```
/// {@endtemplate}
class OnChangeCue extends OnMountCue {
  const OnChangeCue({
    super.key,
    required super.child,
    super.motion,
    super.debugLabel,
    this.value,
    this.skipFirstAnimation = true,
    this.fromCurrentValue = false,
    super.acts,
  });

  final Object? value;
  final bool skipFirstAnimation;
  final bool fromCurrentValue;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('value', value, defaultValue: null));
    properties.add(FlagProperty('skipFirstAnimation', value: skipFirstAnimation, ifTrue: 'skipFirstAnimation'));
    properties.add(FlagProperty('fromCurrentValue', value: fromCurrentValue, ifTrue: 'fromCurrentValue'));
  }

  @override
  State<StatefulWidget> createState() => _OnChangeCueState();
}

class _OnChangeCueState extends SelfAnimatedCueState<OnChangeCue> {


  @override
  String get debugName => 'OnChangeCue';

  @override
  bool get reanimateFromCurrent => widget.fromCurrentValue;

  @override
  void onControllerReady() {
    if (widget.skipFirstAnimation) {
      controller.value = 1.0;
    } else {
      controller.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant OnChangeCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      controller.forward(from: 0.0);
    }
  }
}
