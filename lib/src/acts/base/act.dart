import 'dart:math' as math;
import 'dart:ui';

import 'package:cue/cue.dart';
import 'package:cue/src/acts/base/deferred_tween_act.dart';
import 'package:cue/src/acts/base/animatable_act.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

part '../clip_size.dart';
part '../fractional_size.dart';
part '../translate.dart';
part '../decorate.dart';
part '../color_tint.dart';
part '../rotate.dart';
part '../rotate_layout.dart';
part '../scale.dart';
part '../size.dart';
part '../opacity.dart';
part '../blur.dart';
part '../align.dart';
part '../padding.dart';
part '../style.dart';
part '../clip.dart';
part '../slide.dart';
part '../position.dart';
part '../transfrom.dart';
part '../card.dart';
part '../paint.dart';
part '../path_motion.dart';

typedef TweenBuilder<T> = Animatable<T> Function(T from, T to);

abstract class Act {
  const Act();


  const factory Act.scale({
     double from,
    required double to,
    CueMotion? motion,
    ReverseBehavior<double> reverse,
    Duration delay,
  }) = ScaleAct;

  const factory Act.zoomIn({
    double from,
    double to,
    CueMotion? motion,
  }) = ScaleAct.zoomIn;

  const factory Act.zoomOut({
    double from,
    double to,
    CueMotion? motion,
  }) = ScaleAct.zoomOut;

  const factory Act.fractionalSize({
    AnimatableValue<double>? widthFactor,
    AnimatableValue<double>? heightFactor,
    AnimatableValue<AlignmentGeometry>? alignment,
    CueMotion? motion,
  }) = FractionalSizeAct;

  const factory Act.translate({
    Offset from,
    Offset to,
    CueMotion? motion,
  }) = TranslateAct;

  const factory Act.translateX({
    double from,
    double to,
    CueMotion? motion,
  }) = TranslateAct.fromX;

  const factory Act.translateY({
    double from,
    double to,
    CueMotion? motion,
  }) = TranslateAct.y;

  const factory Act.translateFromGlobal({
    required Offset offset,
    Offset toLocal,
    CueMotion? motion,
  }) = TranslateAct.fromGlobal;

  const factory Act.translateFromGlobalRect(
    Rect rect, {
    AlignmentGeometry alignment,
    Offset toLocal,
    CueMotion? motion,
  }) = TranslateAct.fromGlobalRect;

  const factory Act.translateFromGlobalKey(
    GlobalKey key, {
    AlignmentGeometry alignment,
    Offset toLocal,
    CueMotion? motion,
  }) = TranslateAct.fromGlobalKey;

  const factory Act.slide({
    Offset from,
    Offset to,
    CueMotion? motion,
  }) = SlideAct;

  const factory Act.slideX({
    double from,
    double to,
    CueMotion? motion,
    ReverseBehavior<double> reverse,
    Duration delay,
  }) = SlideAct.fromX;

  const factory Act.slideY({
    double from,
    double to,
    CueMotion? motion,
    ReverseBehavior<double> reverse,
  }) = SlideAct.fromY;

  const factory Act.slideUp({
    CueMotion? motion,
  }) = SlideAct.up;

  const factory Act.slideDown({
    CueMotion? motion,
  }) = SlideAct.down;

  const factory Act.slideFromLeading({
    CueMotion? motion,
  }) = SlideAct.fromLeading;

  const factory Act.slideFromTrailing({
    CueMotion? motion,
  }) = SlideAct.fromTrailing;

  const factory Act.opacity({
    required double from,
    required double to,
    CueMotion? motion,
  }) = OpacityAct;

  const factory Act.fadeIn({
    double from,
    double to,
    CueMotion? motion,
    ReverseBehavior<double> reverse,
  }) = OpacityAct.fadeIn;

  const factory Act.fadeOut({
    double from,
    double to,
    CueMotion? motion,
    ReverseBehavior<double> reverse,
  }) = OpacityAct.fadeOut;

  const factory Act.align({
    AlignmentGeometry from,
    AlignmentGeometry to,
    CueMotion? motion,
  }) = AlignAct;

  const factory Act.padding({
    EdgeInsetsGeometry from,
    EdgeInsetsGeometry to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<EdgeInsetsGeometry> reverse,
  }) = PaddingAct;

  const factory Act.blur({
    double from,
    double to,
    CueMotion? motion,
  }) = BlurAct;

  const factory Act.focus({
    double from,
    double to,
    CueMotion? motion,
  }) = BlurAct.focus;

  const factory Act.unfocus({
    double from,
    double to,
    CueMotion? motion,
  }) = BlurAct.unfocus;

  const factory Act.backdropBlur({
    double from,
    double to,
    CueMotion? motion,
    BlendMode blendMode,
  }) = BackdropBlurAct;

  const factory Act.colorTint({
    required Color from,
    required Color to,
    CueMotion? motion,
  }) = ColorTintAct;

  const factory Act.sizedBox({
    AnimatableValue<double>? width,
    AnimatableValue<double>? height,
    AlignmentGeometry alignment,
    CueMotion? motion,
    Duration delay,
  }) = SizedBoxAct;

  const factory Act.sizedClip({
    NSize? from,
    NSize? to,
    CueMotion? motion,
    AlignmentGeometry alignment,
    Clip clipBehavior,
  }) = SizedClipAct;

  const factory Act.clip({
    BorderRadiusGeometry borderRadius,
    AlignmentGeometry alignment,
    bool useSuperellipse,
    CueMotion? motion,
  }) = ClipAct;

