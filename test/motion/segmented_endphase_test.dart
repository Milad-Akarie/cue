// Tests for SegmentedSimulation with endPhase parameter.
//
// These tests verify that:
// 1. SegmentedSimulation stops at the specified endPhase (not the last phase)
// 2. Duration calculation accounts for endPhase correctly
// 3. isDone fires when reaching endPhase
// 4. Phase advancement stops at endPhase
// 5. Backward compatibility: null endPhase behaves as before (runs to last phase)

import 'package:cue/src/motion/cue_motion.dart';
import 'package:cue/src/motion/simulation.dart';
import 'package:cue/src/motion/spring_motion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SegmentedSimulation with endPhase —', () {
    // Helper to create a 3-segment motion for testing
    List<CueMotion> create3SegmentMotion() => [
      CueMotion.linear(.1),
      CueMotion.linear(.2),
      CueMotion.linear(.3),
    ];

    test('default endPhase (null) runs to last phase — forward', () {
      final motions = create3SegmentMotion();
      final sim = SegmentedSimulation(
        motions: motions,
        forward: true,
        velocity: 0.0,
        initialPhase: 0,
        startValue: 0.0,
        endPhase: null, // should default to motions.length - 1 = 2
      );

      // Duration should include all 3 phases: 100 + 200 + 300 = 600ms
      expect(sim.duration, closeTo(0.6, 0.001));

      // Run simulation and verify it advances through all phases
      double t = 0.0;

      // Phase 0 (100ms)
      expect(sim.phase, equals(0));
      t = 0.11; // past phase 0
      sim.x(t);
      expect(sim.phase, equals(1));

      // Phase 1 (200ms)
      t = 0.32; // past phase 1
      sim.x(t);
      expect(sim.phase, equals(2));

      // Phase 2 (300ms) — should reach this
      t = 0.65;
      expect(sim.isDone(t), isTrue);
      expect(sim.phase, equals(2));
    });

    test('endPhase = 1 stops at phase 1 (forward)', () {
      final motions = create3SegmentMotion();
      final sim = SegmentedSimulation(
        motions: motions,
        forward: true,
        velocity: 0.0,
        initialPhase: 0,
        startValue: 0.0,
        endPhase: 1, // stop at phase 1
      );

      // Duration should only include phases 0 and 1: 100 + 200 = 300ms
      expect(sim.duration, closeTo(0.3, 0.001));

      double t = 0.0;

      // Phase 0
      expect(sim.phase, equals(0));
      t = 0.11; // past phase 0
      sim.x(t);
      expect(sim.phase, equals(1));

      // Phase 1 — should stop here
      t = 0.35;
      expect(sim.isDone(t), isTrue);
      expect(sim.phase, equals(1));

      // Should NOT advance to phase 2
      t = 0.5;
      sim.x(t);
      expect(sim.phase, equals(1), reason: 'Should not advance past endPhase');
    });

    test('endPhase = 0 stops at phase 0 (forward)', () {
      final motions = create3SegmentMotion();
      final sim = SegmentedSimulation(
        motions: motions,
        forward: true,
        velocity: 0.0,
        initialPhase: 0,
        startValue: 0.0,
        endPhase: 0, // stop immediately at phase 0
      );

      // Duration should only be phase 0: 100ms
      expect(sim.duration, closeTo(0.1, 0.001));

      expect(sim.phase, equals(0));

      double t = 0.11;
      expect(sim.isDone(t), isTrue);
      expect(sim.phase, equals(0));

      // Should NOT advance
      t = 0.2;
      sim.x(t);
      expect(sim.phase, equals(0));
    });

    test('default endPhase (null) runs to first phase — reverse', () {
      final motions = create3SegmentMotion();
      final sim = SegmentedSimulation(
        motions: motions,
        forward: false,
        velocity: 0.0,
        initialPhase: 2, // start from last phase
        startValue: 1.0,
        endPhase: null, // should default to 0 for reverse
      );

      // Duration should include all 3 phases in reverse: 300 + 200 + 100 = 600ms
      expect(sim.duration, closeTo(0.6, 0.001));

      double t = 0.0;

      // Phase 2
      expect(sim.phase, equals(2));
      t = 0.31; // past phase 2
      sim.x(t);
      expect(sim.phase, equals(1));

      // Phase 1
      t = 0.52; // past phase 1
      sim.x(t);
      expect(sim.phase, equals(0));

      // Phase 0 — should reach this
      t = 0.65;
      expect(sim.isDone(t), isTrue);
      expect(sim.phase, equals(0));
    });

    test('endPhase = 1 stops at phase 1 (reverse)', () {
      final motions = create3SegmentMotion();
      final sim = SegmentedSimulation(
        motions: motions,
        forward: false,
        velocity: 0.0,
        initialPhase: 2, // start from last phase
        startValue: 1.0,
        endPhase: 1, // stop at phase 1
      );

      // Duration should only include phases 2 and 1: 300 + 200 = 500ms
      expect(sim.duration, closeTo(0.5, 0.001));

      double t = 0.0;

      // Phase 2
      expect(sim.phase, equals(2));
      t = 0.31; // past phase 2
      sim.x(t);
      expect(sim.phase, equals(1));

      // Phase 1 — should stop here
      t = 0.55;
      expect(sim.isDone(t), isTrue);
      expect(sim.phase, equals(1));

      // Should NOT advance to phase 0
      t = 0.7;
      sim.x(t);
      expect(sim.phase, equals(1), reason: 'Should not advance past endPhase in reverse');
    });

    test('endPhase = 2 stops at phase 2 (reverse)', () {
      final motions = create3SegmentMotion();
      final sim = SegmentedSimulation(
        motions: motions,
        forward: false,
        velocity: 0.0,
        initialPhase: 2,
        startValue: 1.0,
        endPhase: 2, // stop immediately
      );

      // Duration should only be phase 2: 300ms
      expect(sim.duration, closeTo(0.3, 0.001));

      expect(sim.phase, equals(2));

      double t = 0.31;
      expect(sim.isDone(t), isTrue);
      expect(sim.phase, equals(2));

      // Should NOT advance
      t = 0.5;
      sim.x(t);
      expect(sim.phase, equals(2));
    });

    test('starting mid-sequence with endPhase', () {
      final motions = create3SegmentMotion();
      final sim = SegmentedSimulation(
        motions: motions,
        forward: true,
        velocity: 0.0,
        initialPhase: 1, // start at phase 1
        startValue: 0.5,
        endPhase: 2, // end at phase 2
      );

      // Duration: phase 1 from 0.5→1.0 (scaled to 100ms) + phase 2 full (300ms) = 400ms
      expect(sim.duration, closeTo(0.4, 0.001));

      expect(sim.phase, equals(1));

      double t = 0.21; // past phase 1
      sim.x(t);
      expect(sim.phase, equals(2));

      t = 0.55;
      expect(sim.isDone(t), isTrue);
      expect(sim.phase, equals(2));
    });

    test('endPhase equals initialPhase (single phase run)', () {
      final motions = create3SegmentMotion();
      final sim = SegmentedSimulation(
        motions: motions,
        forward: true,
        velocity: 0.0,
        initialPhase: 1,
        startValue: 0.5,
        endPhase: 1, // same as initial
      );

      // Duration: phase 1 from 0.5→1.0, scaled to 100ms (200ms * 0.5)
      expect(sim.duration, closeTo(0.1, 0.001));

      expect(sim.phase, equals(1));

      double t = 0.11;
      expect(sim.isDone(t), isTrue);
      expect(sim.phase, equals(1));

      // Should not advance
      t = 0.5;
      sim.x(t);
      expect(sim.phase, equals(1));
    });

    test('SegmentedMotion.build passes endPhase correctly', () {
      final motion = SegmentedMotion([
        CueMotion.linear(0.1),
        CueMotion.linear(0.2),
        CueMotion.linear(0.3),
      ]);

      // Build with endPhase = 1
      final sim =
          motion.build(
                const SimulationBuildData(
                  forward: true,
                  startValue: 0.0,
                  endPhase: 1,
                ),
              )
              as SegmentedSimulation;

      expect(sim.endPhase, equals(1));
      expect(sim.duration, closeTo(0.3, 0.001)); // phases 0 + 1

      // Simulate advancing through phases
      double t = 0.0;
      expect(sim.phase, equals(0));

      // Advance past phase 0 (100ms)
      t = 0.11;
      sim.x(t);
      expect(sim.phase, equals(1), reason: 'Should advance to phase 1 after phase 0 completes');

      // Complete phase 1 (200ms)
      t = 0.35;
      expect(sim.isDone(t), isTrue);
      expect(sim.phase, equals(1));
    });

    test('SegmentedMotion.build defaults endPhase when null', () {
      final motion = SegmentedMotion([
        CueMotion.linear(0.1),
        CueMotion.linear(0.2),
      ]);

      // Build without endPhase
      final sim =
          motion.build(
                const SimulationBuildData(
                  forward: true,
                  startValue: 0.0,
                  // endPhase is null
                ),
              )
              as SegmentedSimulation;

      expect(sim.endPhase, equals(1)); // should default to last phase (motions.length - 1)
      expect(sim.duration, closeTo(0.3, 0.001)); // both phases
    });

    test('reverse with default endPhase from SegmentedMotion.build', () {
      final motion = SegmentedMotion([
        CueMotion.linear(0.1),
        CueMotion.linear(0.2),
      ]);

      final sim =
          motion.build(
                const SimulationBuildData(
                  forward: false,
                  startValue: 1.0,
                  phase: 1,
                  // endPhase is null
                ),
              )
              as SegmentedSimulation;

      expect(sim.endPhase, equals(0)); // should default to 0 for reverse
      expect(sim.duration, closeTo(0.3, 0.001));
    });

    test('valueAtProgress works regardless of endPhase (uses seekable segments)', () {
      // valueAtProgress uses pre-built seekable segments which always span 0→1,
      // so endPhase should not affect it
      final motions = create3SegmentMotion();
      final sim = SegmentedSimulation(
        motions: motions,
        forward: true,
        velocity: 0.0,
        initialPhase: 0,
        startValue: 0.0,
        endPhase: 1, // runtime stops at phase 1
      );

      // But valueAtProgress can still query phase 2's value
      final (value, phase) = sim.valueAtProgress(0.9);
      expect(phase, equals(2)); // phase 2 exists in seekable segments
      expect(value, greaterThan(0.5)); // should be close to 1.0
    });

    test('endValue targets mid-phase value correctly', () {
      final motions = create3SegmentMotion();
      final sim = SegmentedSimulation(
        motions: motions,
        forward: true,
        velocity: 0.0,
        initialPhase: 0,
        startValue: 0.0,
        endPhase: 1,
        endValue: 0.5, // stop at phase 1, value 0.5
      );

      // Run simulation
      double t = 0.0;
      const dt = 1 / 60;

      // Advance through phase 0
      while (t < 0.15 && !sim.isDone(t)) {
        sim.x(t);
        t += dt;
      }
      expect(sim.phase, equals(1), reason: 'Should advance to phase 1');

      // Continue until done
      while (t < 10.0 && !sim.isDone(t)) {
        sim.x(t);
        t += dt;
      }

      expect(sim.isDone(t), isTrue);
      expect(sim.phase, equals(1));
      expect(sim.x(t), closeTo(0.5, 0.01), reason: 'Should settle at endValue 0.5');
    });

    test('endValue via SimulationBuildData', () {
      final motion = SegmentedMotion([
        CueMotion.linear(0.1),
        CueMotion.linear(0.2),
        CueMotion.linear(0.3),
      ]);

      final sim =
          motion.build(
                const SimulationBuildData(
                  forward: true,
                  startValue: 0.0,
                  endPhase: 1,
                  endValue: 0.7,
                ),
              )
              as SegmentedSimulation;

      // Run through phases
      double t = 0.0;
      while (t < 1.0 && !sim.isDone(t)) {
        sim.x(t);
        t += 1 / 60;
      }

      expect(sim.isDone(t), isTrue);
      expect(sim.phase, equals(1));
      expect(sim.x(t), closeTo(0.7, 0.01), reason: 'Should settle at endValue 0.7');
    });

    test('endPhase with spring segments (physics-based)', () {
      TestWidgetsFlutterBinding.ensureInitialized();

      final motions = [
        const Spring.smooth(),
        const Spring.bouncy(),
        const Spring.stiff(),
      ];

      final sim = SegmentedSimulation(
        motions: motions,
        forward: true,
        velocity: 0.0,
        initialPhase: 0,
        startValue: 0.0,
        endPhase: 1, // stop at bouncy spring
      );

      // Should include smooth + bouncy durations only
      final smoothDuration = const Spring.smooth().baseDuration;
      final bouncyDuration = const Spring.bouncy().baseDuration;
      expect(sim.duration, closeTo(smoothDuration + bouncyDuration, 0.01));

      // Run simulation
      double t = 0.0;
      const dt = 1 / 60;
      while (t < 10.0 && !sim.isDone(t)) {
        sim.x(t);
        t += dt;
      }

      expect(sim.isDone(t), isTrue, reason: 'Should settle at endPhase 1');
      expect(sim.phase, equals(1), reason: 'Should stop at phase 1, not advance to phase 2');
    });
  });
}
