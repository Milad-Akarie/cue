import 'package:cue/cue.dart';
import 'package:cue/src/acts/base/tween_act.dart';
import 'package:cue/src/timeline/event_notifier.dart';
import 'package:cue/src/timeline/track/track.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

/// An [AnimationController] that drives animations through a [CueTimeline].
///
/// Extends Flutter's [AnimationController] with Cue's motion and track system.
/// Duration is derived entirely from the timeline—setting it directly is not
/// supported.
///
/// ```dart
/// final controller = CueController(vsync: this, motion: .smooth());
/// ```
///
/// **Tracks**: The timeline manages multiple tracks, each with its own motion.
/// Tracks use the controller's default motion unless overridden. Obtain a track
/// with [obtainTrack], [tweenTrack], or [keyframedTrack].
///
/// **Track lifecycle**: Each call to [obtainTrack] returns a [ReleaseToken].
/// Call [ReleaseToken.release] when the track is no longer needed. The track
/// is only removed from the timeline once all tokens for it are released.
///
/// **Rebuilding the timeline**: If the default motion changes (e.g., after a
/// widget rebuild with a new [Spring]), call [rebuildTimeline]. All previously
/// obtained tracks become stale after a rebuild—including those with their own
/// motion override—and must be re-obtained.
///
/// Cue widgets handle all of this seamlessly. If using the controller manually,
/// be aware of track staleness after rebuilds.
class CueController extends AnimationController {
  late CueTimeline _timeline;

  /// The managed Cue timeline.
  CueTimeline get timeline => _timeline;

  /// Creates a controller with a Cue timeline.
  ///
  /// - [motion]: Default forward motion for all tracks.
  /// - [reverseMotion]: Default reverse motion. Falls back to [motion] if not provided.
  CueController({
    super.debugLabel,
    super.value = 0.0,
    super.animationBehavior,
    required super.vsync,
    required CueMotion motion,
    CueMotion? reverseMotion,
  }) : assert(value >= 0.0 && value <= 1.0, 'The initial value must be between 0.0 and 1.0. Received: $value'),
       _timeline = CueTimelineImpl(
         TrackConfig(
           motion: motion,
           reverseMotion: reverseMotion ?? motion,
         ),
         initialProgress: value,
       ),
       super.unbounded();

  /// Rebuilds the timeline with a new default motion.
  ///
  /// Disposes the current timeline and creates a new one with [newMotion].
  /// **All previously obtained tracks become stale** after this call—including
  /// tracks with their own motion override—and will no longer tick.
  /// Re-obtain all tracks after rebuilding.
  ///
  /// Cue widgets call this automatically when their motion input changes.
  /// Only call this manually if managing tracks outside of Cue widgets.
  void rebuildTimeline(CueMotion newMotion, {CueMotion? reverseMotion, bool keepProgress = true}) {
    final progress = keepProgress ? _timeline.progress : null;
    _timeline.dispose();
    _timeline = CueTimelineImpl(
      TrackConfig(
        motion: newMotion,
        reverseMotion: reverseMotion ?? newMotion,
      ),
    );
    if (progress != null) {
      _timeline.setProgress(progress, forward: progress > 0.0);
    }
  }

  /// Obtains a raw [CueTrack] from the timeline.
  ///
  /// Low-level API. If a track with the given configuration already exists,
  /// returns the existing track; otherwise creates a new one. In both cases,
  /// returns a [ReleaseToken] that must be released when the track is no
  /// longer needed. The track is removed from the timeline only when all
  /// tokens for it are released.
  ///
  /// Prefer [tweenTrack] or [keyframedTrack] over this method when building
  /// typed animations.
  (CueTrack, ReleaseToken) obtainTrack({
    CueMotion? motion,
    CueMotion? reverseMotion,
    ReverseBehaviorType reverseType = ReverseBehaviorType.mirror,
  }) {
    final defaultConfig = timeline.defaultConfig;
    return timeline.obtainTrack(
      TrackConfig(
        motion: motion ?? defaultConfig.motion,
        reverseMotion: reverseMotion ?? defaultConfig.reverseMotion,
        reverseType: reverseType,
      ),
    );
  }

