import 'dart:math' as math;
import 'dart:ui';

import 'package:cue/cue.dart';
import 'package:cue/src/acts/base/deferred_tween_act.dart';
import 'package:cue/src/acts/base/animatable_act.dart';
import 'package:cue/src/acts/base/tween_act.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

part '../sized_clip.dart';
part '../fractional_size.dart';
part '../translate.dart';
part '../parallax.dart';
part '../decorate.dart';
part '../color_tint.dart';
part '../rotate.dart';
part '../rotate_layout.dart';
part '../scale.dart';
part '../sized_box.dart';
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
    Duration delay,
    ReverseBehavior<double> reverse,
  }) = ScaleAct.zoomIn;

  const factory Act.zoomOut({
    double from,
    double to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<double> reverse,
  }) = ScaleAct.zoomOut;

  const factory Act.stretch({
    Stretch from,
    required Stretch to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<Stretch> reverse,
  }) = StretchAct;

  const factory Act.fractionalSize({
    AnimatableValue<double>? widthFactor,
    AnimatableValue<double>? heightFactor,
    AnimatableValue<AlignmentGeometry>? alignment,
    CueMotion? motion,
    ReverseBehavior<FractionalSize> reverse,
    Duration delay,
  }) = FractionalSizeAct;

  const factory Act.translate({
    Offset from,
    Offset to,
    CueMotion? motion,
    ReverseBehavior<Offset> reverse,
    Duration delay,
  }) = TranslateAct;

  const factory Act.parallax({
    required double slide,
    Axis axis,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<double> reverse,
  }) = ParallaxAct;

  const factory Act.translateX({
    double from,
    double to,
    CueMotion? motion,
    Duration delay,

    ReverseBehavior<double> reverse,
  }) = TranslateAct.fromX;

  const factory Act.translateY({
    double from,
    double to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<double> reverse,
  }) = TranslateAct.y;

  const factory Act.translateFromGlobal({
    required Offset offset,
    Offset toLocal,
    CueMotion? motion,
    Duration delay,
  }) = TranslateAct.fromGlobal;

  const factory Act.translateFromGlobalRect(
    Rect rect, {
    AlignmentGeometry alignment,
    Offset toLocal,
    CueMotion? motion,
    Duration delay,
  }) = TranslateAct.fromGlobalRect;

  const factory Act.translateFromGlobalKey(
    GlobalKey key, {
    AlignmentGeometry alignment,
    Offset toLocal,
    CueMotion? motion,
    Duration delay,
  }) = TranslateAct.fromGlobalKey;

  const factory Act.slide({
    Offset from,
    Offset to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<Offset> reverse,
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
    Duration delay,
  }) = SlideAct.y;

  const factory Act.slideUp({
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<Offset> reverse,
  }) = SlideAct.up;

  const factory Act.slideDown({
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<Offset> reverse,
  }) = SlideAct.down;

  const factory Act.slideFromLeading({
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<Offset> reverse,
  }) = SlideAct.fromLeading;

  const factory Act.slideFromTrailing({
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<Offset> reverse,
  }) = SlideAct.fromTrailing;

  const factory Act.opacity({
    required double from,
    required double to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<double> reverse,
  }) = OpacityAct;

  const factory Act.fadeIn({
    double from,
    double to,
    CueMotion? motion,
    ReverseBehavior<double> reverse,

    Duration delay,
  }) = OpacityAct.fadeIn;

  const factory Act.fadeOut({
    double from,
    double to,
    CueMotion? motion,
    ReverseBehavior<double> reverse,
    Duration delay,
  }) = OpacityAct.fadeOut;

  const factory Act.align({
    AlignmentGeometry from,
    AlignmentGeometry to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<AlignmentGeometry> reverse,
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
    Duration delay,
    ReverseBehavior<double> reverse,
  }) = BlurAct;

  const factory Act.focus({
    double from,
    double to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<double> reverse,
  }) = BlurAct.focus;

  const factory Act.unfocus({
    double from,
    double to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<double> reverse,
  }) = BlurAct.unfocus;

  const factory Act.backdropBlur({
    double from,
    double to,
    CueMotion? motion,
    BlendMode blendMode,
    Duration delay,
    ReverseBehavior<double> reverse,
  }) = BackdropBlurAct;

  const factory Act.colorTint({
    required Color from,
    required Color to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<Color> reverse,
  }) = ColorTintAct;

  const factory Act.sizedBox({
    AnimatableValue<double>? width,
    AnimatableValue<double>? height,
    AlignmentGeometry alignment,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<Size> reverse,
  }) = SizedBoxAct;

  const factory Act.sizedClip({
    NSize? from,
    NSize? to,
    CueMotion? motion,
    AlignmentGeometry alignment,
    ClipGeometry clipGeometry,
    Clip clipBehavior,
    Duration delay,
    ReverseBehavior<NSize> reverse,
  }) = SizedClipAct;

  const factory Act.clip({
    BorderRadiusGeometry borderRadius,
    AlignmentGeometry alignment,
    bool useSuperellipse,
    CueMotion? motion,
    Duration delay,
  }) = ClipAct;

  const factory Act.clipHeight({
    double fromFactor,
    double toFactor,
    AlignmentGeometry alignment,
    CueMotion? motion,
    Duration delay,
  }) = ClipAct.height;

  const factory Act.clipWidth({
    double fromFactor,
    double toFactor,
    AlignmentGeometry alignment,
    CueMotion? motion,
    Duration delay,
  }) = ClipAct.width;

  const factory Act.circularClip({
    AlignmentGeometry alignment,
    CueMotion? motion,
    Duration delay,
  }) = ClipAct.circular;

  const factory Act.rotate({
    double from,
    double to,
    CueMotion? motion,
    RotateUnit unit,
    RotateAxis axis,
    Duration delay,
    AlignmentGeometry alignment,
    ReverseBehavior<double> reverse,
  }) = RotateAct;

  const factory Act.rotate3D({
    Rotation3D from,
    Rotation3D to,
    CueMotion? motion,
    Rotate3DUnit unit,
    double perspective,
    AlignmentGeometry alignment,
    Duration delay,
    ReverseBehavior<Rotation3D> reverse,
  }) = Rotate3DAct;

  const factory Act.rotateLayout({
    double from,
    double to,
    CueMotion? motion,
    RotateUnit unit,
    Duration delay,
    ReverseBehavior<double> reverse,
  }) = RotateLayoutAct;

  const factory Act.flipX({
    CueMotion? motion,
    Duration delay,
  }) = RotateAct.flipX;

  const factory Act.flipY({
    CueMotion? motion,
    Duration delay,
  }) = RotateAct.flipY;

  const factory Act.skew({
    Skew from,
    Skew to,
    AlignmentGeometry? alignment,
    Offset? origin,
    CueMotion? motion,
    ReverseBehavior<Skew> reverse,
    Duration delay,
  }) = SkewAct;

  const factory Act.textStyle({
    required TextStyle from,
    required TextStyle to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<TextStyle> reverse,
  }) = TextStyleAct;

  const factory Act.iconTheme({
    required IconThemeData from,
    required IconThemeData to,
    CueMotion? motion,
    Duration delay,
    ReverseBehavior<IconThemeData> reverse,
  }) = IconThemeAct;

  factory Act.transform({
    Matrix4? from,
    required Matrix4 to,
    CueMotion? motion,
    AlignmentGeometry alignment,
    Duration delay,
    ReverseBehavior<Matrix4> reverse,
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
    Duration delay,
    ReverseBehavior<Decoration> reverse,
  }) = DecoratedBoxAct;

  ActKey get key;

  ActContext resolve(ActContext context);

  CueAnimation<Object?> buildAnimation(CueTimeline timline, ActContext context);

  Widget build(BuildContext context, covariant CueAnimation<Object?> animation, Widget child);
}

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
