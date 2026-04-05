part of 'cue.dart';

/// {@template cue.on_scroll_visible}
/// A [Cue] that plays its animation once when the widget scrolls into the viewport.
///
/// The animation plays forward when revealed and stays complete — it does not
/// reverse when the widget scrolls back out.
///
/// [enabled] can be set to `false` to skip the reveal (jumps to completed state).
///
/// Must be inside a [Scrollable]. Does not support nested scrollables or
/// general-purpose visibility detection outside scroll views.
///
/// ## Scrub mode vs. play mode
///
/// Until the widget is revealed, the controller is in **scrub mode**: scroll
/// position drives progress directly, like seeking through a pre-baked
/// animation. [Actor] delays still apply — they shift when each element
/// appears within the 0–1 range.
///
/// Once the widget enters the viewport the controller switches to **play
/// mode** and the animation completes using the configured motion (spring or
/// timed). The motion specs have no effect while scrubbing.
///
/// ```dart
/// Cue.onScrollVisible(
///   acts: [.fadeIn(), .slideY(from: 0.2)],
///   child: MyWidget(),
/// )
/// ```
/// {@endtemplate}
class OnScrollVisibleCue extends Cue {
   /// Default constructor.
  const OnScrollVisibleCue({
    super.key,
    required super.child,
    super.debugLabel,
    this.enabled = true,
    super.acts,
  }) : super._();
  
  /// Whether the reveal animation is enabled. Set to `false` to skip the reveal and jump straight to the completed state.
  final bool enabled;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('enabled', value: enabled, ifFalse: 'disabled'));
  }

  @override
  State<StatefulWidget> createState() => OnScrollVisibleCueState();
}
/// State class for [OnScrollVisibleCue].
class OnScrollVisibleCueState extends CueState<OnScrollVisibleCue> with SingleTickerProviderStateMixin {
  @override
  String get debugName => 'OnScrollVisibleCue';

  @override
  CueController get controller => _controller;

  late final CueController _controller = CueController(vsync: this, motion: .linear(Duration(milliseconds: 500)));
  ScrollPosition? _scrollPosition;
  double? _cachedRevealedOffset;

 
 @override
  void initState() {
    super.initState();
    _controller.setProgress(1.0, forward: true);
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

 
 