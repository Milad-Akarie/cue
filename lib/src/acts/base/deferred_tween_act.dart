import 'package:cue/cue.dart';
import 'package:cue/src/acts/base/act_impl.dart';
import 'package:cue/src/motion/animtable.dart';
import 'package:flutter/widgets.dart';

abstract class DeferredTweenAct<T extends Object?> extends ActImpl<T, T> {
  const DeferredTweenAct({
    super.motion,
    super.delay,
    super.reverse = const ReverseBehavior.mirror(),
  });

  @override
  Widget build(BuildContext context, covariant Animation<Object?> animation, Widget child) {
    assert(
      animation is DeferredCueAnimation<T>,
      'Expected animation of type DeferredCueAnimation<$T>, but got ${animation.runtimeType}',
    );
    return apply(context, animation as DeferredCueAnimation<T>, child);
  }

  @override
  Widget apply(BuildContext context, covariant DeferredCueAnimation<T> animation, Widget child);

  @override
  (CueAnimtable<T> animtable, CueAnimtable<T>? reverseAnimtable) buildTweens(ActContext context, {ValueTransformer<T, T>? transform}) {
    throw StateError('DeferredTweenAct does not build a tween directly. It should be used with a DeferredCueAnimation that will set the tween later.');
  }
}

