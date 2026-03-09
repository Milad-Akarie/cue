import 'dart:math' as math;
import 'dart:ui';

import 'package:cue/cue.dart';
import 'package:cue/src/acts/base/deferred_tween_act.dart';
import 'package:cue/src/acts/base/multi_tween_act.dart';
import 'package:cue/src/acts/base/tween_act.dart';
import 'package:cue/src/acts/base/utils.dart';
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

  const factory Act.compose(
    List<Act> acts, {
    Curve? curve,
    Timing? timing,
    Curve? reverseCurve,
    Timing? reverseTiming,
  }) = ComposeAct;

  const factory Act.scale({
    required double from,
    required double to,
    Curve? curve,
    Timing? timing,
    ReverseBehavior<double> reverse,
  }) = ScaleAct;

  const factory Act.zoomIn({
    double from,
    double to,
    Curve? curve,
    Timing? timing,
  }) = ScaleAct.zoomIn;

  const factory Act.zoomOut({
    double from,
    double to,
    Curve? curve,
    Timing? timing,
  }) = ScaleAct.zoomOut;

  const factory Act.fractionalSize({
    AnimatableValue<double>? widthFactor,
    AnimatableValue<double>? heightFactor,
    AnimtableAlignment alignment,
    Curve? curve,
    Timing? timing,
  }) = FractionalSizeAct;

  const factory Act.translate({
    required Offset from,
    Offset to,
    Curve? curve,
    Timing? timing,
  }) = TranslateAct;

  const factory Act.translateX({
    double from,
    double to,
    Curve? curve,
    Timing? timing,
  }) = TranslateAct.fromX;

  const factory Act.translateY({
    double from,
    double to,
    Curve? curve,
    Timing? timing,
  }) = TranslateAct.y;

  const factory Act.translateFromGlobal({
    required Offset offset,
    Offset toLocal,
    Curve? curve,
    Timing? timing,
  }) = TranslateAct.fromGlobal;

  const factory Act.translateFromGlobalRect(
    Rect rect, {
    AlignmentGeometry alignment,
    Offset toLocal,
    Curve? curve,
    Timing? timing,
  }) = TranslateAct.fromGlobalRect;

  const factory Act.translateFromGlobalKey(
    GlobalKey key, {
    AlignmentGeometry alignment,
    Offset toLocal,
    Curve? curve,
    Timing? timing,
  }) = TranslateAct.fromGlobalKey;

  const factory Act.slide({
    Offset from,
    Offset to,
    Curve? curve,
    Timing? timing,
  }) = SlideAct;

  const factory Act.slideX({
    double from,
    double to,
    Curve? curve,
    Timing? timing,
    ReverseBehavior<double> reverse,
  }) = SlideAct.fromX;

  const factory Act.slideY({
     double from,
    double to,
    Curve? curve,
    Timing? timing,
    ReverseBehavior<double> reverse,
  }) = SlideAct.fromY;

  const factory Act.slideUp({
    Curve? curve,
    Timing? timing,
  }) = SlideAct.up;

  const factory Act.slideDown({
    Curve? curve,
    Timing? timing,
  }) = SlideAct.down;

  const factory Act.slideFromLeading({
    Curve? curve,
    Timing? timing,
  }) = SlideAct.fromLeading;

  const factory Act.slideFromTrailing({
    Curve? curve,
    Timing? timing,
  }) = SlideAct.fromTrailing;

  const factory Act.opacity({
    required double from,
    required double to,
    Curve? curve,
    Timing? timing,
  }) = OpacityAct;

  const factory Act.fadeIn({
    double from,
    double to,
    Curve? curve,
    Timing? timing,
  }) = OpacityAct.fadeIn;

  const factory Act.fadeOut({
    double from,
    double to,
    Curve? curve,
    Timing? timing,
  }) = OpacityAct.fadeOut;

  const factory Act.align({
    AlignmentGeometry from,
    AlignmentGeometry to,
    Curve? curve,
    Timing? timing,
  }) = AlignAct;

  const factory Act.padding({
    EdgeInsetsGeometry from,
    EdgeInsetsGeometry to,
    Curve? curve,
    Timing? timing,
  }) = PaddingAct;

  const factory Act.blur({
    double from,
    double to,
    Curve? curve,
    Timing? timing,
  }) = BlurAct;

  const factory Act.focus({
    double from,
    double to,
    Curve? curve,
    Timing? timing,
  }) = BlurAct.focus;

  const factory Act.unfocus({
    double from,
    double to,
    Curve? curve,
    Timing? timing,
  }) = BlurAct.unfocus;

  const factory Act.backdropBlur({
    double from,
    double to,
    Curve? curve,
    Timing? timing,
    BlendMode blendMode,
  }) = BackdropBlurAct;

  const factory Act.colorTint({
    required Color from,
    required Color to,
    Curve? curve,
    Timing? timing,
  }) = ColorTintAct;

  const factory Act.size({
    AnimatableValue<double>? width,
    AnimatableValue<double>? height,
    Curve? curve,
    Timing? timing,
  }) = SizeAct;

  const factory Act.sizedClip({
    NSize? from,
    NSize? to,
    Curve? curve,
    Timing? timing,
    AlignmentGeometry alignment,
    Clip clipBehavior,
  }) = SizedClipAct;

  const factory Act.clip({
    BorderRadiusGeometry borderRadius,
    AlignmentGeometry alignment,
    bool useSuperellipse,
    Curve? curve,
    Timing? timing,
  }) = ClipAct;

  const factory Act.clipHeight({
    double from,
    double to,
    AlignmentGeometry alignment,
    Curve? curve,
    Timing? timing,
  }) = ClipAct.height;

  const factory Act.clipWidth({
    double from,
    double to,
    AlignmentGeometry alignment,
    Curve? curve,
    Timing? timing,
  }) = ClipAct.width;

  const factory Act.circularClip({
    AlignmentGeometry alignment,
    Curve? curve,
    Timing? timing,
  }) = ClipAct.circular;

  const factory Act.rotate({
    double from,
    double to,
    Curve? curve,
    Timing? timing,
    RotateUnit unit,
    RotateAxis axis,
  }) = RotateAct;

  const factory Act.rotateLayout({
    double from,
    double to,
    Curve? curve,
    Timing? timing,
    RotateUnit unit,
  }) = RotateLayoutAct;

  const factory Act.flipX({
    Curve? curve,
    Timing? timing,
  }) = RotateAct.flipX;

  const factory Act.flipY({
    Curve? curve,
    Timing? timing,
  }) = RotateAct.flipY;

  const factory Act.textStyle({
    required TextStyle from,
    required TextStyle to,
    Curve? curve,
    Timing? timing,
  }) = TextStyleAct;

  const factory Act.iconTheme({
    required IconThemeData from,
    required IconThemeData to,
    Curve? curve,
    Timing? timing,
  }) = IconThemeAct;

  const factory Act.transform({
    required Matrix4 from,
    required Matrix4 to,
    Curve? curve,
    Timing? timing,
  }) = TransformAct;

  const factory Act.decorate({
    AnimtableColor? color,
    AnimtableBorderRadius borderRadius,
    AnimtableBoxBorder? border,
    AnimtableBoxShadow? boxShadow,
    AnimtableGradient? gradient,
    BoxShape shape,
    DecorationPosition position,
    Curve? curve,
    Timing? timing,
  }) = DecoratedBoxAct;

  Animation<Object?> buildAnimation(Animation<double> driver, ActContext context);

  Widget build(BuildContext context, covariant Animation<Object?> animation, Widget child);

  List<(Act, ActContext)> resolve(ActContext base);
}

