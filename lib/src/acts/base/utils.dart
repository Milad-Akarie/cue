import 'package:cue/cue.dart';
import 'package:cue/src/core/curves.dart';
import 'package:flutter/widgets.dart';

Animatable<R> applyCurves<R>(Animatable<R> animatable, {Curve? curve, Timing? timing, bool isBounded = false}) {
  if (curve == null && timing == null) {
    return animatable;
  }
  final effectiveCurve = timing != null
      ? BoundedInterval(timing.start, timing.end, curve: curve ?? Curves.linear)
      : curve ?? Curves.linear;
  return animatable.chain(BoundedCurveTween(curve: effectiveCurve, applyBounds: isBounded));
}

Animatable<T> buildFromPhases<T extends Object?>(
  List<Phase<T>> phases,
  TweenBuilder<T> tweenBuilder,
) {
  assert(phases.isNotEmpty);

  Animatable<T> tween;
  if (phases.length == 1) {
    final phase = phases.single;
    if (phase.isAlwaysStopped) {
      return ConstantTween<T>(phase.begin);
    }
    tween = tweenBuilder(phase.begin, phase.end);
  } else {
    final allSame = phases.every((phase) {
      return phase.begin == phases.first.begin && phase.begin == phase.end;
    });

    if (allSame) {
      return ConstantTween<T>(phases.first.begin);
    }
    tween = BoundedTweenSequence<T>([
      for (final phase in phases)
        TweenSequenceItem(
          tween: phase.isAlwaysStopped
              ? ConstantTween<T>(phase.begin)
              : tweenBuilder(
                  phase.begin,
                  phase.end,
                ),
          weight: phase.weight,
        ),
    ]);
  }
  return tween;
}
