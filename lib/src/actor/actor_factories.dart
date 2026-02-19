import 'package:cue/src/actor/actor.dart';
import 'package:cue/src/effects/effect.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

class RotateActor extends SingleEffectProxy {
  final double from;
  final double to;
  final AlignmentGeometry alignment;
  final bool _rotateAsTurns;
  final bool _inDegrees;
  final RotateAxis axis;

  const RotateActor({
    super.key,
    required this.from,
    required this.to,
    required super.child,
    this.alignment = Alignment.center,
    super.curve,
    super.timing,
    this.axis = RotateAxis.z,
  }) : _rotateAsTurns = false,
       _inDegrees = false;

  const RotateActor.flipX({
    super.key,
    required super.child,
    this.alignment = Alignment.center,
    super.curve,
    super.timing,
  }) : _rotateAsTurns = false,
       _inDegrees = false,
       axis = RotateAxis.x,
       from = 0,
       to = math.pi;

  const RotateActor.flipY({
    super.key,
    required super.child,
    this.alignment = Alignment.center,
    super.curve,
    super.timing,
  }) : _rotateAsTurns = false,
       _inDegrees = false,
       axis = RotateAxis.y,
       from = 0,
       to = math.pi;

  const RotateActor.turns({
    super.key,
    this.from = 0,
    required this.to,
    required super.child,
    this.alignment = Alignment.center,
    super.curve,
    super.timing,
    this.axis = RotateAxis.z,
  }) : _rotateAsTurns = true,
       _inDegrees = false;

  const RotateActor.degrees({
    super.key,
    this.from = 0,
    required this.to,
    required super.child,
    this.alignment = Alignment.center,
    super.curve,
    super.timing,
    this.axis = RotateAxis.z,
  }) : _rotateAsTurns = false,
       _inDegrees = true;

  @override
  Effect get effect => RotateEffect.internal(
    from: from,
    to: to,
    alignment: alignment,
    asQuarterTurns: _rotateAsTurns,
    inDegrees: _inDegrees,
    axis: axis,
  );
}

class ScaleActor extends SingleEffectProxy {
  final double from;
  final double to;
  final AlignmentGeometry? alignment;

  const ScaleActor({
    super.key,
    required this.from,
    required this.to,
    required super.child,
    this.alignment,
    super.curve,
    super.timing,
    super.role,
  });

  @override
  Effect get effect => ScaleEffect(
    from: from,
    to: to,
    alignment: alignment,
  );
}

class FadeActor extends SingleEffectProxy {
  final double from;
  final double to;

  const FadeActor({
    super.key,
    this.from = 1,
    this.to = 0,
    required super.child,
    super.role,
    super.curve,
    super.timing,
  });

  @override
  Effect get effect => FadeEffect(from: from, to: to);
}

class SlideActor extends SingleEffectProxy {
  final Offset? from;
  final Offset? to;
  final double? _axisFrom;
  final double? _axisTo;
  final Axis? _axis;

  const SlideActor({
    super.key,
    required Offset this.from,
    Offset this.to = Offset.zero,
    required super.child,
    super.curve,
    super.reverseCurve,
    super.reverseTiming,
    super.timing,
    super.role,
  }) : _axis = null,
       _axisFrom = null,
       _axisTo = null;

  const SlideActor.x({
    super.key,
    required double from,
    required double to,
    required super.child,
    super.role,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
  }) : _axis = Axis.horizontal,
       _axisFrom = from,
       _axisTo = to,
       from = null,
       to = null;

  const SlideActor.y({
    super.key,
    required double from,
    required double to,
    required super.child,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
    super.role,
  }) : _axisFrom = from,
       _axisTo = to,
       _axis = Axis.vertical,
       from = null,
       to = null;

