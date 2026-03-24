import 'package:cue/cue.dart';
import 'package:cue/src/timeline/event_notifier.dart';
import 'package:cue/src/timeline/track/track.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/material.dart';

class CueTimelineImpl extends CueTimeline with AnimationLocalStatusListenersMixin {
  CueTimelineImpl(TrackConfig config) : super({config: CueTrackImpl(config)});

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

  final Map<TrackConfig, int> _trackRefs = {};

  @override
  CueTrack get mainTrack => tracks.values.first;

  @override
  Duration get forwardDuration {
    double maxDurationSeconds = 0.0;
    for (final track in tracks.values) {
      if (track.forwardDuration > maxDurationSeconds) {
        maxDurationSeconds = track.forwardDuration;
      }
    }
    return Duration(milliseconds: (maxDurationSeconds * 1000).round());
  }

  @override
  Duration get reverseDuration {
    double maxDurationSeconds = 0.0;
    for (final track in tracks.values) {
      if (track.reverseDuration > maxDurationSeconds) {
        maxDurationSeconds = track.reverseDuration;
      }
    }
    return Duration(milliseconds: (maxDurationSeconds * 1000).round());
  }

  @override
  void reset() {
    _repeatConfig = null;
    _cycleOffset = 0.0;
    setProgress(0.0, forward: true);
  }

  @override
  CueTrack trackFor(TrackConfig config) {
    if (config == mainTrackConfig) return mainTrack;
    _trackRefs[config] = (_trackRefs[config] ?? 0) + 1;
    final animation = tracks.putIfAbsent(config, () => buildTrack(config));
    animation.prepare(
      forward: mainTrack.isForwardOrCompleted,
      from: mainTrack.progress,
      exteranlVelocity: mainTrack.velocity,
    );
    return animation;
  }

  @override
  void release(TrackConfig config) {
    if (config == mainTrackConfig) return;
    final next = (_trackRefs[config] ?? 1) - 1;
    assert(
      next >= 0,
      'Track reference count for $config went below zero. This indicates a bug in the reference counting logic.',
    );
    if (next <= 0) {
      _trackRefs.remove(config);
      tracks.remove(config);
    } else {
      _trackRefs[config] = next;
    }
  }

  @override
  AnimationStatus get status => _status;

  AnimationStatus _status = AnimationStatus.dismissed;

  @override
  void setProgress(double value, {bool forward = true}) {
    final maxDuration = (forward ? forwardDuration : reverseDuration).inMicroseconds / Duration.microsecondsPerSecond;
    for (final track in tracks.values) {
      final trackDuration = forward ? track.forwardDuration : track.reverseDuration;
      final normalized = (value * maxDuration / trackDuration).clamp(0.0, 1.0);
      track.setProgress(normalized, forward: forward);
    }
    _updateStatus();
  }

  void _updateStatus() {
    bool allCompleted = true;
    bool allDismissed = true;

    AnimationStatus currentStatus = _status;

    for (final d in tracks.values) {
      final s = d.status;

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
    for (final track in tracks.values) {
      track.prepare(forward: forward, from: from);
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
      for (final track in tracks.values) {
        track.tick(dt);
      }
    }
    _updateStatus();
    return progress;
  }

  @override
  double dx(double time) => mainTrack.velocity;

  @override
  bool isDone(double time) {
    final cycleDone = tracks.values.every((track) => track.isDone);
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

  CueTrack trackFor(TrackConfig config);

  void release(TrackConfig config);

  AnimationStatus get status;

  Duration get forwardDuration;

  Duration get reverseDuration;

  double get progress {
    final isForward = status.isForwardOrCompleted;
    var longest = tracks.values.first;
    for (final track in tracks.values) {
      if ((isForward ? track.forwardDuration : track.reverseDuration) >
          (isForward ? longest.forwardDuration : longest.reverseDuration)) {
        longest = track;
      }
    }
    return longest.progress;
  }

  final Map<TrackConfig, CueTrack> tracks;

  CueTimeline(this.tracks);

  CueTrack buildTrack(TrackConfig config);

  TrackConfig get mainTrackConfig => tracks.keys.first;

  CueTrack get mainTrack;

  @override
  void dispose();

  void resetTracks(TrackConfig main) {
    tracks.clear();
    tracks[main] = buildTrack(main);
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
