import 'package:flutter/physics.dart';

abstract class CueSimulation {
  const CueSimulation();
  Simulation build(SimulationBuildData data);

    double computeSettlingDuration();
}

class SimulationBuildData {
  final double? velocity;
  final bool forward;
  final double progress;
  double get end => forward ? 1.0 : 0.0;

  const SimulationBuildData({
    this.velocity,
     this.forward = true,
     this.progress = 0.0,
  });

 
}
