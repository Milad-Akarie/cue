import 'dart:math' as math;
import 'dart:ui';

import 'package:cue/cue.dart';
import 'package:cue/src/effects/base/animated_prop.dart';
import 'package:cue/src/effects/base/multi_tween_effect.dart';
import 'package:cue/src/effects/base/tween_effect.dart';
import 'package:cue/src/effects/base/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

part '../size.dart';
part '../fractional_size.dart';
part '../translate.dart';
part '../decorate.dart';
part '../color_tint.dart';
part '../rotate.dart';
part '../rotate_layout.dart';
part '../scale.dart';
part '../opacity.dart';
part '../blur.dart';
part '../align.dart';
part '../padding.dart';
part '../style.dart';
part '../clip_reveal.dart';
part '../slide.dart';
part '../position.dart';
part '../transfrom.dart';
part '../physcial_modal.dart';
part '../paint.dart';
part '../path_motion.dart';

typedef TweenBuilder<T> = Animatable<T> Function(T from, T to);

abstract class Effect {
  final Timing? timing;
  final Curve? curve;

  const Effect({
    this.timing,
    this.curve,
  });

  Animation<Object?> buildAnimation(Animation<double> driver, ActorContext data);

  Widget build(BuildContext context, covariant Animation<Object?> animation, Widget child);
}

class ActorContext {
  final Timing? timing;
  final Timing? reverseTiming;
  final Curve? curve;
  final Curve? reverseCurve;
  final bool isBounded;
  final ActorRole role;
  final TextDirection textDirection;

  const ActorContext({
    this.timing,
    this.curve,
    this.isBounded = true,
    this.reverseTiming,
    this.reverseCurve,
    required this.textDirection,
    this.role = ActorRole.both,
  });

  ActorContext copyWith({
    Timing? timing,
    Timing? reverseTiming,
    Curve? curve,
    Curve? reverseCurve,
    bool? isBounded,
    ActorRole? role,
    TextDirection? textDirection,
  }) {
    return ActorContext(
      timing: timing ?? this.timing,
      reverseTiming: reverseTiming ?? this.reverseTiming,
      curve: curve ?? this.curve,
      reverseCurve: reverseCurve ?? this.reverseCurve,
      isBounded: isBounded ?? this.isBounded,
      role: role ?? this.role,
      textDirection: textDirection ?? this.textDirection,
    );
  }
}

enum ActorRole { forward, reverse, both }
