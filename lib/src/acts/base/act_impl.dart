import 'package:cue/cue.dart';
import 'package:cue/src/motion/animtable.dart';
import 'package:cue/src/motion/timeline.dart';
import 'package:flutter/widgets.dart';

abstract class ActImpl<R extends Object?, T extends Object?> extends Act {
  final CueMotion? motion;
  final Duration? delay;
  final ReverseBehaviorBase<T> reverse;

  const ActImpl({this.motion, this.delay, required this.reverse});

  @override
  List<(Act, ActContext)> resolve(ActContext context) {
    return [(this, context)];
  }

  (CueAnimtable<R> animtable, CueAnimtable<R>? reverseAnimtable) buildTweens(ActContext context);

  @override
  CueAnimation<R> buildAnimation(CueTimeline timline, ActContext context) {
    final (animtable, reverseAnimtable) = buildTweens(context);
    final driver = timline.driverFor(
      DriverConfig(
        motion: animtable.motion ?? context.motion,
        reverseMotion: reverseAnimtable?.motion ?? context.reverseMotion,
        delay: delay ?? context.delay,
        reverseDelay: reverse.delay ?? context.reverseDelay,
      ),
    );
    CueAnimtable<R> effectiveAnimatable = reverseAnimtable == null
        ? animtable
        : DualAnimatable(forward: animtable, reverse: reverseAnimtable);
    return CueAnimationImpl<R>(parent: driver, animtable: effectiveAnimatable);
  }

  @override
  Widget build(BuildContext context, covariant CueAnimation<Object?> animation, Widget child) {
    assert(
      animation is CueAnimation<R>,
      'Expected animation of type CueAnimation<$R>, but got ${animation.runtimeType}',
    );
    return apply(context, animation as CueAnimation<R>, child);
  }

  Widget apply(BuildContext context, covariant CueAnimation<R> animation, Widget child);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ActImpl<R, T> && other.motion == motion && other.delay == delay && other.reverse == reverse;
  }

  @override
  int get hashCode => Object.hash(motion, reverse, delay);
}
