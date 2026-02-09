import 'dart:math';
import 'dart:ui';

import 'package:cue/src/core/core.dart';
import 'package:cue/src/core/phase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

part 'resize_act.dart';

typedef TweenBuilder<T> = Animatable<T> Function(T begin, T end);

class ActGroup extends Act {
  final List<Act> acts;

  const ActGroup(
    this.acts, {
    super.timing,
    super.curve,
  });

  @override
  Widget wrapWidget(AnimationContext context, Widget child) {
    return acts.fold(child, (current, act) => act.wrapWidget(context, current));
  }

  @override
  List<Act> get resolved => List.unmodifiable(acts.expand((act) => act.resolved));
}

abstract class Act {
  final Timing? timing;
  final Curve? curve;

  const Act({
    this.timing,
    this.curve,
  });

  const factory Act.group(List<Act> acts, {Timing? timing, Curve? curve}) = ActGroup;

  Act operator &(Act other) {
    // If we are already a group, just add the new one to our list
    if (this is ActGroup) {
      return ActGroup([...(this as ActGroup).acts, other]);
    }
    // Otherwise, create a new group with both acts
    return ActGroup([this, other]);
  }

  List<Act> get resolved => List.unmodifiable([this]);

  Widget wrapWidget(AnimationContext context, Widget child);
}

abstract class TweenAct<T> extends Act {
  final T begin;
  final T? end;
  final List<Phase<T>>? _phases;

  const TweenAct({
    required this.begin,
    required this.end,
    super.curve,
    super.timing,
  }) : _phases = null;

  const TweenAct.seq(
    this.begin, {
    required List<Phase<T>> then,
    super.curve,
    super.timing,
  }) : _phases = then,
       end = null;

  Animatable<T> _defaultTweenBuilder(T begin, T end) => Tween<T>(begin: begin, end: end);

  Animation<T> build(AnimationContext context, {TweenBuilder<T>? tweenBuilder}) {
    final List<FullPhase<T>> phases;
    if (_phases == null) {
      phases = [FullPhase<T>(begin: begin, end: end ?? begin, weight: 1.0)];
    } else {
      assert(begin != null, 'Begin value must be provided when using phases');
      phases = Phase.normalize(begin, _phases);
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
          _phases == other._phases &&
          curve == other.curve &&
          timing == other.timing;

  @override
  int get hashCode => Object.hash(begin, end, _phases, curve, timing);
}

class Scale extends TweenAct<double> {
  const Scale({
    super.begin = 1.0,
    super.end,
    super.curve,
    super.timing,
    this.alignment,
  });

  final AlignmentGeometry? alignment;

  const Scale.up({super.begin = 0.0, super.curve, super.timing, this.alignment}) : super(end: 1.0);

  const Scale.down({super.end = 0.0, super.curve, super.timing, this.alignment}) : super(begin: 1.0);

  const Scale.seq(super.begin, {required super.then, super.curve, super.timing, this.alignment}) : super.seq();

  @override
  Widget wrapWidget(AnimationContext context, Widget child) {
    return ScaleTransition(
      scale: build(context),
      alignment: alignment?.resolve(context.textDirection) ?? Alignment.center,
      child: child,
    );
  }
}

class Fade extends TweenAct<double> {
  const Fade({
    super.begin = 0.0,
    super.end = 1.0,
    super.curve,
    super.timing,
  });

  const Fade.out({super.begin = 1.0, super.curve, super.timing}) : super(end: 0);

  const Fade.seq(super.begin, {required super.then, super.curve, super.timing}) : super.seq();

  @override
  Widget wrapWidget(AnimationContext context, Widget child) {
    return FadeTransition(
      opacity: build(context),
      child: child,
    );
  }
}

class Rotate extends TweenAct<double> {
  const Rotate({
    super.begin = 0,
    super.end = 0,
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

class Blur extends TweenAct<double> {
  const Blur({
    super.begin = 0.0,
    super.end = 0.0,
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

class Anchor extends TweenAct<AlignmentGeometry?> {
  const Anchor({
    super.begin,
    super.end,
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

class Slide extends TweenAct<Offset> {
  const Slide({
    super.begin = Offset.zero,
    super.end,
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

class Translate extends TweenAct<Offset> {
  const Translate({
    super.begin = Offset.zero,
    super.end = Offset.zero,
    super.curve,
    super.timing,
  });

  Translate.x({double begin = 0, double end = 0, Curve? curve, Timing? timing})
    : this(begin: Offset(begin, 0), end: Offset(end, 0), curve: curve, timing: timing);

  Translate.y({double begin = 0, double end = 0, Curve? curve, Timing? timing})
    : this(begin: Offset(0, begin), end: Offset(0, end), curve: curve, timing: timing);

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

class Pad extends TweenAct<EdgeInsetsGeometry> {
  const Pad({
    super.begin = EdgeInsets.zero,
    super.end = EdgeInsets.zero,
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

class ClipReveal extends TweenAct<double> {
  const ClipReveal({
    this.beginSize = Size.zero,
    this.borderRadius = BorderRadius.zero,
    this.alignment,
    super.curve,
    super.timing,
  }) : super(begin: 0, end: 1);

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

abstract class Style extends Act {
  const factory Style.text({
    required TextStyle begin,
    TextStyle? end,
    Curve? curve,
    Timing? timing,
  }) = _TextStyleAct;

  const factory Style.iconTheme({
    required IconThemeData begin,
    IconThemeData? end,
    Curve? curve,
    Timing? timing,
  }) = _IconThemeAct;
}

class _TextStyleAct extends TweenAct<TextStyle> implements Style {
  const _TextStyleAct({
    required super.begin,
    super.end,
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
    return DefaultTextStyleTransition(style: animation, child: child);
  }
}

class _IconThemeAct extends TweenAct<IconThemeData> implements Style {
  const _IconThemeAct({
    required super.begin,
    super.end,
    super.curve,
    super.timing,
  });

  @override
  Widget wrapWidget(AnimationContext context, Widget child) {
    final animation = build(
      context,
      tweenBuilder: (begin, end) {
        return _IconThemeDataTween(begin: begin, end: end);
      },
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return IconTheme(data: animation.value, child: child!);
      },
      child: child,
    );
  }
}

class _IconThemeDataTween extends Tween<IconThemeData> {
  _IconThemeDataTween({required super.begin, required super.end});

  @override
  IconThemeData lerp(double t) {
    return IconThemeData.lerp(begin, end, t);
  }
}
