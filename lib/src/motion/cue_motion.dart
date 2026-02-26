import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

class CueAnimationController extends AnimationController {
  CueSimulation? simulation;
  CueSimulation? reverseSimulation;

  CueAnimationController({
    required Duration super.duration,
    super.reverseDuration,
    super.debugLabel,
    super.value = 0.0,
    super.lowerBound,
    super.upperBound,
    super.animationBehavior,
    required super.vsync,
  }) : simulation = null,
       reverseSimulation = null;

  bool get isBounded => lowerBound != double.negativeInfinity && upperBound != double.infinity;

  CueAnimationController.withSimulation({
    required CueSimulation this.simulation,
    this.reverseSimulation,
    super.duration,
    super.debugLabel,
    super.animationBehavior,
    super.value,
    required super.vsync,
  }) : super.unbounded();

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

  TickerFuture playForward({double? from}) {
    if (isCompleted) reset();
    if (simulation case final simulation?) {
      if (from != null) {
        value = from;
      }
      return animateWith(_createSimulation(simulation, true));
    } else {
      return super.forward(from: from);
    }
  }

  TickerFuture playReverse() {
    if (isDismissed) value = 1.0;
    final effectiveSim = reverseSimulation ?? simulation;
    if (effectiveSim case final effectiveSim?) {
      return animateWith(_createSimulation(effectiveSim, false));
    } else {
      return super.reverse();
    }
  }

  void playLoop({bool reverseOnLoop = false, int? count}) {
    if (simulation == null) {
      super.repeat(reverse: reverseOnLoop, count: count);
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
          if (reverseOnLoop) {
            playReverse();
          } else {
            playForward();
          }
        } else if (status == AnimationStatus.dismissed && reverseOnLoop) {
          playForward();
        }
      };
      addStatusListener(_statusListener!);
      playForward();
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
