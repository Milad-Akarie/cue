part of 'cue.dart';

class _RouteTransitionStage extends Cue {
  const _RouteTransitionStage({
    super.key,
    required super.child,
    super.curve,
    super.debugLabel,
    this.useSecondaryAnimation = false,
  }) : super._();

  final bool useSecondaryAnimation;

  @override
  State<StatefulWidget> createState() => _RouteTransitionStageState();
}

class _RouteTransitionStageState extends _CueState<_RouteTransitionStage> {
  @override
  bool get isBounded => true;

  @override
  Animation<double> getAnimation(BuildContext context) {
    return widget.useSecondaryAnimation
        ? ModalRoute.of(context)!.secondaryAnimation!
        : ModalRoute.of(context)!.animation!;
  }
}
