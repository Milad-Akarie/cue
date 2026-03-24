part of 'cue.dart';

class CueScope extends InheritedWidget {
  const CueScope({
    super.key,
    required super.child,
    required this.timeline,
    required this.mainConfig,
    required this.reanimateFromCurrent,
  });

  final CueTimeline timeline;
  final TrackConfig mainConfig;
  final bool reanimateFromCurrent;

  static CueScope of(BuildContext context) {
    final cue = context.dependOnInheritedWidgetOfExactType<CueScope>();
    assert(cue != null, 'No Cue found in context, make sure to wrap your widget tree with a Cue widget.');
    return cue!;
  }

  @override
  bool updateShouldNotify(covariant CueScope oldWidget) {
    return timeline != oldWidget.timeline ||
        mainConfig != oldWidget.mainConfig ||
        reanimateFromCurrent != oldWidget.reanimateFromCurrent;
  }
}

