import 'package:cue/cue.dart';
import 'package:cue/src/motion/simulations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class TweenActBase<T extends Object?, R extends Object?> extends AnimatablePropBase<T, R> implements Act {
  const TweenActBase({
    required T super.from,
    required T super.to,
    super.motion,
    super.delay,
    super.reverse,
  }) : super(keyframes: null);

  const TweenActBase.keyframes(
    List<Keyframe<T>> keyframes, {
    super.motion,
    super.delay,
    super.reverse,
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
    super.motion,
    super.reverse,
    super.delay,
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
  CueAnimation<R> buildAnimation(Timeline timline, ActContext context) {
    final driver = timline.animationFor(AnimationConfig(
      motion: motion,
      delay: delay,
      reverseMotion: reverse.motion,
      reverseDelay: reverse.delay,
    ));
    return CueAnimationImpl<R>(parent: driver, animtable: buildAnimtable(context));
  }
}

abstract class TweenAct<T extends Object?> extends TweenActBase<T, T> {
  const TweenAct({
    required super.from,
    required super.to,
    super.motion,
    super.reverse,
  });

  @override
  T transform(_, T value) => value;

  const TweenAct.keyframes(
    super.keyframes, {
    super.motion,
    super.reverse,
  }) : super.keyframes();

  @internal
  const TweenAct.internal({
    super.from,
    super.to,
    super.keyframes,
    super.motion,
    super.reverse,
  }) : super.internal();
}
