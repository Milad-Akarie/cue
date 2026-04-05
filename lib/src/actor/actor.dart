import 'package:cue/cue.dart';
import 'package:cue/src/timeline/event_notifier.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A widget that applies one or more animation [Act]s to its [child].
///
/// ## Overview
///
/// [Actor] is the core visual building block for Cue animations. It wraps a
/// child widget with a list of [acts] — declarative descriptions of how the
/// widget should look at different points in the animation.
///
/// **Actor is passive.** It does not trigger or control animations on its own.
/// All animation progress is driven externally by the nearest ancestor [Cue]
/// widget, which exposes a [CueScope] via [InheritedWidget]. Actor reads that
/// scope and reacts to it. Without an ancestor [Cue], an Actor has no effect.
///
/// The typical pattern is:
/// ```dart
/// Cue.onToggle(
///   toggled: isExpanded,
///   motion: .smooth(),
///   child: Actor(
///     acts: [.fadeIn(), .slideUp()],
///     child: MyWidget(),
///   ),
/// )
/// ```
///
/// ## Motion
///
/// Motion controls the timing and easing of all acts within this Actor.
/// The resolution order is:
///
/// 1. If an individual act specifies its own `motion`, that is used for that act including both forward and reverse motion unless specified.
/// 2. Otherwise, the Actor's [motion] is used as the default for all acts.
/// 3. If [motion] is null, the Actor inherits from the parent [Cue] widget. -> timeline.defaultConfig
///
/// **Reverse motion follows the same rule independently.**
/// If [reverseMotion] is not provided, [motion] doubles as the reverse motion too.
/// Reverse motion is NOT inherited from the parent [Cue] widget when [motion]
/// is explicitly set — [motion] is used for both directions unless [reverseMotion]
/// is explicitly specified.
///
/// ```dart
/// // motion: CueMotion.smooth() applies to both forward and reverse
/// Actor(
///   motion: .smooth(),
///   acts: [.fadeIn(), .slideUp()],
///   child: MyWidget(),
/// )
///
/// // Different timing for forward and reverse
/// Actor(
///   motion: .smooth(),
///   reverseMotion: .linear(200.ms),
///   acts: [.fadeIn(), .slideUp()],
///   child: MyWidget(),
/// )
///
/// // An individual act can override the Actor's motion
/// Actor(
///   motion: .smooth(),           // default for all acts
///   acts: [
///     .fadeIn(),                               // uses .smooth() for both directions
///     .scale(to: 1.1, motion: .bouncy()),      // overrides with its own motion
///   ],
///   child: MyWidget(),
/// )
/// ```
///
/// ## Default `from` values
///
/// Most acts have sensible identity defaults for `from`, so you rarely need to
/// specify it explicitly:
/// - Transform acts (`.scale`, `.rotate`, `.translate`, etc.) default to identity (no transform)
/// - `.opacity` defaults to `from: 1.0`; `.fadeIn()` defaults to `from: 0.0`
/// - `.blur` defaults to `from: 0.0`
///
/// When no meaningful identity exists, `from` is required by the act's constructor.
///
/// ## Rules
///
/// **Only one Act of each type (key) may be used per Actor.** Using two Acts with
/// the same key throws a [StateError] at runtime. Note that some seemingly
/// different acts share a key — all slide variants (`.slide()`, `.slideX()`,
/// `.slideY()`, `.slideUp()`, etc.) share the same key and **cannot be combined**:
///
/// ```dart
/// // Not allowed — duplicate ScaleAct
/// Actor(acts: [.scale(to: 1.2), .scale(to: 0.8)], child: widget)
///
/// // Not allowed — slideUp and slideY share the same key
/// Actor(acts: [.slideUp(), .slideY(from: -0.5)], child: widget)
/// ```
///
/// ## Shorthand factory constructors
///
/// Acts can be created via shorthand `Act.` factories or direct class constructors:
///
/// ```dart
/// Actor(
///   acts: [
///     .scale(from: 0.8),  // to: 1.0 is default
///     .fadeIn(),
///     .slideUp(),
///     .blur(from: 8),     // to: 0.0 is default
///   ],
///   child: MyWidget(),
/// )
/// ```
///
/// ## Keyframe animations
///
/// Acts support keyframed sequences via [Keyframes] or [Keyframes.fractional].
/// Use the `.key()` shorthand constructor for a more readable syntax.
/// Each key represents a **target value** to animate towards, not a starting point.
///
/// ```dart
/// // Motion-based keyframes — motion is required at the Keyframes level;
/// // per-frame motion is an optional override.
/// Actor(
///   acts: [
///     TranslateAct.keyframed(
///       frames: Keyframes([
///         .key(Offset(100, 0)),                    // uses Keyframes-level motion
///         .key(Offset.zero, motion: .bouncy()),    // per-frame override
///       ], motion: .smooth()),
///     ),
///   ],
///   child: MyWidget(),
/// )
/// ```
///
/// For acts with no implicit starting value (e.g. `SizedBoxAct`), the first key
/// defines the initial value — it is not animated to; it is the starting point.
/// Any motion on the first key is ignored:
///
/// ```dart
/// Actor(
///   acts: [
///     SizedBoxAct.keyframed(
///       frames: Keyframes([
///         .key(Size(80, 80)),     // initial value, not animated to
///         .key(Size(200, 80)),
///         .key(Size(80, 80)),
///       ], motion: .smooth()),
///     ),
///   ],
///   child: MyWidget(),
/// )
/// ```
///
/// ```dart
/// // Fractional keyframes — frames positioned at fractions of the total duration.
/// // An optional curve can be set at the Keyframes level (applies to all frames)
/// // or at the individual key level (overrides the Keyframes-level curve for that frame).
/// Actor(
///   acts: [
///     TranslateAct.keyframed(
///       frames: Keyframes.fractional([
///         .key(Offset(100, 0), at: 0.5),
///         .key(Offset.zero, at: 1.0, curve: Curves.easeOut),  // per-frame override
///       ], curve: Curves.easeIn),  // default curve for all frames
///     ),
///   ],
///   child: MyWidget(),
/// )
/// ```
///
/// ## Delays
///
/// [delay] and [reverseDelay] set a base time offset for this Actor. Any delay
/// on an individual act is **added on top** of the Actor's delay:
///
/// ```dart
/// // Actor delay: 100ms, act delay: 200ms → act plays after 300ms total
/// Actor(
///   delay: 100.ms,
///   acts: [
///     .fadeIn(delay: 200.ms),   // plays after 300ms
///     .slideUp(),               // plays after 100ms (Actor delay only)
///   ],
///   child: Item(),
/// )
/// ```
///
/// ## Animation cache
///
/// Actor maintains an internal cache of built animations keyed by [ActKey].
/// Animations are only rebuilt when the corresponding act or its configuration
/// actually changes — if an act is identical to its previous value, the cached
/// animation is reused. Acts removed from the list have their animations released
/// immediately.
///
/// When `fromCurrentValue: true` is set on [Cue.onChange], Actor captures the
/// current animated value of each act just before a re-animation begins and
/// passes it as the implicit `from` to the new animation. This ensures smooth
/// transitions when acts change mid-flight without a visible jump.
class Actor extends StatefulWidget {
  /// The list of animation acts to apply to [child].
  ///
  /// **Each Act type must appear at most once.** Duplicates of the same type
  /// (e.g. two [ScaleAct]s) will throw a [StateError] at runtime.
  final List<Act> acts;

