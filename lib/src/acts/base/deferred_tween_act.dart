import 'package:cue/cue.dart';
import 'package:cue/src/motion/cue_motion.dart';
import 'package:cue/src/motion/simulations.dart';
import 'package:flutter/widgets.dart';

abstract class DeferredTweenAct<T extends Object?> extends Act {
  final CueMotion ? motion;
  final CueMotion ? reverseMotion;

  const DeferredTweenAct({
    this.motion,
    this.reverseMotion,
  });

  @override
  List<(Act, ActContext)> resolve(ActContext context) {
    return [
      (
        this,
        context.copyWith(
          motion: motion,
          reverseMotion: reverseMotion,
        ),
      ),
    ];
  }

  @override
  DeferredCueAnimation<T> buildAnimation(Timeline timline, ActContext context) {
    final driver = timline.animationFor(AnimationConfig(motion: motion, reverseMotion: reverseMotion));
    return DeferredCueAnimation(parent: driver, context: context);  
  }

  @override
  Widget build(BuildContext context, covariant Animation<Object?> animation, Widget child) {
    assert(
      animation is DeferredCueAnimation<T>,
      'Expected animation of type DeferredCueAnimation<$T>, but got ${animation.runtimeType}',
    );
    return apply(context, animation as DeferredCueAnimation<T>, child);
  }

  Widget apply(BuildContext context, covariant DeferredCueAnimation<T> animation, Widget child);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is DeferredTweenAct<T> &&
        other.motion == motion &&
        other.reverseMotion == reverseMotion;
  }

  @override
  int get hashCode => Object.hash(motion, reverseMotion);
}
