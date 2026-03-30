import 'package:cue/cue.dart';
import 'package:cue/src/timeline/track/track.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CueAnimationImpl', () {
    late CueTrack track;
    late ReleaseToken token;
    late CueAnimtable<double> animtable;

    setUp(() {
      final motion = CueMotion.linear(300.ms);
      final config = TrackConfig(motion: motion, reverseMotion: motion);
      track = CueTrackImpl(config);
      token = ReleaseToken(config);
      animtable = TweenAnimtable(Tween(begin: 0.0, end: 1.0));
    });

    test('stores parent, token, and animtable', () {
      final animation = CueAnimationImpl<double>(
        parent: track,
        token: token,
        animtable: animtable,
      );

      expect(animation.parent, equals(track));
      expect(animation.token, equals(token));
      expect(animation.animtable, equals(animtable));
    });

    test('value returns evaluated animtable', () {
      final animation = CueAnimationImpl<double>(
        parent: track,
        token: token,
        animtable: animtable,
      );

      track.setProgress(0.0);
      expect(animation.value, equals(0.0));

      track.setProgress(0.5);
      expect(animation.value, equals(0.5));

      track.setProgress(1.0);
      expect(animation.value, equals(1.0));
    });

    test('trackConfig returns parent config', () {
      final animation = CueAnimationImpl<double>(
        parent: track,
        token: token,
        animtable: animtable,
      );

      expect(animation.trackConfig, equals(track.config));
    });

    test('isReverseOrDismissed returns correct value', () {
      final animation = CueAnimationImpl<double>(
        parent: track,
        token: token,
        animtable: animtable,
      );

      track.setProgress(0.0, forward: false);
      expect(animation.isReverseOrDismissed, isTrue);

      track.setProgress(1.0);
      expect(animation.isReverseOrDismissed, isFalse);

      track.prepare(forward: false, from: 1.0);
      track.tick(0.001);
      expect(animation.isReverseOrDismissed, isTrue);
    });

    test('map transforms value using selector', () {
      final animation = CueAnimationImpl<double>(
        parent: track,
        token: token,
        animtable: animtable,
      );

      final mapped = animation.map((value) => value * 100);

      track.setProgress(0.5);
      expect(mapped.value, equals(50.0));

      track.setProgress(1.0);
      expect(mapped.value, equals(100.0));
    });

    test('map preserves parent and token', () {
      final animation = CueAnimationImpl<double>(
        parent: track,
        token: token,
        animtable: animtable,
      );

      final mapped = animation.map((value) => value.toString());

      expect(mapped.parent, equals(track));
      expect(mapped.token, equals(token));
    });

    test('map with complex type transformation', () {
      final colorAnimtable = TweenAnimtable<Color>(
        Tween<Color>(begin: Colors.red, end: Colors.blue),
      );
      final animation = CueAnimationImpl<Color>(
        parent: track,
        token: token,
        animtable: colorAnimtable,
      );

      final mapped = animation.map((color) => color.withValues(alpha: .5));

      track.setProgress(0.0);
      expect(mapped.value, equals(Colors.red.withValues(alpha: .5)));

      track.setProgress(1.0);
      expect(mapped.value, equals(Colors.blue.withValues(alpha: .5)));
    });
  });

  group('DeferredCueAnimation', () {
    late CueTrack track;
    late ReleaseToken token;
    late ActContext context;

    setUp(() {
      final motion = CueMotion.linear(300.ms);
      final config = TrackConfig(motion: motion, reverseMotion: motion);
      track = CueTrackImpl(config);
      token = ReleaseToken(config);
      context = ActContext(
        motion: motion,
        reverseMotion: motion,
      );
    });

    test('stores parent, context, and token', () {
      final animation = DeferredCueAnimation<double>(
        parent: track,
        context: context,
        token: token,
      );

      expect(animation.parent, equals(track));
      expect(animation.context, equals(context));
      expect(animation.token, equals(token));
    });

    test('hasAnimatable returns false initially', () {
      final animation = DeferredCueAnimation<double>(
        parent: track,
        context: context,
        token: token,
      );

      expect(animation.hasAnimatable, isFalse);
    });

    test('hasAnimatable returns true after setting', () {
      final animation = DeferredCueAnimation<double>(
        parent: track,
        context: context,
        token: token,
      );

      animation.setAnimatable(TweenAnimtable(Tween(begin: 0.0, end: 1.0)));

      expect(animation.hasAnimatable, isTrue);
    });

    test('animtable throws before being set', () {
      final animation = DeferredCueAnimation<double>(
        parent: track,
        context: context,
        token: token,
      );

      expect(() => animation.animtable, throwsStateError);
    });

    test('animtable returns value after being set', () {
      final animation = DeferredCueAnimation<double>(
        parent: track,
        context: context,
        token: token,
      );
      final animtable = TweenAnimtable(Tween(begin: 0.0, end: 1.0));

      animation.setAnimatable(animtable);

      expect(animation.animtable, equals(animtable));
    });

    test('setAnimatable can be called with null', () {
      final animation = DeferredCueAnimation<double>(
        parent: track,
        context: context,
        token: token,
      );

      animation.setAnimatable(TweenAnimtable(Tween(begin: 0.0, end: 1.0)));
      expect(animation.hasAnimatable, isTrue);

      animation.setAnimatable(null);
      expect(animation.hasAnimatable, isFalse);
    });

    test('value evaluates animtable when set', () {
      final animation = DeferredCueAnimation<double>(
        parent: track,
        context: context,
        token: token,
      );

      animation.setAnimatable(TweenAnimtable(Tween(begin: 0.0, end: 100.0)));

      track.setProgress(0.5);
      expect(animation.value, equals(50.0));
    });

    test('trackConfig returns parent config', () {
      final animation = DeferredCueAnimation<double>(
        parent: track,
        context: context,
        token: token,
      );

      expect(animation.trackConfig, equals(track.config));
    });

    test('isReverseOrDismissed reflects track status', () {
      final animation = DeferredCueAnimation<double>(
        parent: track,
        context: context,
        token: token,
      );

      track.setProgress(0.0, forward: false);
      expect(animation.isReverseOrDismissed, isTrue);

      track.setProgress(1.0);
      expect(animation.isReverseOrDismissed, isFalse);
    });
  });

  group('CueAnimation.map (MappedCueAnimtable)', () {
    late CueTrack track;
    late CueAnimtable<double> baseAnimtable;

    setUp(() {
      final motion = CueMotion.linear(300.ms);
      final config = TrackConfig(motion: motion, reverseMotion: motion);
      track = CueTrackImpl(config);
      baseAnimtable = TweenAnimtable(Tween(begin: 0.0, end: 1.0));
    });

    test('evaluate transforms value using selector', () {
      final animation = CueAnimationImpl<double>(
        parent: track,
        token: ReleaseToken(track.config),
        animtable: baseAnimtable,
      );
      final mapped = animation.map((value) => 'value: $value');

      track.setProgress(0.5);
      expect(mapped.value, equals('value: 0.5'));

      track.setProgress(1.0);
      expect(mapped.value, equals('value: 1.0'));
    });

    test('evaluate with complex selector', () {
      final animation = CueAnimationImpl<double>(
        parent: track,
        token: ReleaseToken(track.config),
        animtable: baseAnimtable,
      );
      final mapped = animation.map((value) => value * value);

      track.setProgress(0.5);
      expect(mapped.value, equals(0.25));

      track.setProgress(0.3);
      expect(mapped.value, closeTo(0.09, 0.0001));
    });

    test('evaluate with type conversion', () {
      final animation = CueAnimationImpl<double>(
        parent: track,
        token: ReleaseToken(track.config),
        animtable: baseAnimtable,
      );
      final mapped = animation.map((value) => (value * 100).round());

      track.setProgress(0.5);
      expect(mapped.value, equals(50));

      track.setProgress(0.73);
      expect(mapped.value, equals(73));
    });
  });

  group('CueAnimation with AnimationWithParentMixin', () {
    late CueTrack track;
    late ReleaseToken token;
    late CueAnimationImpl<double> animation;

    setUp(() {
      final motion = CueMotion.linear(300.ms);
      final config = TrackConfig(motion: motion, reverseMotion: motion);
      track = CueTrackImpl(config);
      token = ReleaseToken(config);
      animation = CueAnimationImpl<double>(
        parent: track,
        token: token,
        animtable: TweenAnimtable(Tween(begin: 0.0, end: 1.0)),
      );
    });

    test('parent returns track', () {
      expect(animation.parent, equals(track));
    });

    test('value updates when track value changes', () {
      track.setProgress(0.0);
      expect(animation.value, equals(0.0));

      track.setProgress(0.5);
      expect(animation.value, equals(0.5));

      track.setProgress(1.0);
      expect(animation.value, equals(1.0));
    });
  });
}
