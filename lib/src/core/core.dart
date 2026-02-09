import 'package:flutter/widgets.dart';

class AnimationContext {
  AnimationContext({
    required this.buildContext,
    required this.driver,
    this.timing,
    this.curve,
  });

  final BuildContext buildContext;
  final Animation<double> driver;
  final Timing? timing;
  final Curve? curve;

  TextDirection get textDirection => Directionality.of(buildContext);
}

class Timing {
  final double start;
  final double end;
  static const full = Timing();

  const Timing({this.start = 0.0, this.end = 1.0})
    : assert(start >= 0 && start <= 1, 'start must be between 0 and 1'),
      assert(end >= 0 && end <= 1, 'end must be between 0 and 1'),
      assert(start <= end, 'start must be less than or equal to end');

  const Timing.endAt(this.end) : assert(end >= 0 && end <= 1, 'end must be between 0 and 1'), start = 0.0;
  const Timing.startAt(this.start) : assert(start >= 0 && start <= 1, 'start must be between 0 and 1'), end = 1.0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Timing && runtimeType == other.runtimeType && start == other.start && end == other.end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'Timing(start: $start, end: $end)';
}
