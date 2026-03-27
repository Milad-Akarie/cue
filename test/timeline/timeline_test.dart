import 'package:cue/cue.dart';
import 'package:cue/src/motion/simulation.dart';
import 'package:cue/src/timeline/timeline.dart';
import 'package:cue/src/timeline/track/track.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('CueTimeline', () {
    group('Timeline initialization', () {
      test('Timeline initializes with correct main track', () {
        final motion = CueMotion.linear(Duration(milliseconds: 300));
        final config = TrackConfig(motion: motion, reverseMotion: motion);
        final timeline = CueTimelineImpl(config);

        expect(timeline.mainTrack, isNotNull);
        expect(timeline.mainTrackConfig, equals(config));
        expect(timeline.tracks.length, equals(1));
      });

      test('Timeline can be created from motion', () {
        final motion = CueMotion.linear(Duration(milliseconds: 300));
        final timeline = CueTimelineImpl.fromMotion(motion);

        expect(timeline.mainTrack, isNotNull);
        expect(timeline.mainTrack.motion, equals(motion));
        expect(timeline.mainTrack.reverseMotion, equals(motion));
      });

      test('Timeline can be created with different reverse motion', () {
        final motion = CueMotion.linear(Duration(milliseconds: 300));
        final reverseMotion = CueMotion.linear(Duration(milliseconds: 500));
        final timeline = CueTimelineImpl.fromMotion(motion, reverseMotion: reverseMotion);

        expect(timeline.mainTrack, isNotNull);
        expect(timeline.mainTrack.motion, equals(motion));
        expect(timeline.mainTrack.reverseMotion, equals(reverseMotion));
      });
    });

    group('Timeline duration calculation', () {
      test('forwardDuration returns longest track duration', () {
        final fastMotion = CueMotion.linear(Duration(milliseconds: 200));
        final slowMotion = CueMotion.linear(Duration(milliseconds: 400));

        // Create timeline with fast motion as main track
        final fastConfig = TrackConfig(motion: fastMotion, reverseMotion: fastMotion);
        final timeline = CueTimelineImpl(fastConfig);

        // Initial duration should match the main track
        expect(timeline.forwardDuration, equals(200 / 1000));

        // Add a slower track
        final slowConfig = TrackConfig(motion: slowMotion, reverseMotion: slowMotion);
        timeline.trackFor(slowConfig);

        // Duration should now be the slower track's duration
        expect(timeline.forwardDuration, equals(400 / 1000));
      });

      test('reverseDuration returns longest track reverse duration', () {
        final fastReverseMotion = CueMotion.linear(Duration(milliseconds: 200));
        final slowReverseMotion = CueMotion.linear(Duration(milliseconds: 400));

        // Create timeline with fast reverse motion as main track
        final fastConfig = TrackConfig(motion: fastReverseMotion, reverseMotion: fastReverseMotion);
        final timeline = CueTimelineImpl(fastConfig);

        // Initial duration should match the main track
        expect(timeline.reverseDuration, equals(200 / 1000));

        // Add a slower reverse track
        final slowConfig = TrackConfig(motion: slowReverseMotion, reverseMotion: slowReverseMotion);
        timeline.trackFor(slowConfig);

        // Reverse duration should now be the slower track's duration
        expect(timeline.reverseDuration, equals(400 / 1000));
      });
    });

    group('Track coordination', () {
      test('trackFor adds a new track to the timeline', () {
        // Create timeline
        final mainMotion = CueMotion.linear(Duration(milliseconds: 300));
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);

        // Add new track
        final newMotion = CueMotion.curved(Duration(milliseconds: 500), curve: Curves.easeInOut);
        final newConfig = TrackConfig(motion: newMotion, reverseMotion: newMotion);
        final (track, token) = timeline.trackFor(newConfig);

        // Verify track was added
        expect(timeline.tracks.length, equals(2));
        expect(timeline.tracks.containsKey(newConfig), isTrue);
        expect(track, isNotNull);
        expect(token, isNotNull);
      });

      test('release removes track when no tokens remain', () {
        // Create timeline
        final mainMotion = CueMotion.linear(Duration(milliseconds: 300));
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);

        // Add new track and get token
        final newMotion = CueMotion.curved(Duration(milliseconds: 500), curve: Curves.easeInOut);
        final newConfig = TrackConfig(motion: newMotion, reverseMotion: newMotion);
        final (_, token) = timeline.trackFor(newConfig);

        // Release the token
        timeline.release(token);

        // Track should be removed
        expect(timeline.tracks.length, equals(1)); // Only main track remains
        expect(timeline.tracks.containsKey(newConfig), isFalse);
      });

      test('trackFor prepares the new track with main track progress', () {
        // Create timeline and set progress on main track
        final mainMotion = CueMotion.linear(Duration(milliseconds: 300));
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);
        timeline.setProgress(0.5, forward: true);

        // Add new track
        final newMotion = CueMotion.curved(Duration(milliseconds: 500), curve: Curves.easeInOut);
        final newConfig = TrackConfig(motion: newMotion, reverseMotion: newMotion);
        final (track, _) = timeline.trackFor(newConfig);

        // New track should have same direction as main track
        expect(track.status.isForwardOrCompleted, isTrue);

        // For a forward timeline with progress 0.5, the track's progress should be normalized
        // according to relative duration
        final expected = timeline.mainTrack.progress;
        expect(track.progress, equals(expected));
      });

      test('multiple tracks with different durations synchronize correctly', () {
        // Create timeline
        final fastMotion = CueMotion.linear(Duration(milliseconds: 200));
        final mediumMotion = CueMotion.linear(Duration(milliseconds: 400));
        final slowMotion = CueMotion.linear(Duration(milliseconds: 600));

        final fastConfig = TrackConfig(motion: fastMotion, reverseMotion: fastMotion);
        final mediumConfig = TrackConfig(motion: mediumMotion, reverseMotion: mediumMotion);
        final slowConfig = TrackConfig(motion: slowMotion, reverseMotion: slowMotion);

        // Create timeline with medium speed as main track
        final timeline = CueTimelineImpl(mediumConfig);

        // Add fast and slow tracks
        final (fastTrack, _) = timeline.trackFor(fastConfig);
        final (slowTrack, _) = timeline.trackFor(slowConfig);

        // Set timeline progress to 0.5
        timeline.setProgress(0.5, forward: true);

        // Timeline's forwardDuration should be the slowest track's duration
        expect(timeline.forwardDuration, equals(600 / 1000));

        // Medium track (main) should be at 0.5 progress
        expect(timeline.mainTrack.progress, equals(0.5));

        // Fast track should be further along (0.5 * 600 / 200 = 1.5, clamped to 1.0)
        expect(fastTrack.progress, equals(1.0));

        // Slow track should be at proportionally less progress (0.5 * 600 / 600 = 0.5)
        expect(slowTrack.progress, equals(0.5));
      });
    });

    group('Forward progress normalization', () {
      test('_setForwardProgress normalizes progress correctly for tracks with different durations', () {
        // Setup timeline with tracks of different durations
        final fastMotion = CueMotion.linear(Duration(milliseconds: 100));
        final mediumMotion = CueMotion.linear(Duration(milliseconds: 200));
        final slowMotion = CueMotion.linear(Duration(milliseconds: 400));

        final fastConfig = TrackConfig(motion: fastMotion, reverseMotion: fastMotion);
        final mediumConfig = TrackConfig(motion: mediumMotion, reverseMotion: mediumMotion);
        final slowConfig = TrackConfig(motion: slowMotion, reverseMotion: slowMotion);

        // Create timeline with medium speed as main track
        final timeline = CueTimelineImpl(mediumConfig);

        // Add fast and slow tracks
        final (fastTrack, _) = timeline.trackFor(fastConfig);
        final (slowTrack, _) = timeline.trackFor(slowConfig);

        // Test various progress points
        final testPoints = [0.0, 0.25, 0.5, 0.75, 1.0];

        for (final progress in testPoints) {
          timeline.setProgress(progress, forward: true);

          // The timeline's progress should equal the progress parameter
          expect(timeline.progress, equals(progress));

          // Medium track (main) should have the same progress as the timeline
          expect(timeline.mainTrack.progress, equals(progress));

          // Fast track's progress should be scaled up (clamped to 1.0)
          // Formula: progress * timelineDuration / trackDuration
          final expectedFastProgress = (progress * 400 / 100).clamp(0.0, 1.0);
          expect(fastTrack.progress, closeTo(expectedFastProgress, 0.001));

          // Slow track's progress should be the same as timeline progress
          // Formula: progress * timelineDuration / trackDuration
          final expectedSlowProgress = (progress * 400 / 400).clamp(0.0, 1.0);
          expect(slowTrack.progress, closeTo(expectedSlowProgress, 0.001));
        }
      });

      test('setProgress with forward=true correctly updates all tracks', () {
        // Create a timeline with tracks of different durations
        final fastMotion = CueMotion.linear(Duration(milliseconds: 100));
        final slowMotion = CueMotion.linear(Duration(milliseconds: 300));

        final fastConfig = TrackConfig(motion: fastMotion, reverseMotion: fastMotion);
        final slowConfig = TrackConfig(motion: slowMotion, reverseMotion: slowMotion);

        // Use the fast track as main track
        final timeline = CueTimelineImpl(fastConfig);
        final (slowTrack, _) = timeline.trackFor(slowConfig);

        // Set progress to 0.5
        timeline.setProgress(0.5, forward: true);

        // Main track (fast) should be at progress 0.5
        expect(timeline.mainTrack.progress, equals(0.5));

        // Slow track should be at scaled progress: 0.5 * 300 / 300 = 0.5
        // The timeline duration is determined by the slowest track (300ms)
        expect(slowTrack.progress, equals(0.5 * 300 / 300));

        // Set progress to 1.0
        timeline.setProgress(1.0, forward: true);

        // All tracks should be at their max progress
        expect(timeline.mainTrack.progress, equals(1.0));
        expect(slowTrack.progress, equals(1.0));

        // Main track should be completed
        expect(timeline.mainTrack.status, equals(AnimationStatus.completed));
        expect(slowTrack.status, equals(AnimationStatus.completed));
      });
    });

    group('Reverse progress normalization', () {
      test('_setReverseProgress normalizes progress correctly for tracks with different durations', () {
        // Setup timeline with tracks of different reverse durations
        final fastReverseMotion = CueMotion.linear(Duration(milliseconds: 100));
        final mediumReverseMotion = CueMotion.linear(Duration(milliseconds: 200));
        final slowReverseMotion = CueMotion.linear(Duration(milliseconds: 400));

        final fastConfig = TrackConfig(motion: fastReverseMotion, reverseMotion: fastReverseMotion);
        final mediumConfig = TrackConfig(motion: mediumReverseMotion, reverseMotion: mediumReverseMotion);
        final slowConfig = TrackConfig(motion: slowReverseMotion, reverseMotion: slowReverseMotion);

        // Create timeline with medium speed as main track
        final timeline = CueTimelineImpl(mediumConfig);

        // Add fast and slow tracks
        final (fastTrack, _) = timeline.trackFor(fastConfig);
        final (slowTrack, _) = timeline.trackFor(slowConfig);

        // Test various progress points
        final testPoints = [0.0, 0.25, 0.5, 0.75, 1.0];

        for (final progress in testPoints) {
          timeline.setProgress(progress, forward: false);

          // For tracks with lower duration, they'll be idle for some time
          // This creates a more complex normalization

          // Fast track normalization:
          // idleRatio = 1.0 - (fastTrack.reverseDuration / timelineDuration) = 1.0 - (100 / 400) = 0.75
          // If progress < idleRatio, the track should be at progress 0.0 (idle)
          // If progress >= idleRatio, the track should be at normalized progress:
          //   normalized = (progress - idleRatio) / (fastTrack.reverseDuration / timelineDuration)
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

          // Slow track is the timeline duration determiner, so its progress should match the timeline progress
          expect(
            slowTrack.progress,
            closeTo(progress, 0.001),
            reason: 'Slow track progress at timeline progress $progress should be $progress',
          );
        }
      });

      test('setProgress with forward=false correctly updates all tracks', () {
        // Create a timeline with tracks of different reverse durations
        final fastReverseMotion = CueMotion.linear(Duration(milliseconds: 100));
        final slowReverseMotion = CueMotion.linear(Duration(milliseconds: 300));

        final fastConfig = TrackConfig(motion: fastReverseMotion, reverseMotion: fastReverseMotion);
        final slowConfig = TrackConfig(motion: slowReverseMotion, reverseMotion: slowReverseMotion);

        // Use the fast track as main track
        final timeline = CueTimelineImpl(fastConfig);
        final (slowTrack, _) = timeline.trackFor(slowConfig);

        // Initialize tracks to completed state first
        timeline.setProgress(1.0, forward: true);

        // Set reverse progress to 0.5
        timeline.setProgress(0.5, forward: false);

        // Main track (fast) should be at progress 0.0 until its turn to animate
        // The fast track would be idle for the first 2/3 of the animation
        // idleRatio = 1.0 - (100/300) = 0.67
        // At timeline progress 0.5, the fast track should still be idle
        // because 0.5 < idleRatio (0.67)
        expect(timeline.mainTrack.progress, equals(0.0));

        // Slow track's progress should be 0.5
        expect(slowTrack.progress, equals(0.5));

        // Set reverse progress to 0.8, which should start animating the fast track
        timeline.setProgress(0.8, forward: false);

        // Fast track should now have started animating
        // adjustedProgress = 0.8 - 0.67 = 0.13
        // normalized = 0.13 / (100/300) = 0.39
        final fastIdleRatio = 1.0 - (100 / 300);
        final adjustedProgress = 0.8 - fastIdleRatio;
        final expectedFastProgress = (adjustedProgress / (100 / 300)).clamp(0.0, 1.0);

        expect(timeline.mainTrack.progress, closeTo(expectedFastProgress, 0.001));
        expect(slowTrack.progress, equals(0.8));

        // Set reverse progress to 1.0
        timeline.setProgress(1.0, forward: false);

        // All tracks should be at their max reverse progress
        expect(timeline.mainTrack.progress, equals(1.0));
        expect(slowTrack.progress, equals(1.0));
      });
    });

    group('Timeline status tracking', () {
      test('status is updated correctly based on track statuses', () {
        // Create a timeline with two tracks
        final motion = CueMotion.linear(Duration(milliseconds: 300));
        final config = TrackConfig(motion: motion, reverseMotion: motion);
        final timeline = CueTimelineImpl(config);

        final secondConfig = TrackConfig(motion: motion, reverseMotion: motion);
        timeline.trackFor(secondConfig);

        // Initial status should be dismissed
        expect(timeline.status, equals(AnimationStatus.dismissed));

        // Set progress to 0.5 (forward), status should be forward
        timeline.setProgress(0.5, forward: true);
        expect(timeline.status, equals(AnimationStatus.forward));

        // Set progress to 1.0 (forward), status should be completed
        timeline.setProgress(1.0, forward: true);
        expect(timeline.status, equals(AnimationStatus.completed));

        // Set progress to 0.5 (reverse), status should be reverse
        timeline.setProgress(0.5, forward: false);
        expect(timeline.status, equals(AnimationStatus.reverse));

        // Set progress to 0.0 (reverse), status should be dismissed
        timeline.setProgress(0.0, forward: false);
        expect(timeline.status, equals(AnimationStatus.dismissed));
      });

      test('_updateStatus updates status correctly when some tracks are complete', () {
        // Create timeline with two tracks of different durations
        final fastMotion = CueMotion.linear(Duration(milliseconds: 100));
        final slowMotion = CueMotion.linear(Duration(milliseconds: 300));

        final fastConfig = TrackConfig(motion: fastMotion, reverseMotion: fastMotion);
        final slowConfig = TrackConfig(motion: slowMotion, reverseMotion: slowMotion);

        final timeline = CueTimelineImpl(fastConfig);
        timeline.trackFor(slowConfig);

        // Set timeline to 50% progress
        timeline.setProgress(0.5, forward: true);

        // The fast track should be completed (since 0.5 * 300 / 100 > 1.0)
        expect(timeline.mainTrack.status, equals(AnimationStatus.completed));

        // But the timeline status should still be forward because the slow track is still animating
        expect(timeline.status, equals(AnimationStatus.forward));

        // Set timeline to 100% progress
        timeline.setProgress(1.0, forward: true);

        // Now all tracks should be completed
        expect(timeline.status, equals(AnimationStatus.completed));
      });

      test('isDone returns correct value based on track completion', () {
        // Create timeline with two tracks of different durations
        final fastMotion = CueMotion.linear(Duration(milliseconds: 100));
        final slowMotion = CueMotion.linear(Duration(milliseconds: 300));

        final fastConfig = TrackConfig(motion: fastMotion, reverseMotion: fastMotion);
        final slowConfig = TrackConfig(motion: slowMotion, reverseMotion: slowMotion);

        final timeline = CueTimelineImpl(fastConfig);
        final (slowTrack, _) = timeline.trackFor(slowConfig);

        // Prepare timeline for animation
        timeline.prepare(forward: true);

        // At t=0, no track should be done
        expect(timeline.isDone(0.0), isFalse);

        // At t matching fast track duration, the fast track should be done but not the slow track
        expect(timeline.mainTrack.isDone, isFalse);
        expect(slowTrack.isDone, isFalse);

        // Timeline is only done when ALL tracks are done
        expect(timeline.isDone(1.0), isFalse);

        // After enough time for all tracks to complete
        expect(timeline.isDone(0.3), isTrue);
      });
    });

    group('Timeline repeat behavior', () {
      test('prepareForRepeat sets up tracks correctly', () {
        final motion = CueMotion.linear(Duration(milliseconds: 300));
        final config = TrackConfig(motion: motion, reverseMotion: motion);
        final timeline = CueTimelineImpl(config);

        // Initially at 0.0 progress
        expect(timeline.progress, equals(0.0));

        // Set progress to 1.0 to complete the animation
        timeline.setProgress(1.0);
        expect(timeline.progress, equals(1.0));

        // Prepare for repeat with 3 repetitions
        final repeatConfig = RepeatConfig(count: 3, reverse: false);
        timeline.prepareForRepeat(repeatConfig);

        // Progress should be reset to 0.0
        expect(timeline.progress, equals(0.0));

        // Status should be reset to forward
        expect(timeline.status, equals(AnimationStatus.forward));
      });

      test('isDone handles repetitions correctly', () {
        final motion = CueMotion.linear(Duration(milliseconds: 300));
        final config = TrackConfig(motion: motion, reverseMotion: motion);
        final timeline = CueTimelineImpl(config);

        // Prepare for repeat with 3 repetitions
        final repeatConfig = RepeatConfig(count: 3, reverse: false);
        timeline.prepareForRepeat(repeatConfig);

        // First cycle
        expect(timeline.isDone(0.0), isFalse);
        expect(timeline.isDone(0.3), isTrue); // First cycle completed, should trigger next cycle

        // Second cycle should start automatically
        expect(timeline.isDone(0.6), isTrue); // Second cycle completed

        // Third cycle should start automatically
        expect(timeline.isDone(0.9), isTrue); // Third cycle completed

        // After all repetitions, should be truly done
        expect(timeline.isDone(1.2), isTrue);

        // Prepare for infinite repetitions
        final infiniteRepeat = RepeatConfig(count: null, reverse: false);
        timeline.prepareForRepeat(infiniteRepeat);

        // Should never be truly done
        expect(timeline.isDone(0.3), isFalse);
        expect(timeline.isDone(0.6), isFalse);
        expect(timeline.isDone(0.9), isFalse);
      });
    });
  });
}
