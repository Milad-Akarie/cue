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

  group('TextStyleAct', () {
    group('key', () {
      test('has correct key name', () {
        final act = TextStyleAct(
          from: TextStyle(fontSize: 14),
          to: TextStyle(fontSize: 18),
        );
        expect(act.key.key, 'TextStyle');
      });
    });

    group('default constructor', () {
      test('accepts from and to', () {
        final from = TextStyle(fontSize: 14);
        final to = TextStyle(fontSize: 18);
        final act = TextStyleAct(from: from, to: to);
        expect(act.from, from);
        expect(act.to, to);
      });

      test('accepts motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = TextStyleAct(
          from: TextStyle(fontSize: 14),
          to: TextStyle(fontSize: 18),
          motion: motion,
        );
        expect(act.motion, motion);
      });

      test('accepts delay', () {
        final act = TextStyleAct(
          from: TextStyle(fontSize: 14),
          to: TextStyle(fontSize: 18),
          delay: const Duration(milliseconds: 100),
        );
        expect(act.delay, const Duration(milliseconds: 100));
      });
    });

    group('keyframed constructor', () {
      test('accepts frames', () {
        final frames = Keyframes<TextStyle>([
          Keyframe(TextStyle(fontSize: 14), motion: CueMotion.linear(100.ms)),
          Keyframe(TextStyle(fontSize: 18), motion: CueMotion.linear(100.ms)),
        ]);
        final act = TextStyleAct.keyframed(frames: frames);
        expect(act.frames, frames);
      });
    });

    group('resolve', () {
      test('returns ActContext with motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = TextStyleAct(
          from: TextStyle(fontSize: 14),
          to: TextStyle(fontSize: 18),
          motion: motion,
        );
        final ctx = createActContext();
        final resolved = act.resolve(ctx);
        expect(resolved.motion, isNotNull);
      });
    });
  });

  group('IconThemeAct', () {
    group('key', () {
      test('has correct key name', () {
        final act = IconThemeAct(
          from: IconThemeData(size: 24),
          to: IconThemeData(size: 32),
        );
        expect(act.key.key, 'IconTheme');
      });
    });

    group('default constructor', () {
      test('accepts from and to', () {
        final from = IconThemeData(size: 24);
        final to = IconThemeData(size: 32);
        final act = IconThemeAct(from: from, to: to);
        expect(act.from, from);
        expect(act.to, to);
      });

      test('accepts motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = IconThemeAct(
          from: IconThemeData(size: 24),
          to: IconThemeData(size: 32),
          motion: motion,
        );
        expect(act.motion, motion);
      });

      test('accepts delay', () {
        final act = IconThemeAct(
          from: IconThemeData(size: 24),
          to: IconThemeData(size: 32),
          delay: const Duration(milliseconds: 100),
        );
        expect(act.delay, const Duration(milliseconds: 100));
      });
    });

    group('keyframed constructor', () {
      test('accepts frames', () {
        final frames = Keyframes<IconThemeData>([
          Keyframe(IconThemeData(size: 24), motion: CueMotion.linear(100.ms)),
          Keyframe(IconThemeData(size: 32), motion: CueMotion.linear(100.ms)),
        ]);
        final act = IconThemeAct.keyframed(frames: frames);
        expect(act.frames, frames);
      });
    });

    group('resolve', () {
      test('returns ActContext with motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = IconThemeAct(
          from: IconThemeData(size: 24),
          to: IconThemeData(size: 32),
          motion: motion,
        );
        final ctx = createActContext();
        final resolved = act.resolve(ctx);
        expect(resolved.motion, isNotNull);
      });
    });
  });
}
