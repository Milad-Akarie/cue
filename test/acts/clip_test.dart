import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();


  ActContext createActContext() {
    final motion = CueMotion.linear(300.ms);
    return ActContext(motion: motion, reverseMotion: motion);
  }

  group('ClipAct', () {
    group('default constructor', () {
      test('key is "Clip"', () {
        const act = ClipAct();
        expect(act.key, equals(const ActKey('Clip')));
      });

      test('equality', () {
        const radius = BorderRadius.all(Radius.circular(16));
        const act1 = ClipAct(borderRadius: radius, alignment: Alignment.center);
        const act2 = ClipAct(borderRadius: radius, alignment: Alignment.center);
        const act3 = ClipAct(borderRadius: radius, useSuperellipse: true);

        expect(act1, equals(act2));
        expect(act1, isNot(equals(act3)));
      });

      test('hashCode consistency', () {
        const radius = BorderRadius.all(Radius.circular(16));
        const act1 = ClipAct(borderRadius: radius, alignment: Alignment.center);
        const act2 = ClipAct(borderRadius: radius, alignment: Alignment.center);

        expect(act1.hashCode, equals(act2.hashCode));
      });

      test('resolve returns ActContext with motion', () {
        const act = ClipAct();
        final ctx = createActContext();
        final resolved = act.resolve(ctx);

        expect(resolved, isA<ActContext>());
      });
    });

    group('circular constructor', () {
      test('key is "Clip"', () {
        const act = ClipAct.circular();
        expect(act.key, equals(const ActKey('Clip')));
      });
    });

    group('width constructor', () {
      test('key is "Clip"', () {
        const act = ClipAct.width();
        expect(act.key, equals(const ActKey('Clip')));
      });

      test('equality', () {
        const act1 = ClipAct.width(fromFactor: 0.0, toFactor: 1.0);
        const act2 = ClipAct.width(fromFactor: 0.0, toFactor: 1.0);
        const act3 = ClipAct.width(fromFactor: 0.2, toFactor: 1.0);

        expect(act1, equals(act2));
        expect(act1, isNot(equals(act3)));
      });

      test('hashCode consistency', () {
        const act1 = ClipAct.width(fromFactor: 0.0, toFactor: 1.0);
        const act2 = ClipAct.width(fromFactor: 0.0, toFactor: 1.0);

        expect(act1.hashCode, equals(act2.hashCode));
      });
    });

    group('height constructor', () {
      test('key is "Clip"', () {
        const act = ClipAct.height();
        expect(act.key, equals(const ActKey('Clip')));
      });

      test('equality', () {
        const act1 = ClipAct.height(fromFactor: 0.0, toFactor: 1.0);
        const act2 = ClipAct.height(fromFactor: 0.0, toFactor: 1.0);
        const act3 = ClipAct.height(fromFactor: 0.2, toFactor: 1.0);

        expect(act1, equals(act2));
        expect(act1, isNot(equals(act3)));
      });

      test('hashCode consistency', () {
        const act1 = ClipAct.height(fromFactor: 0.0, toFactor: 1.0);
        const act2 = ClipAct.height(fromFactor: 0.0, toFactor: 1.0);

        expect(act1.hashCode, equals(act2.hashCode));
      });
    });
  });

  group('ExpandingPathClipper', () {
    test('shouldReclip returns true when progress changes', () {
      final clipper1 = ExpandingPathClipper(
        progress: 0.5,
        alignment: Alignment.center,
      );
      final clipper2 = ExpandingPathClipper(
        progress: 0.7,
        alignment: Alignment.center,
      );

      expect(clipper1.shouldReclip(clipper2), isTrue);
    });

    test('shouldReclip returns true when borderRadius changes', () {
      final clipper1 = ExpandingPathClipper(
        progress: 0.5,
        borderRadius: BorderRadius.circular(10),
        alignment: Alignment.center,
      );
      final clipper2 = ExpandingPathClipper(
        progress: 0.5,
        borderRadius: BorderRadius.circular(20),
        alignment: Alignment.center,
      );

      expect(clipper1.shouldReclip(clipper2), isTrue);
    });

    test('shouldReclip returns true when alignment changes', () {
      final clipper1 = ExpandingPathClipper(
        progress: 0.5,
        alignment: Alignment.center,
      );
      final clipper2 = ExpandingPathClipper(
        progress: 0.5,
        alignment: Alignment.topLeft,
      );

      expect(clipper1.shouldReclip(clipper2), isTrue);
    });

    test('shouldReclip returns true when useSuperellipse changes', () {
      final clipper1 = ExpandingPathClipper(
        progress: 0.5,
        alignment: Alignment.center,
        useSuperellipse: false,
      );
      final clipper2 = ExpandingPathClipper(
        progress: 0.5,
        alignment: Alignment.center,
        useSuperellipse: true,
      );

      expect(clipper1.shouldReclip(clipper2), isTrue);
    });

    test('shouldReclip returns false when all properties match', () {
      final clipper1 = ExpandingPathClipper(
        progress: 0.5,
        borderRadius: BorderRadius.circular(10),
        alignment: Alignment.center,
        useSuperellipse: false,
      );
      final clipper2 = ExpandingPathClipper(
        progress: 0.5,
        borderRadius: BorderRadius.circular(10),
        alignment: Alignment.center,
        useSuperellipse: false,
      );

      expect(clipper1.shouldReclip(clipper2), isFalse);
    });

    test('getClip creates oval path when borderRadius is null', () {
      final clipper = ExpandingPathClipper(
        progress: 0.5,
        alignment: Alignment.center,
      );

      final path = clipper.getClip(const Size(200, 200));

      expect(path.getBounds().width, equals(100));
      expect(path.getBounds().height, equals(100));
    });

    test('getClip creates rect path when borderRadius is zero', () {
      final clipper = ExpandingPathClipper(
        progress: 0.5,
        borderRadius: BorderRadius.zero,
        alignment: Alignment.center,
      );

      final path = clipper.getClip(const Size(200, 200));

      expect(path.getBounds().width, equals(100));
      expect(path.getBounds().height, equals(100));
    });

    test('getClip creates rounded rect path when borderRadius is set', () {
      final clipper = ExpandingPathClipper(
        progress: 0.5,
        borderRadius: BorderRadius.circular(10),
        alignment: Alignment.center,
      );

      final path = clipper.getClip(const Size(200, 200));

      expect(path.getBounds().width, equals(100));
      expect(path.getBounds().height, equals(100));
    });

    test('getClip with topLeft alignment positions rect correctly', () {
      final clipper = ExpandingPathClipper(
        progress: 0.5,
        borderRadius: BorderRadius.zero,
        alignment: Alignment.topLeft,
      );

      final path = clipper.getClip(const Size(200, 200));

      expect(path.getBounds().left, equals(0));
      expect(path.getBounds().top, equals(0));
    });

    test('getClip with bottomRight alignment positions rect correctly', () {
      final clipper = ExpandingPathClipper(
        progress: 0.5,
        borderRadius: BorderRadius.zero,
        alignment: Alignment.bottomRight,
      );

      final path = clipper.getClip(const Size(200, 200));

      expect(path.getBounds().right, equals(200));
      expect(path.getBounds().bottom, equals(200));
    });

    test('getClip with full progress covers entire size', () {
      final clipper = ExpandingPathClipper(
        progress: 1.0,
        borderRadius: BorderRadius.zero,
        alignment: Alignment.center,
      );

      final path = clipper.getClip(const Size(200, 200));

      expect(path.getBounds().width, equals(200));
      expect(path.getBounds().height, equals(200));
    });

    test('getClip with zero progress creates empty path', () {
      final clipper = ExpandingPathClipper(
        progress: 0.0,
        borderRadius: BorderRadius.zero,
        alignment: Alignment.center,
      );

      final path = clipper.getClip(const Size(200, 200));

      expect(path.getBounds().width, equals(0));
      expect(path.getBounds().height, equals(0));
    });
  });
}
