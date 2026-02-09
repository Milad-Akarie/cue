import 'dart:math';
import 'package:flutter/physics.dart';

void main() {
  print('=== Validating Spring Default Values ===\n');

  // Test the three presets
  testSpring('Smooth', mass: 1, stiffness: 100, damping: 10);
  testSpring('Bouncy', mass: 1, stiffness: 100, damping: 5);
  testSpring('Snappy', mass: 1, stiffness: 100, damping: 20);

  print('\n=== Physics Analysis ===');
  print('✓ Smooth (damping: 10) - Underdamped, gentle oscillation');
  print('✓ Bouncy (damping: 5) - More underdamped, pronounced bounce');
  print('✓ Snappy (damping: 20) - Critically damped, fast settling\n');
}

void testSpring(String name, {required double mass, required double stiffness, required double damping}) {
  final description = SpringDescription(
    mass: mass,
    stiffness: stiffness,
    damping: damping,
  );

  final simulation = SpringSimulation(description, 0, 1, 0);

  // Calculate damping ratio (ζ = c / (2√(mk)))
  final criticalDamping = 2 * sqrt(mass * stiffness);
  final dampingRatio = damping / criticalDamping;

  // Calculate natural frequency (ω = √(k/m))
  final naturalFrequency = sqrt(stiffness / mass);

  // Estimate settling time (time to reach ~98% of target)
  final settlingTime = 4 / (dampingRatio * naturalFrequency);

  print('--- $name Spring ---');
  print('Mass: $mass, Stiffness: $stiffness, Damping: $damping');
  print('Damping Ratio (ζ): ${dampingRatio.toStringAsFixed(3)}');

  String dampingType;
  if (dampingRatio < 1) {
    dampingType = 'Underdamped (oscillates/bounces)';
  } else if (dampingRatio == 1) {
    dampingType = 'Critically damped (optimal, no overshoot)';
  } else {
    dampingType = 'Overdamped (slow, no bounce)';
  }
  print('Type: $dampingType');
  print('Natural Frequency: ${naturalFrequency.toStringAsFixed(2)} rad/s');
  print('Estimated Settling Time: ${(settlingTime * 1000).toStringAsFixed(0)}ms');

  // Check if spring is done at various time points
  print('Animation progress:');
  for (var t in [0.1, 0.2, 0.3, 0.5, 1.0]) {
    final x = simulation.x(t);
    final isDone = simulation.isDone(t);
    print('  t=${t.toStringAsFixed(1)}s: x=${x.toStringAsFixed(4)} ${isDone ? "(DONE)" : ""}');
  }
  print('');
}
