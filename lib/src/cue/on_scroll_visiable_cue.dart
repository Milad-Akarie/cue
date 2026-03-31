part of 'cue.dart';

class _OnScrollVisibleCue extends Cue {
  const _OnScrollVisibleCue({
    super.key,
    required super.child,
    super.debugLabel,
    this.enabled = true,
    super.acts,
  }) : super._();

  final bool enabled;

  @override
  State<StatefulWidget> createState() => _OnVisibleCueState();
}

class _OnVisibleCueState extends CueState<_OnScrollVisibleCue> with SingleTickerProviderStateMixin {
  @override
  String get debugName => 'OnScrollVisibleCue';

  @override
  CueTimeline get timeline => _controller.timeline;

  late final _controller = CueController(
    motion: const .linear(Duration(milliseconds: 300)),
    vsync: this,
    progressDriven: true,
  );

  ScrollPosition? _scrollPosition;
  double? _cachedRevealedOffset;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedRevealedOffset = null;
    if (!widget.enabled) return;

    if (mounted) {
      _subscribeToScrollPosition();
    }
  }

  void _subscribeToScrollPosition() {
    final position = Scrollable.maybeOf(context)?.position;
    if (position == null) {
      throw FlutterError('Cue.onScrollVisible must be used inside a scrollable widget');
    }
    if (_scrollPosition != position) {
      _scrollPosition?.removeListener(_trackViiblity);
      _scrollPosition = position;
      _scrollPosition!.addListener(_trackViiblity);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _trackViiblity());
  }

  @override
  void didUpdateWidget(covariant _OnScrollVisibleCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (!widget.enabled) {
        _controller.setProgress(1.0, forward: true);
        _scrollPosition?.removeListener(_trackViiblity);
      } else {
        _subscribeToScrollPosition();
      }
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_trackViiblity);
    _controller.dispose();
    super.dispose();
  }

  bool _isFirstFrame = true;

  void _trackViiblity() async {
    if (!mounted) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached || !renderObject.hasSize) {
      _controller.setProgress(1.0, forward: true);
      return;
    }

    final revealedOffset = _cachedRevealedOffset ??= RenderAbstractViewport.of(
      renderObject,
    ).getOffsetToReveal(renderObject, 0.0).offset;
    final renderSize = renderObject.size;

    // Widget is visible if its revealed offset is within current scroll range
    final scrollOffset = _scrollPosition!.pixels;
    final viewportDimension = _scrollPosition!.viewportDimension;

    final itemExtent = _scrollPosition!.axis == Axis.horizontal ? renderSize.width : renderSize.height;

    // Compute how many pixels of the widget overlap with the viewport
    final visibleStart = math.max(revealedOffset, scrollOffset);
    final visibleEnd = math.min(revealedOffset + itemExtent, scrollOffset + viewportDimension);
    final visibleExtent = visibleEnd - visibleStart;

    final visibleFraction = itemExtent > 0 ? (visibleExtent / itemExtent) : 0.0;
    final forward = (scrollOffset + viewportDimension / 2) < revealedOffset;

    final target = visibleFraction.clamp(0.0, 1.0);

    if (target != 1 && target != 0.0 && _isFirstFrame) {
      _isFirstFrame = false;
      _controller.animateTo(target, forward: forward);
    } else {
      _controller.setProgress(target, forward: forward);
    }
  }
}
