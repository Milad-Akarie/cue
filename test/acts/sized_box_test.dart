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

  group('SizedBoxAct', () {
    group('key', () {
      test('has correct key name', () {
        final act = SizedBoxAct();
        expect(act.key.key, 'SizedBox');
      });
    });

    group('default constructor', () {
      test('accepts width', () {
        final width = AnimatableValue(from: 100.0, to: 200.0);
        final act = SizedBoxAct(width: width);
        expect(act.width, width);
      });

      test('accepts height', () {
        final height = AnimatableValue(from: 100.0, to: 200.0);
        final act = SizedBoxAct(height: height);
        expect(act.height, height);
      });

      test('accepts both width and height', () {
        final width = AnimatableValue(from: 100.0, to: 200.0);
        final height = AnimatableValue(from: 50.0, to: 100.0);
        final act = SizedBoxAct(width: width, height: height);
        expect(act.width, width);
        expect(act.height, height);
      });

      test('default alignment is center', () {
        final act = SizedBoxAct();
        expect(act.alignment, Alignment.center);
      });

      test('accepts alignment', () {
        final act = SizedBoxAct(alignment: Alignment.topLeft);
        expect(act.alignment, Alignment.topLeft);
      });

      test('accepts motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = SizedBoxAct(motion: motion);
        expect(act.motion, motion);
      });

      test('accepts delay', () {
        final act = SizedBoxAct(delay: const Duration(milliseconds: 100));
        expect(act.delay, const Duration(milliseconds: 100));
      });
    });

    group('keyframed constructor', () {
      test('accepts frames', () {
        final frames = Keyframes<Size>([
          Keyframe(const Size(100, 100), motion: CueMotion.linear(100.ms)),
          Keyframe(const Size(200, 200), motion: CueMotion.linear(100.ms)),
        ]);
        final act = SizedBoxAct.keyframed(frames: frames);
        expect(act.frames, frames);
      });

      test('accepts alignment', () {
        final frames = Keyframes<Size>([
          Keyframe(const Size(100, 100), motion: CueMotion.linear(100.ms)),
        ]);
        final act = SizedBoxAct.keyframed(frames: frames, alignment: Alignment.bottomRight);
        expect(act.alignment, Alignment.bottomRight);
      });
    });

    group('resolve', () {
      test('returns ActContext with motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = SizedBoxAct(motion: motion);
        final ctx = createActContext();
        final resolved = act.resolve(ctx);
        expect(resolved.motion, isNotNull);
      });
    });

    group('equality', () {
      test('equal acts have same hashCode', () {
        final width = AnimatableValue(from: 100.0, to: 200.0);
        final act1 = SizedBoxAct(width: width);
        final act2 = SizedBoxAct(width: width);
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });

      test('different widths are not equal', () {
        final act1 = SizedBoxAct(width: AnimatableValue(from: 100.0, to: 200.0));
        final act2 = SizedBoxAct(width: AnimatableValue(from: 150.0, to: 250.0));
        expect(act1, isNot(act2));
      });

      test('different heights are not equal', () {
        final act1 = SizedBoxAct(height: AnimatableValue(from: 100.0, to: 200.0));
        final act2 = SizedBoxAct(height: AnimatableValue(from: 150.0, to: 250.0));
        expect(act1, isNot(act2));
      });

      test('different alignments are not equal', () {
        final act1 = SizedBoxAct(alignment: Alignment.center);
        final act2 = SizedBoxAct(alignment: Alignment.topLeft);
        expect(act1, isNot(act2));
      });
    });
  });
}
