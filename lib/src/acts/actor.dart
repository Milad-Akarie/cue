import 'package:cue/cue.dart';
import 'package:flutter/widgets.dart';

class Actor extends StatelessWidget {
  final Curve? curve;
  final Timing? timing;
  final List<Act> acts;
  final Widget child;

  const Actor({
    super.key,
    required this.acts,
    required this.child,
    this.curve,
    this.timing,
  });

  static TweenActor<T> tween<T>({
    Key? key,
    Widget? child,
    required Tween<T> tween,
    required Widget Function(BuildContext, T value) builder,
    Curve? curve,
    Timing? timing,
  }) {
    return TweenActor<T>(
      key: key,
      tween: tween,
      builder: (context, value, child) => builder(context, value),
      curve: curve,
      timing: timing,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scope = CueScope.of(context);
    Widget current = child;
    for (final effect in acts.reversed) {
      current = effect.wrapWidget(
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

class TweenActor<T> extends StatefulWidget {
  const TweenActor({
    super.key,
    required this.builder,
    required this.tween,
    this.curve,
    this.timing,
    this.child,
  });

  final Widget? child;
  final ValueWidgetBuilder<T> builder;
  final Tween<T> tween;
  final Curve? curve;
  final Timing? timing;

  @override
  State<StatefulWidget> createState() => _TweenActorState<T>();
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
    if (oldWidget.tween != widget.tween || oldWidget.curve != widget.curve) {
      _setupAnimation(context);
    }
  }

  void _setupAnimation(BuildContext context) {
    final scope = CueScope.of(context);
    final timing = widget.timing;
    final curve = widget.curve;
    final effectiveCurve = timing != null
        ? Interval(timing.start, timing.end, curve: curve ?? Curves.linear)
        : curve ?? Curves.linear;
    animation = widget.tween
        .chain(
          CurveTween(
            curve: effectiveCurve,
          ),
        )
        .animate(scope.animation);
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
  List<Widget> stagger({required List<Act> Function(int index) acts}) {
    return [for (var i = 0; i < length; i++) Actor(acts: acts(i), child: elementAt(i))];
  }
}
