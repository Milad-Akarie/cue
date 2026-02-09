import 'dart:ui';
import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

abstract class Actor extends Widget {
  factory Actor({
    Key? key,
    required Widget child,
    required List<Act> acts,
    Curve? curve,
    Timing? timing,
  }) {
    return _ActorImpl(
      key: key,
      acts: acts,
      curve: curve,
      timing: timing,
      child: child,
    );
  }

  factory Actor.fade({
    Key? key,
    required Widget child,
    double begin = 0.0,
    double? end,
    Curve? curve,
    Timing? timing,
    List<Phase<double>> then = const [],
  }) {
    return Actor(
      key: key,
      acts: [
        FadeAct(
          begin: begin,
          then: then,
          end: end,
          timing: timing,
          curve: curve,
        ),
      ],
      child: child,
    );
  }

  factory Actor.rotate({
    Key? key,
    required Widget child,
    double begin = 0,
    double? end,
    List<Phase<double>> then = const [],
    Curve? curve,
    Timing? timing,
  }) {
    return Actor(
      key: key,
      acts: [
        RotateAct(
          begin: begin,
          end: end,
          then: then,
          timing: timing,
          curve: curve,
        ),
      ],
      child: child,
    );
  }

  static TweenActor<T> tween<T>({
    Key? key,
    required Tween<T> tween,
    required Widget Function(BuildContext, T value) builder,
    Widget? child,
    Curve? curve,
    Timing? timing,
  }) {
    return TweenActor<T>(
      key: key,
      tween: tween,
      builder: (context, value, child) => builder(context, value),
      curve: curve,
      timing: timing,
      child: child,
    );
  }

  factory Actor.translate({
    Key? key,
    required Widget child,
    Offset begin = Offset.zero,
    Offset? end,
    List<Phase<Offset>> then = const [],
    Curve? curve,
    Timing? timing,
  }) {
    return Actor(
      key: key,
      acts: [
        TranslationAct(
          begin: begin,
          end: end,
          then: then,
          timing: timing,
          curve: curve,
        ),
      ],
      child: child,
    );
  }

  factory Actor.scale({
    Key? key,
    required Widget child,
    double begin = 1.0,
    double? end,
    List<Phase<double>> then = const [],
    Curve? curve,
    Timing? timing,
    AlignmentGeometry? alignment,
  }) {
    return Actor(
      key: key,
      acts: [
        ScaleAct(
          begin: begin,
          end: end,
          then: then,
          timing: timing,
          curve: curve,
          alignment: alignment,
        ),
      ],
      child: child,
    );
  }

  factory Actor.slide({
    Key? key,
    required Widget child,
    Offset begin = Offset.zero,
    Offset? end,
    List<Phase<Offset>> then = const [],
    Curve? curve,
    Timing? timing,
  }) {
    return Actor(
      key: key,
      acts: [
        SlideAct(
          begin: begin,
          end: end,
          then: then,
          timing: timing,
          curve: curve,
        ),
      ],
      child: child,
    );
  }

  factory Actor.align({
    Key? key,
    required Widget child,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    List<Phase<AlignmentGeometry>> then = const [],
    Curve? curve,
    Timing? timing,
  }) {
    return Actor(
      key: key,
      acts: [
        AlignAct(
          begin: begin,
          end: end,
          then: then,
          timing: timing,
          curve: curve,
        ),
      ],
      child: child,
    );
  }

  factory Actor.blur({
    Key? key,
    required Widget child,
    double begin = 0,
    double? end = 0,
    List<Phase<double>> then = const [],
    Curve? curve,
    Timing? timing,
  }) {
    return Actor(
      key: key,
      acts: [
        BlurAct(
          begin: begin,
          end: end,
          then: then,
          timing: timing,
          curve: curve,
        ),
      ],
      child: child,
    );
  }

  factory Actor.clipReveal({
    Key? key,
    required Widget child,
    Size intrinsicSize = Size.zero,
    BorderRadius borderRadius = BorderRadius.zero,
    Curve? curve,
    Timing? timing,
    AlignmentGeometry? alignment,
  }) {
    return Actor(
      key: key,
      acts: [
        ClipRevealAct(
          beginSize: intrinsicSize,
          borderRadius: borderRadius,
          timing: timing,
          curve: curve,
          alignment: alignment,
        ),
      ],
      child: child,
    );
  }

  factory Actor.resize({
    Key? key,
    required Widget child,
    SizeOrNull? begin,
    SizeOrNull? end,
    List<Phase<SizeOrNull>> then = const [],
    Curve? curve,
    Timing? timing,
    AlignmentGeometry? alignment,
  }) {
    return Actor(
      key: key,
      acts: [
        ResizeAct(
          begin: begin,
          end: end,
          then: then,
          timing: timing,
          curve: curve,
          alignment: alignment,
        ),
      ],
      child: child,
    );
  }

  factory Actor.textStyle({
    Key? key,
    required Widget child,
    required TextStyle begin,
    required TextStyle end,
    Curve? curve,
    Timing? timing,
  }) {
    return Actor(
      key: key,
      acts: [TextStyleAct(begin: begin, end: end, timing: timing, curve: curve)],
      child: child,
    );
  }

  factory Actor.pad({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry begin = EdgeInsets.zero,
    EdgeInsetsGeometry end = EdgeInsets.zero,
    Curve? curve,
    Timing? timing,
  }) {
    return Actor(
      key: key,
      acts: [PaddingAct(begin: begin, end: end, timing: timing, curve: curve)],
      child: child,
    );
  }

