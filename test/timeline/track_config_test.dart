import 'package:cue/cue.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrackConfig', () {
    group('Construction', () {
      test('creates with default reverseType mirror', () {
        const motion = CueMotion.none;
        const config = TrackConfig(motion: motion, reverseMotion: motion);

        expect(config.motion, equals(motion));
        expect(config.reverseMotion, equals(motion));
        expect(config.reverseType, equals(ReverseBehaviorType.mirror));
      });

      test('creates with explicit reverseType', () {
        const motion = CueMotion.none;
        const config = TrackConfig(
          motion: motion,
          reverseMotion: motion,
          reverseType: ReverseBehaviorType.exclusive,
        );

        expect(config.reverseType, equals(ReverseBehaviorType.exclusive));
      });

      test('creates with different forward and reverse motions', () {
        const forward = CueMotion.none;
        const reverse = CueMotion.defaultTime;
        const config = TrackConfig(
          motion: forward,
          reverseMotion: reverse,
        );

        expect(config.motion, equals(forward));
        expect(config.reverseMotion, equals(reverse));
      });
    });

    group('copyWith', () {
      test('returns same values when no arguments', () {
        const motion = CueMotion.none;
        const config = TrackConfig(
          motion: motion,
          reverseMotion: motion,
          reverseType: ReverseBehaviorType.exclusive,
        );
        final copy = config.copyWith();

        expect(copy.motion, equals(config.motion));
        expect(copy.reverseMotion, equals(config.reverseMotion));
        expect(copy.reverseType, equals(config.reverseType));
      });

      test('replaces motion only', () {
        const oldMotion = CueMotion.none;
        const newMotion = CueMotion.defaultTime;
        const config = TrackConfig(motion: oldMotion, reverseMotion: oldMotion);
        final copy = config.copyWith(motion: newMotion);

        expect(copy.motion, equals(newMotion));
        expect(copy.reverseMotion, equals(oldMotion));
      });

      test('replaces reverseMotion only', () {
        const oldMotion = CueMotion.none;
        const newMotion = CueMotion.defaultTime;
        const config = TrackConfig(motion: oldMotion, reverseMotion: oldMotion);
        final copy = config.copyWith(reverseMotion: newMotion);

        expect(copy.motion, equals(oldMotion));
        expect(copy.reverseMotion, equals(newMotion));
      });

      test('replaces reverseType only', () {
        const motion = CueMotion.none;
        const config = TrackConfig(
          motion: motion,
          reverseMotion: motion,
          reverseType: ReverseBehaviorType.mirror,
        );
        final copy = config.copyWith(reverseType: ReverseBehaviorType.none);

        expect(copy.motion, equals(motion));
        expect(copy.reverseType, equals(ReverseBehaviorType.none));
      });

      test('replaces all fields', () {
        const motion = CueMotion.none;
        const config = TrackConfig(motion: motion, reverseMotion: motion);
        final copy = config.copyWith(
          motion: CueMotion.defaultTime,
          reverseMotion: CueMotion.defaultTime,
          reverseType: ReverseBehaviorType.to,
        );

        expect(copy.motion, equals(CueMotion.defaultTime));
        expect(copy.reverseMotion, equals(CueMotion.defaultTime));
        expect(copy.reverseType, equals(ReverseBehaviorType.to));
      });
    });

    group('Equality', () {
      test('equal instances are equal', () {
        const a = TrackConfig(
          motion: CueMotion.none,
          reverseMotion: CueMotion.defaultTime,
          reverseType: ReverseBehaviorType.exclusive,
        );
        const b = TrackConfig(
          motion: CueMotion.none,
          reverseMotion: CueMotion.defaultTime,
          reverseType: ReverseBehaviorType.exclusive,
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('identical instance is equal', () {
        const config = TrackConfig(
          motion: CueMotion.none,
          reverseMotion: CueMotion.none,
        );

        expect(config, equals(config));
      });

      test('different motion is not equal', () {
        const a = TrackConfig(motion: CueMotion.none, reverseMotion: CueMotion.none);
        const b = TrackConfig(motion: CueMotion.defaultTime, reverseMotion: CueMotion.none);

        expect(a, isNot(equals(b)));
      });

      test('different reverseMotion is not equal', () {
        const a = TrackConfig(motion: CueMotion.none, reverseMotion: CueMotion.none);
        const b = TrackConfig(motion: CueMotion.none, reverseMotion: CueMotion.defaultTime);

        expect(a, isNot(equals(b)));
      });

      test('different reverseType is not equal', () {
        const a = TrackConfig(
          motion: CueMotion.none,
          reverseMotion: CueMotion.none,
          reverseType: ReverseBehaviorType.mirror,
        );
        const b = TrackConfig(
          motion: CueMotion.none,
          reverseMotion: CueMotion.none,
          reverseType: ReverseBehaviorType.none,
        );

        expect(a, isNot(equals(b)));
      });

      test('different type is not equal', () {
        const config = TrackConfig(
          motion: CueMotion.none,
          reverseMotion: CueMotion.none,
        );

        expect(config, isNot(equals('not a TrackConfig')));
      });
    });

    group('hashCode', () {
      test('equal instances have same hashCode', () {
        const a = TrackConfig(
          motion: CueMotion.none,
          reverseMotion: CueMotion.defaultTime,
          reverseType: ReverseBehaviorType.exclusive,
        );
        const b = TrackConfig(
          motion: CueMotion.none,
          reverseMotion: CueMotion.defaultTime,
          reverseType: ReverseBehaviorType.exclusive,
        );

        expect(a.hashCode, equals(b.hashCode));
      });

      test('different motion produces different hashCode', () {
        const a = TrackConfig(motion: CueMotion.none, reverseMotion: CueMotion.none);
        const b = TrackConfig(motion: CueMotion.defaultTime, reverseMotion: CueMotion.none);

        expect(a.hashCode, isNot(equals(b.hashCode)));
      });

      test('different reverseType produces different hashCode', () {
        const a = TrackConfig(
          motion: CueMotion.none,
          reverseMotion: CueMotion.none,
          reverseType: ReverseBehaviorType.mirror,
        );
        const b = TrackConfig(
          motion: CueMotion.none,
          reverseMotion: CueMotion.none,
          reverseType: ReverseBehaviorType.none,
        );

        expect(a.hashCode, isNot(equals(b.hashCode)));
      });
    });
  });
}
