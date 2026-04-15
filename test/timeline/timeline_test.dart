import 'package:cue/cue.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('CueTimeline', () {
    group('Timeline initialization', () {
      test('Timeline can be created from motion', () {
        final motion = CueMotion.linear(300.ms);
        final timeline = CueTimelineImpl.fromMotion(motion);

        final track = timeline.obtainDefaultTrack().$1;
        expect(track.motion, equals(motion));
        expect(track.reverseMotion, equals(motion));
      });

      test('Timeline can be created with different reverse motion', () {
        final motion = CueMotion.linear(300.ms);
        final reverseMotion = CueMotion.linear(500.ms);
        final timeline = CueTimelineImpl.fromMotion(motion, reverseMotion: reverseMotion);

        final track = timeline.obtainDefaultTrack().$1;
        expect(track.motion, equals(motion));
        expect(track.reverseMotion, equals(reverseMotion));
      });
    });

    group('Timeline duration calculation', () {
      test('forwardDuration returns longest track duration', () {
        final fastMotion = CueMotion.linear(200.ms);
        final slowMotion = CueMotion.linear(400.ms);

        final fastConfig = TrackConfig(motion: fastMotion, reverseMotion: fastMotion);
        final timeline = CueTimelineImpl(fastConfig);
        timeline.obtainDefaultTrack();

        expect(timeline.forwardDuration, equals(0.2));

        final slowConfig = TrackConfig(motion: slowMotion, reverseMotion: slowMotion);
        timeline.obtainTrack(slowConfig);

        expect(timeline.forwardDuration, equals(0.4));
      });

      test('reverseDuration returns longest track reverse duration', () {
        final fastReverseMotion = CueMotion.linear(200.ms);
        final slowReverseMotion = CueMotion.linear(400.ms);

        final fastConfig = TrackConfig(motion: fastReverseMotion, reverseMotion: fastReverseMotion);
        final timeline = CueTimelineImpl(fastConfig);
        timeline.obtainDefaultTrack();

        expect(timeline.reverseDuration, equals(0.2));

        final slowConfig = TrackConfig(motion: slowReverseMotion, reverseMotion: slowReverseMotion);
        timeline.obtainTrack(slowConfig);

        expect(timeline.reverseDuration, equals(0.4));
      });
    });

    group('Track coordination', () {
      test('trackFor adds a new track to the timeline', () {
        final mainMotion = CueMotion.linear(300.ms);
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);
        timeline.obtainDefaultTrack();

        final newMotion = CueMotion.curved(500.ms, curve: Curves.easeInOut);
        final newConfig = TrackConfig(motion: newMotion, reverseMotion: newMotion);
        final (track, token) = timeline.obtainTrack(newConfig);

        expect(timeline.tracks.length, equals(2));
        expect(timeline.tracks.containsKey(newConfig), isTrue);
        expect(track, isNotNull);
        expect(token, isNotNull);
      });

      test('release removes track when no tokens remain', () {
        final mainMotion = CueMotion.linear(300.ms);
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);
        timeline.obtainDefaultTrack();

        final newMotion = CueMotion.curved(500.ms, curve: Curves.easeInOut);
        final newConfig = TrackConfig(motion: newMotion, reverseMotion: newMotion);
        final (_, token) = timeline.obtainTrack(newConfig);

        timeline.release(token);

        expect(timeline.tracks.length, equals(1));
        expect(timeline.tracks.containsKey(newConfig), isFalse);
      });

      test('trackFor with main track config returns main track and does not create duplicate', () {
        final mainMotion = CueMotion.linear(300.ms);
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);

        final defaultTrack = timeline.obtainDefaultTrack().$1;
        final (track, token) = timeline.obtainTrack(mainConfig);

        expect(track, equals(defaultTrack));
        expect(timeline.tracks.length, equals(1));
        expect(token.config, equals(mainConfig));
      });

      test('releasing main track token does nothing', () {
        final mainMotion = CueMotion.linear(300.ms);
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);

        timeline.obtainDefaultTrack();
        final (_, token) = timeline.obtainTrack(mainConfig);

        timeline.release(token);

        expect(timeline.tracks.length, equals(1));
        expect(timeline.tracks.containsKey(mainConfig), isTrue);
        expect(timeline.tracks[mainConfig]!.track, isNotNull);
      });

      test('multiple tokens prevent track from being released', () {
        final mainMotion = CueMotion.linear(300.ms);
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);
        // obtain default track to ensure main track exists
        timeline.obtainDefaultTrack();

        final newMotion = CueMotion.curved(500.ms, curve: Curves.easeInOut);
        final newConfig = TrackConfig(motion: newMotion, reverseMotion: newMotion);
        final (track1, token1) = timeline.obtainTrack(newConfig);
        final (track2, token2) = timeline.obtainTrack(newConfig);
        final (track3, token3) = timeline.obtainTrack(newConfig);

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
        final mainMotion = CueMotion.linear(300.ms);
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);
        timeline.obtainDefaultTrack();

        final newMotion = CueMotion.curved(500.ms, curve: Curves.easeInOut);
        final newConfig = TrackConfig(motion: newMotion, reverseMotion: newMotion);
        timeline.obtainTrack(newConfig);

        final otherMotion = CueMotion.linear(400.ms);
        final otherConfig = TrackConfig(motion: otherMotion, reverseMotion: otherMotion);
        final invalidToken = ReleaseToken(otherConfig, timeline);

        timeline.release(invalidToken);

        expect(timeline.tracks.length, equals(2));
      });

      test('releasing same token multiple times is safe', () {
        final mainMotion = CueMotion.linear(300.ms);
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);
        timeline.obtainDefaultTrack();

        final newMotion = CueMotion.curved(500.ms, curve: Curves.easeInOut);
        final newConfig = TrackConfig(motion: newMotion, reverseMotion: newMotion);
        final (_, token) = timeline.obtainTrack(newConfig);

        timeline.release(token);
        expect(timeline.tracks.length, equals(1));

        timeline.release(token);
        timeline.release(token);
        expect(timeline.tracks.length, equals(1));
      });

      test('releasing longest track updates forwardDuration', () {
        final shortMotion = CueMotion.linear(200.ms);
        final longMotion = CueMotion.linear(500.ms);

        final shortConfig = TrackConfig(motion: shortMotion, reverseMotion: shortMotion);
        final timeline = CueTimelineImpl(shortConfig);
        timeline.obtainDefaultTrack();

        final longConfig = TrackConfig(motion: longMotion, reverseMotion: longMotion);
        final (_, token) = timeline.obtainTrack(longConfig);

        expect(timeline.forwardDuration, equals(0.5));

        timeline.release(token);

        expect(timeline.forwardDuration, equals(0.2));
      });

      test('releasing longest reverse track updates reverseDuration', () {
        final motion1 = CueMotion.linear(300.ms);
        final motion2 = CueMotion.linear(500.ms);

        final config1 = TrackConfig(motion: motion1, reverseMotion: motion1);
        final timeline = CueTimelineImpl(config1);
        timeline.obtainDefaultTrack();

        final config2 = TrackConfig(motion: motion2, reverseMotion: motion2);
        final (_, token) = timeline.obtainTrack(config2);

        expect(timeline.reverseDuration, equals(0.5));

        timeline.release(token);

        expect(timeline.reverseDuration, equals(0.3));
      });

      test('releasing intermediate track does not change duration', () {
        final shortMotion = CueMotion.linear(200.ms);
        final mediumMotion = CueMotion.linear(400.ms);
        final longMotion = CueMotion.linear(600.ms);

        final shortConfig = TrackConfig(motion: shortMotion, reverseMotion: shortMotion);
        final timeline = CueTimelineImpl(shortConfig);
        timeline.obtainDefaultTrack();

        final mediumConfig = TrackConfig(motion: mediumMotion, reverseMotion: mediumMotion);
        final longConfig = TrackConfig(motion: longMotion, reverseMotion: longMotion);

        timeline.obtainTrack(mediumConfig);
        final (_, longToken) = timeline.obtainTrack(longConfig);

        expect(timeline.forwardDuration, equals(0.6));

        timeline.release(longToken);

        expect(timeline.forwardDuration, equals(0.4));
      });

      test('duration remains correct with multiple tracks of same duration', () {
        final motion1 = CueMotion.linear(300.ms);
        final motion2 = CueMotion.linear(300.ms);

        final config1 = TrackConfig(motion: motion1, reverseMotion: motion1);
        final timeline = CueTimelineImpl(config1);
        timeline.obtainDefaultTrack();

        final config2 = TrackConfig(motion: motion2, reverseMotion: motion2);
        final (_, token) = timeline.obtainTrack(config2);

        expect(timeline.forwardDuration, equals(0.3));

        timeline.release(token);

        expect(timeline.forwardDuration, equals(0.3));
      });

      test('trackFor prepares the new track with timeline progress', () {
        final mainMotion = CueMotion.linear(300.ms);
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);
        timeline.obtainDefaultTrack();
        timeline.setProgress(0.5, forward: true);

        final newMotion = CueMotion.curved(500.ms, curve: Curves.easeInOut);
        final newConfig = TrackConfig(motion: newMotion, reverseMotion: newMotion);
        final (track, _) = timeline.obtainTrack(newConfig);

        expect(track.status.isForwardOrCompleted, isTrue);

        final expected = timeline.progress;
        expect(track.progress, equals(expected));
      });

      test('multiple tracks with different durations synchronize correctly', () {
        final fastMotion = CueMotion.linear(200.ms);
        final mediumMotion = CueMotion.linear(400.ms);
        final slowMotion = CueMotion.linear(600.ms);

        final fastConfig = TrackConfig(motion: fastMotion, reverseMotion: fastMotion);
        final mediumConfig = TrackConfig(motion: mediumMotion, reverseMotion: mediumMotion);
        final slowConfig = TrackConfig(motion: slowMotion, reverseMotion: slowMotion);

        final timeline = CueTimelineImpl(mediumConfig);

        final (fastTrack, _) = timeline.obtainTrack(fastConfig);
        final (mediumTrack, _) = timeline.obtainTrack(mediumConfig);
        final (slowTrack, _) = timeline.obtainTrack(slowConfig);

        timeline.setProgress(0.5, forward: true);

        expect(timeline.forwardDuration, equals(0.6));

        expect(timeline.progress, equals(0.5));

        expect(mediumTrack.progress, closeTo(0.75, 0.001));

        expect(fastTrack.progress, equals(1.0));

        expect(slowTrack.progress, equals(0.5));
      });
    });

    group('Forward progress normalization', () {
      test('_setForwardProgress normalizes progress correctly for tracks with different durations', () {
        final fastMotion = CueMotion.linear(100.ms);
        final mediumMotion = CueMotion.linear(200.ms);
        final slowMotion = CueMotion.linear(400.ms);

        final fastConfig = TrackConfig(motion: fastMotion, reverseMotion: fastMotion);
        final mediumConfig = TrackConfig(motion: mediumMotion, reverseMotion: mediumMotion);
        final slowConfig = TrackConfig(motion: slowMotion, reverseMotion: slowMotion);

        final timeline = CueTimelineImpl(mediumConfig);

        final (fastTrack, _) = timeline.obtainTrack(fastConfig);
        final (mediumTrack, _) = timeline.obtainTrack(mediumConfig);
        final (slowTrack, _) = timeline.obtainTrack(slowConfig);

        final testPoints = [0.0, 0.25, 0.5, 0.75, 1.0];

        for (final progress in testPoints) {
          timeline.setProgress(progress, forward: true);

          expect(timeline.progress, closeTo(progress, 0.0001));

          final expectedMediumProgress = (progress * 0.4 / 0.2).clamp(0.0, 1.0);
          expect(mediumTrack.progress, closeTo(expectedMediumProgress, 0.0001));

          final expectedFastProgress = (progress * 0.4 / 0.1).clamp(0.0, 1.0);
          expect(fastTrack.progress, closeTo(expectedFastProgress, 0.001));

          final expectedSlowProgress = (progress * 0.4 / 0.4).clamp(0.0, 1.0);
          expect(slowTrack.progress, closeTo(expectedSlowProgress, 0.001));
        }
      });

      test('setProgress with forward=true correctly updates all tracks', () {
        final fastMotion = CueMotion.linear(100.ms);
        final slowMotion = CueMotion.linear(300.ms);

        final fastConfig = TrackConfig(motion: fastMotion, reverseMotion: fastMotion);
        final slowConfig = TrackConfig(motion: slowMotion, reverseMotion: slowMotion);

        final timeline = CueTimelineImpl(fastConfig);

        final (slowTrack, _) = timeline.obtainTrack(slowConfig);
        final (fastTrack, _) = timeline.obtainTrack(fastConfig);

        timeline.setProgress(0.5, forward: true);

        expect(fastTrack.progress, equals(1.0));

        expect(slowTrack.progress, equals(0.5 * 0.3 / 0.3));

        timeline.setProgress(1.0, forward: true);

        expect(fastTrack.progress, equals(1.0));
        expect(slowTrack.progress, equals(1.0));

        expect(fastTrack.status, equals(AnimationStatus.completed));
        expect(slowTrack.status, equals(AnimationStatus.completed));
      });
    });

    group('Reverse progress normalization', () {
      test('_setReverseProgress normalizes progress correctly for tracks with different durations', () {
        final fastReverseMotion = CueMotion.linear(100.ms);
        final mediumReverseMotion = CueMotion.linear(200.ms);
        final slowReverseMotion = CueMotion.linear(400.ms);

        final fastConfig = TrackConfig(motion: fastReverseMotion, reverseMotion: fastReverseMotion);
        final mediumConfig = TrackConfig(motion: mediumReverseMotion, reverseMotion: mediumReverseMotion);
        final slowConfig = TrackConfig(motion: slowReverseMotion, reverseMotion: slowReverseMotion);

        final timeline = CueTimelineImpl(mediumConfig);
        timeline.obtainDefaultTrack();

        final (fastTrack, _) = timeline.obtainTrack(fastConfig);
        final (slowTrack, _) = timeline.obtainTrack(slowConfig);

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
        final fastReverseMotion = CueMotion.linear(100.ms);
        final slowReverseMotion = CueMotion.linear(300.ms);

        final fastConfig = TrackConfig(motion: fastReverseMotion, reverseMotion: fastReverseMotion);
        final slowConfig = TrackConfig(motion: slowReverseMotion, reverseMotion: slowReverseMotion);

        final timeline = CueTimelineImpl(fastConfig);
        final (fastTrack, _) = timeline.obtainTrack(fastConfig);
        final (slowTrack, _) = timeline.obtainTrack(slowConfig);

        timeline.setProgress(1.0, forward: true);

        timeline.setProgress(0.5, forward: false);

        expect(fastTrack.progress, equals(0.0));

        expect(slowTrack.progress, equals(0.5));

        timeline.setProgress(0.8, forward: false);

        final fastIdleRatio = 1.0 - (0.1 / 0.3);
        final adjustedProgress = 0.8 - fastIdleRatio;
        final expectedFastProgress = (adjustedProgress / (0.1 / 0.3)).clamp(0.0, 1.0);

        expect(fastTrack.progress, closeTo(expectedFastProgress, 0.001));
        expect(slowTrack.progress, equals(0.8));

        timeline.setProgress(1.0, forward: false);

        expect(fastTrack.progress, equals(1.0));
        expect(slowTrack.progress, equals(1.0));
      });
    });

    group('Timeline status tracking', () {
      test('status is updated correctly based on track statuses', () {
        final motion = CueMotion.linear(300.ms);
        final config = TrackConfig(motion: motion, reverseMotion: motion);
        final timeline = CueTimelineImpl(config);
        timeline.obtainDefaultTrack();

        final secondConfig = TrackConfig(motion: motion, reverseMotion: motion);
        timeline.obtainTrack(secondConfig);

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
        final fastMotion = CueMotion.linear(100.ms);
        final slowMotion = CueMotion.linear(300.ms);

        final fastConfig = TrackConfig(motion: fastMotion, reverseMotion: fastMotion);
        final slowConfig = TrackConfig(motion: slowMotion, reverseMotion: slowMotion);

        final timeline = CueTimelineImpl(fastConfig);
        final (fastTrack, _) = timeline.obtainTrack(fastConfig);
        final (slowTrack, _) = timeline.obtainTrack(slowConfig);

        timeline.setProgress(0.5, forward: true);

        expect(fastTrack.status, equals(AnimationStatus.completed));
        expect(slowTrack.status, equals(AnimationStatus.forward));
        expect(timeline.status, equals(AnimationStatus.forward));

        expect(timeline.status, equals(AnimationStatus.forward));

        timeline.setProgress(1.0, forward: true);

        expect(timeline.status, equals(AnimationStatus.completed));
      });

      test('isDone returns correct value based on track completion', () {
        final fastMotion = CueMotion.linear(100.ms);
        final slowMotion = CueMotion.linear(300.ms);

        final fastConfig = TrackConfig(motion: fastMotion, reverseMotion: fastMotion);
        final slowConfig = TrackConfig(motion: slowMotion, reverseMotion: slowMotion);

        final timeline = CueTimelineImpl(fastConfig);

        final (fastTrack, _) = timeline.obtainTrack(fastConfig);
        final (slowTrack, _) = timeline.obtainTrack(slowConfig);

        timeline.prepare(forward: true);

        expect(timeline.isDone(0.0), isFalse);

        timeline.x(0.1);
        expect(fastTrack.isDone, isTrue);
        expect(slowTrack.isDone, isFalse);
        expect(timeline.isDone(0.1), isFalse);

        timeline.x(0.3);
        expect(fastTrack.isDone, isTrue);
        expect(slowTrack.isDone, isTrue);
        expect(timeline.isDone(0.3), isTrue);
      });
    });

    group('Timeline repeat behavior', () {
      test('prepareForRepeat sets up tracks correctly', () {
        final motion = CueMotion.linear(300.ms);
        final config = TrackConfig(motion: motion, reverseMotion: motion);
        final timeline = CueTimelineImpl(config);
        timeline.obtainDefaultTrack();

        expect(timeline.progress, equals(0.0));

        timeline.setProgress(1.0);
        expect(timeline.progress, equals(1.0));

        final repeatConfig = RepeatConfig(count: 3, reverse: false);
        timeline.prepareForRepeat(repeatConfig);

        expect(timeline.progress, equals(0.0));

        expect(timeline.status, equals(AnimationStatus.forward));
      });

      test('isDone handles repetitions correctly', () {
        final motion = CueMotion.linear(300.ms);
        final config = TrackConfig(motion: motion, reverseMotion: motion);
        final timeline = CueTimelineImpl(config);
        timeline.obtainDefaultTrack();

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

    group('Timeline reset behavior', () {
      test('reset resets progress and clears repeat config', () {
        final motion = CueMotion.linear(300.ms);
        final config = TrackConfig(motion: motion, reverseMotion: motion);
        final timeline = CueTimelineImpl(config);
        timeline.obtainDefaultTrack();

        timeline.setProgress(0.7, forward: true);
        expect(timeline.progress, equals(0.7));

        timeline.reset();

        expect(timeline.progress, equals(0.0));
        expect(timeline.status, equals(AnimationStatus.forward));
      });

      test('reset does not remove additional tracks', () {
        final mainMotion = CueMotion.linear(300.ms);
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);
        timeline.obtainDefaultTrack();

        final newMotion = CueMotion.linear(500.ms);
        final newConfig = TrackConfig(motion: newMotion, reverseMotion: newMotion);
        timeline.obtainTrack(newConfig);

        expect(timeline.tracks.length, equals(2));

        timeline.reset();

        expect(timeline.tracks.length, equals(2));
      });
    });

    // Timeline resetTracks behavior - removed in refactor

    group('Timeline progress getter', () {
      test('progress returns the progress of the longest track in forward direction', () {
        final shortMotion = CueMotion.linear(200.ms);
        final longMotion = CueMotion.linear(400.ms);

        final shortConfig = TrackConfig(motion: shortMotion, reverseMotion: shortMotion);
        final timeline = CueTimelineImpl(shortConfig);
        timeline.obtainDefaultTrack();

        final longConfig = TrackConfig(motion: longMotion, reverseMotion: longMotion);
        final (longTrack, _) = timeline.obtainTrack(longConfig);

        timeline.setProgress(0.5, forward: true);

        expect(timeline.progress, equals(longTrack.progress));
        expect(timeline.progress, equals(0.5));
      });

      test('progress returns the progress of the longest track in reverse direction', () {
        final shortMotion = CueMotion.linear(200.ms);
        final longMotion = CueMotion.linear(400.ms);

        final shortConfig = TrackConfig(motion: shortMotion, reverseMotion: shortMotion);
        final timeline = CueTimelineImpl(shortConfig);
        timeline.obtainDefaultTrack();

        final longConfig = TrackConfig(motion: longMotion, reverseMotion: longMotion);
        final (longTrack, _) = timeline.obtainTrack(longConfig);

        timeline.setProgress(0.5, forward: false);

        expect(timeline.progress, equals(longTrack.progress));
      });
    });

    group('Timeline prepare behavior', () {
      test('prepare with forward=true sets all tracks to forward', () {
        final motion = CueMotion.linear(300.ms);
        final config = TrackConfig(motion: motion, reverseMotion: motion);
        final timeline = CueTimelineImpl(config);
        timeline.obtainDefaultTrack();

        final secondConfig = TrackConfig(motion: motion, reverseMotion: motion);
        final (secondTrack, _) = timeline.obtainTrack(secondConfig);

        timeline.prepare(forward: true);

        expect(timeline.obtainDefaultTrack().$1.status, equals(AnimationStatus.forward));
        expect(secondTrack.status, equals(AnimationStatus.forward));
      });

      test('prepare with forward=false sets all tracks to reverse', () {
        final motion = CueMotion.linear(300.ms);
        final config = TrackConfig(motion: motion, reverseMotion: motion);
        final timeline = CueTimelineImpl(config);
        timeline.obtainDefaultTrack();

        final secondConfig = TrackConfig(motion: motion, reverseMotion: motion);
        final (secondTrack, _) = timeline.obtainTrack(secondConfig);

        timeline.setProgress(1.0, forward: true);
        timeline.prepare(forward: false);

        expect(timeline.obtainDefaultTrack().$1.status, equals(AnimationStatus.reverse));
        expect(secondTrack.status, equals(AnimationStatus.reverse));
      });

      test('prepare with from parameter sets starting progress', () {
        final motion = CueMotion.linear(300.ms);
        final config = TrackConfig(motion: motion, reverseMotion: motion);
        final timeline = CueTimelineImpl(config);
        timeline.obtainDefaultTrack();

        timeline.prepare(forward: true, from: 0.5);

        expect(timeline.obtainDefaultTrack().$1.progress, equals(0.5));
      });

      test('prepare with target parameter sets target progress', () {
        final motion = CueMotion.linear(300.ms);
        final config = TrackConfig(motion: motion, reverseMotion: motion);
        final timeline = CueTimelineImpl(config);
        timeline.obtainDefaultTrack();

        timeline.prepare(forward: true, from: 0.0, target: 0.7);
        timeline.x(0.3);

        expect(timeline.obtainDefaultTrack().$1.progress, lessThanOrEqualTo(0.7));
      });
    });

    group('Timeline x and dx methods', () {
      test('x returns progress after ticking', () {
        final motion = CueMotion.linear(300.ms);
        final config = TrackConfig(motion: motion, reverseMotion: motion);
        final timeline = CueTimelineImpl(config);
        timeline.obtainDefaultTrack();

        timeline.prepare(forward: true);

        final progress = timeline.x(0.15);

        expect(progress, greaterThanOrEqualTo(0.0));
        expect(progress, lessThanOrEqualTo(1.0));
      });

      test('dx returns main track velocity', () {
        final motion = CueMotion.linear(300.ms);
        final config = TrackConfig(motion: motion, reverseMotion: motion);
        final timeline = CueTimelineImpl(config);

        timeline.prepare(forward: true);
        timeline.x(0.1);

        final velocity = timeline.dx(0.1);

        expect(velocity, isA<double>());
      });

      test('x updates all tracks', () {
        final motion1 = CueMotion.linear(300.ms);
        final motion2 = CueMotion.linear(500.ms);

        final config1 = TrackConfig(motion: motion1, reverseMotion: motion1);
        final timeline = CueTimelineImpl(config1);

        final config2 = TrackConfig(motion: motion2, reverseMotion: motion2);
        final (track2, _) = timeline.obtainTrack(config2);

        timeline.prepare(forward: true);
        timeline.x(0.3);

        expect(timeline.obtainDefaultTrack().$1.progress, greaterThan(0.0));
        expect(track2.progress, greaterThan(0.0));
      });
    });

    group('Timeline edge cases', () {
      test('single track timeline works correctly', () {
        final motion = CueMotion.linear(300.ms);
        final config = TrackConfig(motion: motion, reverseMotion: motion);
        final timeline = CueTimelineImpl(config);
        timeline.obtainDefaultTrack();

        expect(timeline.forwardDuration, equals(0.3));
        expect(timeline.reverseDuration, equals(0.3));

        timeline.setProgress(0.5, forward: true);
        expect(timeline.progress, equals(0.5));

        timeline.setProgress(1.0, forward: true);
        expect(timeline.status, equals(AnimationStatus.completed));
      });

      test('timeline with zero duration tracks', () {
        final zeroMotion = CueMotion.linear(.zero);
        final normalMotion = CueMotion.linear(300.ms);

        final zeroConfig = TrackConfig(motion: zeroMotion, reverseMotion: zeroMotion);
        final timeline = CueTimelineImpl(zeroConfig);
        timeline.obtainDefaultTrack();

        final normalConfig = TrackConfig(motion: normalMotion, reverseMotion: normalMotion);
        timeline.obtainTrack(normalConfig);

        expect(timeline.forwardDuration, equals(0.3));
      });

      test('adding many tracks updates duration correctly', () {
        final mainMotion = CueMotion.linear(200.ms);
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);
        timeline.obtainDefaultTrack();

        for (var i = 1; i <= 5; i++) {
          final motion = CueMotion.linear((200.ms + (100.ms * i)));
          final config = TrackConfig(motion: motion, reverseMotion: motion);
          timeline.obtainTrack(config);

          expect(timeline.forwardDuration, equals((200.ms + (100.ms * i)).inMilliseconds / 1000.0));
        }
      });

      test('releasing all additional tracks returns to initial state', () {
        final mainMotion = CueMotion.linear(300.ms);
        final mainConfig = TrackConfig(motion: mainMotion, reverseMotion: mainMotion);
        final timeline = CueTimelineImpl(mainConfig);
        timeline.obtainDefaultTrack();

        final tokens = <ReleaseToken>[];
        for (var i = 1; i <= 3; i++) {
          final motion = CueMotion.linear((300.ms + (100.ms * i)));
          final config = TrackConfig(motion: motion, reverseMotion: motion);
          final (_, token) = timeline.obtainTrack(config);
          tokens.add(token);
        }

        expect(timeline.tracks.length, equals(4));

        for (final token in tokens) {
          timeline.release(token);
        }

        expect(timeline.tracks.length, equals(1));
        expect(timeline.forwardDuration, equals(0.3));
      });
    });

    group('RepeatConfig', () {
      test('updateCount returns new config with updated count', () {
        final config = RepeatConfig(count: 3, reverse: true);

        final updated = config.updateCount(2);

        expect(updated.count, equals(2));
        expect(updated.reverse, isTrue);
      });

      test('RepeatConfig with null count represents infinite repeat', () {
        final config = RepeatConfig(count: null, reverse: false);

        expect(config.count, isNull);
      });

      test('RepeatConfig with from and target parameters', () {
        final config = RepeatConfig(
          count: 2,
          reverse: true,
          from: 0.2,
          target: 0.8,
        );

        expect(config.from, equals(0.2));
        expect(config.target, equals(0.8));
      });
    });
  });
}
