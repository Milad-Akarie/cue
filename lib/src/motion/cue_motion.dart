import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

class CueAnimationController extends AnimationController {
  CueMotion _motion;
  final double _lowerBound;
  final double _upperBound;

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
        duration = newValue.duration;
        reverseDuration = newValue.reverseDuration;
      }
    }
  }

  CueAnimationController({
    required CueMotion motion,
    super.debugLabel,
    super.value = 0.0,
    double lowerBound = 0.0,
    double upperBound = 1.0,
    super.animationBehavior,
    required super.vsync,
  }) : _motion = motion,
       _lowerBound = lowerBound,
       _upperBound = upperBound {
    if (motion is TimedMotion) {
      duration = motion.duration;
      reverseDuration = motion.reverseDuration;
    }
  }

  bool get usesSimulation => _motion.isSimulation;

  AnimationStatusListener? _statusListener;

  @override
  void dispose() {
    if (_statusListener != null) {
      removeStatusListener(_statusListener!);
    }
    super.dispose();
  }

  Simulation _createSimulation(CueSimulation cueSimulation, bool forward) {
    return cueSimulation.build(
      SimulationBuildData(
        velocity: velocity,
        forward: forward,
        progress: value.clamp(0.0, 1.0),
      ),
    );
  }

  double get timingProgress {
    final elapsedTime = lastElapsedDuration!.inMicroseconds / 1000000.0;
    final durationSeconds = duration!.inMicroseconds / 1000000.0;
    return (elapsedTime / durationSeconds).clamp(0.0, 1.0);
  }

  @override
  TickerFuture forward({double? from}) {
    if (from != null) {
      value = from;
    }
    switch (_motion) {
      case TimedMotion m:
        return super.animateTo(_upperBound, curve: m.curve ?? Curves.linear);
      case SimulationMotion(simulation: final simulation):
        return animateWith(_createSimulation(simulation, true));
    }
  }

  @override
  TickerFuture reverse({double? from}) {
    if (from != null) {
      value = from;
    }

    switch (_motion) {
      case TimedMotion(curve: final curve, reverseCurve: final reverseCurve):
        return super.animateBack(_lowerBound, curve: reverseCurve ?? curve ?? Curves.linear);
      case SimulationMotion(reverse: final reverse, simulation: final simulation):
        final effectiveSim = reverse ?? simulation;
        return animateBackWith(_createSimulation(effectiveSim, false));
    }
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

sealed class CueMotion {
  const CueMotion();
  const factory CueMotion.timed(
    Duration duration, {
    Duration? reverseDuration,
    Curve? curve,
    Curve? reverseCurve,
  }) = TimedMotion;

  static const CueMotion defaultDuration = CueMotion.timed(
    Duration(milliseconds: 300),
  );

  const factory CueMotion.simulation(
    CueSimulation simulation, {
    CueSimulation? reverse,
  }) = SimulationMotion;

  bool get isTimed => this is TimedMotion;
  bool get isSimulation => this is SimulationMotion;
}

class TimedMotion extends CueMotion {
  final Duration duration;
  final Duration? reverseDuration;
  final Curve? curve;
  final Curve? reverseCurve;
  const TimedMotion(this.duration, {this.reverseDuration, this.curve, this.reverseCurve});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimedMotion &&
          runtimeType == other.runtimeType &&
          duration == other.duration &&
          reverseDuration == other.reverseDuration &&
          curve == other.curve &&
          reverseCurve == other.reverseCurve;

  @override
  int get hashCode => duration.hashCode ^ reverseDuration.hashCode ^ curve.hashCode ^ reverseCurve.hashCode;

  Animation<double> applyCurve(Animation<double> animation, {bool reverse = false}) {
    final curve = reverse ? reverseCurve : this.curve;
    if (curve case final curve?) {
      return CurvedAnimation(parent: animation, curve: curve);
    } else {
      return animation;
    }
  }
}

class SimulationMotion extends CueMotion {
  final CueSimulation simulation;
  final CueSimulation? reverse;
  const SimulationMotion(this.simulation, {this.reverse});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SimulationMotion &&
          runtimeType == other.runtimeType &&
          simulation == other.simulation &&
          reverse == other.reverse;

  @override
  int get hashCode => simulation.hashCode ^ reverse.hashCode;
}
