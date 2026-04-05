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


  group('TextStyleAct', () {
    group('key', () {
      test('has correct key name', () {
        final act = TextStyleAct(
          from: TextStyle(fontSize: 14),
          to: TextStyle(fontSize: 18),
        );
        expect(act.key.key, 'TextStyle');
      });
    });

    group('default constructor', () {
      test('accepts from and to', () {
        final from = TextStyle(fontSize: 14);
        final to = TextStyle(fontSize: 18);
        final act = TextStyleAct(from: from, to: to);
        expect(act.from, from);
        expect(act.to, to);
      });

      test('accepts motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = TextStyleAct(
          from: TextStyle(fontSize: 14),
          to: TextStyle(fontSize: 18),
          motion: motion,
        );
        expect(act.motion, motion);
      });

      test('accepts delay', () {
        final act = TextStyleAct(
          from: TextStyle(fontSize: 14),
          to: TextStyle(fontSize: 18),
          delay: const Duration(milliseconds: 100),
        );
        expect(act.delay, const Duration(milliseconds: 100));
      });
    });

    group('keyframed constructor', () {
      test('accepts frames', () {
        final frames = Keyframes<TextStyle>([
          Keyframe(TextStyle(fontSize: 14)),
          Keyframe(TextStyle(fontSize: 18)),
        ] , motion: CueMotion.linear(100.ms));
        final act = TextStyleAct.keyframed(frames: frames);
        expect(act.frames, frames);
      });
    });

    group('resolve', () {
      test('returns ActContext with motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = TextStyleAct(
          from: TextStyle(fontSize: 14),
          to: TextStyle(fontSize: 18),
          motion: motion,
        );
        
        final resolved = act.resolve(actContext);
        expect(resolved.motion, isNotNull);
      });
    });
  });

  group('apply', () {
    testWidgets('wraps child in DefaultTextStyleTransition', (tester) async {
      final act = TextStyleAct(
        from: TextStyle(fontSize: 14),
        to: TextStyle(fontSize: 28),
      );
      
      final (animtable, _) = act.buildTweens(actContext);

      
      track.setProgress(0.5);

      final animation = CueAnimationImpl<TextStyle>(
        parent: track,
        token:  ReleaseToken(track.config, timeline),
        animtable: animtable,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              return act.apply(context, animation, const Text('Styled'));
            },
          ),
        ),
      );

      expect(find.text('Styled'), findsOneWidget);
    });

    testWidgets('renders at progress 0', (tester) async {
      final act = TextStyleAct(
        from: TextStyle(fontSize: 14),
        to: TextStyle(fontSize: 28),
      );
      
      final (animtable, _) = act.buildTweens(actContext);

      
      track.setProgress(0);

      final animation = CueAnimationImpl<TextStyle>(
        parent: track,
        token:  ReleaseToken(track.config, timeline),
        animtable: animtable,
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              return act.apply(context, animation, const Text('At Start'));
            },
          ),
        ),
      );

      await tester.pump();
      expect(find.text('At Start'), findsOneWidget);
    });
  });

  group('IconThemeAct', () {
    group('key', () {
      test('has correct key name', () {
        final act = IconThemeAct(
          from: IconThemeData(size: 24),
          to: IconThemeData(size: 32),
        );
        expect(act.key.key, 'IconTheme');
      });
    });

    group('default constructor', () {
      test('accepts from and to', () {
        final from = IconThemeData(size: 24);
        final to = IconThemeData(size: 32);
        final act = IconThemeAct(from: from, to: to);
        expect(act.from, from);
        expect(act.to, to);
      });

      test('accepts motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = IconThemeAct(
          from: IconThemeData(size: 24),
          to: IconThemeData(size: 32),
          motion: motion,
        );
        expect(act.motion, motion);
      });

      test('accepts delay', () {
        final act = IconThemeAct(
          from: IconThemeData(size: 24),
          to: IconThemeData(size: 32),
          delay: const Duration(milliseconds: 100),
        );
        expect(act.delay, const Duration(milliseconds: 100));
      });
    });

    group('keyframed constructor', () {
      test('accepts frames', () {
        final frames = Keyframes<IconThemeData>([
          Keyframe(IconThemeData(size: 24)),
          Keyframe(IconThemeData(size: 32)),
        ] , motion: CueMotion.linear(100.ms));
        final act = IconThemeAct.keyframed(frames: frames);
        expect(act.frames, frames);
      });
    });

    group('apply', () {
      testWidgets('wraps child in IconTheme', (tester) async {
        final act = IconThemeAct(
          from: IconThemeData(size: 24),
          to: IconThemeData(size: 48),
        );
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0.5);

        final animation = CueAnimationImpl<IconThemeData>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(
                  context,
                  animation,
                  const Icon(Icons.star),
                );
              },
            ),
          ),
        );

        expect(find.byIcon(Icons.star), findsOneWidget);
      });

      testWidgets('renders at progress 0', (tester) async {
        final act = IconThemeAct(
          from: IconThemeData(size: 24),
          to: IconThemeData(size: 48),
        );
        
        final (animtable, _) = act.buildTweens(actContext);

        
        track.setProgress(0);

        final animation = CueAnimationImpl<IconThemeData>(
          parent: track,
          token:  ReleaseToken(track.config, timeline),
          animtable: animtable,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                return act.apply(
                  context,
                  animation,
                  const Icon(Icons.star),
                );
              },
            ),
          ),
        );

        await tester.pump();
        expect(find.byIcon(Icons.star), findsOneWidget);
      });
    });

    group('resolve', () {
      test('returns ActContext with motion', () {
        final motion = CueMotion.linear(300.ms);
        final act = IconThemeAct(
          from: IconThemeData(size: 24),
          to: IconThemeData(size: 32),
          motion: motion,
        );
        
        final resolved = act.resolve(actContext);
        expect(resolved.motion, isNotNull);
      });
    });
  });
}
