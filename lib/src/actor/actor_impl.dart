part of 'actor.dart';

@internal
class ActorBase extends StatelessWidget implements Actor {
  final Curve? curve;
  final Timing? timing;
  final List<Act> acts;
  final Widget child;
  final BoxOverflow overflow;

  const ActorBase({
    super.key,
    required this.acts,
    required this.child,
    this.curve,
    this.timing,
    this.overflow = const BoxOverflow.none(),
  });

  @override
  Widget build(BuildContext context) {
    if (acts.isEmpty) return child;
    final scope = CueScope.of(context);

    Widget current = child;

    if (!overflow.isNone) {
      final targetSize = LayoutInfoScope.of(context)?.size;
      if (targetSize != null) {
        current = OverflowBox(
          maxWidth: overflow.horizontal ? targetSize.width - overflow.horizontalPadding : null,
          maxHeight: overflow.vertical ? targetSize.height - overflow.verticalPadding : null,
          fit: overflow.fit,
          alignment: overflow.alignment,
          child: current,
        );
      }
    }

    for (final effect in acts.reversed) {
      current = effect.apply(
        AnimationContext(
          buildContext: context,
          driver: scope.animation,
          timing: effect.timing ?? timing,
          curve: effect.curve ?? curve,
        ),
        current,
      );
    }
    return current;
  }
}

@internal
abstract class SingleActProxy extends StatelessWidget implements Actor {
  final Widget child;
  final Curve? curve;
  final Timing? timing;
  final BoxOverflow overflow;

  const SingleActProxy({
    super.key,
    required this.child,
    this.curve,
    this.timing,
    this.overflow = const BoxOverflow.none(),
  });
}

class TweenActor<T> extends StatefulWidget {
  final List<Keyframe<T>>? _keyframes;
  final Widget? child;
  final ValueWidgetBuilder<T> builder;
  final TweenBuilder<T>? _tweenBuilder;
  final Tween<T>? _tween;
  final Curve? curve;
  final Timing? timing;

  const TweenActor({
    super.key,
    required this.builder,
    required Tween<T> tween,
    this.curve,
    this.timing,
    this.child,
  }) : _tween = tween,
       _keyframes = null,
       _tweenBuilder = null;

  const TweenActor.keyframes({
    super.key,
    required this.builder,
    required List<Keyframe<T>> keys,
    TweenBuilder<T>? tweenBuilder,
    this.curve,
    this.child,
  }) : _tweenBuilder = tweenBuilder,
       _keyframes = keys,
       _tween = null,
       timing = null;

  @override
  State<StatefulWidget> createState() => _TweenActorState<T>();
}

class _LerpDoubleTweenActor extends TweenActor<double> implements Actor {
  _LerpDoubleTweenActor({
    super.key,
    required super.builder,
    super.curve,
    super.timing,
    super.child,
  }) : super(tween: Tween<double>(begin: 0.0, end: 1.0));

  @override
  State<StatefulWidget> createState() => _TweenActorState<double>();
}

class _TweenActorState<T> extends State<TweenActor<T>> {
  late Animation<T> animation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupAnimation(context);
  }

  @override
  void didUpdateWidget(covariant TweenActor<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._tween != widget._tween ||
        oldWidget.curve != widget.curve ||
        oldWidget.timing != widget.timing ||
        listEquals(widget._keyframes, oldWidget._keyframes)) {
      _setupAnimation(context);
    }
  }

  void _setupAnimation(BuildContext context) {
    AnimationContext animationContext = AnimationContext(
      buildContext: context,
      driver: CueScope.of(context).animation,
      timing: widget.timing,
      curve: widget.curve,
    );

    if (widget._tween case final tween?) {
      animation = TweenActBase.buildFromPhases<T>(
        animationContext,
        [Phase<T>(begin: tween.begin as T, end: tween.end as T, weight: 100)],
        (_, _) => tween,
      );
      return;
    }

    final result = Phase.normalize(widget._keyframes!, (value) => value);
    if (result.timing != null) {
      animationContext = animationContext.copyWith(timing: result.timing);
    }
    animation = TweenActBase.buildFromPhases<T>(
      animationContext,
      result.phases,
      widget._tweenBuilder ?? (begin, end) => Tween<T>(begin: begin, end: end),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return widget.builder(context, animation.value, widget.child);
      },
    );
  }
}

extension StaggeredActorExtension on Iterable<Widget> {
  List<Widget> staggerActs(List<Act> Function(int index) acts, {Curve? curve}) {
    return [
      for (var i = 0; i < length; i++)
        Actor(
          curve: curve,
          acts: acts(i),
          child: elementAt(i),
        ),
    ];
  }
}

class BoxOverflow {
  final bool horizontal;
  final bool vertical;
  final OverflowBoxFit fit;
  final double verticalPadding;
  final double horizontalPadding;
  final AlignmentGeometry alignment;

  const BoxOverflow({
    this.horizontal = true,
    this.vertical = true,
    this.fit = OverflowBoxFit.deferToChild,
    this.alignment = Alignment.center,
    this.verticalPadding = 0.0,
    this.horizontalPadding = 0.0,
  });

  const BoxOverflow.horizontal({this.fit = OverflowBoxFit.deferToChild, this.alignment = .center, double padding = 0.0})
    : vertical = false,
      verticalPadding = 0.0,
      horizontalPadding = padding,
      horizontal = true;

  const BoxOverflow.vertical({this.fit = OverflowBoxFit.deferToChild, this.alignment = .center, double padding = 0.0})
    : horizontal = false,
      horizontalPadding = 0.0,
      verticalPadding = padding,
      vertical = true;

  const BoxOverflow.none()
    : horizontal = false,
      vertical = false,
      fit = OverflowBoxFit.deferToChild,
      verticalPadding = 0.0,
      horizontalPadding = 0.0,
      alignment = Alignment.center;

  bool get isNone => !horizontal && !vertical;

  bool get isAll => horizontal && vertical;
}
