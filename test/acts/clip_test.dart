import 'package:cue/cue.dart';
import 'package:cue/src/acts/base/act.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final motion = CueMotion.linear(300.ms);
  final actContext = ActContext(motion: motion, reverseMotion: motion);

  group('ClipAct', () {
    group('default constructor', () {
      test('key is "Clip"', () {
        const act = ClipAct();
        expect(act.key, equals(const ActKey('Clip')));
      });

      test('constructor with motion', () {
        final motion = CueMotion.linear(500.ms);
        final act = PathClipAct(motion: motion);
        expect(act.motion, equals(motion));
      });

      test('constructor with delay', () {
        const delay = Duration(milliseconds: 200);
        final act = PathClipAct(delay: delay);
        expect(act.delay, equals(delay));
      });

      test('constructor with borderRadius', () {
        final radius = BorderRadius.all(Radius.circular(16));
        final act = PathClipAct(borderRadius: radius);
        expect(act.borderRadius, equals(radius));
      });

      test('constructor with alignment', () {
        const act = PathClipAct(alignment: Alignment.topLeft);
        expect(act.alignment, equals(Alignment.topLeft));
      });

      test('constructor with useSuperellipse', () {
        const act = PathClipAct(useSuperellipse: true);
        expect(act.useSuperellipse, isTrue);
      });

      test('constructor with all parameters', () {
        final motion = CueMotion.linear(500.ms);
        final radius = BorderRadius.all(Radius.circular(12));
        const delay = Duration(milliseconds: 150);
        final act = PathClipAct(
          motion: motion,
          delay: delay,
          borderRadius: radius,
          alignment: Alignment.center,
          useSuperellipse: true,
        );
        expect(act.motion, equals(motion));
        expect(act.delay, equals(delay));
        expect(act.borderRadius, equals(radius));
        expect(act.alignment, equals(Alignment.center));
        expect(act.useSuperellipse, isTrue);
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

        final resolved = act.resolve(actContext);

        expect(resolved, isA<ActContext>());
      });
    });

    group('circular constructor', () {
      test('key is "Clip"', () {
        const act = ClipAct.circular();
        expect(act.key, equals(const ActKey('Clip')));
      });

      test('constructor with motion', () {
        final motion = CueMotion.linear(500.ms);
        final act = PathClipAct.circular(motion: motion);
        expect(act.motion, equals(motion));
      });

      test('constructor with delay', () {
        const delay = Duration(milliseconds: 200);
        final act = PathClipAct.circular(delay: delay);
        expect(act.delay, equals(delay));
      });

      test('constructor with alignment', () {
        const act = PathClipAct.circular(alignment: Alignment.topCenter);
        expect(act.alignment, equals(Alignment.topCenter));
      });

      test('constructor with all parameters', () {
        final motion = CueMotion.linear(500.ms);
        const delay = Duration(milliseconds: 150);
        final act = PathClipAct.circular(
          motion: motion,
          delay: delay,
          alignment: Alignment.center,
        );
        expect(act.motion, equals(motion));
        expect(act.delay, equals(delay));
        expect(act.alignment, equals(Alignment.center));
      });
    });

    group('width constructor', () {
      test('key is "Clip"', () {
        const act = AxisClipAct.horizontal();
        expect(act.key, equals(const ActKey('Clip')));
      });

      test('constructor with custom fromFactor and toFactor', () {
        const act = AxisClipAct.horizontal(fromFactor: 0.2, toFactor: 0.8);
        expect(act.from, equals(0.2));
        expect(act.to, equals(0.8));
      });

      test('constructor with motion', () {
        final motion = CueMotion.linear(500.ms);
        final act = AxisClipAct.horizontal(motion: motion);
        expect(act.motion, equals(motion));
      });

      test('constructor with delay', () {
        const delay = Duration(milliseconds: 200);
        const act = AxisClipAct.horizontal(delay: delay);
        expect(act.delay, equals(delay));
      });

      test('constructor with alignment', () {
        final act = AxisClipAct.horizontal(alignment: Alignment.center);
        expect(act.alignment, equals(Alignment.center));
      });

      test('constructor with all parameters', () {
        final motion = CueMotion.linear(500.ms);
        const delay = Duration(milliseconds: 150);
        final act = AxisClipAct.horizontal(
          fromFactor: 0.1,
          toFactor: 0.9,
          motion: motion,
          delay: delay,
          alignment: Alignment.center,
        );
        expect(act.from, equals(0.1));
        expect(act.to, equals(0.9));
        expect(act.motion, equals(motion));
        expect(act.delay, equals(delay));
        expect(act.alignment, equals(Alignment.center));
      });

      test('equality', () {
        const act1 = AxisClipAct.horizontal(fromFactor: 0.0, toFactor: 1.0);
        const act2 = AxisClipAct.horizontal(fromFactor: 0.0, toFactor: 1.0);
        const act3 = AxisClipAct.horizontal(fromFactor: 0.2, toFactor: 1.0);

        expect(act1, equals(act2));
        expect(act1, isNot(equals(act3)));
      });

      test('hashCode consistency', () {
        const act1 = AxisClipAct.horizontal(fromFactor: 0.0, toFactor: 1.0);
        const act2 = AxisClipAct.horizontal(fromFactor: 0.0, toFactor: 1.0);

        expect(act1.hashCode, equals(act2.hashCode));
      });
    });

    group('height constructor', () {
      test('key is "Clip"', () {
        const act = AxisClipAct.vertical();
        expect(act.key, equals(const ActKey('Clip')));
      });

      test('constructor with custom fromFactor and toFactor', () {
        const act = AxisClipAct.vertical(fromFactor: 0.2, toFactor: 0.8);
        expect(act.from, equals(0.2));
        expect(act.to, equals(0.8));
      });

      test('constructor with motion', () {
        final motion = CueMotion.linear(500.ms);
        final act = AxisClipAct.vertical(motion: motion);
        expect(act.motion, equals(motion));
      });

      test('constructor with delay', () {
        const delay = Duration(milliseconds: 200);
        const act = AxisClipAct.vertical(delay: delay);
        expect(act.delay, equals(delay));
      });

      test('constructor with alignment', () {
        const act = AxisClipAct.vertical(alignment: Alignment.topCenter);
        expect(act.alignment, equals(Alignment.topCenter));
      });

      test('constructor with all parameters', () {
        final motion = CueMotion.linear(500.ms);
        const delay = Duration(milliseconds: 150);
        final act = AxisClipAct.vertical(
          fromFactor: 0.1,
          toFactor: 0.9,
          motion: motion,
          delay: delay,
          alignment: Alignment.center,
        );
        expect(act.from, equals(0.1));
        expect(act.to, equals(0.9));
        expect(act.motion, equals(motion));
        expect(act.delay, equals(delay));
        expect(act.alignment, equals(Alignment.center));
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

    test('getClip with superellipse enabled', () {
      final clipper = ExpandingPathClipper(
        progress: 0.5,
        borderRadius: BorderRadius.circular(10),
        alignment: Alignment.center,
        useSuperellipse: true,
      );

      final path = clipper.getClip(const Size(200, 200));

      expect(path.getBounds().width, closeTo(100, 0.1));
      expect(path.getBounds().height, closeTo(100, 0.1));
    });

    test('getClip with center alignment positions rect correctly', () {
      final clipper = ExpandingPathClipper(
        progress: 0.5,
        borderRadius: BorderRadius.zero,
        alignment: Alignment.center,
      );

      final path = clipper.getClip(const Size(200, 200));

      expect(path.getBounds().left, equals(50));
      expect(path.getBounds().top, equals(50));
    });
  });

  group('PathClipAct', () {
    test('pathClipAct constructor with default values', () {
      const act = PathClipAct();
      expect(act.key.key, equals('Clip'));
      expect(act.borderRadius, equals(BorderRadius.zero));
      expect(act.alignment, isNull);
      expect(act.useSuperellipse, isFalse);
      expect(act.from, equals(0));
      expect(act.to, equals(1));
    });

    test('pathClipAct constructor with borderRadius', () {
      final radius = BorderRadius.circular(16);
      final act = PathClipAct(borderRadius: radius);
      expect(act.borderRadius, equals(radius));
    });

    test('pathClipAct constructor with alignment', () {
      final act = PathClipAct(alignment: Alignment.center);
      expect(act.alignment, equals(Alignment.center));
    });

    test('pathClipAct constructor with useSuperellipse', () {
      const act = PathClipAct(useSuperellipse: true);
      expect(act.useSuperellipse, isTrue);
    });

    test('pathClipAct constructor with motion', () {
      final motion = CueMotion.linear(500.ms);
      final act = PathClipAct(motion: motion);
      expect(act.motion, equals(motion));
    });

    test('pathClipAct constructor with delay', () {
      const delay = Duration(milliseconds: 200);
      const act = PathClipAct(delay: delay);
      expect(act.delay, equals(delay));
    });

    test('pathClipAct constructor with custom from/to', () {
      const act = PathClipAct(from: 0.2, to: 0.8);
      expect(act.from, equals(0.2));
      expect(act.to, equals(0.8));
    });

    test('pathClipAct circular constructor', () {
      const act = PathClipAct.circular();
      expect(act.borderRadius, isNull);
      expect(act.useSuperellipse, isFalse);
      expect(act.from, equals(0));
      expect(act.to, equals(1));
    });

    test('pathClipAct circular with alignment', () {
      const act = PathClipAct.circular(alignment: Alignment.topRight);
      expect(act.alignment, equals(Alignment.topRight));
    });

    test('pathClipAct circular with motion', () {
      final motion = CueMotion.linear(500.ms);
      final act = PathClipAct.circular(motion: motion);
      expect(act.motion, equals(motion));
    });

    test('pathClipAct equality', () {
      final radius = BorderRadius.circular(10);
      final act1 = PathClipAct(borderRadius: radius, alignment: Alignment.center);
      final act2 = PathClipAct(borderRadius: radius, alignment: Alignment.center);
      final act3 = PathClipAct(borderRadius: radius, useSuperellipse: true);

      expect(act1, equals(act2));
      expect(act1, isNot(equals(act3)));
    });

    test('pathClipAct hashCode', () {
      final radius = BorderRadius.circular(10);
      final act1 = PathClipAct(borderRadius: radius);
      final act2 = PathClipAct(borderRadius: radius);

      expect(act1.hashCode, equals(act2.hashCode));
    });
  });

  group('AxisClipAct', () {
    test('AxisClipAct horizontal constructor defaults', () {
      const act = AxisClipAct.horizontal();
      expect(act.key.key, equals('Clip'));
      expect(act.from, equals(0));
      expect(act.to, equals(1));
      expect(act.alignment, equals(AlignmentDirectional.centerStart));
    });

    test('AxisClipAct horizontal with custom fromFactor', () {
      const act = AxisClipAct.horizontal(fromFactor: 0.2);
      expect(act.from, equals(0.2));
    });

    test('AxisClipAct horizontal with custom toFactor', () {
      const act = AxisClipAct.horizontal(toFactor: 0.8);
      expect(act.to, equals(0.8));
    });

    test('AxisClipAct horizontal with alignment', () {
      const act = AxisClipAct.horizontal(alignment: Alignment.centerLeft);
      expect(act.alignment, equals(Alignment.centerLeft));
    });

    test('AxisClipAct horizontal with motion', () {
      final motion = CueMotion.linear(500.ms);
      final act = AxisClipAct.horizontal(motion: motion);
      expect(act.motion, equals(motion));
    });

    test('AxisClipAct horizontal with delay', () {
      const delay = Duration(milliseconds: 200);
      const act = AxisClipAct.horizontal(delay: delay);
      expect(act.delay, equals(delay));
    });

    test('AxisClipAct vertical constructor defaults', () {
      const act = AxisClipAct.vertical();
      expect(act.key.key, equals('Clip'));
      expect(act.from, equals(0));
      expect(act.to, equals(1));
      expect(act.alignment, equals(AlignmentDirectional.topCenter));
    });

    test('AxisClipAct vertical with custom fromFactor', () {
      const act = AxisClipAct.vertical(fromFactor: 0.1);
      expect(act.from, equals(0.1));
    });

    test('AxisClipAct vertical with custom toFactor', () {
      const act = AxisClipAct.vertical(toFactor: 0.9);
      expect(act.to, equals(0.9));
    });

    test('AxisClipAct vertical with alignment', () {
      const act = AxisClipAct.vertical(alignment: Alignment.bottomCenter);
      expect(act.alignment, equals(Alignment.bottomCenter));
    });

    test('AxisClipAct vertical with motion', () {
      final motion = CueMotion.linear(500.ms);
      final act = AxisClipAct.vertical(motion: motion);
      expect(act.motion, equals(motion));
    });

    test('AxisClipAct vertical with delay', () {
      const delay = Duration(milliseconds: 200);
      const act = AxisClipAct.vertical(delay: delay);
      expect(act.delay, equals(delay));
    });

    test('AxisClipAct horizontal equality', () {
      const act1 = AxisClipAct.horizontal(fromFactor: 0.0, toFactor: 1.0);
      const act2 = AxisClipAct.horizontal(fromFactor: 0.0, toFactor: 1.0);
      const act3 = AxisClipAct.horizontal(fromFactor: 0.2, toFactor: 1.0);

      expect(act1, equals(act2));
      expect(act1, isNot(equals(act3)));
    });

    test('AxisClipAct horizontal hashCode', () {
      const act1 = AxisClipAct.horizontal();
      const act2 = AxisClipAct.horizontal();

      expect(act1.hashCode, equals(act2.hashCode));
    });

    test('AxisClipAct vertical equality', () {
      const act1 = AxisClipAct.vertical(fromFactor: 0.0, toFactor: 1.0);
      const act2 = AxisClipAct.vertical(fromFactor: 0.0, toFactor: 1.0);
      const act3 = AxisClipAct.vertical(fromFactor: 0.2);

      expect(act1, equals(act2));
      expect(act1, isNot(equals(act3)));
    });

    test('AxisClipAct vertical hashCode', () {
      const act1 = AxisClipAct.vertical();
      const act2 = AxisClipAct.vertical();

      expect(act1.hashCode, equals(act2.hashCode));
    });

    test('horizontal and vertical AxisClipAct are not equal', () {
      const act1 = AxisClipAct.horizontal();
      const act2 = AxisClipAct.vertical();

      expect(act1, isNot(equals(act2)));
    });
  });

  group('apply methods', () {
    testWidgets('PathClipAct apply creates ClipPath widget', (tester) async {
      const act = PathClipAct(borderRadius: BorderRadius.all(Radius.circular(10)));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              return act.apply(
                context,
                AlwaysStoppedAnimation<double>(0.5),
                const SizedBox(width: 100, height: 100),
              );
            },
          ),
        ),
      );

      expect(find.byType(ClipPath), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('AxisClipAct horizontal apply creates ClipRect widget', (tester) async {
      const act = AxisClipAct.horizontal();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              return act.apply(
                context,
                AlwaysStoppedAnimation<double>(0.5),
                const SizedBox(width: 100, height: 100),
              );
            },
          ),
        ),
      );

      expect(find.byType(ClipRect), findsOneWidget);
      expect(find.byType(Align), findsOneWidget);
    });

    testWidgets('AxisClipAct vertical apply creates ClipRect widget', (tester) async {
      const act = AxisClipAct.vertical();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              return act.apply(
                context,
                AlwaysStoppedAnimation<double>(0.75),
                const SizedBox(width: 100, height: 100),
              );
            },
          ),
        ),
      );

      expect(find.byType(ClipRect), findsOneWidget);
      expect(find.byType(Align), findsOneWidget);
    });

    testWidgets('PathClipAct circular apply creates ClipPath widget', (tester) async {
      const act = PathClipAct.circular();

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              return act.apply(
                context,
                AlwaysStoppedAnimation<double>(0.5),
                const SizedBox(width: 100, height: 100),
              );
            },
          ),
        ),
      );

      expect(find.byType(ClipPath), findsOneWidget);
      expect(find.byType(Align), findsOneWidget);
    });

    testWidgets('AxisClipAct horizontal with different alignment', (tester) async {
      const act = AxisClipAct.horizontal(alignment: Alignment.center);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              return act.apply(
                context,
                AlwaysStoppedAnimation<double>(0.5),
                const SizedBox(width: 100, height: 100),
              );
            },
          ),
        ),
      );

      expect(find.byType(ClipRect), findsOneWidget);
    });

    testWidgets('AxisClipAct vertical with different alignment', (tester) async {
      const act = AxisClipAct.vertical(alignment: Alignment.topCenter);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              return act.apply(
                context,
                AlwaysStoppedAnimation<double>(0.75),
                const SizedBox(width: 100, height: 100),
              );
            },
          ),
        ),
      );

      expect(find.byType(ClipRect), findsOneWidget);
    });

    testWidgets('PathClipAct with useSuperellipse flag', (tester) async {
      const act = PathClipAct(useSuperellipse: true);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              return act.apply(
                context,
                AlwaysStoppedAnimation<double>(0.5),
                const SizedBox(width: 100, height: 100),
              );
            },
          ),
        ),
      );

      expect(find.byType(ClipPath), findsOneWidget);
    });
  });
}
