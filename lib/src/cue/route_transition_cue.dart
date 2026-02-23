part of 'cue.dart';

class _RouteTransitionStage extends Cue {
  const _RouteTransitionStage({
    super.key,
    required super.child,
    super.curve,
    super.debugLabel,
  }) : super._();

  @override
  State<StatefulWidget> createState() => _RouteTransitionStageState();
}

class _RouteTransitionStageState extends _CueState<_RouteTransitionStage> {
  @override
  bool get isBounded => true;

  @override
  Animation<double> getAnimation(BuildContext context) {
    return ModalRoute.of(context)!.animation!;
  }
}
