import 'package:cue/cue.dart';
import 'package:cue/src/motion/cue_motion.dart';
import 'package:flutter/widgets.dart';

class Actor extends StatefulWidget {
  final Act act;
  final Widget child;

  const Actor({
    super.key,
    required this.act,
    required this.child,
  });

  @override
  State<Actor> createState() => ActorState();
}

class ActorState extends State<Actor> {
  final _animations = <Type, CueAnimation<Object?>>{};
  final _cachedAnimations = <Act, CueAnimation<Object?>>{};
  final _animationSnapshots = <Type, Object?>{};

  List<(Act, ActContext)> _acts = [];

  void _onWillReAnimate(bool forward) {
    for (final entry in _animations.entries) {
      _animationSnapshots[entry.key] = entry.value.value;
    }
  }

  CueScope? _cachedScope;

  void _setupAnimations(CueScope scope) {
    _cachedScope = scope;
    assert(() {
      if (_acts.map((e) => e.runtimeType).toSet().length != _acts.length) {
        throw StateError(
          'Multiple effects of the same type are not supported. Please ensure all effects in the list are of different types.',
        );
      }
      return true;
    }());

    _animations.removeWhere((act, _) => !_acts.map((e) => e.$1.runtimeType).contains(act));
    _cachedAnimations.removeWhere((effect, _) => !_acts.map((e) => e.$1).contains(effect));
    for (final entry in _acts) {
      final (act, actContext) = entry;
      if (!_cachedAnimations.containsKey(act)) {
        final implicitFrom = scope.reanimateFromCurrent ? _animationSnapshots[act.runtimeType] : null;
        final animation = act.buildAnimation(
          scope.animations,
          actContext.copyWith(
            textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
            isBounded: scope.isBounded,
            implicitFrom: implicitFrom,
          ),
        );
        _animations[act.runtimeType] = animation;
        _cachedAnimations[act] = animation;
      }
    }
  }

  @override
  void didUpdateWidget(covariant Actor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.act != widget.act) {
      final scope = CueScope.of(context);
      _acts = widget.act.resolve(ActContext(isBounded: scope.isBounded));
      _setupAnimations(scope);
    }
  }

  void _clearCache() {
    _animations.clear();
    _cachedAnimations.clear();
    _animationSnapshots.clear();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = CueScope.of(context);
    if (_acts.isEmpty) {
      _acts = widget.act.resolve(ActContext(isBounded: scope.isBounded));
    }
    if (_cachedScope?.willReanimateNotifier != scope.willReanimateNotifier) {
      _cachedScope?.willReanimateNotifier?.removeEventListener(_onWillReAnimate);
      scope.willReanimateNotifier?.addEventListener(_onWillReAnimate);
    }
    if (_cachedScope == null || scope.updateShouldNotify(_cachedScope!)) {
      if (_cachedScope?.animations != scope.animations) {
        _clearCache();
      }
      _setupAnimations(scope);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_acts.isEmpty) return widget.child;
    Widget current = widget.child;
    for (final entry in _acts.reversed) {
      final (act, _) = entry;
      if (_animations[act.runtimeType] case final animation?) {
        current = act.build(context, animation, current);
      } else {
        throw StateError(
          'Animation for effect $act not found. This should not happen as animations are set up in initState and didUpdateWidget.',
        );
      }
    }
    return current;
  }

  @override
  void dispose() {
    super.dispose();
    _cachedScope?.willReanimateNotifier?.removeEventListener(_onWillReAnimate);
    // _cachedScope?.animations.disposeAll(_animations.values);
  }
}

abstract class SingleActorBase<T> extends StatelessWidget {
  final Widget child;
  final ReverseBehavior<T> reverse;
  final CueMotion? motion;
  final List<Keyframe<T>>? frames;
  final T? _from;
  final T? _to;

  T? get from => _from;
  T? get to => _to;

  const SingleActorBase({
    super.key,
    required this.child,
    required T from,
    required T to,
    this.motion,
    this.reverse = const ReverseBehavior.mirror(),
  }) : frames = null,
       _from = from,
       _to = to;

  const SingleActorBase.keyframes({
    required List<Keyframe<T>> this.frames,
    super.key,
    required this.child,
    this.reverse = const ReverseBehavior.mirror(),
    this.motion,
  }) : _from = null,
       _to = null;

  Act get effect;

  @override
  Widget build(BuildContext context) {
    return Actor(act: effect, child: child);
  }
}

// class TweenActor<T> extends StatefulWidget {
//   final List<Keyframe<T>>? _keyframes;
//   final Widget? child;
//   final ValueWidgetBuilder<T> builder;
//   final TweenBuilder<T>? _tweenBuilder;
//   final Tween<T>? _tween;
//   final Curve? curve;
//   final Timing? timing;

//   const TweenActor({
//     super.key,
//     required this.builder,
//     required Tween<T> tween,
//     this.curve,
//     this.timing,
//     this.child,
//   }) : _tween = tween,
//        _keyframes = null,
//        _tweenBuilder = null;

//   const TweenActor.keyframes({
//     super.key,
//     required this.builder,
//     required List<Keyframe<T>> keys,
//     TweenBuilder<T>? tweenBuilder,
//     this.curve,
//     this.child,
//   }) : _tweenBuilder = tweenBuilder,
//        _keyframes = keys,
//        _tween = null,
//        timing = null;

//   @override
//   State<StatefulWidget> createState() => _ProgressActorState<T>();
// }

// class ProgressActor extends TweenActor<double> {
//   ProgressActor({
//     super.key,
//     required super.builder,
//     super.curve,
//     super.timing,
//     super.child,
//   }) : super(tween: Tween<double>(begin: 0.0, end: 1.0));

//   @override
//   State<StatefulWidget> createState() => _ProgressActorState<double>();
// }

// class _ProgressActorState<T> extends State<TweenActor<T>> {
//   late Animation<T> animation;

//   Animation<double>? _cachedDriver;
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final driver = CueScope.of(context).animations;
//     if (_cachedDriver != driver) {
//       _setupAnimation(driver);
//     }
//   }

//   @override
//   void didUpdateWidget(covariant TweenActor<T> oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget._tween != widget._tween ||
//         oldWidget.curve != widget.curve ||
//         oldWidget.timing != widget.timing ||
//         !listEquals(widget._keyframes, oldWidget._keyframes)) {
//       _setupAnimation(CueScope.of(context).animations);
//     }
//   }

//   void _setupAnimation(Animation<double> driver) {
//     _cachedDriver = driver;
//     Timing? timing = widget.timing;
//     Curve? curve = widget.curve;

//     Animatable<T> effectiveTween;
//     if (widget._tween case final tween?) {
//       effectiveTween = tween;
//     } else {
//       final result = Phase.normalize(widget._keyframes!, (value) => value);

//       if (result.timing != null) {
//         timing = result.timing;
//       }
//       effectiveTween = buildFromPhases<T>(
//         result.phases,
//         widget._tweenBuilder ?? (begin, end) => Tween<T>(begin: begin, end: end),
//       );
//     }

//     if (timing == null && curve == null) {
//       animation = driver.drive<T>(effectiveTween);
//       return;
//     }

//     final effectiveCurve = timing != null
//         ? Interval(timing.start, timing.end, curve: curve ?? Curves.linear)
//         : curve ?? Curves.linear;

//     animation = driver.drive<T>(
//       effectiveTween.chain(CurveTween(curve: effectiveCurve)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: animation,
//       builder: (context, child) {
//         return widget.builder(
//           context,
//           animation.value,
//           widget.child,
//         );
//       },
//     );
//   }
// }