  /// The widget to animate.
  final Widget child;

  /// Optional motion override for all acts in this Actor.
  /// When null, inherits the parent [Cue] widget's motion.
  final CueMotion? motion;

  /// Optional motion override for the reverse pass.
  /// When null, falls back to [motion], then to the parent's reverse motion.
  final CueMotion? reverseMotion;

  /// Delay before the forward animation starts.
  final Duration delay;

  /// Delay before the reverse animation starts.
  final Duration reverseDelay;

  /// Wraps the animated widget in a [RepaintBoundary].
  ///
  /// Defaults to `false`. When multiple Actors animate within the same widget
  /// subtree, it is more efficient to wrap the entire section in a single
  /// [RepaintBoundary] at a higher level rather than adding one per Actor.
  /// Adding too many repaint boundaries can backfire — each boundary introduces
  /// its own compositing layer, which increases memory usage and layer traversal
  /// overhead. Only set this to `true` for isolated, expensive widgets that
  /// animate independently of their surroundings.
  final bool addRepaintBoundary;

  const Actor({
    super.key,
    required this.acts,
    required this.child,
    this.motion,
    this.reverseMotion,
    this.delay = Duration.zero,
    this.reverseDelay = Duration.zero,
    this.addRepaintBoundary = false,
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
          cacheEntry.animation.release();
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
        scope.controller.timeline,
        actContext.copyWith(
          textDirection: textDirection,
          implicitFrom: implicitFrom,
        ),
      );
      if (existing?.animation case final animation?) {
        animation.release();
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
      _resolveActs(scope.controller.timeline.defaultConfig);
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
              reverseMotion: widget.reverseMotion ?? widget.motion ?? mainConfig.reverseMotion,
              delay: widget.delay,
              reverseDelay: widget.reverseDelay,
            ),
          ),
        ),
    ];
  }

  void _clearCache(CueScope scope) {
    for (final entry in _animations.values) {
      entry.animation.release();
    }
    _animations.clear();
    _animationSnapshots.clear();
  }

  EventDisposer? _eventsDisposer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = CueScope.of(context);
    if (_cachedScope?.controller != scope.controller) {
      _eventsDisposer?.call();
      _eventsDisposer = scope.controller.addEventListener<TimelineEvent>((_) => _onWillAnimate());
    }
    if (_cachedScope?.controller != scope.controller) {
      _resolveActs(scope.controller.timeline.defaultConfig);
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
    if (widget.addRepaintBoundary) {
      return RepaintBoundary(child: current);
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
  Object? get value => animation.value;
}

/// A convenience base class for widgets that wrap a single [Act] in an [Actor].
///
/// Provides the same interface as [Actor] but for a single act type,
/// avoiding the need to manually construct an Actor with a one-item list.
///
/// Supports both tween-based and [Keyframes]-based construction.
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

extension ActorExtenstion on Widget {
  Widget act(
    List<Act> acts, {
    CueMotion? motion,
    CueMotion? reverseMotion,
    Duration delay = Duration.zero,
    Duration reverseDelay = Duration.zero,
  }) {
    return Actor(
      motion: motion,
      reverseMotion: reverseMotion,
      delay: delay,
      reverseDelay: reverseDelay,
      acts: acts,
      child: this,
    );
  }
}
