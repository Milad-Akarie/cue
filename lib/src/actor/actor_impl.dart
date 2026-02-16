part of 'actor.dart';

@internal
class ActorBase extends StatefulWidget implements Actor {
  final Curve? curve;
  final Timing? timing;
  final List<Act> acts;
  final Widget child;

  const ActorBase({
    super.key,
    required this.acts,
    required this.child,
    this.curve,
    this.timing,
  });

  @override
  State<ActorBase> createState() => _ActorBaseState();
}

class _ActorBaseState extends State<ActorBase> {
  final _animations = <Act, Animation<Object?>>{};

  Animation<double>? _cachedDriver;

  @override
  void initState() {
    super.initState();
  }

  void _setupAnimations(Animation<double> driver) {
    _cachedDriver = driver;
    // print('Setting up animations for ${widget.child.runtimeType} acts');
    _animations.clear();
    for (final act in widget.acts) {
      if (!_animations.containsKey(act)) {
        _animations[act] = act.buildAnimation(driver);
      }
    }
  }

  @override
  void didUpdateWidget(covariant ActorBase oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.acts, widget.acts) ||
        oldWidget.curve != widget.curve ||
        oldWidget.timing != widget.timing) {
      _setupAnimations(CueScope.of(context).animation);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final driver = CueScope.of(context).animation;
    if (_cachedDriver != driver) {
      _setupAnimations(driver);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.acts.isEmpty) return widget.child;
    Widget current = widget.child;
    for (final act in widget.acts.reversed) {
      if (_animations[act] case final animation?) {
        current = act.build(context, animation, current);
      } else {
        throw StateError(
          'Animation for act $act not found. This should not happen as animations are set up in initState and didUpdateWidget.',
        );
      }
    }
    return current;
  }
}

@internal
abstract class SingleActProxy extends StatelessWidget implements Actor {
  final Widget child;
  final Curve? curve;
  final Timing? timing;

  const SingleActProxy({
    super.key,
    required this.child,
    this.curve,
    this.timing,
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

  Animation<double>? _cachedDriver;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final driver = CueScope.of(context).animation;
    if (_cachedDriver != driver) {
      _setupAnimation(driver);
    }
  }

  @override
  void didUpdateWidget(covariant TweenActor<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._tween != widget._tween ||
        oldWidget.curve != widget.curve ||
        oldWidget.timing != widget.timing ||
        listEquals(widget._keyframes, oldWidget._keyframes)) {
      _setupAnimation(CueScope.of(context).animation);
    }
  }

  void _setupAnimation(Animation<double> driver) {
    _cachedDriver = driver;
    Timing? timing = widget.timing;
    Curve? curve = widget.curve;

    Animatable<T> effectiveTween;
    if (widget._tween case final tween?) {
      effectiveTween = tween;
    } else {
      final result = Phase.normalize(widget._keyframes!, (value) => value);
      if (result.timing != null) {
        timing = result.timing;
      }
      effectiveTween = TweenActBase.buildFromPhases<T>(
        result.phases,
        widget._tweenBuilder ?? (begin, end) => Tween<T>(begin: begin, end: end),
      );
    }
    final effectiveCurve = timing != null
        ? Interval(timing.start, timing.end, curve: curve ?? Curves.linear)
        : curve ?? Curves.linear;

    print(effectiveCurve);
    animation = driver.drive<T>(effectiveTween.chain(CurveTween(curve: effectiveCurve)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return widget.builder(
          context,
          animation.value,
          widget.child,
        );
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
