import 'package:cue/cue.dart';
import 'package:cue/src/timeline/event_notifier.dart';
import 'package:cue/src/timeline/track/track.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/material.dart';

/// Manages and coordinates multiple animation tracks.
///
/// A timeline combines multiple [CueTrack]s with different timings into
/// a single coordinated animation. The timeline:
/// - Maintains a default track and allows additional tracks via [TrackConfig]
/// - Synchronizes all tracks to a single progress value (0-1)
/// - Calculates overall forward/reverse durations as the max of all tracks
/// - Handles track lifecycle (creation, caching, release)
/// - Maintains overall animation status and supports repeating animations
///
/// Typical usage:
/// ```dart
/// final timeline = CueTimelineImpl.fromMotion(Spring.smooth());
/// final (track1, token1) = timeline.obtainDefaultTrack();
/// final (track2, token2) = timeline.obtainTrack(
///   TrackConfig(motion: differentMotion, reverseMotion: differentMotion)
/// );
/// timeline.prepare(forward: true);
/// // animate...
/// timeline.release(token1);
/// timeline.release(token2);
/// ```
class CueTimelineImpl extends CueTimeline with AnimationLocalStatusListenersMixin {
  /// Default track configuration used when timeline is created.
  /// Always present and cannot be removed from the timeline.
  @override
  final TrackConfig defaultConfig;

  /// All active tracks mapped by their configuration.
  /// Includes the default track and any obtained via [obtainTrack].
  @override
  Map<TrackConfig, TrackEntry> get tracks => _tracks;

  final Map<TrackConfig, TrackEntry> _tracks = {};

  double _progressPlaceholder;

  /// Creates a timeline implementation
  CueTimelineImpl(this.defaultConfig, {double initialProgress = 0.0})
    : assert(
        initialProgress >= 0.0 && initialProgress <= 1.0,
        'Initial progress must be between 0.0 and 1.0. Received: $initialProgress',
      ),
      _progressPlaceholder = initialProgress,
      _status = switch (initialProgress) {
        0.0 => AnimationStatus.dismissed,
        1.0 => AnimationStatus.completed,
        _ => AnimationStatus.forward,
      };

  /// Creates a timeline from a single track configuration.
  /// The track is created immediately and available as the default track.
  factory CueTimelineImpl.fromConfig(TrackConfig config, {double initialProgress = 0.0}) {
    return CueTimelineImpl(config, initialProgress: initialProgress);
  }

  /// Creates a timeline from a single motion (forward and reverse use the same).
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

  double? _forwardDuration;
  double? _reverseDuration;

  double _calculateForwardDuration() {
    double maxDuration = 0.0;
    for (final entry in tracks.values) {
      if (entry.track.forwardDuration > maxDuration) {
        maxDuration = entry.track.forwardDuration;
      }
    }
    return maxDuration;
  }

  double _calculateReverseDuration() {
    double maxDuration = 0.0;
    for (final entry in tracks.values) {
      if (entry.track.reverseDuration > maxDuration) {
        maxDuration = entry.track.reverseDuration;
      }
    }
    return maxDuration;
  }

  /// Maximum forward duration across all tracks (in seconds).
  /// Cached until tracks are added/removed.
  @override
  double get forwardDuration => _forwardDuration ??= _calculateForwardDuration();

  /// Maximum reverse duration across all tracks (in seconds).
  /// Cached until tracks are added/removed.
  @override
  double get reverseDuration => _reverseDuration ??= _calculateReverseDuration();

  /// Resets timeline to initial state (progress 0, status dismissed).
  /// Clears repeat configuration and updates all tracks to progress 0.
  @override
  void reset() {
    _repeatConfig = null;
    _cycleOffset = 0.0;
    setProgress(0.0, forward: true);
  }

