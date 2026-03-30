import 'package:flutter_test/flutter_test.dart';
import 'package:cue/src/timeline/event_notifier.dart';

class MyNotifier with EventNotifier<String> {}

void main() {
  group('EventNotifier', () {
    test('listener receives fired event', () {
      final notifier = MyNotifier();
      String? received;
      notifier.addEventListener<String>((event) {
        received = event;
      });
      notifier.fireEvent('hello');
      expect(received, 'hello');
    });

    test('listener can be removed', () {
      final notifier = MyNotifier();
      int count = 0;
      final remove = notifier.addEventListener<String>((event) {
        count++;
      });
      notifier.fireEvent('a');
      remove();
      notifier.fireEvent('b');
      expect(count, 1);
    });

    test('listener with type filter only receives matching events', () {
      final notifier = _TypedNotifier();
      int stringCount = 0;
      int intCount = 0;
      notifier.addEventListener<String>((event) => stringCount++);
      notifier.addEventListener<int>((event) => intCount++);
      notifier.fireEvent('foo');
      notifier.fireEvent(42);
      expect(stringCount, 1);
      expect(intCount, 1);
    });

    test('dispose prevents further listeners and events', () {
      final notifier = MyNotifier();
      notifier.dispose();
      expect(() => notifier.addEventListener((_) {}), throwsA(isA<AssertionError>()));
      expect(() => notifier.fireEvent('x'), throwsA(isA<AssertionError>()));
    });

    test('dispose clears listeners', () {
      final notifier = MyNotifier();
      int count = 0;
      notifier.addEventListener<String>((event) => count++);
      notifier.dispose();
      // Should not call any listeners after dispose
      expect(() => notifier.fireEvent('x'), throwsA(isA<AssertionError>()));
      expect(count, 0);
    });
  });
}

class _TypedNotifier with EventNotifier<Object> {}
