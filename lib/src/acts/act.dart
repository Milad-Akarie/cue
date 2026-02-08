import 'dart:math';
import 'dart:ui';

import 'package:cue/src/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

part 'resize_act.dart';

typedef TweenBuilder<T> = Animatable<T> Function(T begin, T end);

abstract class Act {
  final Timing? timing;
  final Curve? curve;
  const Act({
    this.timing,
    this.curve,
  });

  const factory Act.scale({
    double begin,
    double end,
    Curve? curve,
    Timing? timing,
    AlignmentGeometry? alignment,
  }) = ScaleAct;

  const factory Act.fade({
    double begin,
    double end,
    Curve? curve,
    Timing? timing,
  }) = FadeAct;

  const factory Act.rotate({
    double begin,
    double end,
    Curve? curve,
    Timing? timing,
  }) = RotateAct;

  const factory Act.blur({
    double begin,
    double end,
    Curve? curve,
    Timing? timing,
  }) = BlurAct;

  const factory Act.resize({
    double? beginWidth,
    double? beginHeight,
    double? endWidth,
    double? endHeight,
    Curve? curve,
    Timing? timing,
    AlignmentGeometry? alignment,
  }) = ResizeAct;

  const factory Act.align({
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    Curve? curve,
    Timing? timing,
  }) = AlignAct;

  const factory Act.slide({
    Offset begin,
    Offset end,
    Curve? curve,
    Timing? timing,
  }) = SlideAct;

  const factory Act.translate({
    Offset begin,
    Offset end,
    Curve? curve,
    Timing? timing,
  }) = TranslationAct;

  const factory Act.textStyle({
    required TextStyle begin,
    required TextStyle end,
    Curve? curve,
    Timing? timing,
  }) = TextStyleAct;

  const factory Act.pad({
    EdgeInsetsGeometry begin,
    EdgeInsetsGeometry end,
    Curve? curve,
    Timing? timing,
  }) = PaddingAct;

  const factory Act.clipReveal({
    Size intrinsicSize,
    BorderRadius borderRadius,
    AlignmentGeometry? alignment,
    Curve? curve,
    Timing? timing,
  }) = ClipRevealAct;

  Widget wrapWidget(AnimationContext context, Widget child);
}

abstract class TweenAct<T> extends Act {
  final T? _begin;
  final T? _end;
  final List<Phase<T>>? _phases;

  const TweenAct({
    required T begin,
    required T end,
    super.curve,
    super.timing,
  }) : _end = end,
       _begin = begin,
       _phases = null;

  const TweenAct.sequence(
    List<Phase<T>> phases, {
    super.curve,
    super.timing,
  }) : _phases = phases,
       _begin = null,
       _end = null;

  Animatable<T> _defaultTweenBuilder(T begin, T end) => Tween<T>(begin: begin, end: end);

  Animation<T> build(AnimationContext context, {TweenBuilder<T>? tweenBuilder}) {
    final phases = _phases ?? [Phase<T>(begin: _begin as T, end: _end as T, weight: 1.0)];
    return TweenAct._build<T>(context, phases, tweenBuilder ?? _defaultTweenBuilder);
  }