  factory Actor.tweened({
    Key? key,
    Widget? child,
    required Tween tween,
    required Widget Function(BuildContext, dynamic value) builder,
    Curve? curve,
    Timing? timing,
  }) {
    return TweenActor(
      key: key,
      tween: tween,
      builder: (context, value, child) => builder(context, value),
      curve: curve,
      timing: timing,
      child: child,
    );
  }

  factory Actor.decorationTween({
    Key? key,
    required ValueWidgetBuilder<Decoration> builder,
    Decoration begin = const BoxDecoration(),
    Decoration end = const BoxDecoration(),
    Curve? curve,
    Timing? timing,
    Widget? child,
  }) {
    return _DecorationTweenActor(
      key: key,
      begin: begin,
      end: end,
      curve: curve,
      timing: timing,
      builder: builder,
      child: child,
    );
  }

  factory Actor.propsTween({
    Key? key,
    required ValueWidgetBuilder<Props> builder,
    Props begin = const Props(),
    Props end = const Props(),
    Curve? curve,
    Timing? timing,
    Widget? child,
  }) {
    return _PropsTweenActor(
      key: key,
      begin: begin,
      end: end,
      curve: curve,
      timing: timing,
      builder: builder,
      child: child,
    );
  }
}

class _ActorImpl extends StatelessWidget implements Actor {
  const _ActorImpl({super.key, required this.acts, required this.child, this.timing, this.curve});

  final Curve? curve;
  final Timing? timing;
  final List<Act> acts;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scope = CueScope.of(context);
    Widget current = child;
    for (final effect in acts.reversed) {
      current = effect.wrapWidget(
        AnimationContext(
          buildContext: context,
          driver: scope.animation,
          timing: effect.timing ?? timing,
          curve: effect.curve ?? curve,
        ),
        current,
      );
    }
    return current;
  }
}

class TweenActor<T> extends StatefulWidget implements Actor {
  const TweenActor({super.key, required this.builder, required this.tween, this.curve, this.timing, this.child});

  final Widget? child;
  final ValueWidgetBuilder<T> builder;
  final Tween<T> tween;
  final Curve? curve;
  final Timing? timing;

  @override
  State<StatefulWidget> createState() => _TweenActorState<T>();
}

class _DecorationTweenActor extends TweenActor<Decoration> {
  _DecorationTweenActor({
    super.key,
    Decoration begin = const BoxDecoration(),
    Decoration end = const BoxDecoration(),
    super.curve,
    super.timing,
    final Widget? child,
    required super.builder,
  }) : super(
         tween: DecorationTween(begin: begin, end: end),
       );
}

class _PropsTweenActor extends TweenActor<Props> {
  _PropsTweenActor({
    super.key,
    Props begin = const Props(),
    Props end = const Props(),
    super.curve,
    super.timing,
    final Widget? child,
    required super.builder,
  }) : super(
         tween: PropsTween(begin: begin, end: end),
       );
}

class _TweenActorState<T> extends State<TweenActor<T>> {
  late Animation<T> animation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _setupAnimation(context);
  }

  @override
  void didUpdateWidget(covariant TweenActor<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tween != widget.tween || oldWidget.curve != widget.curve) {
      _setupAnimation(context);
    }
  }

  void _setupAnimation(BuildContext context) {
    final scope = CueScope.of(context);
    if (widget.curve != null) {
      animation = widget.tween.animate(CurvedAnimation(parent: scope.animation, curve: widget.curve!));
    } else {
      animation = widget.tween.animate(scope.animation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return widget.builder(context, animation.value, widget.child);
      },
    );
  }
}

class Props {
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;
  final Decoration? decoration;
  final TextStyle? textStyle;
  final double? opacity;
  final double? rotation;
  final Offset? offset;
  final double? scale;
  final double? blur;
  final Size? size;

  const Props({
    this.padding,
    this.alignment,
    this.borderRadius,
    this.color,
    this.decoration,
    this.textStyle,
    this.opacity,
    this.rotation,
    this.offset,
    this.scale,
    this.blur,
    this.size,
  });
}

class PropsTween extends Tween<Props> {
  PropsTween({Props? begin, Props? end}) : super(begin: begin ?? const Props(), end: end ?? const Props());

  @override
  Props lerp(double t) {
    return Props(
      padding: EdgeInsetsGeometry.lerp(begin!.padding, end!.padding, t),
      alignment: AlignmentGeometry.lerp(begin!.alignment, end!.alignment, t),
      borderRadius: BorderRadiusGeometry.lerp(begin!.borderRadius, end!.borderRadius, t),
      color: Color.lerp(begin!.color, end!.color, t),
      decoration: Decoration.lerp(begin!.decoration, end!.decoration, t),
      textStyle: TextStyle.lerp(begin!.textStyle, end!.textStyle, t),
      opacity: lerpDouble(begin!.opacity, end!.opacity, t),
      rotation: lerpDouble(begin!.rotation, end!.rotation, t),
      offset: Offset.lerp(begin!.offset, end!.offset, t),
      scale: lerpDouble(begin!.scale, end!.scale, t),
      blur: lerpDouble(begin!.blur, end!.blur, t),
      size: Size.lerp(begin!.size, end!.size, t),
    );
  }
}

extension StaggeredActorExtension on Iterable<Widget> {
  List<Widget> stagger({required List<Act> Function(int index) acts}) {
    return [for (var i = 0; i < length; i++) Actor(acts: acts(i), child: elementAt(i))];
  }
}

extension WidgetAnimatableExtension on Widget {
  Widget animate({List<Act> acts = const [], Curve? curve, Timing? timing}) {
    if (acts.isEmpty) {
      return this;
    }
    return Actor(acts: acts, curve: curve, timing: timing, child: this);
  }
}
