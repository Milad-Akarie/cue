part of 'cue.dart';

class CueScope extends InheritedWidget {
  const CueScope({
    super.key,
    required super.child,
    required this.animation,
    required this.isBounded,
  });

  final Animation<double> animation;
  final bool isBounded;

  static CueScope of(BuildContext context) {
    final cue = context.dependOnInheritedWidgetOfExactType<CueScope>();
    assert(cue != null, 'No Cue found in context, make sure to wrap your widget tree with a Cue widget.');
    return cue!;
  }

  @override
  bool updateShouldNotify(covariant CueScope oldWidget) {
    return animation != oldWidget.animation || isBounded != oldWidget.isBounded;
  }
}

/// Calculates the animation value based on the distance between current and target index.
/// Returns a value typically between 0.0 and 1.0.
typedef IndexDistanceCalculator = double Function(double offset, int targetIndex);