  const factory Act.clipHeight({
    double from,
    double to,
    AlignmentGeometry alignment,
    CueMotion? motion,
  }) = ClipAct.height;

  const factory Act.clipWidth({
    double from,
    double to,
    AlignmentGeometry alignment,
    CueMotion? motion,
  }) = ClipAct.width;

  const factory Act.circularClip({
    AlignmentGeometry alignment,
    CueMotion? motion,
  }) = ClipAct.circular;

  const factory Act.rotate({
    double from,
    double to,
    CueMotion? motion,
    RotateUnit unit,
    RotateAxis axis,
  }) = RotateAct;

  const factory Act.rotateLayout({
    double from,
    double to,
    CueMotion? motion,
    RotateUnit unit,
  }) = RotateLayoutAct;

  const factory Act.flipX({
    CueMotion? motion,
  }) = RotateAct.flipX;

  const factory Act.flipY({
    CueMotion? motion,
  }) = RotateAct.flipY;

  const factory Act.textStyle({
    required TextStyle from,
    required TextStyle to,
    CueMotion? motion,
  }) = TextStyleAct;

  const factory Act.iconTheme({
    required IconThemeData from,
    required IconThemeData to,
    CueMotion? motion,
  }) = IconThemeAct;

  factory Act.transform({
    Matrix4? from,
    required Matrix4 to,
    CueMotion? motion,
  }) = TransformAct;

  const factory Act.decorate({
    AnimatableValue<Color>? color,
    AnimatableValue<BorderRadiusGeometry>? borderRadius,
    AnimatableValue<BoxBorder>? border,
    AnimatableValue<List<BoxShadow>>? boxShadow,
    AnimatableValue<Gradient>? gradient,
    BoxShape shape,
    DecorationPosition position,
    CueMotion? motion,
  }) = DecoratedBoxAct;

   ActKey get key;

  ActContext resolve(ActContext context);

  CueAnimation<Object?> buildAnimation(CueTimeline timline, ActContext context);

  Widget build(BuildContext context, covariant CueAnimation<Object?> animation, Widget child);
}

// class ComposeAct extends Act {
//   final List<Act> acts;
//   final CueMotion? motion;
//   final CueMotion? reverseMotion;
//   final Duration delay;
//   final Duration reverseDelay;

//   const ComposeAct(
//     this.acts, {
//     this.motion,
//     this.reverseMotion,
//     this.delay = Duration.zero,
//     this.reverseDelay = Duration.zero,
//   });

//   @override
//   List<(AnimtableAct, ActContext)> resolve(ActContext context) {
//     final result = <(AnimtableAct, ActContext)>[];
//     final composeContext = context.copyWith(
//       motion: motion,
//       reverseMotion: reverseMotion,
//       delay: delay + context.delay,
//       reverseDelay: reverseDelay + context.reverseDelay,
//     );
//     for (final act in acts) {
//       result.addAll(act.resolve(composeContext));
//     }
//     return result;
//   }

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is ComposeAct &&
//           runtimeType == other.runtimeType &&
//           listEquals(acts, other.acts) &&
//           motion == other.motion &&
//           reverseMotion == other.reverseMotion &&
//           delay == other.delay &&
//           reverseDelay == other.reverseDelay;

//   @override
//   int get hashCode => Object.hashAll(acts);
// }

// class SequenceAct extends Act {
//   final List<Act> acts;
//   final Duration overlap;

//   const SequenceAct(this.acts, {this.overlap = Duration.zero});

//   @override
//   List<(AnimtableAct, ActContext)> resolve(ActContext context) {
//     final result = <(AnimtableAct, ActContext)>[];
//     Duration accumulatedDelay = Duration.zero;
//     for (final act in acts) {
//       final actContext = context.copyWith(
//         delay: accumulatedDelay + context.delay,
//         reverseDelay: context.reverseDelay,
//       );
//       final actResult = act.resolve(actContext);
//       final longestDuration = actResult.map((e) => e.$2.motion.baseDuration).reduce((a, b) => a > b ? a : b);
//       // Assuming each act has a method to calculate its duration, which is not defined here.
//       accumulatedDelay += longestDuration - overlap;
//       result.addAll(actResult);
//     }
//     return result;
//   }

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is SequenceAct &&
//           runtimeType == other.runtimeType &&
//           listEquals(acts, other.acts) &&
//           overlap == other.overlap;

//   @override
//   int get hashCode => Object.hash(Object.hashAll(acts), overlap);
// }

class ActContext {
  final CueMotion motion;
  final CueMotion reverseMotion;
  final Duration delay;
  final Duration reverseDelay;
  final TextDirection textDirection;
  final Object? implicitFrom;

  const ActContext({
    required this.motion,
    required this.reverseMotion,
    this.delay = Duration.zero,
    this.reverseDelay = Duration.zero,
    this.textDirection = TextDirection.ltr,
    this.implicitFrom,
  });

  ActContext copyWith({
    TextDirection? textDirection,
    Object? implicitFrom,
    CueMotion? motion,
    CueMotion? reverseMotion,
    Duration? delay,
    Duration? reverseDelay,
  }) {
    return ActContext(
      motion: motion ?? this.motion,
      reverseMotion: reverseMotion ?? this.reverseMotion,
      delay: delay ?? this.delay,
      reverseDelay: reverseDelay ?? this.reverseDelay,
      textDirection: textDirection ?? this.textDirection,
      implicitFrom: implicitFrom ?? this.implicitFrom,
    );
  }
}

class ActKey {
  final String key;
  final String? desc;

 const ActKey(this.key, [this.desc]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ActKey && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'ActKey($key${desc != null ? ', $desc' : ''})';
}
