import 'package:cue/src/acts/act.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'actor.dart';

@internal
class RotateActorFactory extends SingleActProxy {
  final double from;
  final double to;
  final AlignmentGeometry alignment;
  final bool _rotateAsTurns;

  const RotateActorFactory({
    super.key,
    required this.from,
    required this.to,
    required super.child,
    this.alignment = Alignment.center,
    super.curve,
    super.timing,
  }) : _rotateAsTurns = false;

  const RotateActorFactory.turns({
    super.key,
    required this.from,
    required this.to,
    required super.child,
    this.alignment = Alignment.center,
    super.curve,
    super.timing,
  }) : _rotateAsTurns = true;

  @override
  Widget build(BuildContext context) {
    return ActorBase(
      acts: [
        RotateAct.internal(
          from: from,
          to: to,
          alignment: alignment,
          asQuarterTurns: _rotateAsTurns,
          curve: curve,
          timing: timing,
        ),
      ],
      child: child,
    );
  }
}

@internal
class ScaleActorFactory extends SingleActProxy {
  final double from;
  final double to;
  final AlignmentGeometry? alignment;

  const ScaleActorFactory({
    super.key,
    required this.from,
    required this.to,
    required super.child,
    this.alignment,
    super.curve,
    super.timing,
  });

  @override
  Widget build(BuildContext context) {
    return ActorBase(
      acts: [
        ScaleAct(
          from: from,
          to: to,
          alignment: alignment?.resolve(Directionality.of(context)),
          curve: curve,
          timing: timing,
        ),
      ],
      child: child,
    );
  }
}

@internal
class FadeActorFactory extends SingleActProxy {
  final double from;
  final double to;

  const FadeActorFactory({
    super.key,
    this.from = 1,
    this.to = 0,
    required super.child,
    super.curve,
    super.timing,
  });

  @override
  Widget build(BuildContext context) {
    return ActorBase(
      acts: [
        FadeAct(
          from: from,
          to: to,
          curve: curve,
          timing: timing,
        ),
      ],
      child: child,
    );
  }
}

@internal
class SlideActorFactory extends SingleActProxy {
  final Offset? from;
  final Offset? to;
  final double? _axisFrom;
  final double? _axisTo;
  final Axis? _axis;

  const SlideActorFactory({
    super.key,
    required Offset this.from,
    Offset this.to = Offset.zero,
    required super.child,
    super.curve,
    super.timing,
  }) : _axis = null,
       _axisFrom = null,
       _axisTo = null;

  const SlideActorFactory.x({
    super.key,
    required double from,
    required double to,
    required super.child,
    super.curve,
    super.timing,
  }) : _axis = Axis.horizontal,
       _axisFrom = from,
       _axisTo = to,
       from = null,
       to = null;

  const SlideActorFactory.y({
    super.key,
    required double from,
    required double to,
    required super.child,
    super.curve,
    super.timing,
  }) : _axisFrom = from,
       _axisTo = to,
       _axis = Axis.vertical,
       from = null,
       to = null;

  @override
  Widget build(BuildContext context) {
    final Act act = switch (_axis) {
      Axis.horizontal => SlideAct.x(from: _axisFrom!, to: _axisTo!, curve: curve, timing: timing),
      Axis.vertical => SlideAct.y(from: _axisFrom!, to: _axisTo!, curve: curve, timing: timing),
      _ => SlideAct(from: from!, to: to!, curve: curve, timing: timing),
    };
    return ActorBase(
      acts: [act],
      child: child,
    );
  }
}

@internal
class AlignActorFactory extends SingleActProxy {
  final AlignmentGeometry? from;
  final AlignmentGeometry? to;

  const AlignActorFactory({
    super.key,
    this.from,
    this.to,
    required super.child,
    super.curve,
    super.timing,
  });

  @override
  Widget build(BuildContext context) {
    return ActorBase(
      acts: [
        AlignAct(
          from: from,
          to: to,
          curve: curve,
          timing: timing,
        ),
      ],
      child: child,
    );
  }
}

@internal
class ResizeActorFactory extends SingleActProxy {
  final Size from;
  final Size to;
  final AlignmentGeometry alignment;

  final bool _resizeFractionally;

