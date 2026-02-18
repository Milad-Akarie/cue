import 'package:flutter/physics.dart';

abstract class CueSimulation {
  const CueSimulation();
  Simulation build(SimulationBuildData data);
}

class SimulationBuildData {
  final double? velocity;
  final bool forward;
  final double progress;
  double get end => forward ? 1.0 : 0.0;

  SimulationBuildData({
    this.velocity,
    required this.forward,
    required this.progress,
  });
}
