import 'package:cue/cue.dart';
import 'package:cue/src/timeline/event_notifier.dart';
import 'package:cue/src/timeline/track/track.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/material.dart';

class CueTimelineImpl extends CueTimeline with AnimationLocalStatusListenersMixin {
  CueTimelineImpl(TrackConfig config) : super({config: TrackEntry(CueTrackImpl(config))});

  factory CueTimelineImpl.fromMotion(CueMotion motion, {CueMotion? reverseMotion}) {
    final config = TrackConfig(motion: motion, reverseMotion: reverseMotion ?? motion);
    return CueTimelineImpl(config);
  }

  @override
  void willAnimate({required bool forward}) {
    _eventsNotifier.fireEvent(TimelineWillAnimateEvent(forward));
  }

  final _eventsNotifier = EventNotifier<TimelineEvent>();

  double _lastT = 0.0;
  double _cycleOffset = 0.0;
  int _listenres = 0;
  RepeatConfig? _repeatConfig;

  @override
  CueTrack get mainTrack => tracks.values.first.track;

  @override
  double get forwardDuration {
    double maxDuration = 0.0;
    for (final entry in tracks.values) {
      if (entry.track.forwardDuration > maxDuration) {
        maxDuration = entry.track.forwardDuration;
      }
    }
    return maxDuration;
  }

  @override
  double get reverseDuration {
    double maxDuration = 0.0;
    for (final entry in tracks.values) {
      if (entry.track.reverseDuration > maxDuration) {
        maxDuration = entry.track.reverseDuration;
      }
    }
    return maxDuration;
  }

  @override
  void reset() {
    _repeatConfig = null;
    _cycleOffset = 0.0;
    setProgress(0.0, forward: true);
  }

  @override
  (CueTrack track, ReleaseToken token) trackFor(TrackConfig config) {
    if (config == mainTrackConfig) return (mainTrack, ReleaseToken(config));

    final entry = tracks.putIfAbsent(
      config,
      () => TrackEntry(buildTrack(config)),
    );
    entry.track.prepare(
      forward: mainTrack.isForwardOrCompleted,
      from: progress,
      exteranlVelocity: mainTrack.velocity,
    );
    final token = ReleaseToken(config);
    entry.addToken(token);
    return (entry.track, token);
  }

  @override
  void release(ReleaseToken token) {
    if (token.config == mainTrackConfig) return;
    final entry = tracks[token.config];
    if (entry == null) return;
    entry.removeToken(token);
    if (entry.canRelease) {
      tracks.remove(token.config);
    }
  }

  @override
  AnimationStatus get status => _status;

  AnimationStatus _status = AnimationStatus.dismissed;

  @override
  void setProgress(double value, {bool forward = true}) {
    _repeatConfig = null;
    if (forward) {
      _setForwardProgress(value);
    } else {
      _setReverseProgress(value);
    }
    _updateStatus();
  }

  void _setForwardProgress(double value) {
    final timelineDuration = forwardDuration;
    for (final entry in tracks.entries) {
      final track = entry.value.track;
      final normalized = (value * timelineDuration / track.forwardDuration).clamp(0.0, 1.0);
      track.setProgress(normalized, forward: true);
    }
  }

  void _setReverseProgress(double value) {
    final timelineDuration = reverseDuration;
    for (final entry in tracks.entries) {
      final track = entry.value.track;
      final idleRatio = (1.0 - (track.reverseDuration / timelineDuration));
      final adjustedValue = (value - idleRatio);
      final normalized = (adjustedValue / (track.reverseDuration / timelineDuration)).clamp(0.0, 1.0);
      track.setProgress(normalized, forward: false);
    }
  }

  void _updateStatus() {
    bool allCompleted = true;
    bool allDismissed = true;

    AnimationStatus currentStatus = _status;

    for (final entry in tracks.values) {
      final s = entry.track.status;

      if (s != AnimationStatus.completed) {
        allCompleted = false;
      }
      if (s != AnimationStatus.dismissed) {
        allDismissed = false;
      }

      if (s == AnimationStatus.forward) {
        currentStatus = AnimationStatus.forward;
        break;
      }
      if (s == AnimationStatus.reverse) {
        currentStatus = AnimationStatus.reverse;
        break;
      }
    }

    if (allCompleted) currentStatus = AnimationStatus.completed;
    if (allDismissed) currentStatus = AnimationStatus.dismissed;

    if (currentStatus != _status) {
      _status = currentStatus;
      notifyStatusListeners(_status);
    }
  }

