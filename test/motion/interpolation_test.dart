// Tests that verify interpolated values produced by simulations built via
// CueMotion.build(SimulationBuildData) are correct relative to the configured
// start and end values.
//
// Rules validated here:
//  1. At progress 0.0 the value must equal startValue.
//  2. At progress 1.0 the value must equal endValue.
//  3. Intermediate values may freely overshoot or undershoot the [start, end]
//     range (springs and elastic curves legitimately produce values outside
//     that range), so no clamping assertion is made for middle progress.

import 'package:cue/src/motion/cue_motion.dart';
import 'package:cue/src/motion/simulation.dart';
import 'package:cue/src/motion/spring_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helper
// ---------------------------------------------------------------------------

/// Builds a [CueSimulation] from [motion] using an explicit [SimulationBuildData]
/// and asserts:
///  - value at progress 0.0 == [startValue]
///  - value at progress 1.0 == [endValue]
///  - value at every intermediate progress is a finite number (overshoot /
///    undershoot is allowed and expected for springs / elastic curves)
void _assertInterpolation(
  CueMotion motion,
  SimulationBuildData data, {
  double tolerance = 1e-9,
  String? label,
}) {
  final sim = motion.build(data);
  final startValue = data.startValue;
  final endValue = data.endValue;

  final (valueAtStart, _) = sim.valueAtProgress(0.0);
  expect(
    valueAtStart,
    closeTo(startValue, tolerance),
    reason: '${label ?? motion.runtimeType}: value at progress 0.0 should equal startValue ($startValue)',
  );

  final (valueAtEnd, _) = sim.valueAtProgress(1.0);
  expect(
    valueAtEnd,
    closeTo(endValue, tolerance),
    reason: '${label ?? motion.runtimeType}: value at progress 1.0 should equal endValue ($endValue)',
  );

  // Intermediate values must be finite numbers — overshoot is valid.
  for (final p in [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]) {
    final (mid, _) = sim.valueAtProgress(p);
    expect(
      mid.isFinite,
      isTrue,
      reason: '${label ?? motion.runtimeType}: value at progress $p must be finite',
    );
  }
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

void main() {
  // SegmentedMotion / Spring.build() calls WidgetsBinding internally only in
  // Spring.build() to query the display refresh rate.  We initialise the test
  // binding so that code path does not throw.
  TestWidgetsFlutterBinding.ensureInitialized();

  // -------------------------------------------------------------------------
  // TimedMotion (linear)
  // -------------------------------------------------------------------------
  group('TimedMotion (linear) — interpolation', () {
    test('forward 0→1 with SimulationBuildData.forward', () {
      final motion = CueMotion.linear(0.3);
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0),
        label: 'linear forward 0→1',
      );
    });

    test('reverse 1→0 with SimulationBuildData.reverse', () {
      final motion = CueMotion.linear(0.3);
      _assertInterpolation(
        motion,
        const SimulationBuildData.reverse(startValue: 1.0),
        label: 'linear reverse 1→0',
      );
    });

    test('partial forward 0.3→1 (interrupted mid-animation)', () {
      final motion = CueMotion.linear(0.3);
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.3),
        label: 'linear partial forward 0.3→1',
      );
    });

    test('partial reverse 0.6→0 (interrupted mid-animation)', () {
      final motion = CueMotion.linear(0.3);
      _assertInterpolation(
        motion,
        const SimulationBuildData.reverse(startValue: 0.6),
        label: 'linear partial reverse 0.6→0',
      );
    });

    test('explicit endValue override', () {
      final motion = CueMotion.linear(0.3);
      _assertInterpolation(
        motion,
        const SimulationBuildData(forward: true, startValue: 0.2, endValue: 0.8),
        label: 'linear explicit endValue 0.2→0.8',
      );
    });

    test('zero duration linear (instant snap)', () {
      final motion = CueMotion.linear(0.0);
      // Duration 0 means the simulation is immediately at the end.
      final sim = motion.build(const SimulationBuildData.forward(startValue: 0.0));
      final (valueAtEnd, _) = sim.valueAtProgress(1.0);
      expect(valueAtEnd, closeTo(1.0, 1e-9));
    });
  });

  // -------------------------------------------------------------------------
  // TimedMotion (curved)
  // -------------------------------------------------------------------------
  group('TimedMotion (curved) — interpolation', () {
    final curves = <String, Curve>{
      'easeIn': Curves.easeIn,
      'easeOut': Curves.easeOut,
      'easeInOut': Curves.easeInOut,
      'fastOutSlowIn': Curves.fastOutSlowIn,
      'bounceOut': Curves.bounceOut,
      'elasticIn': Curves.elasticIn,
      'elasticOut': Curves.elasticOut,
      'elasticInOut': Curves.elasticInOut,
    };

    for (final entry in curves.entries) {
      final curveName = entry.key;
      final curve = entry.value;

      test('$curveName forward 0→1', () {
        final motion = CueMotion.curved(0.4, curve: curve);
        _assertInterpolation(
          motion,
          const SimulationBuildData.forward(startValue: 0.0),
          label: '$curveName forward 0→1',
        );
      });

      test('$curveName reverse 1→0', () {
        final motion = CueMotion.curved(0.4, curve: curve);
        _assertInterpolation(
          motion,
          const SimulationBuildData.reverse(startValue: 1.0),
          label: '$curveName reverse 1→0',
        );
      });

      test('$curveName partial forward 0.4→1', () {
        final motion = CueMotion.curved(0.4, curve: curve);
        _assertInterpolation(
          motion,
          const SimulationBuildData.forward(startValue: 0.4),
          label: '$curveName partial forward 0.4→1',
        );
      });
    }

    test('curved explicit endValue 0.1→0.9', () {
      final motion = CueMotion.curved(
        0.3,
        curve: Curves.easeInOut,
      );
      _assertInterpolation(
        motion,
        const SimulationBuildData(forward: true, startValue: 0.1, endValue: 0.9),
        label: 'easeInOut explicit 0.1→0.9',
      );
    });
  });

  // -------------------------------------------------------------------------
  // Spring presets — interpolation
  // All spring presets can overshoot/undershoot, so only boundary values are
  // checked strictly; intermediate values just need to be finite.
  // -------------------------------------------------------------------------
  group('Spring presets — interpolation', () {
    // Tolerance for spring boundary values is slightly looser to account for
    // the physics-based settle threshold.
    const springTolerance = 0.01;

    test('Spring.smooth forward 0→1', () {
      final motion = const Spring.smooth();
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0),
        tolerance: springTolerance,
        label: 'Spring.smooth forward 0→1',
      );
    });

    test('Spring.smooth reverse 1→0', () {
      final motion = const Spring.smooth();
      _assertInterpolation(
        motion,
        const SimulationBuildData.reverse(startValue: 1.0),
        tolerance: springTolerance,
        label: 'Spring.smooth reverse 1→0',
      );
    });

    test('Spring.stiff forward 0→1', () {
      final motion = const Spring.stiff();
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0),
        tolerance: springTolerance,
        label: 'Spring.stiff forward 0→1',
      );
    });

    test('Spring.bouncy forward 0→1 — overshoot expected', () {
      final motion = const Spring.bouncy();
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0),
        tolerance: springTolerance,
        label: 'Spring.bouncy forward 0→1',
      );
      // Confirm that bouncy spring actually overshoots (value > 1.0 somewhere)
      final sim = motion.build(const SimulationBuildData.forward(startValue: 0.0));
      bool overshoot = false;
      for (double p = 0.0; p <= 1.0; p += 0.01) {
        final (v, _) = sim.valueAtProgress(p);
        if (v > 1.0 + 1e-4) {
          overshoot = true;
          break;
        }
      }
      expect(overshoot, isTrue, reason: 'Spring.bouncy should overshoot past 1.0');
    });

    test('Spring.wobbly forward 0→1 — overshoot expected', () {
      final motion = const Spring.wobbly();
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0),
        tolerance: springTolerance,
        label: 'Spring.wobbly forward 0→1',
      );
      final sim = motion.build(const SimulationBuildData.forward(startValue: 0.0));
      bool overshoot = false;
      for (double p = 0.0; p <= 1.0; p += 0.01) {
        final (v, _) = sim.valueAtProgress(p);
        if (v > 1.0 + 1e-4) {
          overshoot = true;
          break;
        }
      }
      expect(overshoot, isTrue, reason: 'Spring.wobbly should overshoot past 1.0');
    });

    test('Spring.gentle forward 0→1', () {
      final motion = const Spring.gentle();
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0),
        tolerance: springTolerance,
        label: 'Spring.gentle forward 0→1',
      );
    });

    test('Spring.iosDefault forward 0→1', () {
      final motion = const Spring.iosDefault();
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0),
        tolerance: springTolerance,
        label: 'Spring.iosDefault forward 0→1',
      );
    });

    test('Spring.interactive forward 0→1', () {
      final motion = const Spring.interactive();
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0),
        tolerance: springTolerance,
        label: 'Spring.interactive forward 0→1',
      );
    });

    test('Spring.soft forward 0→1', () {
      final motion = const Spring.soft();
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0),
        tolerance: springTolerance,
        label: 'Spring.soft forward 0→1',
      );
    });

    test('Spring (duration/bounce factory) forward 0→1 with bounce', () {
      final motion = Spring(duration: 0.5, bounce: 0.3);
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0),
        tolerance: springTolerance,
        label: 'Spring factory bounce=0.3 forward 0→1',
      );
    });

    test('Spring partial start 0.5→1', () {
      final motion = const Spring.smooth();
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.5),
        tolerance: springTolerance,
        label: 'Spring.smooth partial 0.5→1',
      );
    });

    test('Spring partial reverse 0.5→0', () {
      final motion = const Spring.smooth();
      _assertInterpolation(
        motion,
        const SimulationBuildData.reverse(startValue: 0.5),
        tolerance: springTolerance,
        label: 'Spring.smooth partial reverse 0.5→0',
      );
    });

    test('Spring with initial velocity forward', () {
      final motion = const Spring.smooth();
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0, velocity: 2.0),
        tolerance: springTolerance,
        label: 'Spring.smooth with positive velocity 0→1',
      );
    });

    test('Spring with opposing initial velocity (will undershoot then recover)', () {
      final motion = const Spring.smooth();
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0, velocity: -2.0),
        tolerance: springTolerance,
        label: 'Spring.smooth with opposing velocity 0→1',
      );
    });

    test('Spring explicit endValue 0.2→0.8', () {
      final motion = const Spring.smooth();
      _assertInterpolation(
        motion,
        const SimulationBuildData(forward: true, startValue: 0.2, endValue: 0.8),
        tolerance: springTolerance,
        label: 'Spring.smooth explicit 0.2→0.8',
      );
    });
  });

  // -------------------------------------------------------------------------
  // DelayedMotion — interpolation
  // During the delay, the value must stay at startValue; after the delay it
  // runs the underlying simulation to endValue.
  // -------------------------------------------------------------------------
  group('DelayedMotion — interpolation', () {
    test('delayed linear: value stays at startValue during delay', () {
      final base = CueMotion.linear(0.3);
      final motion = base.delayed(0.1);
      // Total = 400ms; delay fraction = 100/400 = 0.25

      final sim = motion.build(const SimulationBuildData.forward(startValue: 0.0));

      // Strictly within delay (progress 0.0 – 0.24) value must be startValue.
      for (final p in [0.0, 0.05, 0.1, 0.15, 0.24]) {
        final (v, _) = sim.valueAtProgress(p);
        expect(
          v,
          closeTo(0.0, 1e-9),
          reason: 'Delayed linear: at progress $p (within delay) value should be startValue 0.0',
        );
      }

      // At progress 1.0 value must be endValue.
      final (vEnd, _) = sim.valueAtProgress(1.0);
      expect(vEnd, closeTo(1.0, 1e-9), reason: 'Delayed linear: value at progress 1.0 should be 1.0');
    });

    test('delayed curved (easeOut) forward 0→1', () {
      final base = CueMotion.curved(
        0.3,
        curve: Curves.easeOut,
      );
      final motion = base.delayed(0.15);
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0),
        label: 'delayed easeOut forward 0→1',
      );
    });

    test('delayed spring (smooth) forward 0→1', () {
      final base = const Spring.smooth();
      final motion = base.delayed(0.1);
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0),
        tolerance: 0.01,
        label: 'delayed Spring.smooth forward 0→1',
      );
    });

    test('delayed spring (bouncy) forward 0→1 — overshoot still valid', () {
      final base = const Spring.bouncy();
      final motion = base.delayed(0.1);
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0),
        tolerance: 0.01,
        label: 'delayed Spring.bouncy forward 0→1',
      );
    });

    test('delayed linear reverse 1→0', () {
      final base = CueMotion.linear(0.3);
      final motion = base.delayed(0.1);
      _assertInterpolation(
        motion,
        const SimulationBuildData.reverse(startValue: 1.0),
        label: 'delayed linear reverse 1→0',
      );
    });

    test('delayed with zero delay is equivalent to base motion', () {
      final base = CueMotion.linear(0.3);
      final delayed = base.delayed(0.0);

      final baseSim = base.build(const SimulationBuildData.forward(startValue: 0.0));
      final delayedSim = delayed.build(const SimulationBuildData.forward(startValue: 0.0));

      for (final p in [0.0, 0.25, 0.5, 0.75, 1.0]) {
        final (bv, _) = baseSim.valueAtProgress(p);
        final (dv, _) = delayedSim.valueAtProgress(p);
        expect(dv, closeTo(bv, 1e-9), reason: 'Zero delay: value at $p should match base motion');
      }
    });

    test('delay longer than base animation (extreme ratio)', () {
      final base = CueMotion.curved(
        0.1,
        curve: Curves.easeIn,
      );
      final motion = base.delayed(0.4);
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0),
        label: 'extreme delay ratio 400ms delay / 100ms base',
      );
    });
  });

  // -------------------------------------------------------------------------
  // SegmentedMotion — interpolation
  // -------------------------------------------------------------------------
  group('SegmentedMotion — interpolation', () {
    test('two linear segments forward 0→1', () {
      final motion = SegmentedMotion([
        CueMotion.linear(0.2),
        CueMotion.linear(0.3),
      ]);
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0),
        label: 'segmented 2x linear forward 0→1',
      );
    });

    test('two curved segments forward 0→1', () {
      final motion = SegmentedMotion([
        CueMotion.curved(0.2, curve: Curves.easeIn),
        CueMotion.curved(0.3, curve: Curves.easeOut),
      ]);
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0),
        label: 'segmented 2x curved forward 0→1',
      );
    });

    test('three linear segments forward 0→1', () {
      final motion = SegmentedMotion([
        CueMotion.linear(0.1),
        CueMotion.linear(0.2),
        CueMotion.linear(0.2),
      ]);
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0),
        label: 'segmented 3x linear forward 0→1',
      );
    });

    test('mixed spring + linear segments forward 0→1', () {
      final motion = SegmentedMotion([
        const Spring.smooth(),
        CueMotion.linear(0.2),
      ]);
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0),
        tolerance: 0.01,
        label: 'segmented spring+linear forward 0→1',
      );
    });

    test('two spring segments forward 0→1', () {
      final motion = SegmentedMotion([
        const Spring.smooth(),
        const Spring.bouncy(),
      ]);
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0),
        tolerance: 0.01,
        label: 'segmented Spring.smooth+Spring.bouncy forward 0→1',
      );
    });

    test('two linear segments reverse 1→0', () {
      final motion = SegmentedMotion([
        CueMotion.linear(0.2),
        CueMotion.linear(0.3),
      ]);
      _assertInterpolation(
        motion,
        const SimulationBuildData.reverse(startValue: 1.0),
        label: 'segmented 2x linear reverse 1→0',
      );
    });

    test('partial start — segmented linear with phase=1 has finite values', () {
      final motion = SegmentedMotion([
        CueMotion.linear(0.2),
        CueMotion.linear(0.3),
      ]);
      final sim = motion.build(
        const SimulationBuildData(forward: true, startValue: 0.5, phase: 1),
      );

      for (double p = 0.0; p <= 1.0; p += 0.1) {
        final (v, _) = sim.valueAtProgress(p);
        expect(v.isFinite, isTrue, reason: 'Segmented partial start: value at $p must be finite');
      }

      final (vEnd, _) = sim.valueAtProgress(1.0);
      expect(vEnd, closeTo(1.0, 0.001), reason: 'Segmented partial start: value at progress 1.0 should be 1.0');
    });

    test('two-segment motion with elastic curves — overshoot valid', () {
      final motion = SegmentedMotion([
        CueMotion.curved(0.3, curve: Curves.elasticOut),
        CueMotion.curved(0.3, curve: Curves.elasticIn),
      ]);
      _assertInterpolation(
        motion,
        const SimulationBuildData.forward(startValue: 0.0),
        label: 'segmented 2x elastic forward 0→1',
      );
    });

    test('segmented motion produces finite values at all progress points', () {
      final motion = SegmentedMotion([
        CueMotion.curved(0.2, curve: Curves.bounceOut),
        CueMotion.curved(0.2, curve: Curves.elasticOut),
        CueMotion.linear(0.1),
      ]);
      final sim = motion.build(const SimulationBuildData.forward(startValue: 0.0));

      for (double p = 0.0; p <= 1.0; p += 0.05) {
        final (v, _) = sim.valueAtProgress(p);
        expect(v.isFinite, isTrue, reason: 'Segmented mixed: value at $p must be finite');
      }
    });
  });

  // -------------------------------------------------------------------------
  // Custom / edge-case SimulationBuildData configurations
  // -------------------------------------------------------------------------
  group('SimulationBuildData — edge cases', () {
    test('endValue defaults to 1.0 when forward=true and no endValue supplied', () {
      const data = SimulationBuildData.forward(startValue: 0.0);
      expect(data.endValue, equals(1.0));
    });

    test('endValue defaults to 0.0 when forward=false and no endValue supplied', () {
      const data = SimulationBuildData.reverse(startValue: 1.0);
      expect(data.endValue, equals(0.0));
    });

    test('explicit endValue overrides default for forward data', () {
      const data = SimulationBuildData.forward(startValue: 0.0, endValue: 0.75);
      expect(data.endValue, equals(0.75));
    });

    test('explicit endValue overrides default for reverse data', () {
      const data = SimulationBuildData.reverse(startValue: 1.0, endValue: 0.25);
      expect(data.endValue, equals(0.25));
    });

    test('SimulationBuildData general constructor forward flag', () {
      const data = SimulationBuildData(forward: true, startValue: 0.3);
      expect(data.forward, isTrue);
      expect(data.startValue, equals(0.3));
      expect(data.endValue, equals(1.0));
    });

    test('SimulationBuildData general constructor reverse flag', () {
      const data = SimulationBuildData(forward: false, startValue: 0.7);
      expect(data.forward, isFalse);
      expect(data.startValue, equals(0.7));
      expect(data.endValue, equals(0.0));
    });

    test('linear motion with non-standard range (0.25→0.75) via explicit endValue', () {
      final motion = CueMotion.linear(0.3);
      _assertInterpolation(
        motion,
        const SimulationBuildData(forward: true, startValue: 0.25, endValue: 0.75),
        label: 'linear explicit range 0.25→0.75',
      );
    });

    test('curved motion with non-standard range (0.1→0.9)', () {
      final motion = CueMotion.curved(
        0.3,
        curve: Curves.easeInOut,
      );
      _assertInterpolation(
        motion,
        const SimulationBuildData(forward: true, startValue: 0.1, endValue: 0.9),
        label: 'easeInOut explicit 0.1→0.9',
      );
    });

    test('spring with non-standard range (0.3→0.9)', () {
      final motion = const Spring.smooth();
      _assertInterpolation(
        motion,
        const SimulationBuildData(forward: true, startValue: 0.3, endValue: 0.9),
        tolerance: 0.01,
        label: 'Spring.smooth explicit 0.3→0.9',
      );
    });

    test('reverse motion with explicit endValue override (1.0→0.3)', () {
      final motion = CueMotion.linear(0.3);
      _assertInterpolation(
        motion,
        const SimulationBuildData(forward: false, startValue: 1.0, endValue: 0.3),
        label: 'linear explicit reverse 1.0→0.3',
      );
    });
  });
}
