part of 'cue.dart';

class OnScrollCue extends Cue {
  const OnScrollCue({
    super.key,
    required super.child,
    super.debugLabel,
    super.acts,
  }) : super._();

  @override
  State<StatefulWidget> createState() => _OnScrollCueState();
}

class _OnScrollCueState extends CueState<OnScrollCue> with SingleTickerProviderStateMixin {
  @override
  String get debugName => 'OnScrollCue';

  @override
  CueTimeline get timeline => _controller.timeline;

  late final _controller = CueController(vsync: this, motion: .linear(1000.ms), progressDriven: true);

  ScrollPosition? _scrollPosition;
  double? _cachedRevealedOffset;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedRevealedOffset = null;
    if (mounted) {
      _subscribeToScrollPosition();
    }
  }

  void _subscribeToScrollPosition() {
    final position = Scrollable.maybeOf(context)?.position;
    if (position == null) {
      throw FlutterError('Cue.onScroll must be used inside a scrollable widget');
    }
    if (_scrollPosition != position) {
      _scrollPosition?.removeListener(_trackProgress);
      _scrollPosition = position;
      _scrollPosition!.addListener(_trackProgress);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _trackProgress());
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_trackProgress);
    _controller.dispose();
    super.dispose();
  }

  bool _firstFrame = true;
  void _trackProgress() {
    if (!mounted) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached || !renderObject.hasSize) {
      return;
    }

    final revealedOffset = _cachedRevealedOffset ??= RenderAbstractViewport.of(
      renderObject,
    ).getOffsetToReveal(renderObject, 0.0).offset;

    final viewportDimension = _scrollPosition!.viewportDimension;
    final childSize = renderObject.size;
    final childExtent = _scrollPosition!.axis == Axis.horizontal ? childSize.width : childSize.height;

    // The scroll range during which the child travels through the viewport.
    // Starts when child's leading edge enters the viewport bottom.
    // Ends when child's leading edge reaches the viewport top.
    final scrollRange = viewportDimension + childExtent;

    final scrollOffset = _scrollPosition!.pixels;
    final entryScrollOffset = revealedOffset + childExtent - viewportDimension;

    final rawProgress = scrollRange > 0 ? (scrollOffset - entryScrollOffset) / scrollRange : 0.0;
    final progress = rawProgress.clamp(0.0, 1.0);

    if (_firstFrame && progress != 0.0 && progress != 1.0) {
      _firstFrame = false;
      _controller.animateTo(progress, forward: true);
    } else {
      _controller.setProgress(progress, forward: true);
    }
  }
}