  /// Creates a [CueAnimation] that animates between [from] and [to].
  ///
  /// Obtains a track with the given motion and builds a typed animation over
  /// the provided value range. Release the animation when done via
  /// [CueAnimation.release], which releases the underlying track token.
  ///
  /// - [from], [to]: The value range to animate.
  /// - [motion], [reverseMotion]: Override the default track motion.
  /// - [reverse]: Controls animation behavior when reversing.
  /// - [delay]: Delay before the animation starts.
  /// - [tweenBuilder]: Custom tween factory (e.g., `ColorTween.new`).
  CueAnimation<T> tweenTrack<T>({
    CueMotion? motion,
    CueMotion? reverseMotion,
    ReverseBehavior<T> reverse = const ReverseBehavior.mirror(),
    required T from,
    required T to,
    Duration delay = Duration.zero,
    TweenBuilder<T>? tweenBuilder,
  }) {
    final defaultConfig = timeline.defaultConfig;
    final context = TweenActBase.resolveMotion(
      ActContext(
        motion: motion ?? defaultConfig.motion,
        reverseMotion: reverseMotion ?? defaultConfig.reverseMotion,
      ),
      delay: delay,
      reverse: reverse,
    );

    final (track, token) = timeline.obtainTrack(
      TrackConfig(
        motion: context.motion,
        reverseMotion: context.reverseMotion,
        reverseType: reverse.type,
      ),
    );

    final builder = CueTweenBuildHelper(
      from: from,
      to: to,
      reverse: reverse,
      tweenBuilder: (from, to) {
        return tweenBuilder?.call(begin: from, end: to) ?? Tween<T>(begin: from, end: to);
      },
    );

    return CueAnimationImpl<T>(
      parent: track,
      token: token,
      animtable: builder.buildAnimtable(context),
    );
  }

  /// Creates a [CueAnimation] that animates through a sequence of keyframes.
  ///
  /// Similar to [tweenTrack] but accepts [Keyframes<T>] instead of a single
  /// from/to pair. Each keyframe defines a segment of the animation, driven
  /// by [SegmentedSimulation] and evaluated via [SegmentedAnimtable].
  /// Release the animation when done via [CueAnimation.release].
  ///
  /// - [frames]: The keyframe sequence to animate through.
  /// - [reverse]: Controls behavior when reversing.
  /// - [delay]: Delay before the animation starts.
  /// - [tweenBuilder]: Custom tween factory (e.g., `ColorTween.new`).
  CueAnimation<T> keyframedTrack<T>({
    KFReverseBehavior<T> reverse = const KFReverseBehavior.mirror(),
    required Keyframes<T> frames,
    Duration delay = Duration.zero,
    TweenBuilder<T>? tweenBuilder,
  }) {
    final defaultConfig = timeline.defaultConfig;
    final context = TweenActBase.resolveMotion(
      ActContext(
        motion: defaultConfig.motion,
        reverseMotion: defaultConfig.reverseMotion,
      ),
      delay: delay,
      reverse: reverse,
      frames: frames,
    );

    final (track, token) = timeline.obtainTrack(
      TrackConfig(
        motion: context.motion,
        reverseMotion: context.reverseMotion,
        reverseType: reverse.type,
      ),
    );

    final builder = CueTweenBuildHelper(
      frames: frames,
      reverse: reverse,
      tweenBuilder: (from, to) {
        return tweenBuilder?.call(begin: from, end: to) ?? Tween(begin: from, end: to);
      },
    );

    return CueAnimationImpl<T>(
      parent: track,
      token: token,
      animtable: builder.buildAnimtable(context),
    );
  }

  @override
  void dispose() {
    _timeline.dispose();
    super.dispose();
  }

  /// Not supported. Duration is derived from the timeline's motion.
  ///
  /// Configure duration by setting motion on the track or controller.
  @override
  set duration(Duration? value) {
    throw UnsupportedError(
      'Cannot set duration on CueController. Duration is derived from the timeline.',
    );
  }

  /// Not supported. Reverse duration is derived from the timeline's reverse motion.
  ///
  /// Configure reverse duration by setting [reverseMotion] on the track or controller.
  @override
  set reverseDuration(Duration? value) {
    throw UnsupportedError(
      'Cannot set reverseDuration on CueController. reverseDuration is derived from the timeline.',
    );
  }

  /// The forward animation duration, derived from the timeline's forward motion.
  @override
  Duration get duration {
    final microseconds = _timeline.forwardDuration * Duration.microsecondsPerSecond;
    return Duration(microseconds: microseconds.round());
  }

  /// The reverse animation duration, derived from the timeline's reverse motion.
  @override
  Duration get reverseDuration {
    final microseconds = _timeline.reverseDuration * Duration.microsecondsPerSecond;
    return Duration(microseconds: microseconds.round());
  }

