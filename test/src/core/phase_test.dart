// import 'package:flutter_test/flutter_test.dart';
// import 'package:cue/src/core/phase.dart';
// import 'package:cue/src/core/core.dart';
//
// void main() {
//   group('Phase.normalize', () {
//     group('Basic functionality', () {
//       test('empty list returns empty phases and no timing', () {
//         final result = Phase.normalize<double>([]);
//         expect(result.phases, isEmpty);
//         expect(result.timing, isNull);
//       });
//
//       test('single keyframe at 0.0 returns constant phase and no timing', () {
//         final frames = [Keyframe(100.0, at: 0.0)];
//         final result = Phase.normalize(frames);
//         expect(result.phases, [
//           const Phase(begin: 100.0, end: 100.0, weight: 100.0),
//         ]);
//         expect(result.phases.first.isAlwaysStopped, isTrue);
//         expect(result.timing, isNull);
//       });
//
//       test('single keyframe at 1.0 returns constant phase and no timing', () {
//         final frames = [Keyframe(100.0, at: 1.0)];
//         final result = Phase.normalize(frames);
//         expect(result.phases, [
//           const Phase(begin: 100.0, end: 100.0, weight: 100.0),
//         ]);
//         expect(result.phases.first.isAlwaysStopped, isTrue);
//         expect(result.timing, isNull);
//       });
//
//       test('single keyframe at 0.5 returns constant phase with timing', () {
//         final frames = [Keyframe(50.0, at: 0.5)];
//         final result = Phase.normalize(frames);
//         expect(result.phases, [
//           const Phase(begin: 50.0, end: 50.0, weight: 100.0),
//         ]);
//         expect(result.phases.first.isAlwaysStopped, isTrue);
//         expect(result.timing, const Timing(start: 0.5, end: 0.5));
//       });
//
//       test('two keyframes at 0.0 and 1.0 creates one phase with weight 1.0', () {
//         final frames = [Keyframe(0.0, at: 0.0), Keyframe(100.0, at: 1.0)];
//         final result = Phase.normalize(frames);
//         expect(result.phases, [
//           const Phase(begin: 0.0, end: 100.0, weight: 100.0),
//         ]);
//         expect(result.timing, isNull);
//       });
//
//       test('two keyframes at 0.0 and 0.5 creates one phase with weight 0.5 and timing', () {
//         final frames = [Keyframe(0.0, at: 0.0), Keyframe(100.0, at: 0.5)];
//         final result = Phase.normalize(frames);
//         expect(result.phases, [
//           const Phase(begin: 0.0, end: 100.0, weight: 50.0),
//         ]);
//         expect(result.timing, const Timing(start: 0.0, end: 0.5));
//       });
//
//       test('three keyframes evenly spaced creates two phases', () {
//         final result = Phase.normalize([
//           .key(0.0, at: 0.0),
//           .key(50.0, at: 0.5),
//           .key(100.0, at: 1.0),
//         ]);
//         expect(result.phases, [
//           const Phase(begin: 0.0, end: 50.0, weight: 50.0),
//           const Phase(begin: 50.0, end: 100.0, weight: 50.0),
//         ]);
//         expect(result.timing, isNull);
//       });
//     });
//
//     group('Weight calculation based on time differences', () {
//       test('uneven spacing creates different weights', () {
//         final frames = [
//           Keyframe(0.0, at: 0.0),
//           Keyframe(25.0, at: 0.25),
//           Keyframe(50.0, at: 0.75),
//           Keyframe(100.0, at: 1.0),
//         ];
//         final result = Phase.normalize(frames);
//         expect(result.phases, [
//           const Phase(begin: 0.0, end: 25.0, weight: 25.0),
//           const Phase(begin: 25.0, end: 50.0, weight: 50.0),
//           const Phase(begin: 50.0, end: 100.0, weight: 25.0),
//         ]);
//         expect(result.timing, isNull);
//       });
//
//       test('keyframes at 0.1, 0.2, 0.9 create phases with correct weights', () {
//         final frames = [
//           Keyframe(10.0, at: 0.1),
//           Keyframe(20.0, at: 0.2),
//           Keyframe(90.0, at: 0.9),
//         ];
//         final result = Phase.normalize(frames);
//         expect(result.phases, [
//           const Phase(begin: 10.0, end: 20.0, weight: 10.0),
//           const Phase(begin: 20.0, end: 90.0, weight: 70.0),
//         ]);
//         expect(result.timing, const Timing(start: 0.1, end: 0.9));
//       });
//
//       test('very close keyframes create small weights', () {
//         final frames = [
//           Keyframe(0.0, at: 0.0),
//           Keyframe(50.0, at: 0.01),
//           Keyframe(100.0, at: 1.0),
//         ];
//         final result = Phase.normalize(frames);
//         expect(result.phases, [
//           const Phase(begin: 0.0, end: 50.0, weight: 1.0),
//           const Phase(begin: 50.0, end: 100.0, weight: 99.0),
//         ]);
//         expect(result.timing, isNull);
//       });
//     });
//
//     group('Duplicate time points (keep last)', () {
//       test('duplicate at same time keeps last value', () {
//         final frames = [
//           Keyframe(0.0, at: 0.0),
//           Keyframe(25.0, at: 0.5),
//           Keyframe(75.0, at: 0.5), // This should override the previous one
//           Keyframe(100.0, at: 1.0),
//         ];
//         final result = Phase.normalize(frames);
//         expect(result.phases, [
//           const Phase(begin: 0.0, end: 75.0, weight: 50.0),
//           const Phase(begin: 75.0, end: 100.0, weight: 50.0),
//         ]);
//         expect(result.timing, isNull);
//       });
//
//       test('multiple duplicates keeps only last', () {
//         final frames = [
//           Keyframe(0.0, at: 0.0),
//           Keyframe(10.0, at: 0.5),
//           Keyframe(20.0, at: 0.5),
//           Keyframe(30.0, at: 0.5),
//           Keyframe(100.0, at: 1.0),
//         ];
//         final result = Phase.normalize(frames);
//         expect(result.phases, [
//           const Phase(begin: 0.0, end: 30.0, weight: 50.0),
//           const Phase(begin: 30.0, end: 100.0, weight: 50.0),
//         ]);
//       });
//
//       test('all duplicates at same time results in single constant phase', () {
//         final frames = [
//           Keyframe(10.0, at: 0.5),
//           Keyframe(20.0, at: 0.5),
//           Keyframe(30.0, at: 0.5),
//         ];
//         final result = Phase.normalize(frames);
//         expect(result.phases, [
//           const Phase(begin: 30.0, end: 30.0, weight: 100.0),
//         ]);
//         expect(result.phases.first.isAlwaysStopped, isTrue);
//         expect(result.timing, const Timing(start: 0.5, end: 0.5));
//       });
//     });
//
//     group('Clamping time points to [0, 1]', () {
//       test('negative time clamped to 0.0', () {
//         final frames = [
//           Keyframe(0.0, at: -0.5),
//           Keyframe(100.0, at: 1.0),
//         ];
//         final result = Phase.normalize(frames);
//         expect(result.phases, [
//           const Phase(begin: 0.0, end: 100.0, weight: 100.0),
//         ]);
//         expect(result.timing, isNull);
//       });
//
//       test('time > 1.0 clamped to 1.0', () {
//         final frames = [
//           Keyframe(0.0, at: 0.0),
//           Keyframe(100.0, at: 1.5),
//         ];
//         final result = Phase.normalize(frames);
//         expect(result.phases, [
//           const Phase(begin: 0.0, end: 100.0, weight: 100.0),
//         ]);
//         expect(result.timing, isNull);
//       });
//
//       test('multiple out-of-range times clamped and deduplicated', () {
//         final frames = [
//           Keyframe(0.0, at: -0.5),
//           Keyframe(10.0, at: -0.1),
//           Keyframe(100.0, at: 1.2),
//           Keyframe(200.0, at: 1.5),
//         ];
//         final result = Phase.normalize(frames);
//         // After clamping: -0.5->0.0, -0.1->0.0, 1.2->1.0, 1.5->1.0
//         // After deduplication (keep last): 0.0->10.0, 1.0->200.0
//         expect(result.phases, [
//           const Phase(begin: 10.0, end: 200.0, weight: 100.0),
//         ]);
//         expect(result.timing, isNull);
//       });
//
//       test('clamping causes collision and deduplication', () {
//         final frames = [
//           Keyframe(50.0, at: 0.5),
//           Keyframe(75.0, at: 1.1),
//           Keyframe(100.0, at: 1.5),
//         ];
//         final result = Phase.normalize(frames);
//         // After clamping: 0.5->0.5, 1.1->1.0, 1.5->1.0
//         // After deduplication: 0.5->50.0, 1.0->100.0
//         expect(result.phases, [
//           const Phase(begin: 50.0, end: 100.0, weight: 50.0),
//         ]);
//         expect(result.timing, const Timing(start: 0.5, end: 1.0));
//       });
//     });
//
//     group('Timing return values', () {
//       test('frames starting at 0.0 and ending at 1.0 return null timing', () {
//         final frames = [Keyframe(0.0, at: 0.0), Keyframe(100.0, at: 1.0)];
//         final result = Phase.normalize(frames);
//         expect(result.timing, isNull);
//       });
//
//       test('frames starting at 0.2 return timing with start', () {
//         final frames = [Keyframe(0.0, at: 0.2), Keyframe(100.0, at: 1.0)];
//         final result = Phase.normalize(frames);
//         expect(result.timing, const Timing(start: 0.2, end: 1.0));
//       });
//
//       test('frames ending at 0.8 return timing with end', () {
//         final frames = [Keyframe(0.0, at: 0.0), Keyframe(100.0, at: 0.8)];
//         final result = Phase.normalize(frames);
//         expect(result.timing, const Timing(start: 0.0, end: 0.8));
//       });
//
//       test('frames in middle return timing with both start and end', () {
//         final frames = [Keyframe(0.0, at: 0.3), Keyframe(100.0, at: 0.7)];
//         final result = Phase.normalize(frames);
//         expect(result.timing, const Timing(start: 0.3, end: 0.7));
//       });
//
//       test('timing respects exact values', () {
//         final frames = [Keyframe(0.0, at: 0.123), Keyframe(100.0, at: 0.789)];
//         final result = Phase.normalize(frames);
//         expect(result.timing, const Timing(start: 0.123, end: 0.789));
//       });
//     });
//
//     group('Edge cases and weird scenarios', () {
//       test('zero weight phase when keyframes are at same time', () {
//         final frames = [
//           Keyframe(0.0, at: 0.0),
//           Keyframe(50.0, at: 0.5),
//           Keyframe(100.0, at: 0.5), // Duplicate, will replace previous
//           Keyframe(200.0, at: 1.0),
//         ];
//         final result = Phase.normalize(frames);
//         expect(result.phases.length, 2);
//         expect(result.phases[0].weight, 50.0);
//         expect(result.phases[1].weight, 50.0);
//       });
//
//       test('backwards time order gets sorted', () {
//         final frames = [
//           Keyframe(100.0, at: 1.0),
//           Keyframe(50.0, at: 0.5),
//           Keyframe(0.0, at: 0.0),
//         ];
//         final result = Phase.normalize(frames);
//         expect(result.phases, [
//           const Phase(begin: 0.0, end: 50.0, weight: 50.0),
//           const Phase(begin: 50.0, end: 100.0, weight: 50.0),
//         ]);
//       });
//
//       test('random order gets sorted correctly', () {
//         final frames = [
//           Keyframe(75.0, at: 0.75),
//           Keyframe(0.0, at: 0.0),
//           Keyframe(100.0, at: 1.0),
//           Keyframe(25.0, at: 0.25),
//           Keyframe(50.0, at: 0.5),
//         ];
//         final result = Phase.normalize(frames);
//         expect(result.phases.length, 4);
//         expect(result.phases[0], const Phase(begin: 0.0, end: 25.0, weight: 25.0));
//         expect(result.phases[1], const Phase(begin: 25.0, end: 50.0, weight: 25.0));
//         expect(result.phases[2], const Phase(begin: 50.0, end: 75.0, weight: 25.0));
//         expect(result.phases[3], const Phase(begin: 75.0, end: 100.0, weight: 25.0));
//       });
//
//       test('all keyframes at same time after clamping and deduplication', () {
//         final frames = [
//           Keyframe(10.0, at: -1.0),
//           Keyframe(20.0, at: -0.5),
//           Keyframe(30.0, at: 0.0),
//         ];
//         final result = Phase.normalize(frames);
//         // All negative times clamped to 0.0, last wins (30.0)
//         expect(result.phases, [
//           const Phase(begin: 30.0, end: 30.0, weight: 100.0),
//         ]);
//         expect(result.phases.first.isAlwaysStopped, isTrue);
//         expect(result.timing, isNull);
//       });
//
//       test('negative values work correctly', () {
//         final frames = [
//           Keyframe(-100.0, at: 0.0),
//           Keyframe(0.0, at: 0.5),
//           Keyframe(100.0, at: 1.0),
//         ];
//         final result = Phase.normalize(frames);
//         expect(result.phases, [
//           const Phase(begin: -100.0, end: 0.0, weight: 50.0),
//           const Phase(begin: 0.0, end: 100.0, weight: 50.0),
//         ]);
//       });
//
//       test('backwards animation (decreasing values)', () {
//         final frames = [
//           Keyframe(100.0, at: 0.0),
//           Keyframe(50.0, at: 0.5),
//           Keyframe(0.0, at: 1.0),
//         ];
//         final result = Phase.normalize(frames);
//         expect(result.phases, [
//           const Phase(begin: 100.0, end: 50.0, weight: 50.0),
//           const Phase(begin: 50.0, end: 0.0, weight: 50.0),
//         ]);
//       });
//
//       test('constant value across all keyframes creates zero-change phases', () {
//         final frames = [
//           Keyframe(50.0, at: 0.0),
//           Keyframe(50.0, at: 0.5),
//           Keyframe(50.0, at: 1.0),
//         ];
//         final result = Phase.normalize(frames);
//         expect(result.phases, [
//           const Phase(begin: 50.0, end: 50.0, weight: 50.0),
//           const Phase(begin: 50.0, end: 50.0, weight: 50.0),
//         ]);
//       });
//
//       test('very small time differences', () {
//         final frames = [
//           Keyframe(0.0, at: 0.0),
//           Keyframe(50.0, at: 0.001),
//           Keyframe(100.0, at: 1.0),
//         ];
//         final result = Phase.normalize(frames);
//         expect(result.phases.length, 2);
//         expect(result.phases[0].weight, closeTo(0.1, 0.01));
//         expect(result.phases[1].weight, closeTo(99.9, 0.01));
//       });
//
//       test('precision at boundaries', () {
//         final frames = [
//           Keyframe(0.0, at: 0.0),
//           Keyframe(50.0, at: 0.0000001),
//           Keyframe(100.0, at: 0.9999999),
//           Keyframe(200.0, at: 1.0),
//         ];
//         final result = Phase.normalize(frames);
//         expect(result.phases.length, 3);
//         expect(result.timing, isNull);
//       });
//     });
//
//     group('Real-world animation scenarios', () {
//       test('bounce effect with varying speeds', () {
//         final frames = [
//           Keyframe(0.0, at: 0.0),
//           Keyframe(100.0, at: 0.4), // Fast up
//           Keyframe(80.0, at: 0.6), // Quick down
//           Keyframe(90.0, at: 0.8), // Small bounce
//           Keyframe(100.0, at: 1.0), // Settle
//         ];
//         final result = Phase.normalize(frames);
//         expect(result.phases.length, 4);
//         expect(result.phases[0].weight.roundToDouble(), 40.0);
//         expect(result.phases[1].weight.roundToDouble(), 20.0);
//         expect(result.phases[2].weight.roundToDouble(), 20.0);
//         expect(result.phases[3].weight.roundToDouble(), 20.0);
//       });
//
//       test('ease-in effect (slow start, fast end)', () {
//         final frames = [
//           Keyframe(0.0, at: 0.0),
//           Keyframe(10.0, at: 0.5), // Slow first half
//           Keyframe(100.0, at: 1.0), // Fast second half
//         ];
//         final result = Phase.normalize(frames);
//         expect(result.phases, [
//           const Phase(begin: 0.0, end: 10.0, weight: 50.0),
//           const Phase(begin: 10.0, end: 100.0, weight: 50.0),
//         ]);
//       });
//
//       test('pause in middle of animation', () {
//         final frames = [
//           Keyframe(0.0, at: 0.0),
//           Keyframe(100.0, at: 0.3),
//           Keyframe(100.0, at: 0.7), // Hold position
//           Keyframe(200.0, at: 1.0),
//         ];
//         final result = Phase.normalize(frames);
//         expect(result.phases.length, 3);
//         expect(result.phases[0].begin, 0.0);
//         expect(result.phases[0].end, 100.0);
//         expect(result.phases[0].weight.roundToDouble(), 30.0);
//
//         expect(result.phases[1].begin, 100.0);
//         expect(result.phases[1].end, 100.0);
//         expect(result.phases[1].weight.roundToDouble(), 40.0);
//
//         expect(result.phases[2].begin, 100.0);
//         expect(result.phases[2].end, 200.0);
//         expect(result.phases[2].weight.roundToDouble(), 30.0);
//       });
//
//       test('complex multi-stage animation', () {
//         final frames = [
//           Keyframe(0.0, at: 0.0),
//           Keyframe(20.0, at: 0.1),
//           Keyframe(30.0, at: 0.15),
//           Keyframe(80.0, at: 0.6),
//           Keyframe(85.0, at: 0.8),
//           Keyframe(100.0, at: 1.0),
//         ];
//         final result = Phase.normalize(frames);
//         expect(result.phases.length, 5);
//         expect(result.phases[0].weight.roundToDouble(), 10.0);
//         expect(result.phases[1].weight.roundToDouble(), 5.0);
//         expect(result.phases[2].weight.roundToDouble(), 45.0);
//         expect(result.phases[3].weight.roundToDouble(), 20.0);
//         expect(result.phases[4].weight.roundToDouble(), 20.0);
//       });
//     });
//
//     group('Phase equality', () {
//       test('identical phases are equal', () {
//         const phase1 = Phase(begin: 0.0, end: 100.0, weight: 100.0);
//         const phase2 = Phase(begin: 0.0, end: 100.0, weight: 100.0);
//         expect(phase1, equals(phase2));
//       });
//
//       test('phases with different weights are not equal', () {
//         const phase1 = Phase(begin: 0.0, end: 100.0, weight: 100.0);
//         const phase2 = Phase(begin: 0.0, end: 100.0, weight: 50.0);
//         expect(phase1, isNot(equals(phase2)));
//       });
//
//       test('phases with different begin values are not equal', () {
//         const phase1 = Phase(begin: 0.0, end: 100.0, weight: 100.0);
//         const phase2 = Phase(begin: 50.0, end: 100.0, weight: 100.0);
//         expect(phase1, isNot(equals(phase2)));
//       });
//
//       test('phases with different end values are not equal', () {
//         const phase1 = Phase(begin: 0.0, end: 100.0, weight: 100.0);
//         const phase2 = Phase(begin: 0.0, end: 50.0, weight: 100.0);
//         expect(phase1, isNot(equals(phase2)));
//       });
//     });
//   });
// }