  const ResizeActorFactory({
    super.key,
    required this.from,
    required this.to,
    this.alignment = Alignment.center,
    required super.child,
    super.curve,
    super.timing,
  }) : _resizeFractionally = false;

  const ResizeActorFactory.fractionally({
    super.key,
    required this.from,
    required this.to,
    this.alignment = Alignment.center,
    required super.child,
    super.curve,
    super.timing,
  }) : _resizeFractionally = true;

  @override
  Widget build(BuildContext context) {
    return ActorBase(
      acts: [
        switch (_resizeFractionally) {
          true => ResizeAct.fractional(
            from: from,
            to: to,
            alignment: alignment,
            curve: curve,
            timing: timing,
          ),
          false => ResizeAct(
            from: from,
            to: to,
            alignment: alignment,
            curve: curve,
            timing: timing,
          ),
        },
      ],
      child: child,
    );
  }
}

@internal
class BlurActorFactory extends SingleActProxy {
  final double from;
  final double to;

  const BlurActorFactory({
    super.key,
    required this.from,
    required this.to,
    required super.child,
    super.curve,
    super.timing,
  });

  @override
  Widget build(BuildContext context) {
    return ActorBase(
      acts: [
        BlurAct(
          from: from,
          to: to,
          curve: curve,
          timing: timing,
        ),
      ],
      child: child,
    );
  }
}

@internal
class PaddingActorFactory extends SingleActProxy {
  final EdgeInsetsGeometry from;
  final EdgeInsetsGeometry to;

  const PaddingActorFactory({
    super.key,
    this.from = EdgeInsets.zero,
    required this.to,
    required super.child,
    super.curve,
    super.timing,
  });

  @override
  Widget build(BuildContext context) {
    return ActorBase(
      acts: [
        PaddingAct(
          from: from,
          to: to,
          curve: curve,
          timing: timing,
        ),
      ],
      child: child,
    );
  }
}

class ClipRevealActorFactory extends SingleActProxy {
  final Size? _fromSize;
  final double? _fromAxisSize;
  final double? _toAxisSize;
  final BorderRadiusGeometry borderRadius;
  final AlignmentGeometry alignment;
  final Axis? _axis;

  const ClipRevealActorFactory({
    super.key,
    Size fromSize = Size.zero,
    this.borderRadius = BorderRadius.zero,
    this.alignment = Alignment.center,
    required super.child,
    super.curve,
    super.timing,
  }) : _axis = null,
       _fromSize = fromSize,
       _fromAxisSize = null,
       _toAxisSize = null;

  const ClipRevealActorFactory.horizontal({
    super.key,
    double from = 0,
    double to = 1,
    this.alignment = AlignmentDirectional.centerStart,
    required super.child,
    super.curve,
    super.timing,
  }) : _axis = Axis.horizontal,
       _fromAxisSize = from,
       _toAxisSize = to,
       borderRadius = BorderRadius.zero,
       _fromSize = null;

  const ClipRevealActorFactory.vertical({
    super.key,
    double from = 0,
    double to = 1,
    this.alignment = AlignmentDirectional.topCenter,
    required super.child,
    super.curve,
    super.timing,
  }) : _axis = Axis.vertical,
       _toAxisSize = to,
       _fromAxisSize = from,
       borderRadius = BorderRadius.zero,
       _fromSize = null;

  @override
  Widget build(BuildContext context) {
    return ActorBase(
      acts: [
        switch (_axis) {
          Axis.horizontal => ClipRevealAct.horizontal(
            from: _fromAxisSize!,
            to: _toAxisSize!,
            alignment: alignment,
            curve: curve,
            timing: timing,
          ),
          Axis.vertical => ClipRevealAct.vertical(
            from: _fromAxisSize!,
            to: _toAxisSize!,
            alignment: alignment,
            curve: curve,
            timing: timing,
          ),
          _ => ClipRevealAct(
            fromSize: _fromSize!,
            alignment: alignment,
            borderRadius: borderRadius,
            curve: curve,
            timing: timing,
          ),
        },
      ],
      child: child,
    );
  }
}

@internal
class PositionActorFactory extends SingleActProxy {
  final Position from;
  final Position to;

  const PositionActorFactory({
    super.key,
    required this.from,
    required this.to,
    required super.child,
    super.curve,
    super.timing,
  });