  /// Jumps to [newValue] instantly, clamped to [0, 1].
  ///
  /// Delegates to [setProgress], preserving the current forward/reverse
  /// direction based on [status].
  @override
  set value(double newValue) {
    setProgress(newValue.clamp(0, 1), forward: status.isForwardOrCompleted);
  }

  /// Sets the animation progress directly, typically for scrubbing.
  ///
  /// - [newValue]: Progress in [0, 1].
  /// - [forward]: Whether progress is interpreted as moving forward. Affects
  ///   which motion (forward or reverse) is used for track evaluation.
  /// - [forceLinear]: Bypasses curves/physics for direct linear interpolation.
  ///   Use this for drag-based scrubbing where you want raw positional control.
  void setProgress(double newValue, {bool forward = true, bool forceLinear = false}) {
    assert(newValue >= 0.0 && newValue <= 1.0, 'The animation value must be between 0.0 and 1.0. Received: $newValue');
    timeline.setProgress(newValue, forward: forward, forceLinear: forceLinear);
    super.value = newValue;
  }

  @override
  double get value => timeline.progress;

  @override
  AnimationStatus get status => timeline.status;

  @override
  void addStatusListener(AnimationStatusListener listener) {
    timeline.addStatusListener(listener);
  }

  @override
  void removeStatusListener(AnimationStatusListener listener) {
    timeline.removeStatusListener(listener);
  }

  /// Subscribes to Cue-specific [TimelineEvent]s from the timeline.
  ///
  /// Returns an [EventDisposer] to cancel the subscription.
  EventDisposer addEventListener<T extends TimelineEvent>(ValueChanged<T> listener) {
    return timeline.addEventListener<T>(listener);
  }

  ReleaseToken? _viewReleaseToken;

  /// The raw default track as an `Animation<double>`.
  ///
  /// **Avoid calling this directly.** This exists solely for compatibility with
  /// unowned Flutter APIs that require an `Animation<double>` (e.g., some
  /// third-party widgets), where you have no control over how the animation is
  /// consumed.
  ///
  /// For typed value animations, use [tweenTrack] or [keyframedTrack] instead and
  /// listen to the returned [CueAnimation]. Repeated calls to [view] release the
  /// previously obtained track token and re-obtain a new one, which may cause
  /// the prior track to stop ticking if it had no other token holders.
  @override
  Animation<double> get view {
    if (_viewReleaseToken != null) {
      _viewReleaseToken!.release();
    }
    final (track, token) = timeline.obtainDefaultTrack();
    _viewReleaseToken = token;
    return track;
  }

  /// Starts the animation in the forward direction.
  ///
  /// - [from]: Optional starting progress (0→1).
  /// - [velocity]: Optional initial velocity for spring-based motions.
  @override
  TickerFuture forward({double? from, double? velocity}) {
    _timeline.willAnimate(forward: true);
    if (from != null) {
      assert(from >= 0.0 && from <= 1.0, 'The "from" value must be between 0.0 and 1.0. Received: $from');
    }
    _timeline.prepare(forward: true, from: from, velocity: velocity);
    return super.animateWith(_timeline);
  }

  /// Starts the animation in the reverse direction.
  ///
  /// - [from]: Optional starting progress (0→1).
  /// - [velocity]: Optional initial velocity for spring-based motions.
  @override
  TickerFuture reverse({double? from, double? velocity}) {
    _timeline.willAnimate(forward: false);
    if (from != null) {
      assert(from >= 0.0 && from <= 1.0, 'The "from" value must be between 0.0 and 1.0. Received: $from');
    }
    _timeline.prepare(forward: false, from: from, velocity: velocity);
    return super.animateBackWith(_timeline);
  }

  /// Not supported. Use [forward] to drive the Cue timeline.
  @override
  TickerFuture animateWith(Simulation simulation) {
    throw UnsupportedError('animateWith is not supported by CueController. Use forward instead.');
  }

  /// Not supported. Use [reverse] to drive the Cue timeline.
  @override
  TickerFuture animateBackWith(Simulation simulation) {
    throw UnsupportedError('animateBackWith is not supported by CueController. Use reverse instead.');
  }

  /// Resets the animation to 0 and stops any in-flight animation.
  ///
  /// Also resets the timeline's internal state (e.g., phase and track progress).
  @override
  void reset() {
    timeline.reset();
    super.value = 0.0;
  }

