sealed class Phase<T> {
  const Phase._({required this.weight}) : assert(weight > 0.0);
  final double weight;

  const factory Phase({
    required T begin,
    required T end,
    required double weight,
  }) = FullPhase<T>;

  const factory Phase.to(T begin, {double weight}) = _EndPhase<T>;
  const factory Phase.from(T end, {double weight}) = _BeginPhase<T>;
  const factory Phase.hold(T value, {double weight}) = ConstantPhase<T>;

  static List<FullPhase<T>> normalize<T>(T base, List<Phase<T>> partialPhase) {
    final List<FullPhase<T>> fullPhases = [];
    T currentBase = base;
    for (final phase in partialPhase) {
      switch (phase) {
        case FullPhase<T>():
          fullPhases.add(phase);
          currentBase = phase.end;
        case _BeginPhase<T>():
          // Begin-only phase: needs an end value (use next phase's begin or current base)
          final nextPhase = partialPhase.indexOf(phase) < partialPhase.length - 1
              ? partialPhase[partialPhase.indexOf(phase) + 1]
              : null;
          final end = nextPhase is _EndPhase<T> ? nextPhase.end : currentBase;
          fullPhases.add(FullPhase(begin: phase.begin, end: end, weight: phase.weight));
          currentBase = end;
        case _EndPhase<T>():
          fullPhases.add(FullPhase(begin: currentBase, end: phase.end, weight: phase.weight));
          currentBase = phase.end;
      }
    }

    return fullPhases;
  }
}

class FullPhase<T> extends Phase<T> {
  final T begin;
  final T end;

  const FullPhase({
    required this.begin,
    required this.end,
    required super.weight,
  }) : super._();

  bool get isAlwaysStopped => begin == end;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FullPhase && runtimeType == other.runtimeType && begin == other.begin && end == other.end;

  @override
  int get hashCode => Object.hash(begin, end);
}

class _EndPhase<T> extends Phase<T> {
  final T end;

  const _EndPhase(this.end, {super.weight = 1.0}) : super._();
}

class _BeginPhase<T> extends Phase<T> {
  final T begin;
  const _BeginPhase(this.begin, {super.weight = 1.0}) : super._();
}

class ConstantPhase<T> extends FullPhase<T> {
  final T value;
  const ConstantPhase(this.value, {super.weight = 1.0}) : super(begin: value, end: value);
}
