part of 'act.dart';

class ResizeAct extends Act {
  const ResizeAct({
    this.beginWidth,
    this.beginHeight,
    this.endWidth,
    this.endHeight,
    super.curve,
    super.timing,
    this.alignment,
  }) : _phases = null;

  final AlignmentGeometry? alignment;
  final double? beginWidth;
  final double? beginHeight;
  final double? endWidth;
  final double? endHeight;
  final List<Phase<SizeOrNull>>? _phases;

  const ResizeAct.sequence(List<Phase<SizeOrNull>> phases, {this.alignment})
    : _phases = phases,
      beginWidth = null,
      beginHeight = null,
      endWidth = null,
      endHeight = null;

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
    final phases =
        _phases ??
        [
          Phase(
            begin: SizeOrNull(
              beginWidth,
              beginHeight,
            ),
            end: SizeOrNull(
              endWidth,
              endHeight,
            ),
            weight: 1.0,
          ),
        ];
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
