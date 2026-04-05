part of 'cue.dart';

/// {@template cue.controlled}
/// A [Cue] driven by an externally provided [CueController].
///
/// Delegates full animation control to the caller. Use this for imperative
/// animations triggered by button taps, gestures, or custom business logic.
///
/// The provided [controller] is **not** disposed by this widget — the caller
/// owns its lifecycle.
///
/// ```dart
/// final controller = CueController(vsync: this, motion: Spring.smooth());
///
/// Cue(
///   controller: controller,
///   acts: [.fadeIn(), .slideY(from: 0.3)],
///   child: MyWidget(),
/// )
///
/// // Later:
/// controller.forward();
/// ```
/// {@endtemplate}
class _ControlledCue extends Cue {
  const _ControlledCue({
    super.key,
    required super.child,
    super.debugLabel,
    required this.controller,
    super.acts,
  }) : super._();

  final CueController controller;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<CueController>('controller', controller));
  }

  @override
  State<StatefulWidget> createState() => _ControlledCueState();
}

class _ControlledCueState extends CueState<_ControlledCue> {
  
  @override
  String get debugName => 'ControlledCue';

  @override
  CueController get controller => widget.controller;
}
