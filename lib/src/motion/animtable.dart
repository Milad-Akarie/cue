import 'package:cue/src/motion/cue_motion.dart';
import 'package:cue/src/motion/timeline.dart';
import 'package:flutter/widgets.dart';

abstract class CueAnimtable<T> {
  const CueAnimtable();
  CueMotion? get motion => null;
  T evaluate(CueAnimationDriver animtion);
}

class TweenAnimtable<T> extends CueAnimtable<T> {
  final Animatable<T> tween;
  @override
  final CueMotion? motion;

  const TweenAnimtable(this.tween, {required this.motion});

  @override
  T evaluate(CueAnimationDriver animtion) => tween.transform(animtion.value);
}

class ReversedAnimtable<T> extends TweenAnimtable<T> {
  const ReversedAnimtable(super.tween, {super.motion});

  @override
  T evaluate(CueAnimationDriver animtion) => tween.transform(1.0 - animtion.value);
}

class DualAnimatable<T> extends CueAnimtable<T> {
  final CueAnimtable<T> forward;
  final CueAnimtable<T> reverse;

  DualAnimatable({
    required this.forward,
    required this.reverse,
  });

  @override
  T evaluate(CueAnimationDriver animtion) {
    final isReversing = animtion.isReverseOrDismissed;
    return isReversing ? reverse.evaluate(animtion) : forward.evaluate(animtion);
  }
}

class AlwaysStoppedAnimatable<T> extends CueAnimtable<T> {
  final T value;

  const AlwaysStoppedAnimatable(this.value);

  @override
  T evaluate(CueAnimationDriver animtion) => value;
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
  T evaluate(CueAnimationDriver animtion) {
    return segments[animtion.phase].transform(animtion.value);
  }
}
