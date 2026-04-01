
import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final motion = CueMotion.linear(300.ms);
  final actContext = ActContext(motion: motion, reverseMotion: motion);
 

  group('PathMotionAct', () {
    group('key', () {
      test('has correct key name', () {
        final path = Path()..lineTo(100, 0);
        final act = PathMotionAct(path: path);
        expect(act.key.key, 'PathMotionAct');
      });
    });

    group('default constructor', () {
      test('requires path', () {
        final path = Path()..lineTo(100, 0);
        final act = PathMotionAct(path: path);
        expect(act.path, path);
      });

      test('default autoRotate is false', () {
        final path = Path()..lineTo(100, 0);
        final act = PathMotionAct(path: path);
        expect(act.autoRotate, false);
      });

      test('accepts autoRotate', () {
        final path = Path()..lineTo(100, 0);
        final act = PathMotionAct(path: path, autoRotate: true);
        expect(act.autoRotate, true);
      });

      test('default alignment is center', () {
        final path = Path()..lineTo(100, 0);
        final act = PathMotionAct(path: path);
        expect(act.alignment, Alignment.center);
      });

      test('accepts alignment', () {
        final path = Path()..lineTo(100, 0);
        final act = PathMotionAct(path: path, alignment: Alignment.topLeft);
        expect(act.alignment, Alignment.topLeft);
      });

      test('accepts motion', () {
        final path = Path()..lineTo(100, 0);
        final motion = CueMotion.linear(300.ms);
        final act = PathMotionAct(path: path, motion: motion);
        expect(act.motion, motion);
      });

      test('accepts delay', () {
        final path = Path()..lineTo(100, 0);
        final act = PathMotionAct(
          path: path,
          delay: const Duration(milliseconds: 100),
        );
        expect(act.delay, const Duration(milliseconds: 100));
      });
    });

    group('circular constructor', () {
      test('creates circular path with radius', () {
        final act = PathMotionAct.circular(radius: 50);
        expect(act.path, isNotNull);
      });

      test('accepts center offset', () {
        final act = PathMotionAct.circular(
          radius: 50,
          center: const Offset(100, 100),
        );
        expect(act.path, isNotNull);
      });

      test('accepts startAngle', () {
        final act = PathMotionAct.circular(
          radius: 50,
          startAngle: 90,
        );
        expect(act.path, isNotNull);
      });

      test('accepts autoRotate', () {
        final act = PathMotionAct.circular(radius: 50, autoRotate: true);
        expect(act.autoRotate, true);
      });

      test('accepts alignment', () {
        final act = PathMotionAct.circular(
          radius: 50,
          alignment: Alignment.bottomRight,
        );
        expect(act.alignment, Alignment.bottomRight);
      });
    });

    group('arc constructor', () {
      test('requires radius and sweepAngle', () {
        final act = PathMotionAct.arc(
          radius: 50,
          sweepAngle: 90,
        );
        expect(act.path, isNotNull);
      });

      test('accepts center offset', () {
        final act = PathMotionAct.arc(
          radius: 50,
          sweepAngle: 90,
          center: const Offset(100, 100),
        );
        expect(act.path, isNotNull);
      });

      test('accepts startAngle', () {
        final act = PathMotionAct.arc(
          radius: 50,
          sweepAngle: 90,
          startAngle: 45,
        );
        expect(act.path, isNotNull);
      });

      test('accepts startOffset', () {
        final act = PathMotionAct.arc(
          radius: 50,
          sweepAngle: 90,
          startOffset: 30,
        );
        expect(act.path, isNotNull);
      });

      test('accepts autoRotate', () {
        final act = PathMotionAct.arc(
          radius: 50,
          sweepAngle: 90,
          autoRotate: true,
        );
        expect(act.autoRotate, true);
      });
    });

    group('resolve', () {
      test('returns ActContext with motion', () {
        final path = Path()..lineTo(100, 0);
        final motion = CueMotion.linear(300.ms);
        final act = PathMotionAct(path: path, motion: motion);
        
        final resolved = act.resolve(actContext);
        expect(resolved.motion, isNotNull);
      });
    });

    group('equality', () {
      test('equal acts have same hashCode', () {
        final path = Path()..lineTo(100, 0);
        final act1 = PathMotionAct(path: path, autoRotate: true);
        final act2 = PathMotionAct(path: path, autoRotate: true);
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });

      test('different paths are not equal', () {
        final path1 = Path()..lineTo(100, 0);
        final path2 = Path()..lineTo(200, 0);
        final act1 = PathMotionAct(path: path1);
        final act2 = PathMotionAct(path: path2);
        expect(act1, isNot(act2));
      });

      test('different autoRotate values are not equal', () {
        final path = Path()..lineTo(100, 0);
        final act1 = PathMotionAct(path: path, autoRotate: true);
        final act2 = PathMotionAct(path: path, autoRotate: false);
        expect(act1, isNot(act2));
      });
    });
  });
}
