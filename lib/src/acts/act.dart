import 'dart:math' as math;
import 'dart:ui';

import 'package:cue/src/core/core.dart';
import 'package:cue/src/core/phase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

part 'resize.dart';
part 'translate.dart';
part 'decorate.dart';
part 'rotate.dart';
part 'scale.dart';
part 'fade.dart';
part 'blur.dart';
part 'align.dart';
part 'insets.dart';
part 'style.dart';
part 'clip_reveal.dart';
part 'slide.dart';
part 'position.dart';

typedef TweenBuilder<T> = Animatable<T> Function(T from, T to);

abstract class Act {
  final Timing? timing;
  final Curve? curve;

  const Act({
    this.timing,
    this.curve,
  });

  Widget apply(AnimationContext context, Widget child);
}

abstract class TweenActBase<T extends Object?, R extends Object?> extends Act {
  final T? _from;
  final T? _to;
  final List<Keyframe<T>>? _keyframes;

  R transform(AnimationContext context, T value);

  const TweenActBase({
    required T from,
    required T to,
    super.curve,
    super.timing,
  }) : _keyframes = null,
       _from = from,
       _to = to;

  const TweenActBase.keyframes(
    List<Keyframe<T>> keyframes, {
    super.curve,
  }) : _keyframes = keyframes,
       _from = null,
       _to = null,
       super(timing: null);

  Animatable<R> _defaultTweenBuilder(R from, R to) {
    return Tween<R>(begin: from, end: to);
  }

  Animation<R> build(AnimationContext context, {TweenBuilder<R>? tweenBuilder}) {
    final List<Phase<R>> phases;
    if (_keyframes == null) {
      assert(_from != null && _to != null, 'Begin and end values must be provided when not using keyframes');
      phases = [Phase<R>(begin: transform(context, _from as T), end: transform(context, _to as T), weight: 100)];
    } else {
      final result = Phase.normalize(_keyframes, (value) => transform(context, value));
      phases = result.phases;
      if (result.timing != null) {
        context = context.copyWith(timing: result.timing);
      }
    }
    return TweenActBase.buildFromPhases<R>(context, phases, tweenBuilder ?? _defaultTweenBuilder);
  }

  static Animation<T> buildFromPhases<T extends Object?>(
    AnimationContext context,
    List<Phase<T>> phases,
    TweenBuilder<T> tweenBuilder,
  ) {
    Animatable<T> tween;
    if (phases.length == 1) {
      final phase = phases.single;
      if (phase.begin == phase.end) {
        return AlwaysStoppedAnimation<T>(phase.begin);
      }
      tween = tweenBuilder(phase.begin, phase.end);
    } else {
      tween = TweenSequence<T>([
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
    final timing = context.timing;
    final curve = context.curve;
    final effectiveCurve = timing != null
        ? Interval(timing.start, timing.end, curve: curve ?? Curves.linear)
        : curve ?? Curves.linear;
    return context.driver.drive(tween.chain(CurveTween(curve: effectiveCurve)));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TweenAct &&
          runtimeType == other.runtimeType &&
          _from == other._from &&
          _to == other._to &&
          _keyframes == other._keyframes &&
          curve == other.curve &&
          timing == other.timing;

  @override
  int get hashCode => Object.hash(_from, _to, _keyframes, curve, timing);
}

abstract class TweenAct<T extends Object?> extends TweenActBase<T, T> {
  const TweenAct({
    required super.from,
    required super.to,
    super.curve,
    super.timing,
  });

  @override
  T transform(AnimationContext context, T value) => value;

  const TweenAct.keyframes(
    super.keyframes, {
    super.curve,
  }) : super.keyframes();
}

class LayoutInfoScope extends InheritedWidget {
  final Size? size;

  const LayoutInfoScope({
    super.key,
    this.size,
    required super.child,
  });

  static LayoutInfoScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LayoutInfoScope>();
  }

  @override
  bool updateShouldNotify(covariant LayoutInfoScope oldWidget) {
    return oldWidget.size != size;
  }
}