  @override
  Effect get effect => switch (_axis) {
    Axis.horizontal => SlideEffect.x(from: _axisFrom!, to: _axisTo!),
    Axis.vertical => SlideEffect.y(from: _axisFrom!, to: _axisTo!),
    _ => SlideEffect(from: from!, to: to!),
  };
}

class AlignActor extends SingleEffectProxy {
  final AlignmentGeometry? from;
  final AlignmentGeometry? to;

  const AlignActor({
    required super.child,
    super.key,
    this.from,
    this.to,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  });

  @override
  Effect get effect => AlignEffect(from: from, to: to);
}

class SizeActor extends SingleEffectProxy {
  final Size? _from;
  final Size? _to;
  final AlignmentGeometry alignment;
  final bool allowOverflow;
  final Axis? _axis;
  final double? _axisFrom;
  final double? _axisTo;
  final double? _fixedCrossAxisSize;
  final Clip clipBehavior;

  const SizeActor({
    super.key,
    required Size from,
    required Size to,
    this.alignment = Alignment.center,
    this.allowOverflow = false,
    this.clipBehavior = Clip.hardEdge,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : _from = from,
       _to = to,
       _axis = null,
       _axisFrom = null,
       _axisTo = null,
       _fixedCrossAxisSize = null;

  const SizeActor.width({
    super.key,
    required double from,
    required double to,
    double? fixedHeight,
    this.alignment = Alignment.center,
    this.allowOverflow = false,
    this.clipBehavior = Clip.hardEdge,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : _axis = Axis.horizontal,
       _axisFrom = from,
       _axisTo = to,
       _from = null,
       _to = null,
       _fixedCrossAxisSize = fixedHeight;

  const SizeActor.height({
    super.key,
    required double from,
    required double to,
    double? fixedWidth,
    this.clipBehavior = Clip.hardEdge,
    this.alignment = Alignment.center,
    this.allowOverflow = false,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : _axis = Axis.vertical,
       _axisFrom = from,
       _axisTo = to,
       _from = null,
       _to = null,
       _fixedCrossAxisSize = fixedWidth;

  @override
  Effect get effect {
    Size? from = _from;
    Size? to = _to;
    if (_axis != null) {
      from = switch (_axis) {
        Axis.horizontal => Size(_axisFrom!, _fixedCrossAxisSize ?? double.infinity),
        Axis.vertical => Size(_fixedCrossAxisSize ?? double.infinity, _axisFrom!),
      };
      to = switch (_axis) {
        Axis.horizontal => Size(_axisTo!, _fixedCrossAxisSize ?? double.infinity),
        Axis.vertical => Size(_fixedCrossAxisSize ?? double.infinity, _axisTo!),
      };
    }
    return SizeEffect(
      from: from,
      to: to,
      alignment: alignment,
      allowOverflow: allowOverflow,
      clipBehavior: clipBehavior,
    );
  }
}

class FractionalSizeActor extends SingleEffectProxy {
  final Size? _from;
  final Size? _to;
  final Axis? _axis;
  final double? _axisFrom;
  final double? _axisTo;
  final AlignmentGeometry alignment;

  const FractionalSizeActor({
    super.key,
    required Size from,
    required Size to,
    this.alignment = Alignment.center,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : _from = from,
       _to = to,
       _axis = null,
       _axisFrom = null,
       _axisTo = null;

  const FractionalSizeActor.width({
    super.key,
    required double from,
    required double to,
    this.alignment = Alignment.center,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : _axis = Axis.horizontal,
       _axisFrom = from,
       _axisTo = to,
       _from = null,
       _to = null;

  const FractionalSizeActor.height({
    super.key,
    required double from,
    required double to,
    this.alignment = Alignment.center,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : _axis = Axis.vertical,
       _axisFrom = from,
       _axisTo = to,
       _from = null,
       _to = null;

  @override
  Effect get effect {
    Size from = _from ?? Size.infinite;
    Size to = _to ?? Size.infinite;
    if (_axis != null) {
      from = switch (_axis) {
        Axis.horizontal => Size.fromWidth(_axisFrom!),
        Axis.vertical => Size.fromHeight(_axisFrom!),
      };
      to = switch (_axis) {
        Axis.horizontal => Size.fromWidth(_axisTo!),
        Axis.vertical => Size.fromHeight(_axisTo!),
      };
    }
    return FractionalSizeEffect(from: from, to: to, alignment: alignment);
  }
}

class BlurActor extends SingleEffectProxy {
  final double from;
  final double to;

  const BlurActor({
    super.key,
    required this.from,
    required this.to,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  });

  @override
  Effect get effect => BlurEffect(from: from, to: to);
}

class BackdropBlurActor extends SingleEffectProxy {
  final double from;
  final double to;
  final BlendMode blendMode;

  const BackdropBlurActor({
    super.key,
    required this.from,
    required this.to,
    this.blendMode = BlendMode.srcOver,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  });

  @override
  Effect get effect => BackdropBlurEffect(from: from, to: to, blendMode: blendMode);
}

class PaddingActor extends SingleEffectProxy {
  final EdgeInsetsGeometry from;
  final EdgeInsetsGeometry to;

  const PaddingActor({
    super.key,
    this.from = EdgeInsets.zero,
    required this.to,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  });

  @override
  Effect get effect => PaddingEffect(from: from, to: to);
}

class ClipActor extends SingleEffectProxy {
  final Size? _fromSize;
  final double? _fromAxisSize;
  final double? _toAxisSize;
  final BorderRadiusGeometry? borderRadius;
  final AlignmentGeometry alignment;
  final Axis? _axis;

  const ClipActor({
    super.key,
    Size fromSize = Size.zero,
    BorderRadiusGeometry this.borderRadius = BorderRadius.zero,
    this.alignment = Alignment.center,
    required super.child,
    super.role,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
  }) : _axis = null,
       _fromSize = fromSize,
       _fromAxisSize = null,
       _toAxisSize = null;

  const ClipActor.circular({
    super.key,
    Size fromSize = Size.zero,
    this.alignment = Alignment.center,
    required super.child,
    super.role,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
  }) : _axis = null,
       _fromSize = fromSize,
       _fromAxisSize = null,
       _toAxisSize = null,
       borderRadius = null;

  const ClipActor.horizontal({
    super.key,
    double from = 0,
    double to = 1,
    this.alignment = AlignmentDirectional.centerStart,
    required super.child,
    super.curve,
    super.role,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
  }) : _axis = Axis.horizontal,
       _fromAxisSize = from,
       _toAxisSize = to,
       borderRadius = BorderRadius.zero,
       _fromSize = null;

  const ClipActor.vertical({
    super.key,
    double from = 0,
    double to = 1,
    this.alignment = AlignmentDirectional.topCenter,
    required super.child,
    super.curve,
    super.role,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
  }) : _axis = Axis.vertical,
       _toAxisSize = to,
       _fromAxisSize = from,
       borderRadius = BorderRadius.zero,
       _fromSize = null;

  @override
  Effect get effect => switch (_axis) {
    Axis.horizontal => ClipEffect.horizontal(
      from: _fromAxisSize!,
      to: _toAxisSize!,
      alignment: alignment,
      curve: curve,
      timing: timing,
    ),
    Axis.vertical => ClipEffect.vertical(
      from: _fromAxisSize!,
      to: _toAxisSize!,
      alignment: alignment,
      curve: curve,
      timing: timing,
    ),
    _ when borderRadius != null => ClipEffect(
      fromSize: _fromSize!,
      alignment: alignment,
      borderRadius: borderRadius!,
      curve: curve,
      timing: timing,
    ),
    _ => ClipEffect.circluar(
      fromSize: _fromSize!,
      alignment: alignment,
      curve: curve,
      timing: timing,
    ),
  };
}

class PositionActor extends SingleEffectProxy<Position> {
  final Position from;
  final Position to;
  final Size? _relativeTo;

  const PositionActor({
    super.key,
    required this.from,
    required this.to,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : _relativeTo = null;

  const PositionActor.relative({
    super.key,
    required this.from,
    required this.to,
    required Size size,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : _relativeTo = size;

  @override
  Effect get effect => PositionEffect.internal(
    from: from,
    to: to,
    relativeTo: _relativeTo,
    curve: curve,
    timing: timing,
  );
}

class TextStyleActor extends SingleEffectProxy {
  final TextStyle from;
  final TextStyle to;

  const TextStyleActor({
    super.key,
    required this.from,
    required this.to,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  });

  @override
  Effect get effect => TextStyleEffect(from: from, to: to);
}

class IconThemeActor extends SingleEffectProxy {
  final IconThemeData from;
  final IconThemeData to;

  const IconThemeActor({
    super.key,
    required this.from,
    required this.to,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  });

  @override
  Effect get effect => IconThemeEffect(from: from, to: to);
}

class DecorateActor extends SingleEffectProxy {
  final Decoration from;
  final Decoration to;

  const DecorateActor({
    super.key,
    required this.from,
    required this.to,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  });

  @override
  Effect get effect => DecorateEffect(from: from, to: to);
}

class ColorActor extends SingleEffectProxy {
  final Color from;
  final Color to;

  const ColorActor({
    super.key,
    required this.from,
    required this.to,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  });

  @override
  Effect get effect => ColorEffect(from: from, to: to);
}

class TransformActor extends SingleEffectProxy {
  final Matrix4 from;
  final Matrix4 to;
  final AlignmentGeometry? alignment;
  final Offset? origin;

  const TransformActor({
    super.key,
    required super.child,
    required this.from,
    required this.to,
    this.alignment,
    this.origin,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  });

  @override
  Effect get effect => TransformEffect(from: from, to: to, alignment: alignment, origin: origin);
}

class TranslateActor extends SingleEffectProxy {
  final Offset? from;
  final Offset? to;
  final double? _axisFrom;
  final double? _axisTo;
  final _TranslateVariant? _variant;

  const TranslateActor({
    super.key,
    required Offset this.from,
    Offset this.to = Offset.zero,
    required super.child,
    super.curve,
    super.timing,
    super.role,
    super.reverseCurve,
    super.reverseTiming,
  }) : _variant = _TranslateVariant.offset,
       _axisFrom = null,
       _axisTo = null;

  const TranslateActor.x({
    super.key,
    required double from,
    double to = 0,
    required super.child,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
    super.role,
  }) : _variant = _TranslateVariant.horizontal,
       _axisFrom = from,
       _axisTo = to,
       from = null,
       to = null;

  const TranslateActor.y({
    super.key,
    required double from,
    double to = 0,
    required super.child,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
    super.role,
  }) : _axisFrom = from,
       _axisTo = to,
       _variant = _TranslateVariant.vertical,
       from = null,
       to = null;

  const TranslateActor.fromGlobal({
    super.key,
    required Offset offset,
    Offset toLocal = Offset.zero,
    required super.child,
    super.curve,
    super.timing,
    super.reverseCurve,
    super.reverseTiming,
    super.role,
  }) : _variant = _TranslateVariant.fromGlobal,
       _axisFrom = null,
       _axisTo = null,
       from = offset,
       to = toLocal;

  @override
  Effect get effect => switch (_variant) {
    .horizontal => TranslateEffect.x(from: _axisFrom!, to: _axisTo!),
    .vertical => TranslateEffect.y(from: _axisFrom!, to: _axisTo!),
    .fromGlobal => TranslateEffect.fromGlobal(offset: from!, toLocal: to!),
    _ => TranslateEffect(from: from!, to: to!),
  };
}

enum _TranslateVariant { offset, vertical, horizontal, fromGlobal }
