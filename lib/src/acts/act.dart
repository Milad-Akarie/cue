import 'dart:math';
import 'dart:ui';

import 'package:cue/src/core/core.dart';
import 'package:cue/src/core/phase.dart';
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
    List<Phase<double>> then,
    Curve? curve,
    Timing? timing,
    AlignmentGeometry? alignment,
  }) = ScaleAct;

  const factory Act.fade({
    double begin,
    double end,
    List<Phase<double>> then,
    Curve? curve,
    Timing? timing,
  }) = FadeAct;

  const factory Act.rotate({
    double begin,
    double end,
    List<Phase<double>> then,
    Curve? curve,
    Timing? timing,
  }) = RotateAct;

  const factory Act.blur({
    double begin,
    double end,
    List<Phase<double>> then,
    Curve? curve,
    Timing? timing,
  }) = BlurAct;

  const factory Act.resize({
    SizeOrNull? begin,
    SizeOrNull? end,
    List<Phase<SizeOrNull>> then,
    Curve? curve,
    Timing? timing,
    AlignmentGeometry? alignment,
  }) = ResizeAct;

  const factory Act.align({
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    List<Phase<AlignmentGeometry?>> then,
    Curve? curve,
    Timing? timing,
  }) = AlignAct;

  const factory Act.slide({
    Offset begin,
    Offset end,
    List<Phase<Offset>> then,
    Curve? curve,
    Timing? timing,
  }) = SlideAct;

  const factory Act.translate({
    Offset begin,
    Offset end,
    List<Phase<Offset>> then,
    Curve? curve,
    Timing? timing,
  }) = TranslationAct;

  const factory Act.textStyle({
    required TextStyle begin,
    required TextStyle end,
    List<Phase<TextStyle>> then,
    Curve? curve,
    Timing? timing,
  }) = TextStyleAct;

  const factory Act.pad({
    EdgeInsetsGeometry begin,
    EdgeInsetsGeometry end,
    List<Phase<EdgeInsetsGeometry>> then,
    Curve? curve,
    Timing? timing,
  }) = PaddingAct;

  const factory Act.clipReveal({
    Size beginSize,
    BorderRadius borderRadius,
    AlignmentGeometry? alignment,
    Curve? curve,
    Timing? timing,
  }) = ClipRevealAct;

  Widget wrapWidget(AnimationContext context, Widget child);
}

abstract class TweenAct<T> extends Act {
  final T begin;
  final T? end;
  final List<Phase<T>> then;

  const TweenAct({
    required this.begin,
    required this.end,
    required this.then,
    super.curve,
    super.timing,
  });

  Animatable<T> _defaultTweenBuilder(T begin, T end) => Tween<T>(begin: begin, end: end);

  Animation<T> build(AnimationContext context, {TweenBuilder<T>? tweenBuilder}) {
    final List<FullPhase<T>> phases;
    if (then.isEmpty) {
      phases = [FullPhase<T>(begin: begin, end: end ?? begin, weight: 1.0)];
    } else {
      assert(begin != null, 'Begin value must be provided when using phases');
      if (end case final end?) {
        then.add(.to(end));
      }
      phases = Phase.normalize(begin, then);
    }
    return TweenAct._build<T>(context, phases, tweenBuilder ?? _defaultTweenBuilder);
  }

  static Animation<T> _build<T>(AnimationContext context, List<FullPhase<T>> phases, TweenBuilder<T> tweenBuilder) {
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
            tween: phase is ConstantPhase<T> || phase.isAlwaysStopped
                ? ConstantTween<T>(phase.begin)
                : tweenBuilder(phase.begin, phase.end),
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
          begin == other.begin &&
          end == other.end &&
          then == other.then &&
          curve == other.curve &&
          timing == other.timing;

  @override
  int get hashCode => Object.hash(begin, end, then, curve, timing);
}

class ScaleAct extends TweenAct<double> {
  const ScaleAct({
    super.begin = 1.0,
    super.end,
    super.then = const [],
    super.curve,
    super.timing,
    this.alignment,
  });

  final AlignmentGeometry? alignment;

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
    super.then = const [],
    super.curve,
    super.timing,
  });

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
    super.end,
    super.then = const [],
    super.curve,
    super.timing,
  }) : assert(begin >= -360 && begin <= 360, 'Begin angle must be between 0 and 360 degrees'),
       assert(end == null || (end >= -360 && end <= 360), 'End angle must be between 0 and 360 degrees');

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
    super.then = const [],
    super.curve,
    super.timing,
  });

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
    super.then = const [],
    super.curve,
    super.timing,
  });

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
    super.end,
    super.then = const [],
    super.curve,
    super.timing,
  });

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
    super.end,
    super.then = const [],
    super.curve,
    super.timing,
  });

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
    super.end,
    super.then = const [],
    super.curve,
    super.timing,
  });

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
    super.then = const [],
    super.curve,
    super.timing,
  });

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
    this.beginSize = Size.zero,
    this.borderRadius = BorderRadius.zero,
    this.alignment,
    super.curve,
    super.timing,
  }) : super(begin: 0, end: 1, then: const []);

  final Size beginSize;
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
              minSize: beginSize,
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
