import 'package:cue/cue.dart';
import 'package:cue/src/timeline/track/track.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ActContext createActContext() {
    final motion = CueMotion.linear(300.ms);
    return ActContext(motion: motion, reverseMotion: motion);
  }

  CueTrack createTrack() {
    final motion = CueMotion.linear(300.ms);
    final config = TrackConfig(motion: motion, reverseMotion: motion);
    return CueTrackImpl(config);
  }

  group('ParallaxAct', () {
    group('key', () {
      test('has correct key name', () {
        final act = ParallaxAct(slide: 0.5);
        expect(act.key.key, 'Parallax');
      });
    });

    group('constructors', () {
      test('requires slide', () {
        final act = ParallaxAct(slide: 0.5);
        expect(act.slide, 0.5);
      });

      test('default axis is horizontal', () {
        final act = ParallaxAct(slide: 0.5);
        expect(act.axis, Axis.horizontal);
      });

      test('constructor accepts axis', () {
        final act = ParallaxAct(slide: 0.5, axis: Axis.vertical);
        expect(act.axis, Axis.vertical);
      });

      test('constructor accepts motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = ParallaxAct(slide: 0.5, motion: motion);
        expect(act.motion, motion);
      });

      test('constructor accepts delay', () {
        final act = ParallaxAct(
          slide: 0.5,
          delay: const Duration(milliseconds: 100),
        );
        expect(act.delay, const Duration(milliseconds: 100));
      });
    });

    group('resolve', () {
      test('returns ActContext with motion and delay', () {
        final motion = CueMotion.linear(300.ms);
        final act = ParallaxAct(slide: 0.5, motion: motion);
        final ctx = createActContext();
        final resolved = act.resolve(ctx);
        expect(resolved.motion, isNotNull);
      });
    });

    group('equality', () {
      test('equal acts have same hashCode', () {
        final act1 = ParallaxAct(slide: 0.5, axis: Axis.horizontal);
        final act2 = ParallaxAct(slide: 0.5, axis: Axis.horizontal);
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });

      test('different slide values are not equal', () {
        final act1 = ParallaxAct(slide: 0.5);
        final act2 = ParallaxAct(slide: 0.8);
        expect(act1, isNot(act2));
      });

      test('different axis values are not equal', () {
        final act1 = ParallaxAct(slide: 0.5, axis: Axis.horizontal);
        final act2 = ParallaxAct(slide: 0.5, axis: Axis.vertical);
        expect(act1, isNot(act2));
      });
    });
  });
}