class ComposeAct extends Act {
  final List<Act> acts;
  final Curve? curve;
  final Timing? timing;
  final Curve? reverseCurve;
  final Timing? reverseTiming;

  const ComposeAct(
    this.acts, {
    this.curve,
    this.timing,
    this.reverseCurve,
    this.reverseTiming,
  });

  @override
  Animation<Object?> buildAnimation(Animation<double> driver, ActContext context) {
    throw StateError('ComposeAct should not be used directly');
  }

  @override
  Widget build(BuildContext context, Animation<Object?> animation, Widget child) {
    throw StateError('ComposeAct should not be used directly');
  }

  @override
  List<(Act, ActContext)> resolve(ActContext base) {
    final result = <(Act, ActContext)>[];
    final context = base.copyWith(
      curve: curve,
      timing: timing,
      reverseCurve: reverseCurve,
      reverseTiming: reverseTiming,
    );
    for (final act in acts) {
      result.addAll(act.resolve(context));
    }
    return result;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComposeAct &&
          runtimeType == other.runtimeType &&
          listEquals(acts, other.acts) &&
          curve == other.curve &&
          timing == other.timing &&
          reverseCurve == other.reverseCurve &&
          reverseTiming == other.reverseTiming;

  @override
  int get hashCode => Object.hashAll(acts);
}

class ActContext {
  final Timing? timing;
  final Timing? reverseTiming;
  final Curve? curve;
  final Curve? reverseCurve;
  final bool isBounded;
  final TextDirection textDirection;
  final Object? implicitFrom;

  const ActContext({
    this.timing,
    this.curve,
    this.isBounded = true,
    this.reverseTiming,
    this.reverseCurve,
    this.textDirection = TextDirection.ltr,
    this.implicitFrom,
  });

  ActContext copyWith({
    Timing? timing,
    Timing? reverseTiming,
    Curve? curve,
    Curve? reverseCurve,
    bool? isBounded,
    TextDirection? textDirection,
    Object? implicitFrom,
  }) {
    return ActContext(
      timing: timing ?? this.timing,
      reverseTiming: reverseTiming ?? this.reverseTiming,
      curve: curve ?? this.curve,
      reverseCurve: reverseCurve ?? this.reverseCurve,
      isBounded: isBounded ?? this.isBounded,
      textDirection: textDirection ?? this.textDirection,
      implicitFrom: implicitFrom ?? this.implicitFrom,
    );
  }
}
