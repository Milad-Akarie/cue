import 'package:cue/cue.dart';
import 'package:cue/src/effects/base/utils.dart';
import 'package:flutter/widgets.dart';

abstract class MulitTweenEffect<T extends Object?> extends Effect {
  const MulitTweenEffect({
    super.timing,
    super.curve,
  });

  @override
  Animation<T> buildAnimation(Animation<double> driver, ActorContext context) {
    final animatable = buildTween(context);
    Animatable<T>? reverseAnimatable;
    if (context.reverseCurve != null || context.reverseTiming != null) {
      reverseAnimatable = applyCurves<T>(
        animatable,
        curve: context.reverseCurve,
        timing: context.reverseTiming,
        isBounded: context.isBounded,
      );
    }
    return switch (context.role) {
      ActorRole.both =>
        reverseAnimatable == null
            ? driver.drive(animatable)
            : DualAnimation(
                parent: driver,
                forward: animatable,
                reverse: reverseAnimatable,
              ),
      ActorRole.forward => ForwardOrStoppedAnimation(driver).drive(animatable),
      ActorRole.reverse => ReverseOrStoppedAnimation(driver).drive(animatable),
    };
  }

  @override
  Widget build(BuildContext context, covariant Animation<Object?> animation, Widget child) {
    assert(animation is Animation<T>, 'Expected animation of type Animation<$T>, but got ${animation.runtimeType}');
    return apply(context, animation as Animation<T>, child);
  }

  Widget apply(BuildContext context, covariant Animation<T> animation, Widget child);

  Animatable<T> buildTween(ActorContext data);

  //equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is MulitTweenEffect<T> && other.timing == timing && other.curve == curve;
  }

  @override
  int get hashCode => Object.hash(timing, curve);
}
