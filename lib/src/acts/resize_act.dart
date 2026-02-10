part of 'act.dart';

class Resize extends Act {
  const Resize({
    this.begin,
    this.end,
    super.curve,
    super.timing,
    this.alignment,
  }) : _keyframes = null;

  final AlignmentGeometry? alignment;
  final SizeOrNull? begin;
  final SizeOrNull? end;

  final List<Keyframe<SizeOrNull>>? _keyframes;

  SizeOrNullTween _buildTween(SizeOrNull begin, SizeOrNull end, Size maxSize) {
    final effectiveBeginWidth = begin.width != null && begin.width!.isInfinite ? maxSize.width : begin.width;
    final effectiveBeginHeight = begin.height != null && begin.height!.isInfinite ? maxSize.height : begin.height;
    final effectiveEndWidth = end.width != null && end.width!.isInfinite ? maxSize.width : end.width;
    final effectiveEndHeight = end.height != null && end.height!.isInfinite ? maxSize.height : end.height;
    return SizeOrNullTween(
      begin: SizeOrNull(effectiveBeginWidth, effectiveBeginHeight),
      end: SizeOrNull(effectiveEndWidth, effectiveEndHeight),
    );
  }

  Animation<SizeOrNull> build(AnimationContext context, Size maxSize) {
    final List<Phase<SizeOrNull>> phases;
    final begin = this.begin ?? SizeOrNull.nullSize;
    if (_keyframes == null) {
      phases = [Phase<SizeOrNull>(begin: begin, end: end ?? begin, weight: 1.0)];
    } else {
      final result = Phase.normalize(_keyframes);
      phases = result.phases;
      context = context.copyWith(timing: result.timing);
    }
    return TweenAct._build<SizeOrNull>(context, phases, (begin, end) {
      return _buildTween(begin, end, maxSize);
    });
  }

  @override
  Widget wrapWidget(AnimationContext context, Widget child) {
    return LayoutBuilder(
      builder: (_, constrains) {
        final animation = build(context, constrains.biggest);
        final builder = AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return SizedBox(
              width: animation.value.width,
              height: animation.value.height,
              child: child,
            );
          },
          child: child,
        );
        if (alignment case final alignment?) {
          return Align(
            alignment: alignment,
            child: builder,
          );
        }
        return builder;
      },
    );
  }
}

class SizeOrNull {
  final double? width;
  final double? height;

  const SizeOrNull(this.width, this.height);

  static const infinite = SizeOrNull(double.infinity, double.infinity);

  static const zero = SizeOrNull(0, 0);

  static const nullSize = SizeOrNull(null, null);

  factory SizeOrNull.width(double width) => SizeOrNull(width, null);
  factory SizeOrNull.height(double height) => SizeOrNull(null, height);
  factory SizeOrNull.size(double? width, double? height) => SizeOrNull(width, height);
  factory SizeOrNull.square(double size) => SizeOrNull(size, size);
  factory SizeOrNull.fromSize(Size size) => SizeOrNull(size.width, size.height);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SizeOrNull && width == other.width && height == other.height;

  @override
  int get hashCode => Object.hash(width, height);
}

class SizeOrNullTween extends Tween<SizeOrNull> {
  SizeOrNullTween({super.begin, super.end});

  @override
  SizeOrNull lerp(double t) {
    final beginWidth = begin?.width;
    final endWidth = end?.width;
    final beginHeight = begin?.height;
    final endHeight = end?.height;

    return SizeOrNull(
      beginWidth != null && endWidth != null ? lerpDouble(beginWidth, endWidth, t) : null,
      beginHeight != null && endHeight != null ? lerpDouble(beginHeight, endHeight, t) : null,
    );
  }
}