  /// Repeats the animation [count] times.
  ///
  /// - [min], [max]: Optional progress range for the repeat cycle.
  /// - [reverse]: If `true`, alternates direction each cycle.
  /// - [count]: Number of repetitions. Loops indefinitely if `null`.
  ///
  /// **Note**: The [period] parameter is not supported because Cue treats
  /// physics-based animations as first-class—duration is always derived from
  /// the motion, not set externally.
  @override
  TickerFuture repeat({double? min, double? max, bool reverse = false, int? count, Duration? period}) {
    if (period != null) {
      throw UnsupportedError(
        'CueController does not support time-based repetition because physics-based animations are first-class. You may only specify count and reverse parameters. Received: period: $period',
      );
    }
    assert(min == null || (min >= 0.0 && min <= 1.0), 'The "min" value must be between 0.0 and 1.0. Received: $min');
    assert(max == null || (max >= 0.0 && max <= 1.0), 'The "max" value must be between 0.0 and 1.0. Received: $max');

    assert(count == null || count > 0, 'The "count" value must be greater than 0. Received: $count');
    _timeline.willAnimate(forward: true);
    _timeline.prepareForRepeat(RepeatConfig(reverse: reverse, count: count, from: min, target: max));
    return super.animateWith(_timeline);
  }

  /// Animates to a progress [target] using the configured motion.
  ///
  /// - [target]: Progress value in [0, 1] to animate toward.
  /// - [forward]: Direction override. Inferred from [target] vs current [value] if `null`.
  ///
  /// **Note**: The [duration] and [curve] parameters from [AnimationController.animateTo]
  /// are **ignored**. Motion characteristics are configured per track via [CueMotion],
  /// not through this method.
  @override
  TickerFuture animateTo(double target, {bool? forward, Duration? duration, Curve curve = Curves.linear}) {
    if (duration != null || curve != Curves.linear) {
      assert(() {
        debugPrint(
          'CueController: duration and curve parameters in animateTo are ignored. Configure motion per track instead.',
        );
        return true;
      }());
    }
    assert(target >= 0.0 && target <= 1.0, 'The target value must be between 0.0 and 1.0. Received: $target');
    if (target == value) {
      return TickerFuture.complete();
    }
    forward ??= target > value;
    _timeline.willAnimate(forward: forward);
    _timeline.prepare(forward: forward, target: target);
    if (forward) {
      return super.animateWith(_timeline);
    } else {
      return super.animateBackWith(_timeline);
    }
  }

  /// Drives the animation with a raw Flutter spring fling.
  ///
  /// This is a standard Flutter fling (not related to Cue's motion system or
  /// [Spring] presets). Useful for gesture-driven flings where an external
  /// velocity needs to carry the animation to its boundary.
  ///
  /// The fling drives the animation value toward 0 or 1 depending on [velocity]
  /// direction, and syncs progress to the Cue timeline at each frame.
  @override
  TickerFuture fling({
    double velocity = 1.0,
    SpringDescription? springDescription,
    AnimationBehavior? animationBehavior,
  }) {
    springDescription ??= SpringDescription.withDampingRatio(
      mass: 1.0,
      stiffness: 500.0,
    );
    final forward = velocity > 0.0;
    final tolarence = Tolerance(velocity: double.infinity, distance: 0.01);
    final double target = velocity < 0.0 ? 0.0 - tolarence.distance : 1.0 + tolarence.distance;
    final AnimationBehavior behavior = animationBehavior ?? this.animationBehavior;
    final double scale = switch (behavior) {
      // This is arbitrary (it was chosen because it worked for the drawer widget).
      AnimationBehavior.normal when SemanticsBinding.instance.disableAnimations => 200.0,
      AnimationBehavior.normal || AnimationBehavior.preserve => 1.0,
    };
    final simulation = SpringSimulation(springDescription, value, target, velocity * scale)..tolerance = tolarence;
    assert(
      simulation.type != SpringType.underDamped,
      'The specified spring simulation is of type SpringType.underDamped.\n'
      'An underdamped spring results in oscillation rather than a fling. '
      'Consider specifying a different springDescription, or use animateWith() '
      'with an explicit SpringSimulation if an underdamped spring is intentional.',
    );
    void listener() => timeline.setProgress(super.value.clamp(0, 1), forward: forward);
    addListener(listener);
    if (forward) {
      return super.animateWith(simulation)..whenComplete(() => removeListener(listener));
    } else {
      return super.animateBackWith(simulation)..whenComplete(() => removeListener(listener));
    }
  }
}
