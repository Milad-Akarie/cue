import 'package:cue/src/motion/simulations.dart';
import 'package:flutter/material.dart';

sealed class CueMotion {
  const CueMotion();

  BakedMotion bake({int samples = 60});

  Simulation build(bool forward, double progress, double? velocity);

  const factory CueMotion.timed(
    Duration duration, {
    Curve curve,
  }) = TimedMotion;

  static const CueMotion defaultDuration = CueMotion.timed(
    Duration(milliseconds: 300),
  );

  bool get isTimed => this is TimedMotion;
  bool get isSimulation => this is SimulationMotion;
}

class TimedMotion extends CueMotion {
  final Duration duration;
  final Curve? curve;
  const TimedMotion(this.duration, {this.curve});

  @override
  BakedMotion bake({int samples = 60}) {
    return BakedMotion(
      motion: this,
      samples: List.generate(samples, (i) => i / (samples - 1)),
      durationSeconds: duration.inMicroseconds / Duration.microsecondsPerSecond,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimedMotion && runtimeType == other.runtimeType && duration == other.duration && curve == other.curve;

  @override
  int get hashCode => duration.hashCode ^ curve.hashCode;

  @override
  Simulation build(bool forward, double progress, double? velocity) {
    return CurvedSimulation(
      duration: duration,
      curve: curve ?? Curves.linear,
      from: progress,
      to: forward ? 1.0 : 0.0,
    );
  }
}

class CurvedSimulation extends Simulation {
  final double _durationSeconds;
  final Curve _curve;
  final double _from;
  final double _to;

  CurvedSimulation({
    required Duration duration,
    required Curve curve,
    required double from,
    required double to,
  }) : _durationSeconds = duration.inMicroseconds / Duration.microsecondsPerSecond,
       _curve = curve,
       _from = from,
       _to = to;

  @override
  double x(double t) {
    final progress = (t / _durationSeconds).clamp(0.0, 1.0);
    return _from + (_to - _from) * _curve.transform(progress);
  }

  @override
  double dx(double t) => 0.0;

  @override
  bool isDone(double t) => t >= _durationSeconds;
}

abstract base class SimulationMotion<S extends Simulation> extends CueMotion {
  const SimulationMotion();
}

final class LinearSimulationMotion extends SimulationMotion<LinearSimulation> {
  const LinearSimulationMotion();

  @override
  BakedMotion bake({int samples = 60}) {
    return BakedMotion(
      motion: this,
      samples: const [],
      durationSeconds: 0.0,
      valueGetter: (progress, _) => progress,
    );
  }

  @override
  LinearSimulation build(bool forward, double progress, double? velocity) {
    return LinearSimulation();
  }
}

class LinearSimulation extends Simulation {
  LinearSimulation();

  @override
  double dx(double time) => time;

  @override
  bool isDone(double time) => false;

  @override
  double x(double time) => time;
}

extension DurationExtension on int {
  Duration get ms => Duration(milliseconds: this);
  Duration get s => Duration(seconds: this);
  Duration get m => Duration(minutes: this);
}