  static Animation<T> _build<T>(AnimationContext context, List<Phase<T>> phases, TweenBuilder<T> tweenBuilder) {
    Animatable<T> tween;
    if (phases.length == 1) {
      final phase = phases.single;
      tween = tweenBuilder(phase.begin, phase.end);
    } else {
      tween = TweenSequence<T>([
        for (final phase in phases)
          TweenSequenceItem(
            tween: tweenBuilder(phase.begin, phase.end),
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
  String toString() {
    return '$runtimeType(begin: $_begin, end: $_end, phases: $_phases, curve: $curve, timing: $timing)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TweenAct &&
          runtimeType == other.runtimeType &&
          _begin == other._begin &&
          _end == other._end &&
          _phases == other._phases &&
          curve == other.curve &&
          timing == other.timing;

  @override
  int get hashCode => Object.hash(_begin, _end, _phases, curve, timing);
}

class ScaleAct extends TweenAct<double> {
  const ScaleAct({
    super.begin = 1.0,
    super.end = 1.0,
    super.curve,
    super.timing,
    this.alignment,
  });
  final AlignmentGeometry? alignment;

  const ScaleAct.sequence(super.phases, {this.alignment}) : super.sequence();

  @override
  Widget wrapWidget(AnimationContext context, Widget child) {
    return ScaleTransition(
      scale: build(context),
      alignment: alignment?.resolve(context.textDirection) ?? Alignment.center,
      child: child,
    );
  }
}

class FadeAct extends TweenAct<double> {
  const FadeAct({
    super.begin = 0.0,
    super.end = 1.0,
    super.curve,
    super.timing,
  });

  const FadeAct.sequence(super.phases) : super.sequence();

  @override
  Widget wrapWidget(AnimationContext context, Widget child) {
    return FadeTransition(
      opacity: build(context),
      child: child,
    );
  }
}

class RotateAct extends TweenAct<double> {
  const RotateAct({
    super.begin = 0,
    super.end = 360,
    super.curve,
    super.timing,
  }) : assert(begin >= -360 && begin <= 360, 'Begin angle must be between 0 and 360 degrees'),
       assert(end >= -360 && end <= 360, 'End angle must be between 0 and 360 degrees');

  const RotateAct.sequence(super.phases) : super.sequence();

  @override
  Widget wrapWidget(AnimationContext ctx, Widget child) {
    final animation = build(ctx);
    return ListenableBuilder(
      listenable: animation,
      child: child,
      builder: (context, child) {
        return Transform.rotate(
          angle: animation.value * (pi / 180),
          child: child,
        );
      },
    );
  }
}

class BlurAct extends TweenAct<double> {
  const BlurAct({
    super.begin = 0.0,
    super.end = 0.0,
    super.curve,
    super.timing,
  });

  const BlurAct.sequence(super.phases) : super.sequence();

  @override
  Widget wrapWidget(AnimationContext ctx, Widget child) {
    final animation = build(ctx);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final blurValue = animation.value;
        return ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: blurValue,
            sigmaY: blurValue,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

class AlignAct extends TweenAct<AlignmentGeometry?> {
  const AlignAct({
    super.begin,
    super.end,
    super.curve,
    super.timing,
  });

  const AlignAct.sequence(List<Phase<AlignmentGeometry>> super.phases) : super.sequence();

  @override
  Widget wrapWidget(AnimationContext ctx, Widget child) {
    final animation = build(
      ctx,
      tweenBuilder: (begin, end) => AlignmentGeometryTween(begin: begin, end: end),
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Align(
          alignment: animation.value ?? Alignment.center,
          child: child,
        );
      },
      child: child,
    );
  }
}

class SlideAct extends TweenAct<Offset> {
  const SlideAct({
    super.begin = Offset.zero,
    super.end = Offset.zero,
    super.curve,
    super.timing,
  });

  const SlideAct.sequence(super.phases) : super.sequence();

  @override
  Widget wrapWidget(AnimationContext context, Widget child) {
    return SlideTransition(
      position: build(context),
      child: child,
    );
  }
}

class TranslationAct extends TweenAct<Offset> {
  const TranslationAct({
    super.begin = Offset.zero,
    super.end = Offset.zero,
    super.curve,
    super.timing,
  });

  TranslationAct.fromValues({
    double fromX = 0,
    double fromY = 0,
    double toX = 0,
    double toY = 0,
  }) : super(
         begin: Offset(fromX, fromY),
         end: Offset(toX, toY),
       );

  const TranslationAct.sequence(super.phases) : super.sequence();

  @override
  Widget wrapWidget(AnimationContext context, Widget child) {
    final animation = build(context);
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        return Transform.translate(
          offset: animation.value,
          child: child,
        );
      },
    );
  }
}

class TextStyleAct extends TweenAct<TextStyle> {
  const TextStyleAct({
    required super.begin,
    required super.end,
    super.curve,
    super.timing,
  });

  const TextStyleAct.sequence(super.phases) : super.sequence();

  @override
  Widget wrapWidget(AnimationContext context, Widget child) {
    final animation = build(
      context,
      tweenBuilder: (begin, end) {
        return TextStyleTween(begin: begin, end: end);
      },
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return DefaultTextStyle(
          style: animation.value,
          child: child!,
        );
      },
      child: child,
    );
  }
}

class PaddingAct extends TweenAct<EdgeInsetsGeometry> {
  const PaddingAct({
    super.begin = EdgeInsets.zero,
    super.end = EdgeInsets.zero,
    super.curve,
    super.timing,
  });

  const PaddingAct.sequence(List<Phase<EdgeInsets>> super.phases) : super.sequence();

  @override
  Widget wrapWidget(AnimationContext context, Widget child) {
    final animation = build(
      context,
      tweenBuilder: (begin, end) {
        return EdgeInsetsGeometryTween(begin: begin, end: end);
      },
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Padding(
          padding: animation.value.clamp(EdgeInsets.zero, EdgeInsetsGeometry.infinity),
          child: child,
        );
      },
      child: child,
    );
  }
}

class ClipRevealAct extends TweenAct<double> {
  const ClipRevealAct({
    this.intrinsicSize = Size.zero,
    this.borderRadius = BorderRadius.zero,
    this.alignment,
    super.curve,
    super.timing,
  }) : super(begin: 0, end: 1);

  final Size intrinsicSize;
  final BorderRadius borderRadius;
  final AlignmentGeometry? alignment;

  @override
  Widget wrapWidget(AnimationContext context, Widget child) {
    final animation = build(context);
    final directionality = Directionality.of(context.buildContext);
    final effectiveAlignment = alignment ?? Alignment.topLeft;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Align(
          alignment: effectiveAlignment,
          widthFactor: animation.value,
          heightFactor: animation.value,
          child: ClipPath(
            clipper: ExpandingPathClipper(
              progress: animation.value,
              minSize: intrinsicSize,
              borderRadius: borderRadius,
              alignment: effectiveAlignment.resolve(directionality),
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class ExpandingPathClipper extends CustomClipper<Path> {
  final double progress;
  final Size minSize;
  final BorderRadius borderRadius;
  final Alignment alignment;

  ExpandingPathClipper({
    required this.progress,
    required this.minSize,
    this.borderRadius = BorderRadius.zero,
    required this.alignment,
  });

  @override
  Path getClip(Size size) {
    double minWidth = minSize.width;
    if (minWidth.isInfinite) {
      minWidth = size.width;
    }
    double minHeight = minSize.height;
    if (minHeight.isInfinite) {
      minHeight = size.height;
    }

    final animatableWidth = size.width - minWidth;
    final animatableHeight = size.height - minHeight;
    final currentWidth = minWidth + animatableWidth * progress;
    final currentHeight = minHeight + animatableHeight * progress;
    // Calculate the alignment point within the available size
    final alignmentOffset = alignment.alongSize(size);
    // Calculate the alignment point within the clipped rect
    final rectAlignmentOffset = alignment.alongSize(Size(currentWidth, currentHeight));

    // Position the rect so its alignment point matches the size's alignment point
    final left = alignmentOffset.dx - rectAlignmentOffset.dx;
    final top = alignmentOffset.dy - rectAlignmentOffset.dy;

    final rect = Rect.fromLTWH(left, top, currentWidth, currentHeight);
    return Path()..addRRect(borderRadius.toRRect(rect));
  }

  @override
  bool shouldReclip(covariant ExpandingPathClipper oldClipper) {
    return oldClipper.progress != progress || oldClipper.minSize != minSize;
  }
}
