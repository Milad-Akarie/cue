import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestSimulation extends Simulation {
  @override
  double x(double time) => time;

  @override
  double dx(double time) => 1.0;

  @override
  bool isDone(double time) => time >= 1.0;
}

CueController _createController({
  CueMotion? motion,
  CueMotion? reverseMotion,
}) {
  final controller = CueController(
    vsync: TestVSync(),
    motion: motion ?? CueMotion.linear(300.ms),
    reverseMotion: reverseMotion,
  );
  controller.timeline.obtainDefaultTrack();
  addTearDown(controller.dispose);
  return controller;
}

Future<void> _pump([Duration duration = Duration.zero]) async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  if (duration == Duration.zero) {
    binding.handleBeginFrame(Duration.zero);
    binding.handleDrawFrame();
  } else {
    // Pump multiple frames over the duration
    const step = Duration(milliseconds: 16);
    var elapsed = Duration.zero;
    while (elapsed < duration) {
      binding.handleBeginFrame(elapsed);
      binding.handleDrawFrame();
      elapsed += step;
    }
    // Final frame at exact duration
    binding.handleBeginFrame(duration);
    binding.handleDrawFrame();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CueController', () {
    group('Construction', () {
      test('initializes with given motion', () {
        final motion = CueMotion.linear(300.ms);
        final controller = _createController(motion: motion);

        expect(controller.timeline, isNotNull);
        final defaultTrack = controller.timeline.obtainDefaultTrack().$1;
        expect(defaultTrack.motion, equals(motion));
        expect(defaultTrack.reverseMotion, equals(motion));
      });

      test('uses motion as reverseMotion when not provided', () {
        final motion = CueMotion.linear(300.ms);
        final controller = _createController(motion: motion);
        final defaultTrack = controller.timeline.obtainDefaultTrack().$1;
        expect(defaultTrack.motion, equals(motion));
        expect(defaultTrack.reverseMotion, equals(motion));
      });

      test('uses separate reverseMotion when provided', () {
        final motion = CueMotion.linear(300.ms);
        final reverseMotion = CueMotion.linear(500.ms);
        final controller = _createController(
          motion: motion,
          reverseMotion: reverseMotion,
        );
        final defaultTrack = controller.timeline.obtainDefaultTrack().$1;
        expect(defaultTrack.motion, equals(motion));
        expect(defaultTrack.reverseMotion, equals(reverseMotion));
        expect(defaultTrack.motion, equals(motion));
        expect(defaultTrack.reverseMotion, equals(reverseMotion));
      });

      test('starts with value 0.0 by default', () {
        final controller = _createController();
        expect(controller.value, equals(0.0));
      });
    });

    group('Duration', () {
      test('duration is derived from timeline forwardDuration', () {
        final motion = CueMotion.linear(500.ms);
        final controller = _createController(motion: motion);

        expect(controller.duration, equals(const Duration(milliseconds: 500)));
      });

      test('reverseDuration is derived from timeline reverseDuration', () {
        final motion = CueMotion.linear(300.ms);
        final reverseMotion = CueMotion.linear(600.ms);
        final controller = _createController(
          motion: motion,
          reverseMotion: reverseMotion,
        );

        expect(controller.reverseDuration, equals(const Duration(milliseconds: 600)));
      });

      test('setting duration throws UnsupportedError', () {
        final controller = _createController();
        expect(
          () => controller.duration = const Duration(milliseconds: 500),
          throwsUnsupportedError,
        );
      });

      test('setting reverseDuration throws UnsupportedError', () {
        final controller = _createController();
        expect(
          () => controller.reverseDuration = const Duration(milliseconds: 500),
          throwsUnsupportedError,
        );
      });
    });

    group('updateMotion', () {
      test('updates motion when different', () {
        final motion = CueMotion.linear(300.ms);
        final controller = _createController(motion: motion);

        final newMotion = CueMotion.linear(500.ms);
        controller.rebuildTimeline(newMotion);
        final defaultTrack = controller.timeline.obtainDefaultTrack().$1;

        expect(defaultTrack.motion, equals(newMotion));
        expect(defaultTrack.reverseMotion, equals(newMotion));
      });

      test('updates with separate reverseMotion', () {
        final motion = CueMotion.linear(300.ms);
        final controller = _createController(motion: motion);

        final newMotion = CueMotion.linear(500.ms);
        final newReverse = CueMotion.linear(200.ms);
        controller.rebuildTimeline(newMotion, reverseMotion: newReverse);
        final defaultTrack = controller.timeline.obtainDefaultTrack().$1;

        expect(defaultTrack.motion, equals(newMotion));
        expect(defaultTrack.reverseMotion, equals(newReverse));
      });

      test('rebuilds timeline with same motion, creates a fresh timeline', () {
        final motion = CueMotion.linear(300.ms);
        final controller = _createController(motion: motion);
        final originalTimeline = controller.timeline;
        controller.rebuildTimeline(motion, reverseMotion: motion);
        expect(controller.timeline, isNot(same(originalTimeline)));
      });
    });

    group('obtainTrack', () {
      test('returns track with main config when no overrides', () {
        final motion = CueMotion.linear(300.ms);
        final controller = _createController(motion: motion);

        final (track, token) = controller.obtainTrack();

        expect(track, isNotNull);
        expect(token, isNotNull);
        expect(track.motion, equals(motion));
        expect(track.reverseMotion, equals(motion));
        expect(token.config.reverseType, equals(ReverseBehaviorType.mirror));
      });

      test('returns track with custom motion', () {
        final motion = CueMotion.linear(300.ms);
        final controller = _createController(motion: motion);

        final customMotion = CueMotion.linear(600.ms);
        final (track, _) = controller.obtainTrack(motion: customMotion);

        expect(track.motion, equals(customMotion));
      });

      test('returns track with custom reverseMotion', () {
        final motion = CueMotion.linear(300.ms);
        final controller = _createController(motion: motion);

        final customReverse = CueMotion.linear(400.ms);
        final (track, _) = controller.obtainTrack(reverseMotion: customReverse);

        expect(track.reverseMotion, equals(customReverse));
      });

      test('returns track with custom reverseType', () {
        final motion = CueMotion.linear(300.ms);
        final controller = _createController(motion: motion);

        final (track, _) = controller.obtainTrack(
          reverseType: ReverseBehaviorType.none,
        );

        expect(track.reverseType, equals(ReverseBehaviorType.none));
      });
    });

    group('tweenTrack', () {
      test('creates CueAnimation with tween', () {
        final motion = CueMotion.linear(300.ms);
        final controller = _createController(motion: motion);

        final animation = controller.tweenTrack<double>(
          from: 0.0,
          to: 100.0,
        );

        expect(animation, isNotNull);
        expect(animation.parent, isNotNull);
        expect(animation.token, isNotNull);
      });

      test('animation value tracks progress', () {
        final motion = CueMotion.linear(300.ms);
        final controller = _createController(motion: motion);

        final animation = controller.tweenTrack<double>(
          from: 0.0,
          to: 100.0,
        );

        controller.setProgress(0.5);
        expect(animation.value, equals(50.0));

        controller.setProgress(1.0);
        expect(animation.value, equals(100.0));
      });

      test('creates animation with custom motion', () {
        final motion = CueMotion.linear(300.ms);
        final controller = _createController(motion: motion);

        final customMotion = CueMotion.linear(500.ms);
        final animation = controller.tweenTrack<double>(
          motion: customMotion,
          from: 0.0,
          to: 1.0,
        );

        expect(animation.parent.config.motion, equals(customMotion));
      });

      test('creates animation with custom reverse type', () {
        final motion = CueMotion.linear(300.ms);
        final controller = _createController(motion: motion);

        final animation = controller.tweenTrack<double>(
          reverse: const ReverseBehavior.exclusive(),
          from: 0.0,
          to: 1.0,
        );

        expect(animation.parent.config.reverseType, equals(ReverseBehaviorType.exclusive));
      });

      test('creates animation with reverseTo behavior', () {
        final motion = CueMotion.linear(300.ms);
        final controller = _createController(motion: motion);

        final animation = controller.tweenTrack<double>(
          reverse: const ReverseBehavior.to(0.5),
          from: 0.0,
          to: 1.0,
        );

        expect(animation, isNotNull);
      });
    });

    group('Value and progress', () {
      test('setProgress updates value', () {
        final controller = _createController();
        controller.setProgress(0.5);
        expect(controller.value, equals(0.5));

        controller.setProgress(1.0);
        expect(controller.value, equals(1.0));
      });

      test('setProgress with forward=false', () {
        final controller = _createController();
        controller.setProgress(0.5, forward: false);
        expect(controller.value, equals(0.5));
        expect(controller.status, equals(AnimationStatus.reverse));
      });

      test('value setter clamps and uses current direction', () {
        final controller = _createController();

        controller.setProgress(0.5, forward: true);
        controller.value = 0.8;
        expect(controller.value, equals(0.8));
      });

      test('setProgress asserts on out-of-range values', () {
        final controller = _createController();

        expect(
          () => controller.setProgress(-0.1),
          throwsA(isA<AssertionError>()),
        );
        expect(
          () => controller.setProgress(1.1),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('Status', () {
      test('status returns timeline status', () {
        final controller = _createController();

        expect(controller.status, equals(AnimationStatus.dismissed));

        controller.setProgress(0.5, forward: true);
        expect(controller.status, equals(AnimationStatus.forward));

        controller.setProgress(1.0, forward: true);
        expect(controller.status, equals(AnimationStatus.completed));
      });

      test('status listeners are notified', () {
        final controller = _createController();
        final statuses = <AnimationStatus>[];

        controller.addStatusListener((status) => statuses.add(status));

        controller.setProgress(0.5, forward: true);
        controller.setProgress(1.0, forward: true);

        expect(statuses, contains(AnimationStatus.forward));
        expect(statuses, contains(AnimationStatus.completed));
      });

      test('removeStatusListener stops notifications', () {
        final controller = _createController();
        final statuses = <AnimationStatus>[];

        void listener(AnimationStatus s) => statuses.add(s);
        controller.addStatusListener(listener);

        controller.setProgress(0.5, forward: true);
        final countAfterAdd = statuses.length;

        controller.removeStatusListener(listener);
        controller.setProgress(1.0, forward: true);

        expect(statuses.length, equals(countAfterAdd));
      });
    });

    group('view', () {
      test('view returns default track', () {
        final motion = CueMotion.linear(300.ms);
        final controller = _createController(motion: motion);

        expect(controller.view, same(controller.timeline.obtainDefaultTrack().$1));
      });
    });

    group('forward', () {
      test('forward starts forward animation', () async {
        final controller = _createController(motion: CueMotion.linear(300.ms));

        controller.forward();
        await _pump();

        expect(controller.status, equals(AnimationStatus.forward));
      });

      test('forward with from parameter', () async {
        final controller = _createController(motion: CueMotion.linear(300.ms));

        controller.forward(from: 0.5);
        await _pump();

        expect(controller.status, equals(AnimationStatus.forward));
      });

      test('forward asserts on out-of-range from', () {
        final controller = _createController();

        expect(
          () => controller.forward(from: -0.1),
          throwsA(isA<AssertionError>()),
        );
        expect(
          () => controller.forward(from: 1.1),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('reverse', () {
      test('reverse starts reverse animation', () async {
        final controller = _createController(motion: CueMotion.linear(300.ms));

        controller.setProgress(1.0, forward: true);
        controller.reverse();
        await _pump();

        expect(controller.status, equals(AnimationStatus.reverse));
      });

      test('reverse with from parameter', () async {
        final controller = _createController(motion: CueMotion.linear(300.ms));

        controller.setProgress(1.0, forward: true);
        controller.reverse(from: 0.5);
        await _pump();

        expect(controller.status, equals(AnimationStatus.reverse));
      });

      test('reverse asserts on out-of-range from', () {
        final controller = _createController();

        expect(
          () => controller.reverse(from: -0.1),
          throwsA(isA<AssertionError>()),
        );
        expect(
          () => controller.reverse(from: 1.1),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('Unsupported operations', () {
      test('animateWith throws UnsupportedError', () {
        final controller = _createController();

        expect(
          () => controller.animateWith(_TestSimulation()),
          throwsUnsupportedError,
        );
      });

      test('animateBackWith throws UnsupportedError', () {
        final controller = _createController();

        expect(
          () => controller.animateBackWith(_TestSimulation()),
          throwsUnsupportedError,
        );
      });
    });

    group('reset', () {
      test('reset sets value to 0.0', () {
        final controller = _createController();

        controller.setProgress(0.7, forward: true);
        expect(controller.value, equals(0.7));

        controller.reset();
        expect(controller.value, equals(0.0));
      });

      test('reset resets timeline progress', () {
        final controller = _createController();

        controller.setProgress(0.7, forward: true);
        controller.reset();

        expect(controller.timeline.progress, equals(0.0));
      });
    });

    group('repeat', () {
      test('repeat without period starts repetition', () async {
        final controller = _createController(motion: CueMotion.linear(300.ms));

        controller.repeat(count: 2);
        await _pump();

        expect(controller.status, equals(AnimationStatus.forward));
      });

      test('repeat with reverse parameter', () async {
        final controller = _createController(motion: CueMotion.linear(300.ms));

        controller.repeat(count: 2, reverse: true);
        await _pump();

        expect(controller.status, equals(AnimationStatus.forward));
      });

      test('repeat with period throws UnsupportedError', () {
        final controller = _createController();

        expect(
          () => controller.repeat(period: const Duration(milliseconds: 500)),
          throwsUnsupportedError,
        );
      });

      test('repeat asserts on invalid min', () {
        final controller = _createController();

        expect(
          () => controller.repeat(min: -0.1),
          throwsA(isA<AssertionError>()),
        );
        expect(
          () => controller.repeat(min: 1.1),
          throwsA(isA<AssertionError>()),
        );
      });

      test('repeat asserts on invalid max', () {
        final controller = _createController();

        expect(
          () => controller.repeat(max: -0.1),
          throwsA(isA<AssertionError>()),
        );
        expect(
          () => controller.repeat(max: 1.1),
          throwsA(isA<AssertionError>()),
        );
      });

      test('repeat asserts on invalid count', () {
        final controller = _createController();

        expect(
          () => controller.repeat(count: 0),
          throwsA(isA<AssertionError>()),
        );
        expect(
          () => controller.repeat(count: -1),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('animateTo', () {
      test('animateTo starts forward animation when target > value', () async {
        final controller = _createController(motion: CueMotion.linear(300.ms));

        controller.animateTo(0.8);
        await _pump();

        expect(controller.status, equals(AnimationStatus.forward));
      });

      test('animateTo starts reverse animation when target < value', () async {
        final controller = _createController(motion: CueMotion.linear(300.ms));

        controller.setProgress(1.0, forward: true);
        controller.animateTo(0.3);
        await _pump();

        expect(controller.status, equals(AnimationStatus.reverse));
      });

      test('animateTo returns complete future when target == value', () {
        final controller = _createController();

        controller.setProgress(0.5, forward: true);
        final future = controller.animateTo(0.5);

        expect(future, isNotNull);
      });

      test('animateTo asserts on out-of-range target', () {
        final controller = _createController();

        expect(
          () => controller.animateTo(-0.1),
          throwsA(isA<AssertionError>()),
        );
        expect(
          () => controller.animateTo(1.1),
          throwsA(isA<AssertionError>()),
        );
      });

      test('animateTo respects forward parameter', () async {
        final controller = _createController(motion: CueMotion.linear(300.ms));

        controller.setProgress(0.5, forward: true);
        controller.animateTo(0.8, forward: true);
        await _pump();

        expect(controller.status, equals(AnimationStatus.forward));
      });
    });

    group('fling', () {
      test('fling with positive velocity animates forward', () async {
        final controller = _createController(motion: CueMotion.linear(300.ms));

        controller.fling(velocity: 1.0);
        await _pump();

        expect(controller.status, equals(AnimationStatus.forward));
      });

      test('fling with negative velocity animates backward', () async {
        final controller = _createController(motion: CueMotion.linear(300.ms));
        controller.setProgress(1.0, forward: true);
         controller.fling(velocity: -1.0);
        await _pump();
        expect(controller.value, lessThan(1.0));
      });

      test('fling with custom springDescription', () async {
        final controller = _createController(motion: CueMotion.linear(300.ms));

        final spring = SpringDescription.withDampingRatio(
          mass: 1.0,
          stiffness: 300.0,
          ratio: 1.0,
        );
        controller.fling(velocity: 1.0, springDescription: spring);
        await _pump();

        expect(controller.status, equals(AnimationStatus.forward));
      });
    });

    group('dispose', () {
      test('dispose cleans up controller', () {
        final controller = CueController(
          vsync: TestVSync(),
          motion: CueMotion.linear(300.ms),
        );

        controller.setProgress(0.5, forward: true);
        controller.dispose();
      });

      test('dispose after forward stops animation', () {
        final controller = CueController(
          vsync: TestVSync(),
          motion: CueMotion.linear(300.ms),
        );

        controller.forward();
        controller.dispose();
      });
    });

    group('Integration', () {
      test('forward animation completes after duration', () async {
        final controller = _createController(motion: CueMotion.linear(100.ms));

        controller.forward();
        await _pump(const Duration(milliseconds: 200));

        expect(controller.value, equals(1.0));
        expect(controller.status, equals(AnimationStatus.completed));
      });

      test('reverse animation completes after duration', () async {
        final controller = _createController(motion: CueMotion.linear(100.ms));

        controller.setProgress(1.0, forward: true);
        controller.reverse();
        await _pump(const Duration(milliseconds: 200));

        expect(controller.value, equals(0.0));
        expect(controller.status, equals(AnimationStatus.dismissed));
      });

      test('forward then reverse cycle works', () async {
        final controller = _createController(motion: CueMotion.linear(100.ms));

        controller.forward();
        await _pump(const Duration(milliseconds: 200));
        expect(controller.status, equals(AnimationStatus.completed));

        controller.reverse();
        await _pump(const Duration(milliseconds: 200));
        expect(controller.status, equals(AnimationStatus.dismissed));
      });

      test('animateTo targets specific value', () async {
        final controller = _createController(motion: CueMotion.linear(100.ms));

        controller.animateTo(0.5);
        await _pump(const Duration(milliseconds: 200));

        expect(controller.value, equals(0.5));
      });

      test('animation drives tween correctly through full lifecycle', () {
        final controller = _createController(motion: CueMotion.linear(100.ms));

        final animation = controller.tweenTrack<double>(
          from: 0.0,
          to: 200.0,
        );

        controller.setProgress(0.0);
        expect(animation.value, closeTo(0.0, 0.0001));

        controller.setProgress(0.25);
        expect(animation.value, closeTo(50.0, 0.0001));

        controller.setProgress(0.5);
        expect(animation.value, closeTo(100.0, 0.0001));

        controller.setProgress(0.75);
        expect(animation.value, closeTo(150.0, 0.0001));

        controller.setProgress(1.0);
        expect(animation.value, closeTo(200.0, 0.0001));
      });
    });

    group('keyframedTrack', () {
      test('creates CueAnimation with basic keyframes', () {
        final controller = _createController();

        final frames = Keyframes<double>([
          Keyframe<double>(0.0),
          Keyframe<double>(100.0),
        ], motion: .linear(100.ms));

        final animation = controller.keyframedTrack<double>(frames: frames);

        expect(animation, isA<CueAnimation<double>>());
        expect(animation.value, equals(0.0));
      });

      test('keyframedTrack animation progresses through frames', () {
        final controller = _createController(motion: CueMotion.linear(200.ms));

        final frames = Keyframes<double>([
          Keyframe<double>(0.0),
          Keyframe<double>(100.0),
        ], motion: .linear(100.ms));

        final animation = controller.keyframedTrack<double>(frames: frames);

        controller.setProgress(0.0);
        expect(animation.value, closeTo(0.0, 0.0001));

        controller.setProgress(0.5);
        expect(animation.value, isNotNull);

        controller.setProgress(1.0);
        expect(animation.value, isNotNull);
      });

      test('keyframedTrack with mirror reverse behavior', () {
        final controller = _createController(motion: CueMotion.linear(200.ms));

        final frames = Keyframes<double>([
          Keyframe<double>(0.0),
          Keyframe<double>(100.0),
        ], motion: CueMotion.linear(100.ms));

        final animation = controller.keyframedTrack<double>(
          frames: frames,
          reverse: const KFReverseBehavior.mirror(),
        );

        expect(animation, isA<CueAnimation<double>>());
      });

      test('keyframedTrack with exclusive reverse behavior', () {
        final controller = _createController(motion: CueMotion.linear(200.ms));

        final frames = Keyframes<double>([
          Keyframe<double>(0.0),
          Keyframe<double>(100.0),
        ], motion: CueMotion.linear(100.ms));

        final animation = controller.keyframedTrack<double>(
          frames: frames,
          reverse: const KFReverseBehavior.exclusive(),
        );

        expect(animation, isA<CueAnimation<double>>());
      });

      test('keyframedTrack with none reverse behavior', () {
        final controller = _createController(motion: CueMotion.linear(200.ms));

        final frames = Keyframes<double>([
          Keyframe<double>(0.0),
          Keyframe<double>(100.0),
        ], motion: CueMotion.linear(100.ms));

        final animation = controller.keyframedTrack<double>(
          frames: frames,
          reverse: const KFReverseBehavior.none(),
        );

        expect(animation, isA<CueAnimation<double>>());
      });

      test('keyframedTrack with delay parameter', () {
        final controller = _createController(motion: CueMotion.linear(200.ms));

        final frames = Keyframes<double>([
          Keyframe<double>(0.0),
          Keyframe<double>(100.0),
        ], motion: CueMotion.linear(100.ms));

        final animation = controller.keyframedTrack<double>(
          frames: frames,
          delay: Duration(milliseconds: 50),
        );

        expect(animation, isA<CueAnimation<double>>());
      });

      test('keyframedTrack with custom tween builder', () {
        final controller = _createController(motion: CueMotion.linear(200.ms));

        final frames = Keyframes<double>([
          Keyframe<double>(0.0),
          Keyframe<double>(100.0),
        ], motion: CueMotion.linear(100.ms));

        final animation = controller.keyframedTrack<double>(
          frames: frames,
          tweenBuilder: ({double? begin, double? end}) => Tween<double>(begin: begin ?? 0, end: end ?? 100),
        );

        expect(animation, isA<CueAnimation<double>>());
      });

      test('keyframedTrack with string keyframes', () {
        final controller = _createController(motion: CueMotion.linear(200.ms));

        final frames = Keyframes<String>([
          Keyframe<String>('start'),
          Keyframe<String>('end'),
        ], motion: CueMotion.linear(100.ms));

        final animation = controller.keyframedTrack<String>(frames: frames);

        expect(animation, isA<CueAnimation<String>>());
        expect(animation.value, equals('start'));
      });

      test('keyframedTrack with color keyframes', () {
        final controller = _createController(motion: CueMotion.linear(200.ms));

        final frames = Keyframes<Color>([
          Keyframe<Color>(Colors.red),
          Keyframe<Color>(Colors.blue),
        ], motion: CueMotion.linear(100.ms));

        final animation = controller.keyframedTrack<Color>(frames: frames);

        expect(animation, isA<CueAnimation<Color>>());
        expect(animation.value, equals(Colors.red));
      });

      test('keyframedTrack with multiple keyframes', () {
        final controller = _createController(motion: CueMotion.linear(300.ms));

        final frames = Keyframes<double>([
          Keyframe<double>(0.0),
          Keyframe<double>(50.0),
          Keyframe<double>(100.0),
        ], motion: CueMotion.linear(100.ms));

        final animation = controller.keyframedTrack<double>(frames: frames);

        controller.setProgress(0.0);
        expect(animation.value, isNotNull);

        controller.setProgress(0.33);
        expect(animation.value, isNotNull);

        controller.setProgress(0.66);
        expect(animation.value, isNotNull);

        controller.setProgress(1.0);
        expect(animation.value, isNotNull);
      });
    });
  });
}
