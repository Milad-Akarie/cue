import 'package:cue/src/motion/cue_motion.dart';
import 'package:cue/src/motion/timeline.dart';
import 'package:flutter/material.dart';

class CueAnimationController extends AnimationController {
  CueMotion _motion;
  CueMotion? _reverseMotion;
  final double _lowerBound;
  final double _upperBound;
  final CueTimelineImpl _timline;

  CueTimeline get timline => _timline;

  @override
  double get lowerBound {
    return _motion.isSimulation ? double.negativeInfinity : _lowerBound;
  }

  @override
  double get upperBound {
    return _motion.isSimulation ? double.infinity : _upperBound;
  }

  set motion(CueMotion newValue) {
    if (_motion != newValue) {
      _motion = newValue;
      if (newValue is TimedMotion) {
        // duration = newValue.duration;
        // reverseDuration = newValue.reverseDuration;
      }
    }
  }

  CueAnimationController({
    required CueMotion motion,
    CueMotion? reverseMotion,
    super.debugLabel,
    super.value = 0.0,
    double lowerBound = 0.0,
    double upperBound = 1.0,
    super.animationBehavior,
    required super.vsync,
  }) : _motion = motion,
       _reverseMotion = reverseMotion,
       _lowerBound = lowerBound,
       _upperBound = upperBound,
       _timline = CueTimelineImpl(
         CueAnimationDriverImpl(
           motion,
           reverseMotion: reverseMotion,
         ),
       );

  bool get usesSimulation => _motion.isSimulation;

  AnimationStatusListener? _statusListener;

  @override
  void dispose() {
    if (_statusListener != null) {
      removeStatusListener(_statusListener!);
    }
    super.dispose();
  }

  @override
  Animation<double> get view => _timline.mainAnimation;

  @override
  TickerFuture forward({double? from}) {
    if (from != null) {
      value = from;
    }
    _timline.prepare(forward: true);
    return super.animateWith(_timline);
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
  TickerFuture reverse({double? from}) {
    if (from != null) {
      value = from;
    }
    _timline.prepare(forward: false);
    return super.animateBackWith(_timline);
  }

  @override
  void reset() {
    value = _lowerBound;
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
