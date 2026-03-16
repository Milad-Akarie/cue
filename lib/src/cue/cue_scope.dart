part of 'cue.dart';

class CueScope extends InheritedWidget {
  const CueScope({
    super.key,
    required super.child,
    required this.timeline,
    this.willReanimateNotifier,
    required this.reanimateFromCurrent,
  });

  final EventNotifier<bool>? willReanimateNotifier;
  final CueTimeline timeline;
  final bool reanimateFromCurrent;

  static CueScope of(BuildContext context) {
    final cue = context.dependOnInheritedWidgetOfExactType<CueScope>();
    assert(cue != null, 'No Cue found in context, make sure to wrap your widget tree with a Cue widget.');
    return cue!;
  }

  @override
  bool updateShouldNotify(covariant CueScope oldWidget) {
    return timeline != oldWidget.timeline ||
        timeline.mainDriver != oldWidget.timeline.mainDriver ||
        willReanimateNotifier != oldWidget.willReanimateNotifier ||
        reanimateFromCurrent != oldWidget.reanimateFromCurrent;
  }
}

/// A ChangeNotifier that allows listeners to receive data when notified
class EventNotifier<T> {
  final List<void Function(T)> _eventListeners = [];

  bool _disposed = false;

  /// Add a listener that receives data when events are fired
  void addEventListener(void Function(T) listener) {
    assert(!_disposed, 'Cannot add event listener to a disposed EventNotifier');
    _eventListeners.add(listener);
  }

  /// Remove an event listener
  void removeEventListener(void Function(T) listener) {
    assert(!_disposed, 'Cannot remove event listener from a disposed EventNotifier');
    _eventListeners.remove(listener);
  }

  /// Fire an event with data to all event listeners
  void fireEvent(T data) {
    assert(!_disposed, 'Cannot fire event on a disposed EventNotifier');
    // Send event to all event listeners
    for (final listener in _eventListeners.toList()) {
      listener(data);
    }
  }

  @mustCallSuper
  void dispose() {
    _disposed = true;
    _eventListeners.clear();
  }
}
