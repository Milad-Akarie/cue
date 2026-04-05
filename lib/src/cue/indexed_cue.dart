part of 'cue.dart';

/// {@template cue.indexed}
/// A [Cue] driven by an [IndexedCueController] at a specific [index].
///
/// Primarily intended for use with [PageView] via [CuePageController], though
/// it works with any [IndexedCueController] implementation (see also
/// [CueTabController] and [CueIndexController]).
///
/// Each [IndexedCue] listens to a shared [IndexedCueController] and maps the
/// controller's global offset to a per-item 0–1 progress. Items below the
/// offset animate forward; at or above it they animate in reverse.
///
/// ## Scrub mode vs. play mode
///
/// When the [IndexedCueController] sets its offset directly (scrubbing — e.g.
/// while the user drags between pages), each item's controller is in **scrub
/// mode**: the offset is mapped to a 0–1 progress value and the motion is
/// scrubbed as a timeline rather than played in real time. The motion you
/// configure still shapes the animation curve — it just gets seeked through
/// instead of ticked forward.
///
/// When the controller plays forward or reverse (play mode — e.g. after the
/// drag ends and the page snaps), the motion specs and [Actor] delays take
/// effect — delays shift when each item enters and exits, producing the
/// staggered sequence.
///
/// ## Example — PageView with per-page Actor tree
///
/// Place a single [Cue.indexed] at the root of each page. Multiple [Actor]s
/// anywhere in that page's subtree are all driven by the same per-page
/// controller:
///
/// ```dart
/// final controller = CuePageController();
///
/// PageView(
///   controller: controller,
///   children: [
///     for (int i = 0; i < pages.length; i++)
///       Cue.indexed(
///         controller: controller,
///         index: i,
///         motion: .smooth(),
///         child: Column(
///           children: [
///             Actor(
///               acts: [.fadeIn(), .slideY(from: 0.2)],
///               child: PageTitle(pages[i]),
///             ),
///             Actor(
///               acts: [.fadeIn(), .slideY(from: 0.2)],
///               delay: 60.ms,
///               child: PageBody(pages[i]),
///             ),
///             Actor(
///               acts: [.fadeIn(), .scale(from: 0.9)],
///               delay: 120.ms,
///               child: PageFooter(pages[i]),
///             ),
///           ],
///         ),
///       ),
///   ],
/// )
/// ```
/// {@endtemplate}
class IndexedCue extends Cue {
  const IndexedCue({
    super.key,
    super.debugLabel,
    required super.child,
    required this.index,
    required this.controller,
    super.acts,
  }) : super._();

  final int index;
  final IndexedCueController controller;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('index', index));
  }

  @override
  State<StatefulWidget> createState() => _IndexedCueState();
}

class _IndexedCueState extends CueState<IndexedCue> with SingleTickerProviderStateMixin {
  
  late final _controller = CueController(vsync: this, motion: const .linear(Duration(milliseconds: 500)));

  @override
  String get debugName => 'IndexedCue';

  @override
  String get _debugId => '$debugName-${widget.controller.hashCode}-${widget.index}';

