import 'package:flutter/material.dart';

typedef EventDisposer = void Function();

/// A ChangeNotifier that allows listeners to receive data when notified
mixin class EventNotifier<T> {
  final List<void Function(T)> _eventListeners = [];

  bool _disposed = false;
  /// Add an event listener that will be called with the event data when [fireEvent] is called.
  ///
  /// The listener will only be called for events of type [E] or its subtypes.
  EventDisposer addEventListener<E extends T>(void Function(E) listener) {
    assert(!_disposed, 'Cannot add event listener to a disposed EventNotifier');
    void wrapper(T event) {
      if (event is E) listener(event);
    }
    _eventListeners.add(wrapper);
    return () => _eventListeners.remove(wrapper);
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