  /// Gets or creates a track for the given configuration.
  ///
  /// If a track with this config already exists, reuses it.
  /// Otherwise creates a new track and caches it.
  /// Returns a [ReleaseToken] which must be released when done.
  ///
  /// Multiple "owners" can obtain the same track; it's only removed
  /// when all tokens are released AND it's not the default track.
  @override
  (CueTrack track, ReleaseToken token) obtainTrack(TrackConfig config) {
    // must obtain here
    double handOffProgress = progress;
    final entry = tracks.putIfAbsent(
      config,
      () => TrackEntry(buildTrack(config)),
    );
    _forwardDuration = null;
    _reverseDuration = null;
    if (entry.tokens.isEmpty) {
      // this mean the track is newly created
      // we attach the current timeline state to it so that it can be in sync with other tracks
      entry.track.prepare(
        forward: status.isForwardOrCompleted,
        from: handOffProgress,
        exteranlVelocity: dx(_lastT),
      );
    }

    // we now use actual progress
    _progressPlaceholder = 0.0;
    final token = ReleaseToken(config, this);
    entry.addToken(token);
    return (entry.track, token);
  }

  /// Releases a track obtained via [obtainTrack] or [obtainDefaultTrack].
  ///
  /// If all tokens for a track are released (and it's not the default),
  /// the track is also removed from the timeline.
  @override
  void release(ReleaseToken token) {
    final entry = tracks[token.config];
    if (entry == null) return;
    entry.removeToken(token);
    if (token.config != defaultConfig && entry.canRelease) {
      tracks.remove(token.config);
      _forwardDuration = null;
      _reverseDuration = null;
    }
  }

  @override
  AnimationStatus get status => _status;

  AnimationStatus _status = AnimationStatus.dismissed;

  /// Overall timeline progress (0-1).
  ///
  /// Returns the progress of the longest-duration track in the current direction.
  /// Shorter tracks complete earlier but the timeline progress follows the longest.
  @override
  double get progress {
    if (tracks.isEmpty) {
      return _progressPlaceholder;
    }
    final isForward = status.isForwardOrCompleted;
    var longest = tracks.values.first;
    for (final entry in tracks.values) {
      if ((isForward ? entry.track.forwardDuration : entry.track.reverseDuration) >
          (isForward ? longest.track.forwardDuration : longest.track.reverseDuration)) {
        longest = entry;
      }
    }
    return longest.track.progress.clamp(0.0, 1.0);
  }

  /// Sets timeline progress directly (0-1).
  ///
  /// Updates all tracks proportionally based on their durations.
  /// Shorter tracks will complete before longer tracks.
  /// Clears any active repeat configuration.
  @override
  void setProgress(double value, {bool forward = true, bool forceLinear = false}) {
    _repeatConfig = null;
    if (tracks.isEmpty) {
      _progressPlaceholder = value;
      _status = switch (value) {
        0.0 => AnimationStatus.dismissed,
        1.0 => AnimationStatus.completed,
        _ => forward ? AnimationStatus.forward : AnimationStatus.reverse,
      };
      return;
    }
    if (forward) {
      _setForwardProgress(value, forceLinear: forceLinear);
    } else {
      _setReverseProgress(value, forceLinear: forceLinear);
    }
    _updateStatus();
  }

  void _setForwardProgress(double value, {bool forceLinear = false}) {
    final timelineDuration = forwardDuration;
    for (final entry in tracks.entries) {
      final track = entry.value.track;
      final normalized = (value * timelineDuration / track.forwardDuration).clamp(0.0, 1.0);
      track.setProgress(normalized, forward: true, forceLinear: forceLinear);
    }
  }

  void _setReverseProgress(double value, {bool forceLinear = false}) {
    final timelineDuration = reverseDuration;
    for (final entry in tracks.entries) {
      final track = entry.value.track;
      final idleRatio = (1.0 - (track.reverseDuration / timelineDuration));
      final adjustedValue = (value - idleRatio);
      final normalized = (adjustedValue / (track.reverseDuration / timelineDuration)).clamp(0.0, 1.0);
      track.setProgress(normalized, forward: false, forceLinear: forceLinear);
    }
  }

