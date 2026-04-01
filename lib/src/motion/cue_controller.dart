import 'package:cue/cue.dart';
import 'package:cue/src/timeline/track/track.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

class CueController extends AnimationController {
  final CueTimeline _timeline;

  CueTimeline get timeline => _timeline;

  CueController({
    super.debugLabel,
    super.value = 0.0,
    super.animationBehavior,
    required super.vsync,
    required CueMotion motion,
    CueMotion? reverseMotion,
  }) : _timeline = CueTimelineImpl(
         TrackConfig(
           motion: motion,
           reverseMotion: reverseMotion ?? motion,
         ),
       ),
       super.unbounded();

  void updateMotion(CueMotion newMotion, {CueMotion? reverseMotion}) {
    final mainTrack = timeline.mainTrack;
    if (newMotion != mainTrack.motion || reverseMotion != mainTrack.reverseMotion) {
      timeline.resetTracks(TrackConfig(motion: newMotion, reverseMotion: reverseMotion ?? newMotion));
    }
  }

  (CueTrack, ReleaseToken) obtainTrack({
    CueMotion? motion,
    CueMotion? reverseMotion,
    ReverseBehaviorType reverseType = ReverseBehaviorType.mirror,
  }) {
    final mainConfig = timeline.mainTrack.config;
    return timeline.obtainTrack(
      TrackConfig(
        motion: motion ?? mainConfig.motion,
        reverseMotion: reverseMotion ?? mainConfig.reverseMotion,
        reverseType: reverseType,
      ),
    );
  }

  CueAnimation<T> createAnimation<T>({
    CueMotion? motion,
    CueMotion? reverseMotion,
    ReverseBehaviorType reverseType = ReverseBehaviorType.mirror,
    required Animatable<T> tween,
  }) {
    final (track, token) = obtainTrack(
      motion: motion,
      reverseMotion: reverseMotion,
      reverseType: reverseType,
    );
    return CueAnimationImpl<T>(
      parent: track,
      token: token,
      animtable: TweenAnimtable<T>(tween),
    );
  }

  RetargetableCueAnimation<T> createRetargetable<T>({
    CueMotion? motion,
    CueMotion? reverseMotion,
    ReverseBehaviorType reverseType = ReverseBehaviorType.mirror,
    required T initialValue,
  }) {
    final (track, token) = obtainTrack(
      motion: motion,
      reverseMotion: reverseMotion,
      reverseType: reverseType,
    );
    return RetargetableCueAnimation<T>(
      parent: track,
      token: token,
      controller: this,
      initialValue: initialValue,
    );
  }

  @override
  void dispose() {
    _timeline.dispose();
    super.dispose();
  }

  @override
  set duration(Duration? value) {
    throw UnsupportedError(
      'Cannot set duration on CueController. Duration is derived from the timeline.',
    );
  }

  @override
  set reverseDuration(Duration? value) {
    throw UnsupportedError(
      'Cannot set reverseDuration on CueController. reverseDuration is derived from the timeline.',
    );
  }

  @override
  Duration get duration {
    final microseconds = _timeline.forwardDuration * Duration.microsecondsPerSecond;
    return Duration(microseconds: microseconds.round());
  }

  @override
  Duration get reverseDuration {
    final microseconds = _timeline.reverseDuration * Duration.microsecondsPerSecond;
    return Duration(microseconds: microseconds.round());
  }

  @override
  set value(double newValue) {
    setProgress(newValue.clamp(0, 1), forward: status.isForwardOrCompleted);
  }

  void setProgress(double newValue, {bool forward = true}) {
    assert(newValue >= 0.0 && newValue <= 1.0, 'The animation value must be between 0.0 and 1.0. Received: $newValue');
    timeline.setProgress(newValue, forward: forward);
    super.value = newValue;
  }

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

  @override
  Animation<double> get view => _timeline.mainTrack;

  @override
  @override
  TickerFuture forward({double? from}) {
    _timeline.willAnimate(forward: true);
    if (from != null) {
      assert(from >= 0.0 && from <= 1.0, 'The "from" value must be between 0.0 and 1.0. Received: $from');
    }
    _timeline.prepare(forward: true, from: from);
    if (from != null) {
      super.value = from;
    }
    return super.animateWith(_timeline);
  }

  @override
  TickerFuture reverse({double? from}) {
    _timeline.willAnimate(forward: false);
    if (from != null) {
      assert(from >= 0.0 && from <= 1.0, 'The "from" value must be between 0.0 and 1.0. Received: $from');
    }
    _timeline.prepare(forward: false, from: from);
    if (from != null) {
      super.value = from;
    }
    return super.animateBackWith(_timeline);
  }

  @override
  TickerFuture animateWith(Simulation simulation) {
    throw UnsupportedError('animateWith is not supported by CueController. Use forward instead.');
  }

  @override
  TickerFuture animateBackWith(Simulation simulation) {
    throw UnsupportedError('animateBackWith is not supported by CueController. Use reverse instead.');
  }

  @override
  void reset() {
    timeline.reset();
    super.value = 0.0;
  }

  @override
  TickerFuture repeat({double? min, double? max, bool reverse = false, int? count, Duration? period}) {
    if (period != null) {
      throw UnsupportedError(
        'CueController does does not support time-based repetitio because physics-based animations is a first-class citizen. You may only specify count and reverse parameters. Received: period: $period',
      );
    }
    assert(min == null || (min >= 0.0 && min <= 1.0), 'The "min" value must be between 0.0 and 1.0. Received: $min');
    assert(max == null || (max >= 0.0 && max <= 1.0), 'The "max" value must be between 0.0 and 1.0. Received: $max');

    assert(count == null || count > 0, 'The "count" value must be greater than 0. Received: $count');
    _timeline.willAnimate(forward: true);
    _timeline.prepareForRepeat(RepeatConfig(reverse: reverse, count: count, from: min, target: max));
    return super.animateWith(_timeline);
  }

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
    void listener() => timeline.setProgress(value.clamp(0, 1), forward: forward);
    addListener(listener);
    if (forward) {
      return super.animateWith(simulation)..whenComplete(() => removeListener(listener));
    } else {
      return super.animateBackWith(simulation)..whenComplete(() => removeListener(listener));
    }
  }
}
