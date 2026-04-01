import 'dart:ui';

import 'package:cue/cue.dart';
import 'package:cue/src/timeline/track/track.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final motion = CueMotion.linear(300.ms);
  final actContext = ActContext(motion: motion, reverseMotion: motion);
  final track = CueTrackImpl(TrackConfig(motion: motion, reverseMotion: motion));
  final timeline = CueTimelineImpl.fromMotion(motion);

  group('PaintAct', () {
    group('key', () {
      test('has correct key name', () {
        final act = PaintAct(
          painter: Painter.paint((canvas, size, progress) {}),
        );
        expect(act.key.key, 'Paint');
      });
    });

    group('constructors', () {
      test('requires painter', () {
        final painter = Painter.paint((canvas, size, progress) {});
        final act = PaintAct(painter: painter);
        expect(act.painter, painter);
      });

      test('default paintOnTop is false', () {
        final act = PaintAct(
          painter: Painter.paint((canvas, size, progress) {}),
        );
        expect(act.paintOnTop, false);
      });

      test('constructor accepts paintOnTop', () {
        final act = PaintAct(
          painter: Painter.paint((canvas, size, progress) {}),
          paintOnTop: true,
        );
        expect(act.paintOnTop, true);
      });

      test('constructor accepts motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = PaintAct(
          painter: Painter.paint((canvas, size, progress) {}),
          motion: motion,
        );
        expect(act.motion, motion);
      });

      test('constructor accepts delay', () {
        final act = PaintAct(
          painter: Painter.paint((canvas, size, progress) {}),
          delay: const Duration(milliseconds: 100),
        );
        expect(act.delay, const Duration(milliseconds: 100));
      });

      test('from and to are fixed at 0.0 and 1.0', () {
        final act = PaintAct(
          painter: Painter.paint((canvas, size, progress) {}),
        );
        expect(act.from, 0.0);
        expect(act.to, 1.0);
      });
    });

    group('buildTweens', () {
      test('creates animtable', () {
        final act = PaintAct(
          painter: Painter.paint((canvas, size, progress) {}),
        );
        
        final (animtable, _) = act.buildTweens(actContext);
        expect(animtable, isNotNull);
      });
    });

    group('apply', () {
      testWidgets('wraps child in CustomPaint', (tester) async {
        final act = PaintAct(
          painter: Painter.paint((canvas, size, progress) {}),
        );
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0.5);

        final animation = CueAnimationImpl<double>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const Text('Child'));
              },
            ),
          ),
        );

        expect(find.byType(CustomPaint), findsOneWidget);
        expect(find.text('Child'), findsOneWidget);
      });

      testWidgets('uses painter when paintOnTop is false', (tester) async {
        final act = PaintAct(
          painter: Painter.paint((canvas, size, progress) {}),
          paintOnTop: false,
        );
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0.5);

        final animation = CueAnimationImpl<double>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const SizedBox());
              },
            ),
          ),
        );

        final customPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));
        expect(customPaint.painter, isNotNull);
        expect(customPaint.foregroundPainter, isNull);
      });

      testWidgets('uses foregroundPainter when paintOnTop is true', (tester) async {
        final act = PaintAct(
          painter: Painter.paint((canvas, size, progress) {}),
          paintOnTop: true,
        );
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0.5);

        final animation = CueAnimationImpl<double>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(context, animation, const SizedBox());
              },
            ),
          ),
        );

        final customPaint = tester.widget<CustomPaint>(find.byType(CustomPaint));
        expect(customPaint.painter, isNull);
        expect(customPaint.foregroundPainter, isNotNull);
      });
    });

    group('equality', () {
      test('equal acts have same hashCode', () {
        final painter = Painter.paint((canvas, size, progress) {});
        final act1 = PaintAct(painter: painter, paintOnTop: false);
        final act2 = PaintAct(painter: painter, paintOnTop: false);
        expect(act1, act2);
        expect(act1.hashCode, act2.hashCode);
      });

      test('different paintOnTop values are not equal', () {
        final painter = Painter.paint((canvas, size, progress) {});
        final act1 = PaintAct(painter: painter, paintOnTop: false);
        final act2 = PaintAct(painter: painter, paintOnTop: true);
        expect(act1, isNot(act2));
      });
    });
  });

  group('PaintActor', () {
    test('creates PaintAct with correct values', () {
      final painter = Painter.paint((canvas, size, progress) {});
      final actor = PaintActor(
        painter: painter,
        child: const SizedBox(),
      );
      final act = actor.act as PaintAct;
      expect(act.painter, painter);
      expect(act.paintOnTop, false);
    });

    test('passes paintOnTop to act', () {
      final painter = Painter.paint((canvas, size, progress) {});
      final actor = PaintActor(
        painter: painter,
        paintOnTop: true,
        child: const SizedBox(),
      );
      final act = actor.act as PaintAct;
      expect(act.paintOnTop, true);
    });
  });

  group('Painter', () {
    test('paint callback is called', () {
      double? receivedProgress;
      final painter = Painter.paint((canvas, size, progress) {
        receivedProgress = progress;
      });

      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(100, 100), 0.5);
      expect(receivedProgress, 0.5);
    });
  });
}
