import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';
import 'package:cue/src/acts/base/act.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ActKey', () {
    test('equality', () {
      const key1 = ActKey('test');
      const key2 = ActKey('test');
      expect(key1, equals(key2));
    });

    test('different keys not equal', () {
      const key1 = ActKey('test1');
      const key2 = ActKey('test2');
      expect(key1, isNot(equals(key2)));
    });

    test('hashCode consistency', () {
      const key1 = ActKey('test');
      const key2 = ActKey('test');
      expect(key1.hashCode, equals(key2.hashCode));
    });

    test('toString without desc', () {
      const key = ActKey('test');
      expect(key.toString(), equals('ActKey(test)'));
    });

    test('toString with desc', () {
      const key = ActKey('test', 'description');
      expect(key.toString(), equals('ActKey(test, description)'));
    });
  });

  group('ActContext', () {
    test('creates with required parameters', () {
      final context = ActContext(
        motion: CueMotion.defaultTime,
        reverseMotion: CueMotion.defaultTime,
      );

      expect(context.motion, equals(CueMotion.defaultTime));
      expect(context.reverseMotion, equals(CueMotion.defaultTime));
      expect(context.delay, equals(Duration.zero));
      expect(context.reverseDelay, equals(Duration.zero));
      expect(context.textDirection, equals(TextDirection.ltr));
      expect(context.implicitFrom, isNull);
    });

    test('creates with all parameters', () {
      final context = ActContext(
        motion: CueMotion.linear(Duration(milliseconds: 300)),
        reverseMotion: CueMotion.linear(Duration(milliseconds: 300)),
        delay: Duration(milliseconds: 100),
        reverseDelay: Duration(milliseconds: 200),
        textDirection: TextDirection.rtl,
        implicitFrom: 'value',
      );

      expect(context.delay, equals(Duration(milliseconds: 100)));
      expect(context.reverseDelay, equals(Duration(milliseconds: 200)));
      expect(context.textDirection, equals(TextDirection.rtl));
      expect(context.implicitFrom, equals('value'));
    });

    test('copyWith updates specific fields', () {
      final original = ActContext(
        motion: CueMotion.linear(Duration(milliseconds: 300)),
        reverseMotion: CueMotion.linear(Duration(milliseconds: 300)),
      );

      final copied = original.copyWith(
        delay: Duration(milliseconds: 100),
        textDirection: TextDirection.rtl,
      );

      expect(copied.motion, equals(original.motion));
      expect(copied.reverseMotion, equals(original.reverseMotion));
      expect(copied.delay, equals(Duration(milliseconds: 100)));
      expect(copied.textDirection, equals(TextDirection.rtl));
    });

    test('copyWith preserves unchanged fields', () {
      final original = ActContext(
        motion: CueMotion.linear(Duration(milliseconds: 300)),
        reverseMotion: CueMotion.linear(Duration(milliseconds: 300)),
        delay: Duration(milliseconds: 50),
      );

      final copied = original.copyWith();

      expect(copied.motion, equals(original.motion));
      expect(copied.reverseMotion, equals(original.reverseMotion));
      expect(copied.delay, equals(original.delay));
    });
  });

  group('Act factories', () {
    testWidgets('Act.scale creates ScaleAct', (tester) async {
      final act = Act.scale(from: 0.0, to: 1.0);
      expect(act.key.key, equals('Scale'));
    });

    testWidgets('Act.zoomIn creates ScaleAct', (tester) async {
      final act = Act.zoomIn();
      expect(act.key.key, equals('Scale'));
    });

    testWidgets('Act.fadeIn creates OpacityAct', (tester) async {
      final act = Act.fadeIn();
      expect(act.key.key, equals('Opacity'));
    });

    testWidgets('Act.slideUp creates SlideAct', (tester) async {
      final act = Act.slideUp();
      expect(act.key.key, equals('Slide'));
    });

    testWidgets('Act.opacity creates OpacityAct', (tester) async {
      final act = Act.opacity(from: 0.0, to: 1.0);
      expect(act.key.key, equals('Opacity'));
    });

    testWidgets('Act.blur creates BlurAct', (tester) async {
      final act = Act.blur(from: 0.0, to: 10.0);
      expect(act.key.key, equals('Blur'));
    });

    testWidgets('Act.rotate creates RotateAct', (tester) async {
      final act = Act.rotate(from: 0, to: 3.14);
      expect(act.key.key, equals('Rotate'));
    });
  });
}
