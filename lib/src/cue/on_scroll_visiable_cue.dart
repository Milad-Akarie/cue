part of 'cue.dart';

class _OnScrollVisibleCue extends SelfAnimatedCue {
  const _OnScrollVisibleCue({
    required Key super.key,
    required super.child,
    super.debugLabel,
    super.motion,
    this.enabled = true,
    this.visibilityThreshold = 0.0,
  }) : assert(visibilityThreshold >= 0 && visibilityThreshold <= 1, 'visibilityThreshold must be between 0 and 1');

  final bool enabled;
  final double visibilityThreshold;

  @override
  State<StatefulWidget> createState() => _OnVisibleCueState();
}

class _OnVisibleCueState extends SelfAnimatedState<_OnScrollVisibleCue> {
  bool? _wasVisible;

  @override
  String get debugName => 'OnScrollVisibleCue';

  @override
  void onControllerReady() {
    // Assume visible on mount so the widget renders at its final state
    // until the VisibilityDetector fires and corrects if needed.
    controller.value = 1.0;
  }

  void _onVisibilityChanged(bool isVisible) {
    if (_wasVisible == null) {
      if (!isVisible && widget.enabled) {
        controller.value = 0.0;
      }
      _wasVisible = isVisible;
      return;
    }
    if (_wasVisible == isVisible) return;

    // Only animate if going from not visible to invisible.
    if (isVisible) {
      controller.forward();
    } else {
      if (widget.visibilityThreshold == 0) {
        // no need to animate an invisible widget, just jump to the end state.
        controller.value = 0.0;
      } else {
        controller.reverse();
      }
    }
    _wasVisible = isVisible;
  }

  ScrollPosition? _scrollPosition;
  double? _cachedRevealedOffset;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedRevealedOffset = null;
    if (!widget.enabled) return;
    _subscribeToScrollPosition();
  }

  void _subscribeToScrollPosition() {
    final position = Scrollable.maybeOf(context)?.position;
    if (position == null) {
      throw FlutterError('Cue.onScrollVisible must be used inside a scrollable widget');
    }
    if (_scrollPosition != position) {
      _scrollPosition?.removeListener(_checkVisibility);
      _scrollPosition = position;
      _scrollPosition!.addListener(_checkVisibility);
    }
    _checkVisibility();
  }

  @override
  void didUpdateWidget(covariant _OnScrollVisibleCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (!widget.enabled) {
        controller.value = 1.0;
        _scrollPosition?.removeListener(_checkVisibility);
      } else {
        _subscribeToScrollPosition();
      }
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_checkVisibility);
    super.dispose();
  }

  void _checkVisibility() {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) return;

    if (!renderObject.attached || _scrollPosition == null) return;

    final revealedOffset = _cachedRevealedOffset ??= RenderAbstractViewport.of(
      renderObject,
    ).getOffsetToReveal(renderObject, 0.0).offset;

    // Widget is visible if its revealed offset is within current scroll range
    final scrollOffset = _scrollPosition!.pixels;
    final viewportDimension = _scrollPosition!.viewportDimension;

    final itemExtent = _scrollPosition!.axis == Axis.horizontal ? renderObject.size.width : renderObject.size.height;

    // Compute how many pixels of the widget overlap with the viewport
    final visibleStart = math.max(revealedOffset, scrollOffset);
    final visibleEnd = math.min(revealedOffset + itemExtent, scrollOffset + viewportDimension);
    final visibleExtent = visibleEnd - visibleStart;

    // Widget is considered visible when the visible fraction meets or exceeds the threshold.
    // A threshold of 0.0 means any overlap counts as visible.
    final visibleFraction = itemExtent > 0 ? (visibleExtent / itemExtent).clamp(0.0, 1.0) : 0.0;
    final isVisible = visibleFraction > widget.visibilityThreshold;
    _onVisibilityChanged(isVisible);
  }
}