  @override
  Widget build(BuildContext context) {
    return ActorBase(
      acts: [
        PositionAct(
          from: from,
          to: to,
          curve: curve,
          timing: timing,
        ),
      ],
      child: child,
    );
  }
}

@internal
class TextStyleActorFactory extends SingleActProxy {
  final TextStyle from;
  final TextStyle to;

  const TextStyleActorFactory({
    super.key,
    required this.from,
    required this.to,
    required super.child,
    super.curve,
    super.timing,
  });

  @override
  Widget build(BuildContext context) {
    return ActorBase(
      acts: [
        TextStyleAct(
          from: from,
          to: to,
          curve: curve,
          timing: timing,
        ),
      ],
      child: child,
    );
  }
}

@internal
class IconThemeActorFactory extends SingleActProxy {
  final IconThemeData from;
  final IconThemeData to;

  const IconThemeActorFactory({
    super.key,
    required this.from,
    required this.to,
    required super.child,
    super.curve,
    super.timing,
  });

  @override
  Widget build(BuildContext context) {
    return ActorBase(
      acts: [
        IconThemeAct(
          from: from,
          to: to,
          curve: curve,
          timing: timing,
        ),
      ],
      child: child,
    );
  }
}

@internal
class DecoratedBoxActorFactory extends SingleActProxy {
  final Decoration from;
  final Decoration to;

  const DecoratedBoxActorFactory({
    super.key,
    required this.from,
    required this.to,
    required super.child,
    super.curve,
    super.timing,
  });

  @override
  Widget build(BuildContext context) {
    return ActorBase(
      acts: [
        DecorateAct(
          from: from,
          to: to,
          curve: curve,
          timing: timing,
        ),
      ],
      child: child,
    );
  }
}

@internal
class ColorActorFactory extends SingleActProxy {
  final Color from;
  final Color to;

  const ColorActorFactory({
    super.key,
    required this.from,
    required this.to,
    required super.child,
    super.curve,
    super.timing,
  });

  @override
  Widget build(BuildContext context) {
    return ActorBase(
      acts: [
        ColorAct(
          from: from,
          to: to,
          curve: curve,
          timing: timing,
        ),
      ],
      child: child,
    );
  }
}

@internal
class TranslateActorFactory extends SingleActProxy {
  final Offset? from;
  final Offset? to;
  final double? _axisFrom;
  final double? _axisTo;
  final _TranslateVariant? _variant;

  const TranslateActorFactory({
    super.key,
    required Offset this.from,
    Offset this.to = Offset.zero,
    required super.child,
    super.curve,
    super.timing,
  }) : _variant = _TranslateVariant.offset,
       _axisFrom = null,
       _axisTo = null;

  const TranslateActorFactory.x({
    super.key,
    required double from,
    required double to,
    required super.child,
    super.curve,
    super.timing,
  }) : _variant = _TranslateVariant.horizontal,
       _axisFrom = from,
       _axisTo = to,
       from = null,
       to = null;

  const TranslateActorFactory.y({
    super.key,
    required double from,
    required double to,
    required super.child,
    super.curve,
    super.timing,
  }) : _axisFrom = from,
       _axisTo = to,
       _variant = _TranslateVariant.vertical,
       from = null,
       to = null;

  const TranslateActorFactory.fromGlobal({
    super.key,
    required Offset offset,
    required super.child,
    super.curve,
    super.timing,
  }) : _variant = _TranslateVariant.fromGlobal,
       _axisFrom = null,
       _axisTo = null,
       from = offset,
       to = null;

  @override
  Widget build(BuildContext context) {
    final Act act = switch (_variant) {
      _TranslateVariant.horizontal => TranslateAct.x(from: _axisFrom!, to: _axisTo!, curve: curve, timing: timing),
      _TranslateVariant.vertical => TranslateAct.y(from: _axisFrom!, to: _axisTo!, curve: curve, timing: timing),
      _TranslateVariant.fromGlobal => TranslateAct.fromGlobal(offset: from!, curve: curve, timing: timing),
      _ => TranslateAct(from: from!, to: to!, curve: curve, timing: timing),
    };
    return ActorBase(
      acts: [act],
      child: child,
    );
  }
}

enum _TranslateVariant {
  offset,
  vertical,
  horizontal,
  fromGlobal,
}
