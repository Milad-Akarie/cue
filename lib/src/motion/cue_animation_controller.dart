import 'package:cue/src/motion/cue_motion.dart';
import 'package:cue/src/motion/simulations.dart';
import 'package:flutter/material.dart';

class CueAnimationController extends AnimationController {
  CueMotion _motion;
  CueMotion? _reverseMotion;
  final double _lowerBound;
  final double _upperBound;
  final AnimationsSetImpl _animationsSet;
  
  Timeline get animations => _animationsSet;

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
       _animationsSet = AnimationsSetImpl(
         SimulationAnimationImpl(
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
  TickerFuture forward({double? from}) {
    if (from != null) {
      value = from;
    }
    _animationsSet.prepare(forward: true, velocity: velocity);
    return animateWith(_animationsSet);
  }

  @override
  TickerFuture reverse({double? from}) {
    if (from != null) {
      value = from;
    }
    _animationsSet.prepare(forward: false, velocity: velocity);
    return animateBackWith(_animationsSet);
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
    if (_motion.isTimed) {
      assert(min == null || (min >= _lowerBound && min <= _upperBound));
      assert(max == null || (max >= _lowerBound && max <= _upperBound));
      return super.repeat(
        reverse: reverse,
        count: count,
        min: min ?? _lowerBound,
        max: max ?? _upperBound,
        period: period,
      );
    } else {
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
}
