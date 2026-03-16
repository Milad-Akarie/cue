import 'package:cue/src/motion/cue_motion.dart';
import 'package:cue/src/motion/timeline.dart';
import 'package:flutter/material.dart';

class CueAnimationController extends CueAnimationControllerBase<CuePlaybackTimeline> {
  CueAnimationController({
    required CueMotion motion,
    CueMotion? reverseMotion,
    required super.vsync,
    super.debugLabel,
  }) : super(
         timeline: CuePlaybackTimeline(
           CuePlaypackDriver(
             motion,
             reverseMotion: reverseMotion,
           ),
         ),
       );

  CueMotion get motion => timeline.mainDriver.motion;

  void updateMotion(CueMotion newMotion, {CueMotion? newReverseMotion}) {
    final mainDriver = timeline.mainDriver;
    if (newMotion != mainDriver.motion || newReverseMotion != mainDriver.reverseMotion) {
      timeline.reset(DriverConfig(motion: newMotion, reverseMotion: newReverseMotion));
    }
  }
 
}

class CueSeekableAnimationController extends CueAnimationControllerBase<CueSeekableTimeline> {
  CueSeekableAnimationController({
    super.debugLabel,
    required super.vsync,
    double initialProgress = 0.0,
    AnimationStatus status = AnimationStatus.forward,
  }) : super(timeline: CueSeekableTimeline(initialProgress, status: status));

  void seek(double progress, {AnimationStatus status = AnimationStatus.forward}) {
    timeline.seek(progress, status: status);
    value = progress;
  }

  @override
  TickerFuture forward({double? from}) {
    final progress = from ?? timeline.progress;
    return super.forward(from: progress);
  }

  @override
  TickerFuture reverse({double? from}) {
    final progress = from ?? timeline.progress;
    return super.reverse(from: progress);
  }
}

abstract class CueAnimationControllerBase<Timeline extends CueTimeline> extends AnimationController {
  final Timeline _timeline;

  Timeline get timeline => _timeline;

  CueAnimationControllerBase({
    super.debugLabel,
    super.value = 0.0,
    super.animationBehavior,
    required super.vsync,
    required Timeline timeline,
  }) : _timeline = timeline,
       super.unbounded();

  AnimationStatusListener? _statusListener;

  @override
  void dispose() {
    if (_statusListener != null) {
      removeStatusListener(_statusListener!);
    }
    super.dispose();
  }

  @override
  set value(double newValue) {
    super.value = newValue;
    timeline.setValue(newValue);
  }

  @override
  Animation<double> get view => _timeline.mainDriver;

  @override
  TickerFuture forward({double? from}) {
    if (from != null) {
      assert(from >= 0.0 && from <= 1.0, 'The "from" value must be between 0.0 and 1.0.');
      value = from;
    }
    _timeline.prepare(forward: true, from: from);
    return super.animateWith(_timeline);
  }

  @override
  TickerFuture reverse({double? from}) {
    if (from != null) {
      assert(from >= 0.0 && from <= 1.0, 'The "from" value must be between 0.0 and 1.0.');
      value = from;
    }
    _timeline.prepare(forward: false, from: value);
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
  void reset() {
    value = 0.0;
  }

  @override
  void stop({bool canceled = true}) {
    if (_statusListener != null) {
      removeStatusListener(_statusListener!);
    }
    super.stop(canceled: canceled);
  }

  @override
  TickerFuture repeat({double? min, double? max, bool reverse = false, int? count, Duration? period}) {
    if (_statusListener != null) {
      removeStatusListener(_statusListener!);
    }
    int loopCount = 0;
    _statusListener = (status) {
      if (status == AnimationStatus.completed) {
        loopCount++;
        if (count != null && loopCount >= count) {
          return;
        }
        if (reverse) {
          this.reverse();
        } else {
          forward();
        }
      } else if (status == AnimationStatus.dismissed && reverse) {
        forward();
      }
    };
    addStatusListener(_statusListener!);
    forward();
    return TickerFuture.complete();
  }
}
