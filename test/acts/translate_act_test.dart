import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';

void main() {
  group('TranslateAct', () {
    test('translateX equality', () {
      final a = TranslateAct.fromX(from: 0, to: 100);
      final b = TranslateAct.fromX(from: 0, to: 100);
      expect(a, equals(b));
    });

    test('translateX different from not equal', () {
      final a = TranslateAct.fromX(from: 0, to: 100);
      final b = TranslateAct.fromX(from: 50, to: 100);
      expect(a, isNot(equals(b)));
    });

    test('translateX different to not equal', () {
      final a = TranslateAct.fromX(from: 0, to: 100);
      final b = TranslateAct.fromX(from: 0, to: 200);
      expect(a, isNot(equals(b)));
    });

    test('translateY equality', () {
      final a = TranslateAct.y(from: 0, to: 100);
      final b = TranslateAct.y(from: 0, to: 100);
      expect(a, equals(b));
    });

    test('translateY different from not equal', () {
      final a = TranslateAct.y(from: 0, to: 100);
      final b = TranslateAct.y(from: 50, to: 100);
      expect(a, isNot(equals(b)));
    });

    test('translateY different to not equal', () {
      final a = TranslateAct.y(from: 0, to: 100);
      final b = TranslateAct.y(from: 0, to: 200);
      expect(a, isNot(equals(b)));
    });

    test('translateX vs translateY not equal', () {
      final a = TranslateAct.fromX(from: 0, to: 100);
      final b = TranslateAct.y(from: 0, to: 100);
      expect(a, isNot(equals(b)));
    });

    test('translateX keyframed equality', () {
      final frames = MotionKeyframes<double>([
        Keyframe.key(0.0, motion: CueMotion.none),
        Keyframe.key(100.0, motion: CueMotion.none),
      ]);
      final a = TranslateAct.keyframedX(frames: frames);
      final b = TranslateAct.keyframedX(frames: frames);
      expect(a, equals(b));
    });

    test('translateY keyframed equality', () {
      final frames = MotionKeyframes<double>([
        Keyframe.key(0.0, motion: CueMotion.none),
        Keyframe.key(100.0, motion: CueMotion.none),
      ]);
      final a = TranslateAct.keyframedY(frames: frames);
      final b = TranslateAct.keyframedY(frames: frames);
      expect(a, equals(b));
    });

    test('translateX with different motion not equal', () {
      final a = TranslateAct.fromX(from: 0, to: 100, motion: CueMotion.none);
      final b = TranslateAct.fromX(from: 0, to: 100, motion: CueMotion.linear(Duration(milliseconds: 200)));
      expect(a, isNot(equals(b)));
    });

    test('translateX with different delay not equal', () {
      final a = TranslateAct.fromX(from: 0, to: 100, delay: Duration.zero);
      final b = TranslateAct.fromX(from: 0, to: 100, delay: Duration(milliseconds: 100));
      expect(a, isNot(equals(b)));
    });

    test('translateX with different reverse not equal', () {
      final a = TranslateAct.fromX(from: 0, to: 100, reverse: ReverseBehavior.mirror());
      final b = TranslateAct.fromX(from: 0, to: 100, reverse: ReverseBehavior.none());
      expect(a, isNot(equals(b)));
    });

    test('translateX hashCode consistency', () {
      final a = TranslateAct.fromX(from: 0, to: 100);
      final b = TranslateAct.fromX(from: 0, to: 100);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('translateY hashCode consistency', () {
      final a = TranslateAct.y(from: 0, to: 100);
      final b = TranslateAct.y(from: 0, to: 100);
      expect(a.hashCode, equals(b.hashCode));
    });

    test('translateX keyframed with different frames not equal', () {
      final framesA = MotionKeyframes<double>([
        Keyframe.key(0.0, motion: CueMotion.none),
      ]);
      final framesB = MotionKeyframes<double>([
        Keyframe.key(100.0, motion: CueMotion.none),
      ]);
      final a = TranslateAct.keyframedX(frames: framesA);
      final b = TranslateAct.keyframedX(frames: framesB);
      expect(a, isNot(equals(b)));
    });

    test('translateY keyframed with different frames not equal', () {
      final framesA = MotionKeyframes<double>([
        Keyframe.key(0.0, motion: CueMotion.none),
      ]);
      final framesB = MotionKeyframes<double>([
        Keyframe.key(100.0, motion: CueMotion.none),
      ]);
      final a = TranslateAct.keyframedY(frames: framesA);
      final b = TranslateAct.keyframedY(frames: framesB);
      expect(a, isNot(equals(b)));
    });

    test('translateX keyframed with different delay not equal', () {
      final frames = MotionKeyframes<double>([
        Keyframe.key(0.0, motion: CueMotion.none),
      ]);
      final a = TranslateAct.keyframedX(frames: frames, delay: Duration(milliseconds: 100));
      final b = TranslateAct.keyframedX(frames: frames, delay: Duration(milliseconds: 200));
      expect(a, isNot(equals(b)));
    });

    test('translateY keyframed with different delay not equal', () {
      final frames = MotionKeyframes<double>([
        Keyframe.key(0.0, motion: CueMotion.none),
      ]);
      final a = TranslateAct.keyframedY(frames: frames, delay: Duration(milliseconds: 100));
      final b = TranslateAct.keyframedY(frames: frames, delay: Duration(milliseconds: 200));
      expect(a, isNot(equals(b)));
    });
  });

  group('TranslateTransition', () {
    testWidgets('renders child with translation', (tester) async {
      final animation = AlwaysStoppedAnimation<Offset>(Offset(10, 20));
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: TranslateTransition(
            offset: animation,
            child: Container(width: 50, height: 50, color: Color(0xFF000000)),
          ),
        ),
      );
      expect(find.byType(Transform), findsOneWidget);
    });

    testWidgets('respects transformHitTests', (tester) async {
      final animation = AlwaysStoppedAnimation<Offset>(Offset(10, 20));
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: TranslateTransition(
            offset: animation,
            transformHitTests: false,
            child: Container(width: 50, height: 50, color: Color(0xFF000000)),
          ),
        ),
      );
      expect(find.byType(Transform), findsOneWidget);
    });
  });

  group('TranslateAct.fromX widget tests', () {
    testWidgets('applies horizontal translation', (tester) async {
      final timeline = CueTimelineImpl.fromMotion(CueMotion.linear(Duration(milliseconds: 300)));
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Cue(
            timeline: timeline,
            acts: [TranslateAct.fromX(from: 0, to: 100)],
            child: Container(width: 50, height: 50),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Transform), findsWidgets);
    });
  });

  group('TranslateAct.y widget tests', () {
    testWidgets('applies vertical translation', (tester) async {
      final timeline = CueTimelineImpl.fromMotion(CueMotion.linear(Duration(milliseconds: 300)));
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Cue(
            timeline: timeline,
            acts: [TranslateAct.y(from: 0, to: 100)],
            child: Container(width: 50, height: 50),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Transform), findsWidgets);
    });
  });

  group('TranslateAct.fromGlobal', () {
    test('fromGlobal creates valid instance', () {
      final act = TranslateAct.fromGlobal(offset: Offset(100, 200));
      expect(act.key, equals(const ActKey('Translate')));
    });

    test('fromGlobalRect creates valid instance', () {
      final act = TranslateAct.fromGlobalRect(Rect.fromLTWH(0, 0, 100, 100));
      expect(act.key, equals(const ActKey('Translate')));
    });

    test('fromGlobalKey creates valid instance', () {
      final key = GlobalKey();
      final act = TranslateAct.fromGlobalKey(key);
      expect(act.key, equals(const ActKey('Translate')));
    });

    test('fromGlobal with motion creates valid instance', () {
      final act = TranslateAct.fromGlobal(
        offset: Offset(100, 200),
        motion: CueMotion.linear(Duration(milliseconds: 300)),
      );
      expect(act.key, equals(const ActKey('Translate')));
    });

    test('fromGlobal with delay creates valid instance', () {
      final act = TranslateAct.fromGlobal(
        offset: Offset(100, 200),
        delay: Duration(milliseconds: 100),
      );
      expect(act.key, equals(const ActKey('Translate')));
    });

    testWidgets('fromGlobal applies translation', (tester) async {
      final targetKey = GlobalKey();
      final timeline = CueTimelineImpl.fromMotion(CueMotion.linear(Duration(milliseconds: 300)));
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              Positioned(
                key: targetKey,
                left: 100,
                top: 100,
                child: SizedBox(width: 50, height: 50),
              ),
              Cue(
                timeline: timeline,
                acts: [TranslateAct.fromGlobal(offset: Offset(100, 100))],
                child: SizedBox(width: 50, height: 50),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Visibility), findsWidgets);
    });

    testWidgets('fromGlobalRect applies translation', (tester) async {
      final timeline = CueTimelineImpl.fromMotion(CueMotion.linear(Duration(milliseconds: 300)));
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              Cue(
                timeline: timeline,
                acts: [TranslateAct.fromGlobalRect(Rect.fromLTWH(100, 100, 200, 200))],
                child: SizedBox(width: 50, height: 50),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Visibility), findsWidgets);
    });

    testWidgets('fromGlobal with globalKey applies translation', (tester) async {
      final targetKey = GlobalKey();
      final timeline = CueTimelineImpl.fromMotion(CueMotion.linear(Duration(milliseconds: 300)));
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              Positioned(
                key: targetKey,
                left: 100,
                top: 100,
                child: SizedBox(width: 50, height: 50),
              ),
              Cue(
                timeline: timeline,
                acts: [TranslateAct.fromGlobalKey(targetKey)],
                child: SizedBox(width: 50, height: 50),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Visibility), findsWidgets);
    });

    testWidgets('fromGlobal updates when offset changes', (tester) async {
      final timeline = CueTimelineImpl.fromMotion(CueMotion.linear(Duration(milliseconds: 300)));

      // First render
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Cue(
            timeline: timeline,
            acts: [TranslateAct.fromGlobal(offset: Offset(100, 100))],
            child: Container(width: 50, height: 50),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Update with different offset - this triggers didUpdateWidget
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Cue(
            timeline: timeline,
            acts: [TranslateAct.fromGlobal(offset: Offset(200, 200))],
            child: SizedBox(width: 50, height: 50),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Visibility), findsWidgets);
    });

    testWidgets('fromGlobalRect updates when rect changes', (tester) async {
      final timeline = CueTimelineImpl.fromMotion(CueMotion.linear(Duration(milliseconds: 300)));

      // First render
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Cue(
            timeline: timeline,
            acts: [TranslateAct.fromGlobalRect(Rect.fromLTWH(100, 100, 200, 200))],
            child: SizedBox(width: 50, height: 50),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Update with different rect - this triggers didUpdateWidget
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Cue(
            timeline: timeline,
            acts: [TranslateAct.fromGlobalRect(Rect.fromLTWH(150, 150, 250, 250))],
            child: SizedBox(width: 50, height: 50),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(Visibility), findsWidgets);
    });

    testWidgets('fromGlobal with valid globalKey measures correctly', (tester) async {
      final targetKey = GlobalKey();
      final timeline = CueTimelineImpl.fromMotion(CueMotion.linear(Duration(milliseconds: 300)));

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              Positioned(
                key: targetKey,
                left: 100,
                top: 100,
                child: SizedBox(width: 50, height: 50),
              ),
              Cue(
                timeline: timeline,
                acts: [TranslateAct.fromGlobalKey(targetKey)],
                child: SizedBox(width: 50, height: 50),
              ),
            ],
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // The widget should render with the global key
      expect(find.byType(Visibility), findsWidgets);
    });
  });
}
