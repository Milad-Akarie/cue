import 'package:cue/cue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class TweenActBase<T extends Object?, R extends Object?> extends AnimatablePropBase<T, R> implements Act {
  const TweenActBase({
    required T super.from,
    required T super.to,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
  }) : super(keyframes: null);

  const TweenActBase.keyframes(
    List<Keyframe<T>> keyframes, {
    super.curve,
    super.reverseCurve,
  }) : super(
         from: null,
         to: null,
         keyframes: keyframes,
       );

  @internal
  const TweenActBase.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
  });

  @override
  List<(Act, ActContext)> resolve(ActContext context) {
    return [(this, context)];
  }

  @nonVirtual
  @override
  Widget build(BuildContext context, covariant Animation<Object?> animation, Widget child) {
    assert(
      animation is Animation<R>,
      'Expected animation of type Animation<$T>, but got ${animation.runtimeType}',
    );
    return apply(context, animation as Animation<R>, child);
  }

  Widget apply(BuildContext context, Animation<R> animation, Widget child);

  @override
  Animation<R> buildAnimation(Animation<double> driver, ActContext context) {
    return CueAnimation<R>(parent: driver, animtable: buildAnimtable(context));
  }
}

abstract class TweenAct<T extends Object?> extends TweenActBase<T, T> {
  const TweenAct({
    required super.from,
    required super.to,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
  });

  @override
  T transform(_, T value) => value;

  const TweenAct.keyframes(
    super.keyframes, {
    super.curve,
    super.reverseCurve,
  }) : super.keyframes();

  @internal
  const TweenAct.internal({
    super.from,
    super.to,
    super.keyframes,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
  }) : super.internal();
}
