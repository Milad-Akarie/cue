import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

class Actor extends StatelessWidget {
  const Actor({
    super.key,
    this.role = ActorRole.both,
    this.curve,
    this.timing,
    this.reverseCurve,
    this.reverseTiming,
    this.scale,
    this.opacity,
    this.clip,
    this.translate,
    this.colorTint,
    this.decoration,
    this.slide,
    this.rotate,
    this.align,
    this.blur,
    this.textStyle,
    this.iconTheme,
    this.padding,
    this.size,
    this.child,
  });
  final ActorRole role;
  final Curve? curve;
  final Timing? timing;
  final Curve? reverseCurve;
  final Timing? reverseTiming;

  final ColorTintEffect? colorTint;
  final DecoratedBoxEffect? decoration;
  final ScaleEffect? scale;
  final OpacityEffect? opacity;
  final ClipEffect? clip;
  final SlideEffect? slide;
  final TranslateEffect? translate;
  final RotateEffect? rotate;
  final AlignEffect? align;
  final BlurEffect? blur;
  final TextStyleEffect? textStyle;
  final IconThemeEffect? iconTheme;
  final PaddingEffect? padding;
  final SizeEffect? size;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return RawActor(
      role: role,
      curve: curve,
      timing: timing,
      reverseCurve: reverseCurve,
      reverseTiming: reverseTiming,
      effects: [
        ?size, // outermost — establishes animated bounds
        ?clip, // shapes within those bounds
        ?padding,
        ?align,
        ?slide,
        ?translate,
        ?scale,
        ?rotate,
        ?colorTint,
        ?decoration,
        ?opacity,
        ?blur,
        ?textStyle,
        ?iconTheme,
      ],
      child: child ?? const SizedBox.shrink(),
    );
  }
}
