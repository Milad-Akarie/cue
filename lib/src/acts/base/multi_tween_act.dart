import 'package:cue/cue.dart';
import 'package:cue/src/motion/cue_motion.dart';
import 'package:cue/src/motion/simulations.dart';
import 'package:flutter/widgets.dart';

abstract class MulitTweenAct<T extends Object?> extends Act {
 final CueMotion? motion;
  final CueMotion? reverseMotion;
  final Duration? delay;
  final Duration? reverseDelay;

  const MulitTweenAct({
    this.motion,
    this.reverseMotion,
    this.delay,
    this.reverseDelay,
  });

  @override
  List<(Act, ActContext)> resolve(ActContext context) {
    return [
      (
        this,
        context.copyWith(
            motion: motion,
            reverseMotion: reverseMotion,
            delay: delay,
            reverseDelay: reverseDelay,
        ),
      ),
    ];
  }

  CueAnimtable<T> buildTween(ActContext context);

  @override
  CueAnimation<T> buildAnimation(Timeline timline, ActContext context) {
    //TODO: track what motion should be used? from context?
    final driver = timline.animationFor(AnimationConfig(
      motion: context.motion ?? motion,
      reverseMotion: context.reverseMotion ?? reverseMotion,
      delay: context.delay ?? delay,
      reverseDelay: context.reverseDelay ?? reverseDelay,
    ));
    return CueAnimationImpl<T>(parent: driver, animtable: buildTween(context));
  }

  @override
  Widget build(BuildContext context, covariant CueAnimation<Object?> animation, Widget child) {
    assert(animation is CueAnimation<T>, 'Expected animation of type CueAnimation<$T>, but got ${animation.runtimeType}');
    return apply(context, animation as CueAnimation<T>, child);
  }

  Widget apply(BuildContext context, covariant CueAnimation<T> animation, Widget child);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is MulitTweenAct<T> &&
        other.motion == motion &&
        other.reverseMotion == reverseMotion &&
        other.delay == delay &&
        other.reverseDelay == reverseDelay;
  }

  @override
  int get hashCode => Object.hash(motion, reverseMotion, delay, reverseDelay);
}
