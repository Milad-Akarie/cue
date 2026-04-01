import 'package:cue/cue.dart';
import 'package:cue/src/motion/simulation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CueSpringSimulation.duration', () {
    // Test basic critically damped spring (zeta = 1.0)
    test('critically damped: zero velocity, 0->1', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 20.0),
        0.0,
        1.0,
        0.0,
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });

    // Underdamped springs (zeta < 1.0) - oscillate
    test('underdamped: zero velocity, 0->1', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.0,
        1.0,
        0.0,
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });

    test('underdamped: positive velocity, 0->1', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.0,
        1.0,
        2.0,
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });

    test('underdamped: negative velocity, 0->1', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.0,
        1.0,
        -1.5,
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });

    // Overdamped springs (zeta > 1.0) - no oscillation, slow
    test('overdamped: zero velocity, 0->1', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 50.0, damping: 20.0),
        0.0,
        1.0,
        0.0,
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });

    test('overdamped: positive velocity, 0->1', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 50.0, damping: 20.0),
        0.0,
        1.0,
        1.0,
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });

    test('overdamped: negative velocity, 0->1', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 50.0, damping: 20.0),
        0.0,
        1.0,
        -2.0,
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });

    // Different start and end values
    test('underdamped: different range (0.5->2.5)', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.5,
        2.5,
        0.0,
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });

    test('overdamped: different range (-1.0->1.0)', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 50.0, damping: 20.0),
        -1.0,
        1.0,
        0.0,
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });

    test('underdamped: reverse direction (1.0->0.0)', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        1.0,
        0.0,
        0.0,
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });

    // Different frame rates: 90 fps = 1/90
    test('underdamped @ 90fps: 0->1', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.0,
        1.0,
        0.0,
        samplingStepSize: 1 / 90,
      );
      expect(refDuration(sim, stepSize: 1 / 90), closeTo(sim.duration, 1 / 90));
    });

    test('critically damped @ 90fps: 0->1', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 20.0),
        0.0,
        1.0,
        0.0,
        samplingStepSize: 1 / 90,
      );
      expect(refDuration(sim, stepSize: 1 / 90), closeTo(sim.duration, 1 / 90));
    });

    test('overdamped @ 90fps: 0->1', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 50.0, damping: 20.0),
        0.0,
        1.0,
        0.0,
        samplingStepSize: 1 / 90,
      );
      expect(refDuration(sim, stepSize: 1 / 90), closeTo(sim.duration, 1 / 90));
    });

    // Different frame rates: 120 fps = 1/120
    test('underdamped @ 120fps: 0->1', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.0,
        1.0,
        0.0,
        samplingStepSize: 1 / 120,
      );
      expect(refDuration(sim, stepSize: 1 / 120), closeTo(sim.duration, 1 / 120));
    });

    test('critically damped @ 120fps: 0->1', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 20.0),
        0.0,
        1.0,
        0.0,
        samplingStepSize: 1 / 120,
      );
      expect(refDuration(sim, stepSize: 1 / 120), closeTo(sim.duration, 1 / 120));
    });

    test('overdamped @ 120fps: 0->1', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 50.0, damping: 20.0),
        0.0,
        1.0,
        0.0,
        samplingStepSize: 1 / 120,
      );
      expect(refDuration(sim, stepSize: 1 / 120), closeTo(sim.duration, 1 / 120));
    });

    // Different frame rates: 144 fps = 1/144
    test('underdamped @ 144fps: 0->1', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.0,
        1.0,
        0.0,
        samplingStepSize: 1 / 144,
      );
      expect(refDuration(sim, stepSize: 1 / 144), closeTo(sim.duration, 1 / 144));
    });

    test('critically damped @ 144fps: 0->1', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 20.0),
        0.0,
        1.0,
        0.0,
        samplingStepSize: 1 / 144,
      );
      expect(refDuration(sim, stepSize: 1 / 144), closeTo(sim.duration, 1 / 144));
    });

    test('overdamped @ 144fps: 0->1', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 50.0, damping: 20.0),
        0.0,
        1.0,
        0.0,
        samplingStepSize: 1 / 144,
      );
      expect(refDuration(sim, stepSize: 1 / 144), closeTo(sim.duration, 1 / 144));
    });

    // Complex combinations
    test('underdamped + velocity @ 120fps: large displacement', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 2.0, stiffness: 200.0, damping: 15.0),
        0.0,
        5.0,
        3.0,
        samplingStepSize: 1 / 120,
      );
      expect(refDuration(sim, stepSize: 1 / 120), closeTo(sim.duration, 1 / 120));
    });

    test('underdamped: high stiffness', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 500.0, damping: 30.0),
        0.0,
        1.0,
        0.0,
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });

    test('overdamped: high mass', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 5.0, stiffness: 50.0, damping: 30.0),
        0.0,
        1.0,
        0.0,
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });
  });

  group('DelayedSimulation wrapping CueSpringSimulation', () {
    // Basic delayed spring - underdamped
    test('underdamped with 0.5s delay', () {
      final springCue = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.0,
        1.0,
        0.0,
      );
      final delayed = DelayedSimulation(base: springCue, delay: 0.5);

      expect(refDuration(delayed), closeTo(delayed.duration, 1 / 60));
    });

    test('critically damped with 0.3s delay', () {
      final springCue = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 20.0),
        0.0,
        1.0,
        0.0,
      );
      final delayed = DelayedSimulation(base: springCue, delay: 0.3);

      expect(refDuration(delayed), closeTo(delayed.duration, 1 / 60));
    });

    test('overdamped with 0.2s delay', () {
      final springCue = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 50.0, damping: 20.0),
        0.0,
        1.0,
        0.0,
      );
      final delayed = DelayedSimulation(base: springCue, delay: 0.2);

      expect(refDuration(delayed), closeTo(delayed.duration, 1 / 60));
    });

    // Delayed spring with initial velocity
    test('underdamped with velocity and 0.4s delay', () {
      final springCue = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.0,
        1.0,
        2.0,
      );
      final delayed = DelayedSimulation(base: springCue, delay: 0.4);

      expect(refDuration(delayed), closeTo(delayed.duration, 1 / 60));
    });

    // Delayed spring with different ranges
    test('underdamped different range with 0.25s delay', () {
      final springCue = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.5,
        2.5,
        0.0,
      );
      final delayed = DelayedSimulation(base: springCue, delay: 0.25);

      expect(refDuration(delayed), closeTo(delayed.duration, 1 / 60));
    });

    // Delayed spring with different frame rates
    test('underdamped delayed @ 90fps', () {
      final springCue = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.0,
        1.0,
        0.0,
        samplingStepSize: 1 / 90,
      );
      final delayed = DelayedSimulation(base: springCue, delay: 0.3);

      expect(refDuration(delayed, stepSize: 1 / 90), closeTo(delayed.duration, 1 / 90));
    });

    test('critically damped delayed @ 120fps', () {
      final springCue = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 20.0),
        0.0,
        1.0,
        0.0,
        samplingStepSize: 1 / 120,
      );
      final delayed = DelayedSimulation(base: springCue, delay: 0.5);

      expect(refDuration(delayed, stepSize: 1 / 120), closeTo(delayed.duration, 1 / 120));
    });

    test('overdamped delayed @ 144fps', () {
      final springCue = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 50.0, damping: 20.0),
        0.0,
        1.0,
        0.0,
        samplingStepSize: 1 / 144,
      );
      final delayed = DelayedSimulation(base: springCue, delay: 0.2);

      expect(refDuration(delayed, stepSize: 1 / 144), closeTo(delayed.duration, 1 / 144));
    });

    // Very small and very large delays
    test('underdamped with very small delay (0.01s)', () {
      final springCue = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.0,
        1.0,
        0.0,
      );
      final delayed = DelayedSimulation(base: springCue, delay: 0.01);

      expect(refDuration(delayed), closeTo(delayed.duration, 1 / 60));
    });

    test('underdamped with large delay (1.5s)', () {
      final springCue = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.0,
        1.0,
        0.0,
      );
      final delayed = DelayedSimulation(base: springCue, delay: 1.5);

      expect(refDuration(delayed), closeTo(delayed.duration, 1 / 60));
    });

    // Delayed spring with complex parameters
    test('complex delayed spring: high mass, velocity, delay', () {
      final springCue = CueSpringSimulation(
        SpringDescription(mass: 2.0, stiffness: 200.0, damping: 15.0),
        0.0,
        5.0,
        3.0,
        samplingStepSize: 1 / 120,
      );
      final delayed = DelayedSimulation(base: springCue, delay: 0.6);

      expect(refDuration(delayed, stepSize: 1 / 120), closeTo(delayed.duration, 1 / 120));
    });

    // Delayed spring with reverse direction
    test('reversed underdamped with delay', () {
      final springCue = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        1.0,
        0.0,
        0.0,
      );
      final delayed = DelayedSimulation(base: springCue, delay: 0.4);

      expect(refDuration(delayed), closeTo(delayed.duration, 1 / 60));
    });
  });

  group('CueSpringSimulation edge cases', () {
    // Zero displacement
    test('zero displacement (0->0)', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.0,
        0.0,
        0.0,
      );
      // Should be nearly instant or very short
      expect(sim.duration, lessThan(0.1));
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });

    // Negative displacement
    test('negative displacement (-1.0->1.0)', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        -1.0,
        1.0,
        0.0,
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });

    test('negative displacement (5.0->-5.0)', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        5.0,
        -5.0,
        0.0,
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });

    // Extreme positive velocity
    test('extremely high positive velocity', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.0,
        1.0,
        10.0,
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });

    // Extreme negative velocity
    test('extremely high negative velocity', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.0,
        1.0,
        -10.0,
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });

    // Very low stiffness (sluggish)
    test('very low stiffness (sluggish spring)', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 10.0, damping: 5.0),
        0.0,
        1.0,
        0.0,
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });

    // Very low damping (bouncy)
    test('very low damping (bouncy spring)', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 500.0, damping: 1.0),
        0.0,
        1.0,
        0.0,
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });

    // Opposite velocity (moving away first)
    test('opposite initial velocity (1.0->0.0 with positive velocity)', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.0,
        1.0,
        -2.0, // Moving backwards initially
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });

    // Very large displacement
    test('very large displacement (0->100)', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.0,
        100.0,
        0.0,
      );
      expect(refDuration(sim), closeTo(sim.duration, 0.05));
    });

    // Different masses
    test('very heavy mass (10.0)', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 10.0, stiffness: 100.0, damping: 20.0),
        0.0,
        1.0,
        0.0,
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });

    test('very light mass (0.1)', () {
      final sim = CueSpringSimulation(
        SpringDescription(mass: 0.1, stiffness: 100.0, damping: 5.0),
        0.0,
        1.0,
        0.0,
      );
      expect(refDuration(sim), closeTo(sim.duration, 1 / 60));
    });
  });

  group('CurvedSimulation duration', () {
    // Linear curve
    test('linear curve 300ms', () {
      final motion = CueMotion.linear(300.ms);
      final curved = motion.build(SimulationBuildData.forward(startValue: 0.0));

      expect(refDuration(curved), closeTo(curved.duration, 1 / 60));
    });

    test('linear curve 500ms', () {
      final motion = CueMotion.linear(500.ms);
      final curved = motion.build(SimulationBuildData.forward(startValue: 0.0));

      expect(refDuration(curved), closeTo(curved.duration, 1 / 60));
    });

    // Ease in curve
    test('easeIn curve', () {
      final motion = CueMotion.curved(
        300.ms,
        curve: Curves.easeIn,
      );
      final curved = motion.build(SimulationBuildData.forward(startValue: 0.0));

      expect(refDuration(curved), closeTo(curved.duration, 1 / 60));
    });

    // Ease out curve
    test('easeOut curve', () {
      final motion = CueMotion.curved(
        300.ms,
        curve: Curves.easeOut,
      );
      final curved = motion.build(SimulationBuildData.forward(startValue: 0.0));

      expect(refDuration(curved), closeTo(curved.duration, 1 / 60));
    });

    // Ease in-out curve
    test('easeInOut curve', () {
      final motion = CueMotion.curved(
        300.ms,
        curve: Curves.easeInOut,
      );
      final curved = motion.build(SimulationBuildData.forward(startValue: 0.0));

      expect(refDuration(curved), closeTo(curved.duration, 1 / 60));
    });

    // Elastic curve
    test('elasticIn curve', () {
      final motion = CueMotion.curved(
        500.ms,
        curve: Curves.elasticIn,
      );
      final curved = motion.build(SimulationBuildData.forward(startValue: 0.0));

      expect(refDuration(curved), closeTo(curved.duration, 1 / 60));
    });

    // Bounce curve
    test('bounceOut curve', () {
      final motion = CueMotion.curved(
        400.ms,
        curve: Curves.bounceOut,
      );
      final curved = motion.build(SimulationBuildData.forward(startValue: 0.0));

      expect(refDuration(curved), closeTo(curved.duration, 1 / 60));
    });

    // Zero duration curve (edge case)
    test('zero duration curve', () {
      final motion = CueMotion.linear(0.ms);
      final curved = motion.build(SimulationBuildData.forward(startValue: 0.0));

      expect(curved.duration, lessThanOrEqualTo(0.01));
      expect(refDuration(curved), closeTo(curved.duration, 1 / 60));
    });

    // Very long duration curve
    test('very long duration curve (2s)', () {
      final motion = CueMotion.linear(2000.ms);
      final curved = motion.build(SimulationBuildData.forward(startValue: 0.0));

      expect(refDuration(curved), closeTo(curved.duration, 1 / 60));
    });

    // Different starting values
    test('curved motion with non-zero start value', () {
      final motion = CueMotion.curved(
        300.ms,
        curve: Curves.easeOut,
      );
      final curved = motion.build(SimulationBuildData.forward(startValue: 0.5));

      expect(refDuration(curved), closeTo(curved.duration, 1 / 60));
    });
  });

  group('Chained DelayedSimulations', () {
    // Double delayed: DelayedSimulation wrapping DelayedSimulation wrapping CueSpringSimulation
    test('double delayed spring (delay + delay + spring)', () {
      final springCue = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 10.0),
        0.0,
        1.0,
        0.0,
      );
      final delayed1 = DelayedSimulation(base: springCue, delay: 0.2);
      final delayed2 = DelayedSimulation(base: delayed1, delay: 0.3);

      // Total duration = 0.3 + 0.2 + spring.duration
      expect(refDuration(delayed2), closeTo(delayed2.duration, 1 / 60));
    });

    test('triple delayed spring', () {
      final springCue = CueSpringSimulation(
        SpringDescription(mass: 1.0, stiffness: 100.0, damping: 20.0),
        0.0,
        1.0,
        0.0,
      );
      final delayed1 = DelayedSimulation(base: springCue, delay: 0.1);
      final delayed2 = DelayedSimulation(base: delayed1, delay: 0.2);
      final delayed3 = DelayedSimulation(base: delayed2, delay: 0.1);

      // Total duration = 0.1 + 0.2 + 0.1 + spring.duration
      expect(refDuration(delayed3), closeTo(delayed3.duration, 1 / 60));
    });

    // Delayed curved motion
    test('delayed curved motion', () {
      final motion = CueMotion.curved(
        300.ms,
        curve: Curves.easeOut,
      );
      final curved = motion.build(SimulationBuildData.forward(startValue: 0.0));
      final delayed = DelayedSimulation(base: curved, delay: .5);

      expect(refDuration(delayed), closeTo(delayed.duration, 1 / 60));
    });

    // Delayed + delayed curved motion
    test('double delayed curved motion', () {
      final motion = CueMotion.curved(
        300.ms,
        curve: Curves.easeInOut,
      );
      final curved = motion.build(SimulationBuildData.forward(startValue: 0.0));
      final delayed1 = DelayedSimulation(base: curved, delay: 0.3);
      final delayed2 = DelayedSimulation(base: delayed1, delay: 0.2);

      expect(refDuration(delayed2), closeTo(delayed2.duration, 1 / 60));
    });
  });

  group('DelayedSimulation phase getter', () {
    test('phase returns base simulation phase', () {
      final baseSim = TimedMotion(Duration(milliseconds: 300)).buildBase();
      final delayedSim = DelayedSimulation(base: baseSim, delay: 0.1);
      expect(delayedSim.phase, equals(baseSim.phase));
    });
  });

  group('DelayedSimulation x method', () {
    test('x returns 0 during delay', () {
      final baseSim = TimedMotion(Duration(milliseconds: 300)).buildBase();
      final delayedSim = DelayedSimulation(base: baseSim, delay: 0.1);
      expect(delayedSim.x(0.05), equals(0.0));
    });

    test('x returns base value after delay', () {
      final baseSim = TimedMotion(Duration(milliseconds: 300)).buildBase();
      final delayedSim = DelayedSimulation(base: baseSim, delay: 0.1);
      final value = delayedSim.x(0.2);
      expect(value, greaterThan(0.0));
      expect(value, lessThanOrEqualTo(1.0));
    });
  });

  group('DelayedSimulation dx method', () {
    test('dx returns 0 during delay', () {
      final baseSim = TimedMotion(Duration(milliseconds: 300)).buildBase();
      final delayedSim = DelayedSimulation(base: baseSim, delay: 0.1);
      expect(delayedSim.dx(0.05), equals(0.0));
    });

    test('dx returns base derivative after delay', () {
      final baseSim = TimedMotion(Duration(milliseconds: 300)).buildBase();
      final delayedSim = DelayedSimulation(base: baseSim, delay: 0.1);
      final derivative = delayedSim.dx(0.2);
      expect(derivative, isNonZero);
    });
  });

  group('SegmentedSimulation dx method', () {
    test('dx returns derivative at given time', () {
      final motion = SegmentedMotion([
        TimedMotion(Duration(milliseconds: 200)),
        TimedMotion(Duration(milliseconds: 300)),
      ]);
      final sim = motion.build(
        SimulationBuildData.forward(startValue: 0.0),
      );
      final derivative = sim.dx(0.1);
      expect(derivative, isNotNull);
    });

    test('dx works for reverse direction', () {
      final motion = SegmentedMotion([
        TimedMotion(Duration(milliseconds: 200)),
        TimedMotion(Duration(milliseconds: 300)),
      ]);
      final sim = motion.build(
        SimulationBuildData.reverse(startValue: 1.0),
      );
      final derivative = sim.dx(0.1);
      expect(derivative, isNotNull);
    });
  });

  group('SegmentedSimulation valueAtProgress edge cases', () {
    test('valueAtProgress with zero duration motions', () {
      final motion = SegmentedMotion([
        TimedMotion(Duration.zero),
        TimedMotion(Duration.zero),
      ]);
      final sim = motion.build(
        SimulationBuildData.forward(startValue: 0.0),
      );
      final (value, phase) = sim.valueAtProgress(0.5);
      expect(value, isNotNull);
      expect(phase, equals(0));
    });
  });
}

// mimic an actual ticker by incrementing time until the simulation reports it's done,
//then return the total elapsed time
double refDuration(Simulation sim, {double stepSize = 1 / 60}) {
  double t = 0.0;
  while (t < 100.0) {
    if (sim.isDone(t)) return t;
    t += stepSize;
  }
  return t;
}
 