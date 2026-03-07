import 'package:cue/cue.dart';
import 'package:flutter/widgets.dart';

abstract class DeferredTweenAct<T extends Object?> extends Act {
  final Curve? curve;
  final Timing? timing;
  final Curve? reverseCurve;
  final Timing? reverseTiming;

  const DeferredTweenAct({
    this.curve,
    this.timing,
    this.reverseCurve,
    this.reverseTiming,
  });

  @override
  List<(Act, ActContext)> resolve(ActContext context) {
    return [
      (
        this,
        context.copyWith(
          curve: curve,
          timing: timing,
          reverseCurve: reverseCurve,
          reverseTiming: reverseTiming,
        ),
      ),
    ];
  }

  @override
  DeferredCueAnimation<T> buildAnimation(Animation<double> driver, ActContext context) {
    return DeferredCueAnimation(parent: driver, context: context);
  }

  @override
  Widget build(BuildContext context, covariant Animation<Object?> animation, Widget child) {
    assert(
      animation is DeferredCueAnimation<T>,
      'Expected animation of type DeferredProxyAnimation<$T>, but got ${animation.runtimeType}',
    );
    return apply(context, animation as DeferredCueAnimation<T>, child);
  }

  Widget apply(BuildContext context, covariant DeferredCueAnimation<T> animation, Widget child);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is DeferredTweenAct<T> &&
        other.timing == timing &&
        other.curve == curve &&
        other.reverseTiming == reverseTiming &&
        other.reverseCurve == reverseCurve;
  }

  @override
  int get hashCode => Object.hash(timing, curve, reverseTiming, reverseCurve);
}
