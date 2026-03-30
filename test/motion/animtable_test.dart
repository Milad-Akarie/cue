import 'package:cue/cue.dart';
import 'package:cue/src/timeline/track/track.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  CueTrack createTrack({int phases = 1}) {
    final motion = CueMotion.linear(300.ms);
    final config = TrackConfig(motion: motion, reverseMotion: motion);
    final track = CueTrackImpl(config);
    return track;
  }

  group('TweenAnimtable', () {
    test('evaluate returns tween-transformed track value', () {
      final track = createTrack();
      final animtable = TweenAnimtable(Tween(begin: 0.0, end: 100.0));

      track.setProgress(0.0);
      expect(animtable.evaluate(track), equals(0.0));

      track.setProgress(0.5);
      expect(animtable.evaluate(track), equals(50.0));

      track.setProgress(1.0);
      expect(animtable.evaluate(track), equals(100.0));
    });

    test('evaluate with Color tween', () {
      final track = createTrack();
      final animtable = TweenAnimtable<Color>(
        Tween(begin: Colors.red, end: Colors.blue),
      );

      track.setProgress(0.0);
      expect(animtable.evaluate(track), equals(Colors.red));

      track.setProgress(1.0);
      expect(animtable.evaluate(track), equals(Colors.blue));
    });

    test('evaluate with curved tween', () {
      final track = createTrack();
      final animtable = TweenAnimtable(
        Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
      );

      track.setProgress(0.5);
      final value = animtable.evaluate(track);
      expect(value, lessThan(0.5));
    });

    test('evaluate with Offset tween', () {
      final track = createTrack();
      final animtable = TweenAnimtable<Offset>(
        Tween(begin: Offset.zero, end: const Offset(100, 200)),
      );

      track.setProgress(0.0);
      expect(animtable.evaluate(track), equals(Offset.zero));

      track.setProgress(0.5);
      expect(animtable.evaluate(track), equals(const Offset(50, 100)));

      track.setProgress(1.0);
      expect(animtable.evaluate(track), equals(const Offset(100, 200)));
    });
  });

  group('ReversedAnimtable', () {
    test('evaluate reverses track value before transform', () {
      final track = createTrack();
      final animtable = ReversedAnimtable(Tween(begin: 0.0, end: 100.0));

      track.setProgress(0.0);
      expect(animtable.evaluate(track), equals(100.0));

      track.setProgress(0.5);
      expect(animtable.evaluate(track), equals(50.0));

      track.setProgress(1.0);
      expect(animtable.evaluate(track), equals(0.0));
    });

    test('evaluate with Color tween reversed', () {
      final track = createTrack();
      final animtable = ReversedAnimtable<Color>(
        Tween(begin: Colors.red, end: Colors.blue),
      );

      track.setProgress(0.0);
      expect(animtable.evaluate(track), equals(Colors.blue));

      track.setProgress(1.0);
      expect(animtable.evaluate(track), equals(Colors.red));
    });

    test('reversed with curved tween', () {
      final track = createTrack();
      final animtable = ReversedAnimtable(
        Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
      );

      track.setProgress(0.5);
      final value = animtable.evaluate(track);
      final expected = Curves.easeIn.transform(1.0 - 0.5);
      expect(value, equals(expected));
    });
  });

  group('DualAnimatable', () {
    test('evaluate uses forward when track is forward', () {
      final track = createTrack();
      final animtable = DualAnimatable<double>(
        forward: TweenAnimtable(Tween(begin: 0.0, end: 100.0)),
        reverse: TweenAnimtable(Tween(begin: 0.0, end: 200.0)),
      );

      track.setProgress(0.5);
      expect(animtable.evaluate(track), equals(50.0));

      track.setProgress(1.0);
      expect(animtable.evaluate(track), equals(100.0));
    });

    test('evaluate uses reverse when track is reversing', () {
      final track = createTrack();
      final animtable = DualAnimatable<double>(
        forward: TweenAnimtable(Tween(begin: 0.0, end: 100.0)),
        reverse: TweenAnimtable(Tween(begin: 0.0, end: 200.0)),
      );

      track.setProgress(0.5, forward: false);
      expect(animtable.evaluate(track), equals(100.0));

      track.setProgress(0.0, forward: false);
      expect(animtable.evaluate(track), equals(0.0));
    });

    test('evaluate with different types for forward and reverse', () {
      final track = createTrack();
      final animtable = DualAnimatable<double>(
        forward: TweenAnimtable(Tween(begin: 0.0, end: 100.0)),
        reverse: TweenAnimtable(Tween(begin: 1000.0, end: 2000.0)),
      );

      track.setProgress(0.5);
      expect(animtable.evaluate(track), equals(50.0));

      track.setProgress(0.5, forward: false);
      expect(animtable.evaluate(track), equals(1500.0));
    });

    test('forward and reverse can have different ranges', () {
      final track = createTrack();
      final animtable = DualAnimatable<double>(
        forward: TweenAnimtable(Tween(begin: 0.0, end: 10.0)),
        reverse: TweenAnimtable(Tween(begin: 100.0, end: 1000.0)),
      );

      track.setProgress(0.0);
      expect(animtable.evaluate(track), equals(0.0));

      track.setProgress(0.0, forward: false);
      expect(animtable.evaluate(track), equals(100.0));

      track.setProgress(1.0);
      expect(animtable.evaluate(track), equals(10.0));

      track.setProgress(1.0, forward: false);
      expect(animtable.evaluate(track), equals(1000.0));
    });
  });

  group('AlwaysStoppedAnimatable', () {
    test('evaluate always returns the same value', () {
      final track = createTrack();
      final animtable = AlwaysStoppedAnimatable(42.0);

      track.setProgress(0.0);
      expect(animtable.evaluate(track), equals(42.0));

      track.setProgress(0.5);
      expect(animtable.evaluate(track), equals(42.0));

      track.setProgress(1.0);
      expect(animtable.evaluate(track), equals(42.0));
    });

    test('evaluate with complex type', () {
      final track = createTrack();
      final animtable = AlwaysStoppedAnimatable(Colors.red);

      track.setProgress(0.0);
      expect(animtable.evaluate(track), equals(Colors.red));

      track.setProgress(1.0);
      expect(animtable.evaluate(track), equals(Colors.red));
    });

    test('evaluate ignores track direction', () {
      final track = createTrack();
      final animtable = AlwaysStoppedAnimatable('constant');

      track.setProgress(0.5);
      expect(animtable.evaluate(track), equals('constant'));

      track.setProgress(0.5, forward: false);
      expect(animtable.evaluate(track), equals('constant'));
    });

    test('with nullable value', () {
      final track = createTrack();
      final animtable = AlwaysStoppedAnimatable<String?>(null);

      expect(animtable.evaluate(track), isNull);
    });
  });

  group('AnimatableSegment', () {
    test('transform delegates to animatable', () {
      final segment = AnimatableSegment<double>(
        animatable: Tween(begin: 0.0, end: 100.0),
      );

      expect(segment.transform(0.0), equals(0.0));
      expect(segment.transform(0.5), equals(50.0));
      expect(segment.transform(1.0), equals(100.0));
    });

    test('transform with curved animatable', () {
      final segment = AnimatableSegment<double>(
        animatable: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
      );

      final value = segment.transform(0.5);
      expect(value, lessThan(0.5));
    });

    test('transform with Color animatable', () {
      final segment = AnimatableSegment<Color>(
        animatable: Tween(begin: Colors.red, end: Colors.blue),
      );

      expect(segment.transform(0.0), equals(Colors.red));
      expect(segment.transform(1.0), equals(Colors.blue));
    });
  });

  group('SegmentedAnimtable', () {
    test('evaluate returns correct segment based on phase', () {
      final track = createTrack();
      final animtable = SegmentedAnimtable<double>([
        AnimatableSegment(animatable: Tween(begin: 0.0, end: 10.0)),
        AnimatableSegment(animatable: Tween(begin: 100.0, end: 200.0)),
        AnimatableSegment(animatable: Tween(begin: 500.0, end: 600.0)),
      ]);

      track.setProgress(0.5);
      expect(animtable.evaluate(track), equals(5.0));
    });

    test('evaluate with single segment', () {
      final track = createTrack();
      final animtable = SegmentedAnimtable<double>([
        AnimatableSegment(animatable: Tween(begin: 0.0, end: 100.0)),
      ]);

      track.setProgress(0.0);
      expect(animtable.evaluate(track), equals(0.0));

      track.setProgress(1.0);
      expect(animtable.evaluate(track), equals(100.0));
    });

    test('evaluate with different types per segment', () {
      final track = createTrack();
      final animtable = SegmentedAnimtable<Color>([
        AnimatableSegment(
          animatable: Tween(begin: Colors.red, end: Colors.blue),
        ),
      ]);

      track.setProgress(0.0);
      expect(animtable.evaluate(track), equals(Colors.red));

      track.setProgress(1.0);
      expect(animtable.evaluate(track), equals(Colors.blue));
    });

    test('evaluate respects track phase', () {
      final track = createTrack();
      final segments = [
        AnimatableSegment(animatable: Tween(begin: 0.0, end: 10.0)),
        AnimatableSegment(animatable: Tween(begin: 20.0, end: 30.0)),
      ];
      final animtable = SegmentedAnimtable<double>(segments);

      track.setProgress(0.5);
      expect(animtable.evaluate(track), equals(5.0));
    });
  });

  group('CueAnimtable base class', () {
    test('is const constructable', () {
      final animtable = TweenAnimtable<double>(Tween(begin: 0.0, end: 1.0));
      expect(animtable, isA<CueAnimtable<double>>());
    });

    test('can be used as base type', () {
      CueAnimtable<double> animtable = TweenAnimtable(Tween(begin: 0.0, end: 1.0));
      final track = createTrack();

      track.setProgress(0.5);
      expect(animtable.evaluate(track), equals(0.5));

      animtable = AlwaysStoppedAnimatable(42.0);
      expect(animtable.evaluate(track), equals(42.0));

      animtable = ReversedAnimtable(Tween(begin: 0.0, end: 1.0));
      expect(animtable.evaluate(track), equals(0.5));
    });
  });
}
