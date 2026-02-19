import 'package:cue/cue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class Actor extends StatefulWidget {
  final Curve? curve;
  final Curve? reverseCurve;
  final Timing? timing;
  final Timing? reverseTiming;
  final ActorRole role;
  final List<Effect> effects;
  final Widget child;

  const Actor({
    super.key,
    required this.effects,
    required this.child,
    this.role = ActorRole.both,
    this.curve,
    this.reverseCurve,
    this.timing,
    this.reverseTiming,
  });

  @override
  State<Actor> createState() => _ActorState();
}

class _ActorState extends State<Actor> {
  final _animations = <Effect, Animation<Object?>>{};

  CueScope? _cachedScope;

  @override
  void initState() {
    super.initState();
  }

  void _setupAnimations(CueScope scope) {
    _cachedScope = scope;
    _animations.clear();
    for (final act in widget.effects) {
      if (!_animations.containsKey(act)) {
        _animations[act] = act.buildAnimation(
          scope.animation,
          AnimationBuildData(
            curve: widget.curve,
            timing: widget.timing,
            isBounded: scope.isBounded,
            reverseCurve: widget.reverseCurve,
            reverseTiming: widget.reverseTiming,
            role: widget.role,
          ),
        );
      }
    }
  }

  @override
  void didUpdateWidget(covariant Actor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.effects, widget.effects) ||
        oldWidget.curve != widget.curve ||
        oldWidget.timing != widget.timing ||
        oldWidget.reverseCurve != widget.reverseCurve ||
        oldWidget.reverseTiming != widget.reverseTiming ||
        oldWidget.role != widget.role) {
      _setupAnimations(CueScope.of(context));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = CueScope.of(context);
    if (_cachedScope == null || scope.updateShouldNotify(_cachedScope!)) {
      _setupAnimations(scope);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.effects.isEmpty) return widget.child;
    Widget current = widget.child;
    for (final act in widget.effects.reversed) {
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

abstract class SingleEffectProxy<T> extends StatelessWidget {
  final Widget child;
  final Curve? curve;
  final Curve? reverseCurve;
  final Timing? timing;
  final Timing? reverseTiming;
  final ActorRole role;
  final List<Keyframe<T>>? keys;

  const SingleEffectProxy({
    super.key,
    required this.child,
    this.curve,
    this.timing,
    this.role = ActorRole.both,
    this.reverseCurve,
    this.reverseTiming,
  }) : keys = null;

  const SingleEffectProxy.keyFrames({
    required List<Keyframe<T>> this.keys,
    super.key,
    required this.child,
    this.role = ActorRole.both,
    this.reverseCurve,
    this.reverseTiming,
    this.curve,
  }) : timing = null;

  Effect get effect;

  @override
  Widget build(BuildContext context) {
    return Actor(
      curve: curve,
      timing: timing,
      reverseCurve: reverseCurve,
      reverseTiming: reverseTiming,
      role: role,
      effects: [effect],
      child: child,
    );
  }
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

class ProgressActor extends TweenActor<double> {
  ProgressActor({
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
      effectiveTween = TweenEffectBase.buildFromPhases<T>(
        result.phases,
        widget._tweenBuilder ?? (begin, end) => Tween<T>(begin: begin, end: end),
      );
    }

    if (timing == null && curve == null) {
      animation = driver.drive<T>(effectiveTween);
      return;
    }

    final effectiveCurve = timing != null
        ? Interval(timing.start, timing.end, curve: curve ?? Curves.linear)
        : curve ?? Curves.linear;

    animation = driver.drive<T>(
      effectiveTween.chain(CurveTween(curve: effectiveCurve)),
    );
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
  List<Widget> staggerEffects(
    List<Effect> Function(int index) effects, {
    Curve? curve,
  }) {
    return [
      for (var i = 0; i < length; i++)
        Actor(
          curve: curve,
          effects: effects(i),
          child: elementAt(i),
        ),
    ];
  }
}
