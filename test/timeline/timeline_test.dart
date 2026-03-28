import 'package:cue/cue.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('CueTimeline', () {
    group('Timeline initialization', () {
      test('Timeline initializes with correct main track', () {
        final motion = CueMotion.linear(0.3);
        final config = TrackConfig(motion: motion, reverseMotion: motion);
        final timeline = CueTimelineImpl(config);

        expect(timeline.mainTrack, isNotNull);
        expect(timeline.mainTrackConfig, equals(config));
        expect(timeline.tracks.length, equals(1));
      });

      test('Timeline can be created from motion', () {
        final motion = CueMotion.linear(0.3);
        final timeline = CueTimelineImpl.fromMotion(motion);

        expect(timeline.mainTrack, isNotNull);
        expect(timeline.mainTrack.motion, equals(motion));
        expect(timeline.mainTrack.reverseMotion, equals(motion));
      });

      test('Timeline can be created with different reverse motion', () {
        final motion = CueMotion.linear(0.3);
        final reverseMotion = CueMotion.linear(0.5);
        final timeline = CueTimelineImpl.fromMotion(motion, reverseMotion: reverseMotion);

        expect(timeline.mainTrack, isNotNull);
        expect(timeline.mainTrack.motion, equals(motion));
        expect(timeline.mainTrack.reverseMotion, equals(reverseMotion));
      });
    });

    group('Timeline duration calculation', () {
      test('forwardDuration returns longest track duration', () {
        final fastMotion = CueMotion.linear(0.2);
        final slowMotion = CueMotion.linear(0.4);

        final fastConfig = TrackConfig(motion: fastMotion, reverseMotion: fastMotion);
        final timeline = CueTimelineImpl(fastConfig);

        expect(timeline.forwardDuration, equals(0.2));

        final slowConfig = TrackConfig(motion: slowMotion, reverseMotion: slowMotion);
        timeline.trackFor(slowConfig);

        expect(timeline.forwardDuration, equals(0.4));
      });

      test('reverseDuration returns longest track reverse duration', () {
        final fastReverseMotion = CueMotion.linear(0.2);
        final slowReverseMotion = CueMotion.linear(0.4);

        final fastConfig = TrackConfig(motion: fastReverseMotion, reverseMotion: fastReverseMotion);
        final timeline = CueTimelineImpl(fastConfig);

        expect(timeline.reverseDuration, equals(0.2));

        final slowConfig = TrackConfig(motion: slowReverseMotion, reverseMotion: slowReverseMotion);
        timeline.trackFor(slowConfig);

        expect(timeline.reverseDuration, equals(0.4));
      });
    });

    group('Track coordination', () {
      test('trackFor adds a new track to the timeline', () {
        final mainMotion = CueMotion.linear(0.3);
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);

        final newMotion = CueMotion.curved(0.5, curve: Curves.easeInOut);
        final newConfig = TrackConfig(motion: newMotion, reverseMotion: newMotion);
        final (track, token) = timeline.trackFor(newConfig);

        expect(timeline.tracks.length, equals(2));
        expect(timeline.tracks.containsKey(newConfig), isTrue);
        expect(track, isNotNull);
        expect(token, isNotNull);
      });

      test('release removes track when no tokens remain', () {
        final mainMotion = CueMotion.linear(0.3);
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);

        final newMotion = CueMotion.curved(0.5, curve: Curves.easeInOut);
        final newConfig = TrackConfig(motion: newMotion, reverseMotion: newMotion);
        final (_, token) = timeline.trackFor(newConfig);

        timeline.release(token);

        expect(timeline.tracks.length, equals(1));
        expect(timeline.tracks.containsKey(newConfig), isFalse);
      });

      test('trackFor with main track config returns main track and does not create duplicate', () {
        final mainMotion = CueMotion.linear(0.3);
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);

        final (track, token) = timeline.trackFor(mainConfig);

        expect(track, equals(timeline.mainTrack));
        expect(timeline.tracks.length, equals(1));
        expect(token.config, equals(mainConfig));
      });

      test('releasing main track token does nothing', () {
        final mainMotion = CueMotion.linear(0.3);
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);

        final (_, token) = timeline.trackFor(mainConfig);

        timeline.release(token);

        expect(timeline.tracks.length, equals(1));
        expect(timeline.tracks.containsKey(mainConfig), isTrue);
        expect(timeline.mainTrack, isNotNull);
      });

      test('multiple tokens prevent track from being released', () {
        final mainMotion = CueMotion.linear(0.3);
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);

        final newMotion = CueMotion.curved(0.5, curve: Curves.easeInOut);
        final newConfig = TrackConfig(motion: newMotion, reverseMotion: newMotion);
        final (track1, token1) = timeline.trackFor(newConfig);
        final (track2, token2) = timeline.trackFor(newConfig);
        final (track3, token3) = timeline.trackFor(newConfig);

        expect(track1, equals(track2));
        expect(track2, equals(track3));
        expect(timeline.tracks.length, equals(2));

        timeline.release(token1);
        expect(timeline.tracks.length, equals(2));
        expect(timeline.tracks.containsKey(newConfig), isTrue);

        timeline.release(token2);
        expect(timeline.tracks.length, equals(2));
        expect(timeline.tracks.containsKey(newConfig), isTrue);

        timeline.release(token3);
        expect(timeline.tracks.length, equals(1));
        expect(timeline.tracks.containsKey(newConfig), isFalse);
      });

      test('releasing invalid token does nothing', () {
        final mainMotion = CueMotion.linear(0.3);
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);

        final newMotion = CueMotion.curved(0.5, curve: Curves.easeInOut);
        final newConfig = TrackConfig(motion: newMotion, reverseMotion: newMotion);
        timeline.trackFor(newConfig);

        final otherMotion = CueMotion.linear(0.4);
        final otherConfig = TrackConfig(motion: otherMotion, reverseMotion: otherMotion);
        final invalidToken = ReleaseToken(otherConfig);

        timeline.release(invalidToken);

        expect(timeline.tracks.length, equals(2));
      });

      test('releasing same token multiple times is safe', () {
        final mainMotion = CueMotion.linear(0.3);
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);

        final newMotion = CueMotion.curved(0.5, curve: Curves.easeInOut);
        final newConfig = TrackConfig(motion: newMotion, reverseMotion: newMotion);
        final (_, token) = timeline.trackFor(newConfig);

        timeline.release(token);
        expect(timeline.tracks.length, equals(1));

        timeline.release(token);
        timeline.release(token);
        expect(timeline.tracks.length, equals(1));
      });

      test('trackFor prepares the new track with timeline progress', () {
        final mainMotion = CueMotion.linear(0.3);
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);
        timeline.setProgress(0.5, forward: true);

        final newMotion = CueMotion.curved(0.5, curve: Curves.easeInOut);
        final newConfig = TrackConfig(motion: newMotion, reverseMotion: newMotion);
        final (track, _) = timeline.trackFor(newConfig);

        expect(track.status.isForwardOrCompleted, isTrue);

        final expected = timeline.progress;
        expect(track.progress, equals(expected));
      });

      test('multiple tracks with different durations synchronize correctly', () {
        final fastMotion = CueMotion.linear(0.2);
        final mediumMotion = CueMotion.linear(0.4);
        final slowMotion = CueMotion.linear(0.6);

        final fastConfig = TrackConfig(motion: fastMotion, reverseMotion: fastMotion);
        final mediumConfig = TrackConfig(motion: mediumMotion, reverseMotion: mediumMotion);
        final slowConfig = TrackConfig(motion: slowMotion, reverseMotion: slowMotion);

        final timeline = CueTimelineImpl(mediumConfig);

        final (fastTrack, _) = timeline.trackFor(fastConfig);
        final (slowTrack, _) = timeline.trackFor(slowConfig);

        timeline.setProgress(0.5, forward: true);

        expect(timeline.forwardDuration, equals(0.6));

        expect(timeline.progress, equals(0.5));

        expect(timeline.mainTrack.progress, closeTo(0.75, 0.001));

        expect(fastTrack.progress, equals(1.0));

        expect(slowTrack.progress, equals(0.5));
      });
    });

    group('Forward progress normalization', () {
      test('_setForwardProgress normalizes progress correctly for tracks with different durations', () {
        final fastMotion = CueMotion.linear(0.1);
        final mediumMotion = CueMotion.linear(0.2);
        final slowMotion = CueMotion.linear(0.4);

        final fastConfig = TrackConfig(motion: fastMotion, reverseMotion: fastMotion);
        final mediumConfig = TrackConfig(motion: mediumMotion, reverseMotion: mediumMotion);
        final slowConfig = TrackConfig(motion: slowMotion, reverseMotion: slowMotion);

        final timeline = CueTimelineImpl(mediumConfig);

        final (fastTrack, _) = timeline.trackFor(fastConfig);
        final (slowTrack, _) = timeline.trackFor(slowConfig);

        final testPoints = [0.0, 0.25, 0.5, 0.75, 1.0];

        for (final progress in testPoints) {
          timeline.setProgress(progress, forward: true);

          expect(timeline.progress, closeTo(progress, 0.0001));

          final expectedMediumProgress = (progress * 0.4 / 0.2).clamp(0.0, 1.0);
          expect(timeline.mainTrack.progress, closeTo(expectedMediumProgress, 0.0001));

          final expectedFastProgress = (progress * 0.4 / 0.1).clamp(0.0, 1.0);
          expect(fastTrack.progress, closeTo(expectedFastProgress, 0.001));

          final expectedSlowProgress = (progress * 0.4 / 0.4).clamp(0.0, 1.0);
          expect(slowTrack.progress, closeTo(expectedSlowProgress, 0.001));
        }
      });

      test('setProgress with forward=true correctly updates all tracks', () {
        final fastMotion = CueMotion.linear(0.1);
        final slowMotion = CueMotion.linear(0.3);

        final fastConfig = TrackConfig(motion: fastMotion, reverseMotion: fastMotion);
        final slowConfig = TrackConfig(motion: slowMotion, reverseMotion: slowMotion);

        final timeline = CueTimelineImpl(fastConfig);
        final (slowTrack, _) = timeline.trackFor(slowConfig);

        timeline.setProgress(0.5, forward: true);

        expect(timeline.mainTrack.progress, equals(1.0));

        expect(slowTrack.progress, equals(0.5 * 0.3 / 0.3));

        timeline.setProgress(1.0, forward: true);

        expect(timeline.mainTrack.progress, equals(1.0));
        expect(slowTrack.progress, equals(1.0));

        expect(timeline.mainTrack.status, equals(AnimationStatus.completed));
        expect(slowTrack.status, equals(AnimationStatus.completed));
      });
    });

    group('Reverse progress normalization', () {
      test('_setReverseProgress normalizes progress correctly for tracks with different durations', () {
        final fastReverseMotion = CueMotion.linear(0.1);
        final mediumReverseMotion = CueMotion.linear(0.2);
        final slowReverseMotion = CueMotion.linear(0.4);

        final fastConfig = TrackConfig(motion: fastReverseMotion, reverseMotion: fastReverseMotion);
        final mediumConfig = TrackConfig(motion: mediumReverseMotion, reverseMotion: mediumReverseMotion);
        final slowConfig = TrackConfig(motion: slowReverseMotion, reverseMotion: slowReverseMotion);

        final timeline = CueTimelineImpl(mediumConfig);

        final (fastTrack, _) = timeline.trackFor(fastConfig);
        final (slowTrack, _) = timeline.trackFor(slowConfig);

        final testPoints = [0.0, 0.25, 0.5, 0.75, 1.0];

        for (final progress in testPoints) {
          timeline.setProgress(progress, forward: false);

          final fastIdleRatio = 1.0 - (fastTrack.reverseDuration / timeline.reverseDuration);
          double expectedFastProgress;
          if (progress < fastIdleRatio) {
            expectedFastProgress = 0.0;
          } else {
            final adjustedProgress = progress - fastIdleRatio;
            expectedFastProgress = (adjustedProgress / (fastTrack.reverseDuration / timeline.reverseDuration)).clamp(
              0.0,
              1.0,
            );
          }

          expect(
            fastTrack.progress,
            closeTo(expectedFastProgress, 0.001),
            reason: 'Fast track progress at timeline progress $progress should be $expectedFastProgress',
          );

          expect(
            slowTrack.progress,
            closeTo(progress, 0.001),
            reason: 'Slow track progress at timeline progress $progress should be $progress',
          );
        }
      });

      test('setProgress with forward=false correctly updates all tracks', () {
        final fastReverseMotion = CueMotion.linear(0.1);
        final slowReverseMotion = CueMotion.linear(0.3);

        final fastConfig = TrackConfig(motion: fastReverseMotion, reverseMotion: fastReverseMotion);
        final slowConfig = TrackConfig(motion: slowReverseMotion, reverseMotion: slowReverseMotion);

        final timeline = CueTimelineImpl(fastConfig);
        final (slowTrack, _) = timeline.trackFor(slowConfig);

        timeline.setProgress(1.0, forward: true);

        timeline.setProgress(0.5, forward: false);

        expect(timeline.mainTrack.progress, equals(0.0));

        expect(slowTrack.progress, equals(0.5));

        timeline.setProgress(0.8, forward: false);

        final fastIdleRatio = 1.0 - (0.1 / 0.3);
        final adjustedProgress = 0.8 - fastIdleRatio;
        final expectedFastProgress = (adjustedProgress / (0.1 / 0.3)).clamp(0.0, 1.0);

        expect(timeline.mainTrack.progress, closeTo(expectedFastProgress, 0.001));
        expect(slowTrack.progress, equals(0.8));

        timeline.setProgress(1.0, forward: false);

        expect(timeline.mainTrack.progress, equals(1.0));
        expect(slowTrack.progress, equals(1.0));
      });
    });

    group('Timeline status tracking', () {
      test('status is updated correctly based on track statuses', () {
        final motion = CueMotion.linear(0.3);
        final config = TrackConfig(motion: motion, reverseMotion: motion);
        final timeline = CueTimelineImpl(config);

        final secondConfig = TrackConfig(motion: motion, reverseMotion: motion);
        timeline.trackFor(secondConfig);

        expect(timeline.status, equals(AnimationStatus.dismissed));

        timeline.setProgress(0.5, forward: true);
        expect(timeline.status, equals(AnimationStatus.forward));

        timeline.setProgress(1.0, forward: true);
        expect(timeline.status, equals(AnimationStatus.completed));

        timeline.setProgress(0.5, forward: false);
        expect(timeline.status, equals(AnimationStatus.reverse));

        timeline.setProgress(0.0, forward: false);
        expect(timeline.status, equals(AnimationStatus.dismissed));
      });

      test('_updateStatus updates status correctly when some tracks are complete', () {
        final fastMotion = CueMotion.linear(0.1);
        final slowMotion = CueMotion.linear(0.3);

        final fastConfig = TrackConfig(motion: fastMotion, reverseMotion: fastMotion);
        final slowConfig = TrackConfig(motion: slowMotion, reverseMotion: slowMotion);

        final timeline = CueTimelineImpl(fastConfig);
        timeline.trackFor(slowConfig);

        timeline.setProgress(0.5, forward: true);

        expect(timeline.mainTrack.status, equals(AnimationStatus.completed));

        expect(timeline.status, equals(AnimationStatus.forward));

        timeline.setProgress(1.0, forward: true);

        expect(timeline.status, equals(AnimationStatus.completed));
      });

      test('isDone returns correct value based on track completion', () {
        final fastMotion = CueMotion.linear(0.1);
        final slowMotion = CueMotion.linear(0.3);

        final fastConfig = TrackConfig(motion: fastMotion, reverseMotion: fastMotion);
        final slowConfig = TrackConfig(motion: slowMotion, reverseMotion: slowMotion);

        final timeline = CueTimelineImpl(fastConfig);
        final (slowTrack, _) = timeline.trackFor(slowConfig);

        timeline.prepare(forward: true);

        expect(timeline.isDone(0.0), isFalse);

        timeline.x(0.1);
        expect(timeline.mainTrack.isDone, isTrue);
        expect(slowTrack.isDone, isFalse);
        expect(timeline.isDone(0.1), isFalse);

        timeline.x(0.3);
        expect(timeline.mainTrack.isDone, isTrue);
        expect(slowTrack.isDone, isTrue);
        expect(timeline.isDone(0.3), isTrue);
      });
    });

    group('Timeline repeat behavior', () {
      test('prepareForRepeat sets up tracks correctly', () {
        final motion = CueMotion.linear(0.3);
        final config = TrackConfig(motion: motion, reverseMotion: motion);
        final timeline = CueTimelineImpl(config);

        expect(timeline.progress, equals(0.0));

        timeline.setProgress(1.0);
        expect(timeline.progress, equals(1.0));

        final repeatConfig = RepeatConfig(count: 3, reverse: false);
        timeline.prepareForRepeat(repeatConfig);

        expect(timeline.progress, equals(0.0));

        expect(timeline.status, equals(AnimationStatus.forward));
      });

      test('isDone handles repetitions correctly', () {
        final motion = CueMotion.linear(0.3);
        final config = TrackConfig(motion: motion, reverseMotion: motion);
        final timeline = CueTimelineImpl(config);

        final repeatConfig = RepeatConfig(count: 3, reverse: false);
        timeline.prepareForRepeat(repeatConfig);

        expect(timeline.isDone(0.0), isFalse);
        timeline.x(0.3);
        expect(timeline.isDone(0.3), isFalse);

        timeline.x(0.6);
        expect(timeline.isDone(0.6), isFalse);

        timeline.x(0.9);
        expect(timeline.isDone(0.9), isTrue);

        final infiniteRepeat = RepeatConfig(count: null, reverse: false);
        timeline.prepareForRepeat(infiniteRepeat);

        timeline.x(0.3);
        expect(timeline.isDone(0.3), isFalse);
        timeline.x(0.6);
        expect(timeline.isDone(0.6), isFalse);
        timeline.x(0.9);
        expect(timeline.isDone(0.9), isFalse);
      });
    });
  });
}