  @override
  void prepare({required bool forward, double? from}) {
    _repeatConfig = null;
    _cycleOffset = 0.0;
    fireEvent(TimelinePrepareEvent(forward));
    _lastT = 0.0;
    _prepareInternal(forward, from);
  }

  void _prepareInternal(bool forward, [double? from]) {
    for (final entry in tracks.values) {
      entry.track.prepare(forward: forward, from: from);
    }
    _updateStatus();
  }

  @override
  void prepareForRepeat(RepeatConfig config) {
    _repeatConfig = config;
    _lastT = 0.0;
    _cycleOffset = 0.0;
    _prepareInternal(true, 0.0);
  }

  @override
  double x(double time) {
    final adjustedTime = time - _cycleOffset;
    final dt = adjustedTime - _lastT;
    _lastT = adjustedTime;
    if (dt > 0) {
      for (final entry in tracks.values) {
        entry.track.tick(dt);
      }
    }
    _updateStatus();
    return progress;
  }

  @override
  double dx(double time) => mainTrack.velocity;

  @override
  bool isDone(double time) {
    final cycleDone = tracks.values.every((entry) => entry.track.isDone);
    if (!cycleDone) return false;

    final config = _repeatConfig;
    if (config == null) return true;

    if (config.count != null) {
      final nextCount = config.count! - 1;
      _repeatConfig = config.updateCount(nextCount);

      if (nextCount == 0) {
        return true;
      }
    }

    _cycleOffset = time;
    _lastT = 0.0;

    if (config.reverse) {
      _prepareInternal(!mainTrack.isForwardOrCompleted);
    } else {
      _prepareInternal(true, 0.0);
    }

    return false;
  }

  @override
  CueTrack buildTrack(TrackConfig config) {
    return CueTrackImpl(config);
  }

  @override
  void didRegisterListener() => _listenres++;

  @override
  void didUnregisterListener() => _listenres--;

  bool get hasListeners => _listenres > 0;

  @override
  void dispose() {
    super.dispose();
    _eventsNotifier.dispose();
  }
}

abstract class CueTimeline extends Simulation with EventNotifier<TimelineEvent> {
  void prepare({required bool forward, double? from});
  void prepareForRepeat(RepeatConfig config);

  void willAnimate({required bool forward});

  void setProgress(double value, {bool forward = true});

  void reset();

  (CueTrack, ReleaseToken) trackFor(TrackConfig config);

  void release(ReleaseToken token);

  AnimationStatus get status;

  double get forwardDuration;

  double get reverseDuration;

  double get progress {
    final isForward = status.isForwardOrCompleted;
    var longest = tracks.values.first;
    for (final entry in tracks.values) {
      if ((isForward ? entry.track.forwardDuration : entry.track.reverseDuration) >
          (isForward ? longest.track.forwardDuration : longest.track.reverseDuration)) {
        longest = entry;
      }
    }
    return longest.track.progress;
  }

  final Map<TrackConfig, TrackEntry> tracks;

  CueTimeline(this.tracks);

  CueTrack buildTrack(TrackConfig config);

  TrackConfig get mainTrackConfig => tracks.keys.first;

  CueTrack get mainTrack;

  @override
  void dispose();

  void resetTracks(TrackConfig main) {
    tracks.clear();
    tracks[main] = TrackEntry(buildTrack(main));
  }

  void addStatusListener(AnimationStatusListener listener);
  void removeStatusListener(AnimationStatusListener listener);
}

sealed class TimelineEvent {
  const TimelineEvent();
}

class TimelineWillAnimateEvent extends TimelineEvent {
  final bool forward;

  const TimelineWillAnimateEvent(this.forward);
}

class TimelinePrepareEvent extends TimelineEvent {
  final bool forward;

  const TimelinePrepareEvent(this.forward);
}

class RepeatConfig {
  final int? count;
  final bool reverse;

  RepeatConfig({
    this.count,
    required this.reverse,
  });

  RepeatConfig updateCount(int newCount) {
    return RepeatConfig(count: newCount, reverse: reverse);
  }
}

class ReleaseToken {
  final TrackConfig config;
  const ReleaseToken(this.config);
}

class TrackEntry {
  final CueTrack track;
  final List<ReleaseToken> tokens;
  TrackEntry(this.track) : tokens = [];

  void addToken(ReleaseToken token) {
    tokens.add(token);
  }

  bool removeToken(ReleaseToken token) {
    return tokens.remove(token);
  }

  bool get canRelease => tokens.isEmpty;
}
