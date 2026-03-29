import 'package:cue/src/motion/cue_motion.dart';
import 'package:cue/src/timeline/timeline.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/material.dart';

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
    bool progressDriven = false,
  }) : _timeline = CueTimelineImpl(
         TrackConfig(
           motion: motion,
           reverseMotion: reverseMotion ?? motion,
         ),
         progressDriven: progressDriven,
       ),
       super.unbounded();

  void updateMotion(CueMotion newMotion, {CueMotion? newReverseMotion}) {
    final mainTrack = timeline.mainTrack;
    if (newMotion != mainTrack.motion || newReverseMotion != mainTrack.reverseMotion) {
      timeline.resetTracks(TrackConfig(motion: newMotion, reverseMotion: newReverseMotion ?? newMotion));
    }
  }

  @override
  void dispose() {
    _timeline.dispose();
    super.dispose();
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
  TickerFuture forward({double? from}) {
    _timeline.willAnimate(forward: true);
    if (from != null) {
      assert(from >= 0.0 && from <= 1.0, 'The "from" value must be between 0.0 and 1.0. Received: $from');
      value = from;
    }
    _timeline.prepare(forward: true, from: from);
    return super.animateWith(_timeline);
  }

  @override
  TickerFuture reverse({double? from}) {
    _timeline.willAnimate(forward: false);
    if (from != null) {
      assert(from >= 0.0 && from <= 1.0, 'The "from" value must be between 0.0 and 1.0. Received: $from');
      value = from;
    }
    _timeline.prepare(forward: false, from: from);
    return super.animateBackWith(_timeline);
  }

  @override
  TickerFuture animateWith(Simulation simulation) {
    throw UnsupportedError('animateWith is not supported by CueAnimationController. Use forward instead.');
  }

  @override
  TickerFuture animateBackWith(Simulation simulation) {
    throw UnsupportedError('animateBackWith is not supported by CueAnimationController. Use reverse instead.');
  }

  @override
  void reset() => timeline.reset();

  @override
  TickerFuture repeat({double? min, double? max, bool reverse = false, int? count, Duration? period}) {
    if (period != null) {
      throw UnsupportedError(
        'CueController does does not support time-based repetitio because physics-based animations is a first-class citizen. You may only specify count and reverse parameters. Received: period: $period, min: $min, max: $max',
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
    if (duration != null) {
      throw UnsupportedError(
        'animateTo with duration is not supported by CueController. CueController is designed for physics-based animations and does not support time-based animations. Received: duration: $duration',
      );
    }
    if (curve != Curves.linear) {
      throw UnsupportedError(
        'animateTo with curve is not supported by CueController. CueController is designed to run muliple tracks, each with its own motion configuration, and does not support global curves. Received: curve: $curve',
      );
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

  // @override
  // TickerFuture fling({
  //   double velocity = 1.0,
  //   SpringDescription? springDescription,
  //   AnimationBehavior? animationBehavior,
  // }) {
  //   super.fling()
  //   throw UnsupportedError(
  //     'fling is not supported by CueController. Use forward or reverse instead.',
  //   );
  // }
}
