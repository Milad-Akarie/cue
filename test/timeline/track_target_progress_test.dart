// Tests that verify track.prepare(target: ...) correctly reports progress
// back to the target value, not always to 1.0 or 0.0

import 'package:cue/src/motion/cue_motion.dart';
import 'package:cue/src/timeline/track/track.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CueTrack target progress —', () {
    test('animateTo(0.8) reports progress = 0.8 when done', () {
      final motion = CueMotion.linear(0.3);
      final track = CueTrackImpl(TrackConfig(motion: motion, reverseMotion: motion));

      track.prepare(forward: true, from: 0.0, target: 0.8);
      expect(track.progress, equals(0.0));

      double time = 0.0;
      while (time < 10.0 && !track.isDone) {
        track.tick(1 / 60);
        time += 1 / 60;
      }

      expect(track.isDone, isTrue);
      expect(track.progress, closeTo(0.8, 0.001));
      expect(track.value, closeTo(0.8, 0.01));
    });

    test('animateTo(0.5) from 0.2 reports correct progress', () {
      final motion = CueMotion.linear(0.2);
      final track = CueTrackImpl(TrackConfig(motion: motion, reverseMotion: motion));

      track.prepare(forward: true, from: 0.2, target: 0.5);
      expect(track.progress, equals(0.2));

      double time = 0.0;
      while (time < 10.0 && !track.isDone) {
        track.tick(1 / 60);
        time += 1 / 60;
      }

      expect(track.isDone, isTrue);
      expect(track.progress, closeTo(0.5, 0.001));
      expect(track.value, closeTo(0.5, 0.01));
    });

    test('animateTo(0.3) reverse reports correct progress', () {
      final motion = CueMotion.linear(0.2);
      final track = CueTrackImpl(TrackConfig(motion: motion, reverseMotion: motion));

      track.prepare(forward: false, from: 0.7, target: 0.3);
      expect(track.progress, equals(0.7));

      double time = 0.0;
      while (time < 10.0 && !track.isDone) {
        track.tick(1 / 60);
        time += 1 / 60;
      }

      expect(track.isDone, isTrue);
      expect(track.progress, closeTo(0.3, 0.001));
      expect(track.value, closeTo(0.3, 0.01));
    });

    test('target = null defaults to full range (forward to 1.0)', () {
      final motion = CueMotion.linear(0.2);
      final track = CueTrackImpl(TrackConfig(motion: motion, reverseMotion: motion));

      track.prepare(forward: true, from: 0.0);

      double time = 0.0;
      while (time < 10.0 && !track.isDone) {
        track.tick(1 / 60);
        time += 1 / 60;
      }

      expect(track.isDone, isTrue);
      expect(track.progress, closeTo(1.0, 0.001));
    });

    test('target = null defaults to full range (reverse to 0.0)', () {
      final motion = CueMotion.linear(0.2);
      final track = CueTrackImpl(TrackConfig(motion: motion, reverseMotion: motion));

      track.prepare(forward: false, from: 1.0);

      double time = 0.0;
      while (time < 10.0 && !track.isDone) {
        track.tick(1 / 60);
        time += 1 / 60;
      }

      expect(track.isDone, isTrue);
      expect(track.progress, closeTo(0.0, 0.001));
    });

    test('progress interpolates correctly during animation', () {
      final motion = CueMotion.linear(0.1);
      final track = CueTrackImpl(TrackConfig(motion: motion, reverseMotion: motion));

      track.prepare(forward: true, from: 0.2, target: 0.7);
      expect(track.progress, equals(0.2));

      track.tick(0.025);
      expect(track.progress, closeTo(0.45, 0.05));

      track.tick(0.03);
      expect(track.isDone, isTrue);
      expect(track.progress, closeTo(0.7, 0.001));
    });

    test('segmented motion with target reports correct progress', () {
      final motion = SegmentedMotion([
        CueMotion.linear(0.1),
        CueMotion.linear(0.2),
      ]);
      final track = CueTrackImpl(TrackConfig(motion: motion, reverseMotion: motion));

      track.prepare(forward: true, from: 0.0, target: 0.6);

      double time = 0.0;
      while (time < 10.0 && !track.isDone) {
        track.tick(1 / 60);
        time += 1 / 60;
      }

      expect(track.isDone, isTrue);
      expect(track.progress, closeTo(0.6, 0.001));
    });
  });
}
