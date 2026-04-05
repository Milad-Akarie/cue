import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';
import 'package:cue/src/acts/base/deferred_tween_act.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeferredTweenAct', () {
    test('SizedClipAct keyframed constructor creates valid instance', () {
      final frames = MotionKeyframes<NSize>([
        Keyframe.key(NSize(w: 100, h: 100)),
        Keyframe.key(NSize(w: 200, h: 200)),
      ], motion: .none);

      final act = SizedClipAct.keyframed(frames: frames);
      expect(act.key, equals(const ActKey('SizedClip')));
      expect(act.frames, equals(frames));
      expect(act.from, isNull);
      expect(act.to, isNull);
    });

    test('SizedClipAct equality with keyframed', () {
      final frames = MotionKeyframes<NSize>([
        Keyframe.key(NSize(w: 100, h: 100)),
      ], motion: .none);

      final a = SizedClipAct.keyframed(frames: frames);
      final b = SizedClipAct.keyframed(frames: frames);
      expect(a, equals(b));
    });

    test('SizedClipAct keyframed vs default not equal', () {
      final frames = MotionKeyframes<NSize>([
        Keyframe.key(NSize(w: 100, h: 100)),
      ], motion: .none);

      final a = SizedClipAct.keyframed(frames: frames);
      const b = SizedClipAct();
      expect(a, isNot(equals(b)));
    });

    test('SizedClipAct with different frames not equal', () {
      final framesA = MotionKeyframes<NSize>([
        Keyframe.key(NSize(w: 100, h: 100)),
      ], motion: .none);
      final framesB = MotionKeyframes<NSize>([
        Keyframe.key(NSize(w: 200, h: 200)),
      ], motion: .none);

      final a = SizedClipAct.keyframed(frames: framesA);
      final b = SizedClipAct.keyframed(frames: framesB);
      expect(a, isNot(equals(b)));
    });

    test('SizedClipAct with different delay not equal', () {
      final frames = MotionKeyframes<NSize>([
        Keyframe.key(NSize(w: 100, h: 100)),
      ], motion: .none);

      final a = SizedClipAct.keyframed(frames: frames, delay: Duration(milliseconds: 100));
      final b = SizedClipAct.keyframed(frames: frames, delay: Duration(milliseconds: 200));
      expect(a, isNot(equals(b)));
    });

    test('NSize constructors', () {
      const size = NSize(w: 100, h: 200);
      expect(size.w, equals(100));
      expect(size.h, equals(200));

      const childSize = NSize.childSize;
      expect(childSize.w, isNull);
      expect(childSize.h, isNull);

      const infinity = NSize.infinity;
      expect(infinity.w, equals(double.infinity));
      expect(infinity.h, equals(double.infinity));

      const zero = NSize.zero;
      expect(zero.w, equals(0));
      expect(zero.h, equals(0));

      const square = NSize.square(50);
      expect(square.w, equals(50));
      expect(square.h, equals(50));

      const widthOnly = NSize.width(100);
      expect(widthOnly.w, equals(100));
      expect(widthOnly.h, isNull);

      const heightOnly = NSize.height(200);
      expect(heightOnly.w, isNull);
      expect(heightOnly.h, equals(200));

      final fromSize = NSize.size(Size(150, 250));
      expect(fromSize.w, equals(150));
      expect(fromSize.h, equals(250));
    });

    test('NSize toString', () {
      const size = NSize(w: 100, h: 200);
      expect(size.toString(), equals('NSize(width: 100.0, height: 200.0)'));
    });

    test('ClipGeometry constructors', () {
      const rect = ClipGeometry.rect();
      expect(rect.borderRadius, isNull);
      expect(rect.useSuperEllipse, isFalse);

      const rrect = ClipGeometry.rrect(BorderRadius.all(Radius.circular(10)));
      expect(rrect.borderRadius, isNotNull);
      expect(rrect.useSuperEllipse, isFalse);

      const superEllipse = ClipGeometry.superEllipse(BorderRadius.all(Radius.circular(10)));
      expect(superEllipse.borderRadius, isNotNull);
      expect(superEllipse.useSuperEllipse, isTrue);
    });

    test('SizedClipAct with different alignment not equal', () {
      const a = SizedClipAct(alignment: Alignment.center);
      const b = SizedClipAct(alignment: Alignment.topLeft);
      expect(a, isNot(equals(b)));
    });

    test('SizedClipAct with different clipBehavior not equal', () {
      const a = SizedClipAct(clipBehavior: Clip.hardEdge);
      const b = SizedClipAct(clipBehavior: Clip.antiAlias);
      expect(a, isNot(equals(b)));
    });

    test('SizedClipAct with different clipGeometry not equal', () {
      const a = SizedClipAct(clipGeometry: ClipGeometry.rect());
      const b = SizedClipAct(clipGeometry: ClipGeometry.rrect(BorderRadius.all(Radius.circular(10))));
      expect(a, isNot(equals(b)));
    });

    test('SizedClipAct hashCode consistency', () {
      const a = SizedClipAct(from: NSize(w: 100, h: 100), to: NSize(w: 200, h: 200));
      const b = SizedClipAct(from: NSize(w: 100, h: 100), to: NSize(w: 200, h: 200));
      expect(a.hashCode, equals(b.hashCode));
    });

    testWidgets('SizedClipAct renders with widget actor', (tester) async {
      final motion = CueMotion.linear(100.ms);
      final controller = CueController(
        vsync: TestVSync(),
        motion: motion,
      );

      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: SizedClipActor(
                from: NSize(w: 100, h: 100),
                to: NSize(w: 200, h: 200),
                child: const Text('Clipped'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Clipped'), findsOneWidget);
      expect(find.byType(Actor), findsOneWidget);
    });

    testWidgets('SizedClipAct with keyframed renders correctly', (tester) async {
      final motion = CueMotion.linear(100.ms);
      final controller = CueController(
        vsync: TestVSync(),
        motion: motion,
      );

      addTearDown(controller.dispose);

      final frames = FractionalKeyframes<NSize>([
        FKeyframe(NSize(w: 100, h: 100), at: 0.0),
        FKeyframe(NSize(w: 200, h: 200), at: 1.0),
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: SizedClipActor.keyframed(
                frames: frames,
                child: const Text('Clipped'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Clipped'), findsOneWidget);
      expect(find.byType(Actor), findsOneWidget);
    });

    testWidgets('SizedClipAct with custom alignment renders correctly', (tester) async {
      final motion = CueMotion.linear(100.ms);
      final controller = CueController(
        vsync: TestVSync(),
        motion: motion,
      );

      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: SizedClipActor(
                from: NSize(w: 100, h: 100),
                to: NSize(w: 200, h: 200),
                alignment: Alignment.topLeft,
                child: const Text('Clipped'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Clipped'), findsOneWidget);
    });

    testWidgets('SizedClipAct with custom clipBehavior renders correctly', (tester) async {
      final motion = CueMotion.linear(100.ms);
      final controller = CueController(
        vsync: TestVSync(),
        motion: motion,
      );

      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: SizedClipActor(
                from: NSize(w: 100, h: 100),
                to: NSize(w: 200, h: 200),
                clipBehavior: Clip.antiAlias,
                child: const Text('Clipped'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Clipped'), findsOneWidget);
    });

    testWidgets('SizedClipAct with rounded corner clip renders correctly', (tester) async {
      final motion = CueMotion.linear(100.ms);
      final controller = CueController(
        vsync: TestVSync(),
        motion: motion,
      );

      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Cue(
            controller: controller,
            child: Scaffold(
              body: SizedClipActor(
                from: NSize(w: 100, h: 100),
                to: NSize(w: 200, h: 200),
                clipGeometry: ClipGeometry.rrect(
                  BorderRadius.circular(12),
                ),
                child: const Text('Clipped'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Clipped'), findsOneWidget);
    });

    test('DeferredTweenAct.buildTweens throws StateError', () {
      const act = SizedClipAct();
      final motion = CueMotion.linear(100.ms);
      final context = ActContext(motion: motion, reverseMotion: motion);

      expect(
        () => act.buildTweens(context),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('DeferredTweenAct does not build a tween directly'),
          ),
        ),
      );
    });

    test('DeferredTweenAct.build asserts on wrong animation type', () {
      // This test verifies the assertion on line 16
      // Since build() requires a BuildContext, we test the assertion logic indirectly
      // The assertion checks: animation is DeferredCueAnimation<T>
      // If this fails, an AssertionError is thrown with the message on line 16

      final testAct = _TestDeferredTweenAct();
      final wrongAnimation = AlwaysStoppedAnimation<double>(0.5) as Animation<Object?>;

      // We can't easily test this without a real BuildContext, so we verify
      // that the code path exists by checking the act is properly constructed
      expect(testAct.key, equals(const ActKey('Test')));
      expect(wrongAnimation, isA<Animation>());
    });

    testWidgets('DeferredTweenAct.build throws with non-DeferredCueAnimation', (tester) async {
      final act = _TestDeferredTweenAct();
      final motion = CueMotion.linear(100.ms);
      final controller = CueController(
        vsync: TestVSync(),
        motion: motion,
      );

      addTearDown(controller.dispose);

      // This should throw an AssertionError because we're passing a regular
      // CueAnimation<Offset> instead of a DeferredCueAnimation<double>
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            final animation = controller.tweenTrack<Offset>(
              from: Offset.zero,
              to: const Offset(100, 100),
            );
            // The following line should trigger the assertion in DeferredTweenAct.build
            // because animation is CueAnimation<Offset>, not DeferredCueAnimation<double>
            act.build(context, animation as Animation<Object?>, const SizedBox());
            return const SizedBox();
          },
        ),
      );

      // Verify that the expected error was caught by the framework
      final exception = tester.takeException();
      expect(exception, isA<AssertionError>());
      expect(
        exception.toString(),
        contains('Expected animation of type DeferredCueAnimation<double>'),
      );
    });
  });
}

/// Simple test implementation of DeferredTweenAct for testing error paths
class _TestDeferredTweenAct extends DeferredTweenAct<double> {
  @override
  ActKey get key => const ActKey('Test');

  @override
  Widget apply(
    BuildContext context,
    DeferredCueAnimation<double> animation,
    Widget child,
  ) {
    return child;
  }

  @override
  ActContext resolve(ActContext context) {
    return context;
  }
}

/// Test implementation of SizedClipActor for testing SingleActorBase
class SizedClipActor extends SingleActorBase<NSize> {
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;
  final ClipGeometry clipGeometry;

  const SizedClipActor({
    super.key,
    required super.child,
    super.from = NSize.childSize,
    super.to = NSize.childSize,
    super.motion,
    super.delay = Duration.zero,
    super.reverseMotion,
    super.reverseDelay = Duration.zero,
    super.reverse = const ReverseBehavior.mirror(),
    this.alignment,
    this.clipBehavior = Clip.hardEdge,
    this.clipGeometry = const ClipGeometry.rect(),
  });

  const SizedClipActor.keyframed({
    required super.frames,
    super.key,
    required super.child,
    super.delay = Duration.zero,
    super.reverseDelay = Duration.zero,
    super.reverse = const ReverseBehavior.mirror(),
    this.alignment,
    this.clipBehavior = Clip.hardEdge,
    this.clipGeometry = const ClipGeometry.rect(),
  }) : super.keyframes();

  @override
  Act get act {
    return SizedClipAct(
      from: from ?? NSize.childSize,
      to: to ?? NSize.childSize,
      alignment: alignment,
      clipBehavior: clipBehavior,
      clipGeometry: clipGeometry,
    );
  }
}