  void _updateStatus() {
    if (tracks.isEmpty) return;
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

  /// Prepares timeline for animation playback.
  ///
  /// Sets up all tracks with the current state and animation direction.
  /// Clears any repeat configuration and fires [TimelinePrepareEvent].
  ///
  /// [forward] - Direction to animate
  /// [from] - Optional starting progress
  /// [target] - Optional target progress
  /// [velocity] - Optional starting velocity
  @override
  void prepare({required bool forward, double? from, double? target, double? velocity}) {
    _repeatConfig = null;
    _cycleOffset = 0.0;
    fireEvent(TimelinePrepareEvent(forward));
    _lastT = 0.0;
    if (tracks.isEmpty) {
      _progressPlaceholder = from ?? _progressPlaceholder;
      _status = forward ? AnimationStatus.forward : AnimationStatus.reverse;
    } else {
      _prepareInternal(forward, from, target, velocity);
    }
  }

  void _prepareInternal(bool forward, [double? from, double? target, double? velocity]) {
    for (final entry in tracks.values) {
      entry.track.prepare(
        forward: forward,
        from: from,
        target: target,
        exteranlVelocity: velocity,
      );
    }
    _updateStatus();
  }

  @override
  void prepareForRepeat(RepeatConfig config) {
    _repeatConfig = config;
    _lastT = 0.0;
    _cycleOffset = 0.0;
    _prepareInternal(true, config.from ?? 0.0, config.target);
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
  double dx(double time) {
    if (tracks.isEmpty) {
      return 0.0;
    }
    double maxVelocity = 0.0;
    for (final entry in tracks.values) {
      final velocity = entry.track.velocity;
      if (velocity.abs() > maxVelocity.abs()) {
        maxVelocity = velocity;
      }
    }
    return maxVelocity;
  }

  @override
  bool isDone(double time) {
    if (tracks.isEmpty) {
      return true;
    }
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
      if (status.isForwardOrCompleted) {
        _prepareInternal(false, config.target, config.from ?? 0.0);
      } else {
        _prepareInternal(true, config.from ?? 0.0, config.target);
      }
    } else {
      _prepareInternal(true, config.from ?? 0.0, config.target);
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

  /// Whether this timeline has any listeners.
  bool get hasListeners => _listenres > 0;

  @override
  void dispose() {
    super.dispose();
    _eventsNotifier.dispose();
  }
}

/// Base class for timeline implementations.
///
/// Defines the interface for managing and coordinating animation tracks.
/// Subclasses handle the actual track management, progress synchronization,
/// and animation lifecycle.
abstract class CueTimeline extends Simulation with EventNotifier<TimelineEvent> {
  /// Prepares timeline for animation playback.
  void prepare({required bool forward, double? from, double? target, double? velocity});

  /// Prepares timeline for repeating animations.
  void prepareForRepeat(RepeatConfig config);

  /// Fires pre-animation event.
  void willAnimate({required bool forward});

  /// Sets timeline progress (0-1).
  void setProgress(double value, {bool forward = true, bool forceLinear = false});

  /// Resets timeline to initial state.
  void reset();

  /// Gets or creates a track for the given configuration.
  (CueTrack, ReleaseToken) obtainTrack(TrackConfig config);

  /// Gets or creates the default track.
  (CueTrack, ReleaseToken) obtainDefaultTrack() => obtainTrack(defaultConfig);

  /// Releases a track obtained via obtainTrack or obtainDefaultTrack.
  void release(ReleaseToken token);

  /// Current animation status.
  /// Represents the overall status across all tracks (forward, reverse, completed, dismissed).
  ///
  /// if any track is animating forward, status is forward;
  /// if any track is animating reverse, status is reverse;
  /// if all tracks are completed, status is completed;
  /// if all tracks are dismissed, status is dismissed.
  AnimationStatus get status;

  /// Forward animation duration (max across all tracks).
  double get forwardDuration;

  /// Reverse animation duration (max across all tracks).
  double get reverseDuration;

  /// Overall timeline progress (0-1).
  double get progress;

  /// All active tracks mapped by configuration.
  Map<TrackConfig, TrackEntry> get tracks;

  /// Builds a track instance for a configuration.
  CueTrack buildTrack(TrackConfig config);

  /// Default track configuration.
  TrackConfig get defaultConfig;

  @override
  /// Disposes timeline resources.
  void dispose();

  /// Adds a status listener to be notified of animation state changes.
  void addStatusListener(AnimationStatusListener listener);

  /// Removes a previously added status listener.
  void removeStatusListener(AnimationStatusListener listener);
}

/// Base class for timeline events.
///
/// Events are fired during key animation lifecycle moments.
/// Listen via [CueTimeline.addListener] or the event notifier.
sealed class TimelineEvent {
  const TimelineEvent();
}

/// Event fired before timeline begins animating.
///
/// Indicates the animation is about to start in the specified direction.
/// Listen via the [EventNotifier] interface on [CueTimeline].
class TimelineWillAnimateEvent extends TimelineEvent {
  /// Whether the animation is progressing forward (true) or in reverse (false).
  final bool forward;

  /// Creates a TimelineWillAnimateEvent.
  const TimelineWillAnimateEvent(this.forward);
}

/// Event fired when timeline is prepared for animation.
///
/// Fired after [CueTimeline.prepare] is called and all tracks are set up.
/// Indicates the animation is ready to start advancing.
class TimelinePrepareEvent extends TimelineEvent {
  /// Whether the animation is prepared for forward (true) or reverse (false).
  final bool forward;

  /// Creates a TimelinePrepareEvent.
  const TimelinePrepareEvent(this.forward);
}

/// Configuration for repeating animations.
///
/// Defines how to loop or cycle animations with optional direction reversal.
/// Used with [CueTimeline.prepareForRepeat] to set up repeating behavior.
class RepeatConfig {
  /// Number of cycles to repeat (null = infinite).
  /// Decremented after each cycle completion.
  final int? count;

  /// Whether to reverse direction between cycles (true) or always forward (false).
  final bool reverse;

  /// Optional target progress for each cycle.
  /// If null, uses default (1.0 forward, 0.0 reverse).
  final double? target;

  /// Optional starting progress for each cycle.
  /// If null, uses default based on direction.
  final double? from;

  /// Creates a RepeatConfig with the specified settings.
  RepeatConfig({
    this.count,
    required this.reverse,
    this.target,
    this.from,
  });

  /// Creates a copy with updated cycle count.
  /// Used internally to track remaining cycles.
  RepeatConfig updateCount(int newCount) {
    return RepeatConfig(
      count: newCount,
      reverse: reverse,
      target: target,
      from: from,
    );
  }
}

/// Token for managing track lifecycle and release.
///
/// Returned by [CueTimeline.obtainTrack] and [CueTimeline.obtainDefaultTrack].
/// Must be released via [release] when no longer needed. Tracks are only
/// removed when all tokens are released (except the default track).
///
/// Multiple owners can hold tokens for the same track; reference counting
/// ensures proper lifetime management.
class ReleaseToken {
  /// The configuration of the track this token refers to.
  final TrackConfig config;

  /// Reference to the timeline for releasing this token.
  final CueTimeline _timeline;

  /// Creates a ReleaseToken for the given config and timeline.
  const ReleaseToken(this.config, this._timeline);

  /// Releases this token, potentially removing the track if no other tokens exist.
  void release() => _timeline.release(this);
}

/// Container for a track and its active release tokens.
///
/// Manages reference counting for track lifetime. A track can be removed
/// only when [canRelease] is true (no active tokens) AND it's not the default track.
/// This enables safe multi-owner track usage.
class TrackEntry {
  /// The animation track instance.
  final CueTrack track;

  /// Active release tokens for this track.
  /// Tracks are kept alive as long as this list is not empty.
  final List<ReleaseToken> tokens;

  /// Creates a TrackEntry for the given track.
  TrackEntry(this.track) : tokens = [];

  /// Adds a release token to mark this track as "in use".
  void addToken(ReleaseToken token) {
    tokens.add(token);
  }

  /// Removes a release token, returning true if it was present.
  /// When all tokens are removed, the track can be released.
  bool removeToken(ReleaseToken token) {
    return tokens.remove(token);
  }

  /// Whether all tokens have been released and track can be removed.
  /// Returns false while any token is still active.
  bool get canRelease => tokens.isEmpty;
}
