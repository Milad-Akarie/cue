part of 'cue.dart';

class _IndexedCue extends Cue {
  const _IndexedCue({
    super.key,
    super.curve,
    super.debugLabel,
    required super.child,
    required this.targetIndex,
    required this.controller,
  }) : super._();

  final int targetIndex;
  final IndexedCueController controller;

  @override
  State<StatefulWidget> createState() => _IndexedCueState();
}

class _IndexedCueState extends _CueState<_IndexedCue> {
  final _animation = DrivenAnimation(value: 0.0);

  @override
  bool get isBounded => true;

  Listenable get listenable => widget.controller.tickListneable;
  @override
  void initState() {
    super.initState();
    listenable.addListener(_updateAnimation);
    _updateAnimation();
  }

  @override
  void dispose() {
    listenable.removeListener(_updateAnimation);
    super.dispose();
  }

  void _updateAnimation() {
    final value = widget.controller.valueFor(widget.targetIndex);
    final status = switch (value) {
      1.0 => AnimationStatus.completed,
      0.0 => AnimationStatus.dismissed,
      _ => value > _animation.value ? AnimationStatus.forward : AnimationStatus.reverse,
    };

    _animation.update(value, status);
  }

  @override
  void didUpdateWidget(covariant _IndexedCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller || listenable != oldWidget.controller.tickListneable) {
      listenable.removeListener(_updateAnimation);
      listenable.addListener(_updateAnimation);
      _updateAnimation();
    }
  }

  @override
  Animation<double> getAnimation(BuildContext context) => _animation;
}

mixin IndexedCueController implements Listenable {
  int get destinationIndex;

  int get lastSettledIndex;

  int get currentIndex;

  bool get animateAll => false;

  bool get isAnimating;

  double get globalOffset;

  double valueFor(int targetIndex) {
    if (!animateAll && isAnimating) {
      final isRelevant = targetIndex == lastSettledIndex || targetIndex == destinationIndex;
      if (!isRelevant) return 0.0;

      // Normalize progress across the full travel distance
      final totalDistance = (destinationIndex - lastSettledIndex).abs().toDouble();
      if (totalDistance == 0) return calculateOffsetFor(targetIndex);

      final progress = (globalOffset - lastSettledIndex).abs() / totalDistance;
      // lastSettledIndex animates from 1.0 → 0.0, destinationIndex from 0.0 → 1.0
      return targetIndex == destinationIndex ? progress.clamp(0.0, 1.0) : (1.0 - progress).clamp(0.0, 1.0);
    }
    return calculateOffsetFor(targetIndex);
  }

  Listenable get tickListneable => this;

  double calculateOffsetFor(int targetIndex) {
    final distance = (globalOffset - targetIndex).abs();
    return (1.0 - distance).clamp(0.0, 1.0);
  }
}

class CuePageController extends PageController with IndexedCueController {
  bool _isAnimating = false;
  int _destination = 0;

  CuePageController({
    super.initialPage,
    super.viewportFraction,
    super.keepPage,
    super.onAttach,
    super.onDetach,
    this.animateAll = false,
  }) {
    _lastSettledIndex = initialPage;
  }

  @override
  final bool animateAll;

  late int _lastSettledIndex = initialPage;

  @override
  bool get isAnimating => _isAnimating;

  @override
  int get currentIndex => globalOffset.round();

  @override
  int get lastSettledIndex => _lastSettledIndex;

  @override
  Future<void> animateToPage(int page, {required Duration duration, required Curve curve}) {
    _destination = page;
    _isAnimating = true;
    return super.animateToPage(page, duration: duration, curve: curve).whenComplete(() => _isAnimating = false);
  }

  @override
  void jumpToPage(int page) {
    _destination = page;
    super.jumpToPage(page);
  }

  @override
  int get destinationIndex {
    if (_isAnimating) return _destination;
    final current = globalOffset;
    return current > _lastSettledIndex ? current.ceil() : current.floor();
  }

  @override
  double get globalOffset {
    if (!hasClients) return initialPage.toDouble();
    return page ?? initialPage.toDouble();
  }

  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    position.isScrollingNotifier.addListener(_listenToSettledIndex);
  }

  void _listenToSettledIndex() {
    assert(hasClients, 'Controller must be attached to a ScrollPosition to track settled index.');
    if (!position.isScrollingNotifier.value) {
      _lastSettledIndex = globalOffset.round();
    }
  }

  @override
  void detach(ScrollPosition position) {
    position.isScrollingNotifier.removeListener(_listenToSettledIndex);
    super.detach(position);
  }
}

class CueTabController extends TabController with IndexedCueController {
  CueTabController({
    required super.length,
    super.initialIndex = 0,
    required super.vsync,
    this.animateAll = false,
  });

  int _destinationIndex = 0;

  @override
  final bool animateAll;

  @override
  int get lastSettledIndex => previousIndex;

  @override
  int get currentIndex => index;

  @override
  int get destinationIndex {
    if (indexIsChanging) return _destinationIndex;
    return index;
  }

  @override
  void animateTo(int value, {Duration? duration, Curve curve = Curves.ease}) {
    _destinationIndex = value;
    super.animateTo(value, duration: duration, curve: curve);
  }

  @override
  bool get isAnimating => indexIsChanging;

  @override
  Listenable get tickListneable => animation ?? this;

  @override
  double get globalOffset {
    if (animation == null) return index.toDouble();
    return animation!.value;
  }
}