  Listenable get listenable => widget.controller.tickListenable;

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
    final forward = widget.controller.globalOffset < widget.index;
    final value = widget.controller.valueFor(widget.index);
    _controller.setProgress(value, forward: forward);
  }

  @override
  void didUpdateWidget(covariant IndexedCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller || listenable != oldWidget.controller.tickListenable) {
      listenable.removeListener(_updateAnimation);
      listenable.addListener(_updateAnimation);
      _updateAnimation();
    }
  }

  @override
  CueController get controller => _controller;
}

 
/// The controller protocol for [IndexedCue].
///
/// Exposes a [globalOffset] — a fractional index value (e.g. `1.5` means
/// halfway between item 1 and item 2) — that each [IndexedCue] uses to
/// compute its own 0–1 animation progress.
///
/// Three concrete implementations are provided:
///
/// | Class | Use with |
/// |---|---|
/// | [CuePageController] | [PageView] |
/// | [CueTabController] | [TabBarView] / [TabController] |
/// | [CueIndexController] | Custom index-driven UI |
///
/// Implement this mixin to integrate [IndexedCue] with any other
/// index-based controller.
mixin IndexedCueController implements Listenable {
  /// The index the controller is currently animating **toward**.
  ///
  /// While animating, this is the target page/tab. When idle it equals
  /// [currentIndex].
  int get destinationIndex;

  /// The index where the controller was **before** the current animation started.
  ///
  /// Used together with [destinationIndex] to normalize per-item progress
  /// when jumping multiple indices at once.
  int get lastSettledIndex;

  /// The index nearest to the current [globalOffset], rounded to the closest integer.
  int get currentIndex;

  /// Whether to animate **all** items simultaneously during a transition,
  /// or only the departing and arriving items.
  ///
  /// Defaults to `false` — only [lastSettledIndex] and [destinationIndex]
  /// receive a non-zero progress value while animating, which keeps
  /// off-screen items at their resting state and avoids unnecessary repaints.
  ///
  /// Set to `true` when items are partially visible (e.g. a [PageView] with
  /// `viewportFraction < 1`) so that surrounding pages also animate.
  bool get animateAll => false;

  /// Whether the controller is currently mid-animation.
  bool get isAnimating;

  /// The fractional index position — e.g. `1.5` while halfway between index 1
  /// and index 2, `2.0` when settled on index 2.
  ///
  /// This is the primary value [IndexedCue] reads on every notification to
  /// compute each item's progress.
  double get globalOffset;

  /// Returns the 0–1 animation progress for [targetIndex] given the current
  /// [globalOffset].
  ///
  /// When [animateAll] is `false` and the controller [isAnimating], only
  /// [lastSettledIndex] and [destinationIndex] receive a non-zero value;
  /// all other indices return `0.0`.
  double valueFor(int targetIndex) {
    if (!animateAll && isAnimating) {
      final isRelevant = targetIndex == lastSettledIndex || targetIndex == destinationIndex;
      if (!isRelevant) return 0.0;
      return calculateOffsetFor(targetIndex, isDestination: targetIndex == destinationIndex);
    }
    return calculateOffsetFor(targetIndex);
  }

  /// The [Listenable] that [IndexedCue] subscribes to for progress updates.
  ///
  /// Defaults to `this`. Override when the controller wraps an inner
  /// animation object whose tick rate should drive updates — e.g.
  /// [CueTabController] returns `animation` so updates fire every frame
  /// during a tab transition rather than only at discrete index changes.
  Listenable get tickListenable => this;

  /// Core offset-to-progress mapping for [targetIndex].
  ///
  /// When [isDestination] is `false`, progress is `1 - distance` clamped to
  /// `[0, 1]` — the item fades/slides in as [globalOffset] approaches it and
  /// out as it moves away.
  ///
  /// When [isDestination] is `true` and the jump spans more than one index,
  /// progress is normalized across the full travel distance so the active and
  /// destination items animate in parallel regardless of how many pages are
  /// skipped.
  double calculateOffsetFor(int targetIndex, {bool isDestination = false}) {
    final distance = (globalOffset - targetIndex).abs();
    if (!isDestination) return (1.0 - distance).clamp(0.0, 1.0);

    // Normalize progress across the full travel distance so active and
    // destination indexes animate in parallel regardless of page distance.
    final totalDistance = (destinationIndex - lastSettledIndex).abs().toDouble();
    if (totalDistance <= 1.0) return (1.0 - distance).clamp(0.0, 1.0);

    final progress = ((globalOffset - lastSettledIndex) / (destinationIndex - lastSettledIndex)).clamp(0.0, 1.0);
    return isDestination ? progress : 1.0 - progress;
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
  Listenable get tickListenable => animation ?? this;

  @override
  double get globalOffset {
    if (animation == null) return index.toDouble();
    return animation!.value;
  }
}

class CueIndexController with ChangeNotifier, IndexedCueController {
  CueIndexController({
    required this.length,
    required TickerProvider vsync,
    int initialIndex = 0,
    Duration duration = const Duration(milliseconds: 300),
    Duration? reverseDuration,
    this.animateAll = false,
  }) : assert(length > 0, 'length must be greater than 0'),
       assert(
         initialIndex >= 0 && initialIndex < length,
         'initialIndex must be in range [0, length)',
       ),
       _currentIndex = initialIndex,
       _destinationIndex = initialIndex,
       _lastSettledIndex = initialIndex {
    _animationController = AnimationController(
      vsync: vsync,
      duration: duration,
      reverseDuration: reverseDuration,
      lowerBound: 0.0,
      upperBound: (length - 1).toDouble(),
      value: initialIndex.toDouble(),
      debugLabel: 'CueIndexController',
    )..addListener(notifyListeners);
  }

  /// The total number of items managed by this controller.
  final int length;

  @override
  final bool animateAll;

  late final AnimationController _animationController;

  int _currentIndex;
  int _destinationIndex;
  int _lastSettledIndex;

  /// The underlying [AnimationController] used to drive the animation.
  AnimationController get animationController => _animationController;

  @override
  int get currentIndex => _currentIndex;

  @override
  int get destinationIndex => _destinationIndex;

  @override
  int get lastSettledIndex => _lastSettledIndex;

  @override
  bool get isAnimating => _animationController.isAnimating;

  @override
  double get globalOffset => _animationController.value;

  @override
  Listenable get tickListenable => _animationController;

  /// Animates to the given [index].
  ///
  /// If an animation is already in progress, it is cancelled first. The
  /// cancelled animation's [Future] resolves with a [TickerCanceled] error,
  /// which is silently swallowed — the controller snaps its internal state to
  /// the nearest integer index at the point of cancellation.
  ///
  /// The [duration] and [curve] parameters override the controller defaults
  /// for this specific animation.
  Future<void> animateTo(
    int index, {
    Duration? duration,
    Curve curve = Curves.linear,
  }) {
    assert(index >= 0 && index < length, 'index must be in range [0, length)');
    _lastSettledIndex = _currentIndex;
    _destinationIndex = index;
    notifyListeners();
    // Calling animateTo on the underlying AnimationController while it is
    // already running will cancel the previous TickerFuture, causing its
    // .orCancel future to complete with a TickerCanceled error. The catchError
    // below handles that case for the *new* future as well (e.g. when jumpTo
    // or dispose is called while this animation is in flight).
    return _animationController
        .animateTo(
          index.toDouble(),
          duration: duration,
          curve: curve,
        )
        .orCancel
        .then((_) {
          _currentIndex = index;
          _lastSettledIndex = index;
          notifyListeners();
        })
        .catchError(
          (Object _) {
            // Animation was cancelled (e.g. jumpTo, stop, or dispose was called).
            // Snap internal state to the nearest integer at the current position.
            _currentIndex = _animationController.value.round();
            _lastSettledIndex = _currentIndex;
            _destinationIndex = _currentIndex;
          },
          test: (e) => e is TickerCanceled,
        );
  }

  /// Stops the current animation at its current position.
  ///
  /// The [currentIndex] and [lastSettledIndex] are snapped to the nearest
  /// integer index. Any in-flight [animateTo] future will complete with a
  /// [TickerCanceled] error that is silently handled.
  void stop() {
    _animationController.stop();
    _currentIndex = _animationController.value.round();
    _destinationIndex = _currentIndex;
    _lastSettledIndex = _currentIndex;
    notifyListeners();
  }

  /// Jumps immediately to the given [index] without animation.
  ///
  /// Any in-flight animation is cancelled before the jump. The cancelled
  /// animation's future is silently discarded.
  void jumpTo(int index) {
    assert(index >= 0 && index < length, 'index must be in range [0, length)');
    _animationController.stop();
    _animationController.value = index.toDouble();
    _currentIndex = index;
    _destinationIndex = index;
    _lastSettledIndex = index;
    notifyListeners();
  }

  /// Releases the resources used by this controller.
  ///
  /// Must be called when the controller is no longer needed, typically in
  /// [State.dispose].
  @override
  void dispose() {
    _animationController.removeListener(notifyListeners);
    _animationController.dispose();
    super.dispose();
  }
}
