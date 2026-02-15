import 'package:cue/cue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'actor_factory.dart';
part 'actor_impl.dart';

abstract class Actor extends Widget {
  const factory Actor({
    Key? key,
    required List<Act> acts,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = ActorBase;

  const factory Actor.rotate({
    Key? key,
    required double from,
    required double to,
    AlignmentGeometry alignment,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = RotateActorFactory;

  const factory Actor.rotateTurns({
    Key? key,
    required double from,
    required double to,
    AlignmentGeometry alignment,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = RotateActorFactory.turns;

  const factory Actor.scale({
    Key? key,
    required double from,
    required double to,
    AlignmentGeometry? alignment,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = ScaleActorFactory;

  const factory Actor.fade({
    Key? key,
    double from,
    double to,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = FadeActorFactory;

  const factory Actor.slide({
    Key? key,
    required Offset from,
    Offset to,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = SlideActorFactory;

  const factory Actor.slideX({
    Key? key,
    required double from,
    required double to,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = SlideActorFactory.x;

  const factory Actor.slideY({
    Key? key,
    required double from,
    required double to,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = SlideActorFactory.y;

  const factory Actor.align({
    Key? key,
    AlignmentGeometry? from,
    AlignmentGeometry? to,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = AlignActorFactory;

  const factory Actor.resize({
    Key? key,
    required Size from,
    required Size to,
    AlignmentGeometry alignment,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = ResizeActorFactory;

  const factory Actor.resizeFractionally({
    Key? key,
    required Size from,
    required Size to,
    AlignmentGeometry alignment,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = ResizeActorFactory.fractionally;

  const factory Actor.blur({
    Key? key,
    required double from,
    required double to,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = BlurActorFactory;

  const factory Actor.padding({
    Key? key,
    EdgeInsetsGeometry from,
    required EdgeInsetsGeometry to,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = PaddingActorFactory;

  const factory Actor.translate({
    Key? key,
    required Offset from,
    Offset to,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = TranslateActorFactory;

  const factory Actor.translateX({
    Key? key,
    required double from,
    required double to,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = TranslateActorFactory.x;

  const factory Actor.translateY({
    Key? key,
    required double from,
    required double to,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = TranslateActorFactory.y;

  const factory Actor.translateFromGlobal({
    Key? key,
    required Offset offset,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = TranslateActorFactory.fromGlobal;

  const factory Actor.clipReveal({
    Key? key,
    Size fromSize,
    BorderRadiusGeometry borderRadius,
    AlignmentGeometry alignment,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = ClipRevealActorFactory;

  const factory Actor.clipRevealHorizontal({
    Key? key,
    double from,
    double to,
    AlignmentGeometry alignment,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = ClipRevealActorFactory.horizontal;

  const factory Actor.clipRevealVertical({
    Key? key,
    double from,
    double to,
    AlignmentGeometry alignment,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = ClipRevealActorFactory.vertical;

  const factory Actor.position({
    Key? key,
    required Position from,
    required Position to,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = PositionActorFactory;

  const factory Actor.textStyle({
    Key? key,
    required TextStyle from,
    required TextStyle to,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = TextStyleActorFactory;

  const factory Actor.iconTheme({
    Key? key,
    required IconThemeData from,
    required IconThemeData to,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = IconThemeActorFactory;

  const factory Actor.decorate({
    Key? key,
    required Decoration from,
    required Decoration to,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = DecoratedBoxActorFactory;

  const factory Actor.color({
    Key? key,
    required Color from,
    required Color to,
    required Widget child,
    Curve? curve,
    Timing? timing,
  }) = ColorActorFactory;

  factory Actor.lerp({
    Key? key,
    required ValueWidgetBuilder<double> builder,
    Curve? curve,
    Timing? timing,
    Widget? child,
  }) = _LerpDoubleTweenActor;
}
