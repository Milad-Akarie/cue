import 'package:cue/cue.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class Actor extends StatefulWidget {
  final List<Act> acts;
  final Widget child;
  final CueMotion? motion;
  final CueMotion? reverseMotion;
  final Duration delay;
  final Duration reverseDelay;

  const Actor({
    super.key,
    required this.acts,
    required this.child,
    this.motion,
    this.reverseMotion,
    this.delay = Duration.zero,
    this.reverseDelay = Duration.zero,
  });

  @override
  State<Actor> createState() => ActorState();
}

class ActorState extends State<Actor> {
  final _animations = <ActKey, _CacheEntry>{};
  final _animationSnapshots = <ActKey, Object?>{};
  CueScope? _cachedScope;

  List<(Act, ActContext)> _acts = [];

  void _onWillAnimate() {
    _animationSnapshots.clear();
    for (final entry in _animations.entries) {
      _animationSnapshots[entry.key] = entry.value.value;
    }
  }

  void _setupAnimations(CueScope scope) {
    _cachedScope = scope;
    assert(() {
      if (_acts.map((e) => e.$1.key).toSet().length != _acts.length) {
        final seenKeys = <ActKey>{};
        for (final key in _acts.map((e) => e.$1.key)) {
          if (seenKeys.contains(key)) {
            throw StateError(
              'Multiple Acts of the same type are not supported. Please ensure all Acts in the list are of different types. Duplicate found: $key',
            );
          }
          seenKeys.add(key);
        }
      }
      return true;
    }());

    final acts = _acts.map((e) => e.$1);
    final actKeys = acts.map((e) => e.key).toSet();

    for (final entry in List.of(_animations.entries)) {
      if (!actKeys.contains(entry.key)) {
        if (_animations.remove(entry.key) case final cacheEntry?) {
          scope.timeline.release(cacheEntry.trackConfig);
        }
      }
    }

    final textDirection = Directionality.maybeOf(context) ?? TextDirection.ltr;
    for (final entry in _acts) {
      final (act, actContext) = entry;
      final existing = _animations[act.key];
      if (existing?.act == act) continue;
      final implicitFrom = scope.reanimateFromCurrent ? _animationSnapshots[act.key] : null;
      final animation = act.buildAnimation(
        scope.timeline,
        actContext.copyWith(
          textDirection: textDirection,
          implicitFrom: implicitFrom,
        ),
      );
      if (existing?.trackConfig case final trackConfig?) {
        scope.timeline.release(trackConfig);
      }
      _animations[act.key] = _CacheEntry(act, animation);
    }
  }

  @override
  void didUpdateWidget(covariant Actor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.acts, oldWidget.acts) ||
        widget.delay != oldWidget.delay ||
        widget.reverseDelay != oldWidget.reverseDelay ||
        widget.motion != oldWidget.motion ||
        widget.reverseMotion != oldWidget.reverseMotion) {
      final scope = CueScope.of(context);
      _resolveActs(scope.mainConfig);
      _setupAnimations(scope);
    }
  }

  void _resolveActs(TrackConfig mainConfig) {
    _acts = [
      for (final act in widget.acts)
        (
          act,
          act.resolve(
            ActContext(
              motion: widget.motion ?? mainConfig.motion,
              reverseMotion: widget.reverseMotion ?? mainConfig.reverseMotion,
              delay: widget.delay,
              reverseDelay: widget.reverseDelay,
            ),
          ),
        ),
    ];
  }

  void _clearCache(CueScope scope) {
    for (final animation in _animations.values) {
      scope.timeline.release(animation.trackConfig);
    }
    _animations.clear();
    _animationSnapshots.clear();
  }

  VoidCallback? _eventsDisposer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = CueScope.of(context);
    if (_acts.isEmpty) {
      _resolveActs(scope.mainConfig);
    }
    if (_cachedScope?.timeline != scope.timeline) {
      _eventsDisposer?.call();
      _eventsDisposer = scope.timeline.addEventListener<TimelineEvent>((_) => _onWillAnimate());
    }
    if ( _cachedScope?.timeline != scope.timeline ||_cachedScope?.mainConfig != scope.mainConfig) {
      _resolveActs(scope.mainConfig);
      _clearCache(scope);
      _setupAnimations(scope);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_acts.isEmpty) return widget.child;
    Widget current = widget.child;
    for (final entry in _acts.reversed) {
      final (act, _) = entry;
      if (_animations[act.key]?.animation case final animation?) {
        current = act.build(context, animation, current);
      } else {
        throw StateError(
          'Animation for act $act not found. This should not happen as animations are set up in initState and didUpdateWidget.',
        );
      }
    }
    return current;
  }

  @override
  void dispose() {
    super.dispose();
    _eventsDisposer?.call();
    _eventsDisposer = null;
    if (_cachedScope case final scope?) {
      _clearCache(scope);
    }
  }
}

class _CacheEntry {
  final Act act;
  final CueAnimation<Object?> animation;
  _CacheEntry(this.act, this.animation);
  TrackConfig get trackConfig => animation.trackConfig;
  Object? get value => animation.value;
}

abstract class SingleActorBase<T> extends StatelessWidget {
  final Widget child;
  final ReverseBehavior<T> reverse;
  final CueMotion? motion;
  final Duration delay;
  final Duration reverseDelay;
  final CueMotion? reverseMotion;

  final Keyframes<T>? frames;
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
    this.delay = Duration.zero,
    this.reverseMotion,
    this.reverseDelay = Duration.zero,
    this.reverse = const ReverseBehavior.mirror(),
  }) : frames = null,
       _from = from,
       _to = to;

  const SingleActorBase.keyframes({
    required Keyframes<T> this.frames,
    super.key,
    required this.child,
    this.reverse = const ReverseBehavior.mirror(),
    this.delay = Duration.zero,
    this.reverseDelay = Duration.zero,
  }) : _from = null,
       _to = null,
       motion = null,
       reverseMotion = null;

  Act get act;

  @override
  Widget build(BuildContext context) {
    return Actor(
      motion: motion,
      delay: delay,
      reverseMotion: reverseMotion,
      reverseDelay: reverseDelay,
      acts: [act],
      child: child,
    );
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
