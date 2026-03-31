part of 'cue.dart';

class OnScrollVisibleCue extends Cue {
  const OnScrollVisibleCue({
    super.key,
    required super.child,
    super.debugLabel,
    this.enabled = true,
    super.acts,
    this.mode = const ScrollAnimationMode.progress(),
  }) : super._();

  final bool enabled;

  final ScrollAnimationMode mode;

  @override
  State<StatefulWidget> createState() => OnScrollVisibleCueState();
}

class OnScrollVisibleCueState extends CueState<OnScrollVisibleCue> with SingleTickerProviderStateMixin {
  @override
  String get debugName => 'OnScrollVisibleCue';

  @override
  CueTimeline get timeline => _controller.timeline;

  late final CueController _controller;
  ScrollPosition? _scrollPosition;
  double? _cachedRevealedOffset;

  @override
  void initState() {
    super.initState();
    _controller = CueController(
      vsync: this,
      motion: widget.mode.motion ?? .defaultTime,
      reverseMotion: widget.mode.reverseMotion ?? widget.mode.motion ?? .defaultTime,
    );
  }

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
  void didUpdateWidget(covariant OnScrollVisibleCue oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (!widget.enabled) {
        _controller.setProgress(1.0, forward: true);
        _scrollPosition?.removeListener(_trackViiblity);
      } else {
        _subscribeToScrollPosition();
      }
    }
    if (widget.mode.motion != oldWidget.mode.motion || widget.mode.reverseMotion != oldWidget.mode.reverseMotion) {
      _controller.updateMotion(
        widget.mode.motion ?? .defaultTime,
        reverseMotion: widget.mode.reverseMotion ?? widget.mode.motion ?? .defaultTime,
      );
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

class ScrollAnimationMode {
  final double? fraction;
  final CueMotion? motion;
  final CueMotion? reverseMotion;

  const ScrollAnimationMode.progress() : fraction = null, motion = null, reverseMotion = null;

  const ScrollAnimationMode.trigger({
    this.fraction = 1.0,
    this.motion,
    this.reverseMotion,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ScrollAnimationMode &&
        other.fraction == fraction &&
        other.motion == motion &&
        other.reverseMotion == reverseMotion;
  }

  @override
  int get hashCode => fraction.hashCode ^ motion.hashCode ^ reverseMotion.hashCode;
}
