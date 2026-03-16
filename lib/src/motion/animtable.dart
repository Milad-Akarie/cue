import 'package:cue/src/motion/cue_motion.dart';
import 'package:cue/src/motion/timeline.dart';
import 'package:flutter/widgets.dart';

abstract class CueAnimtable<T> {
  const CueAnimtable();
  CueMotion? get motion => null;
  T evaluate(CueAnimationDriver driver);
}

class TweenAnimtable<T> extends CueAnimtable<T> {
  final Animatable<T> tween;
  @override
  final CueMotion? motion;

  const TweenAnimtable(this.tween, {required this.motion});

  @override
  T evaluate(CueAnimationDriver driver) {
    return tween.transform(driver.value);
  }
}

class ReversedAnimtable<T> extends TweenAnimtable<T> {
  const ReversedAnimtable(super.tween, {super.motion});

  @override
  T evaluate(CueAnimationDriver driver) => tween.transform(1.0 - driver.value);
}

class DualAnimatable<T> extends CueAnimtable<T> {
  final CueAnimtable<T> forward;
  final CueAnimtable<T> reverse;

  DualAnimatable({
    required this.forward,
    required this.reverse,
  });

  @override
  T evaluate(CueAnimationDriver driver) {
    final isReversing = driver.isReverseOrDismissed;
    return isReversing ? reverse.evaluate(driver) : forward.evaluate(driver);
  }
}

class AlwaysStoppedAnimatable<T> extends CueAnimtable<T> {
  final T value;

  const AlwaysStoppedAnimatable(this.value);

  @override
  T evaluate(CueAnimationDriver driver) => value;
}

class AnimatableSegment<T> extends Animatable<T> {
  final Animatable<T> animatable;
  final CueMotion motion;

  AnimatableSegment({
    required this.animatable,
    required this.motion,
  });

  @override
  T transform(double t) => animatable.transform(t);
}

class SegmentedAnimtable<T> extends CueAnimtable<T> {
  final List<AnimatableSegment<T>> segments;

  SegmentedAnimtable(this.segments);

  @override
  CueMotion? get motion => SegmentedMotion(List.unmodifiable(segments.map((e) => e.motion)));

  @override
  T evaluate(CueAnimationDriver driver) {
    return segments[driver.phase].transform(driver.value);
  }
}
