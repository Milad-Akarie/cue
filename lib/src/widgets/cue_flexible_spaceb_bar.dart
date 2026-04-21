import 'dart:ui' show clampDouble;

import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

/// A Cue version of [FlexibleSpaceBar], it drives cue animations based on the collapse progress of the flexible space bar.
///
/// Animations provided by FlexiableSpaceBarSettings are always forward.
///
/// Does **not** react to [SliverAppBar.expandedHeight] changes at runtime.
/// If you have a dynamic height wrap this widget with a [ValueKey] to force
/// re-instantiation when height changes:
///
/// ```dart
/// CueFlexibleSpaceBar(
///   key: ValueKey(dynamicHeight),
///   background: Actor(acts: [FadeIn()],
///      child: Image.asset('assets/image.jpg'))
///    ),
///   title: title,
/// )
/// ```
class CueFlexibleSpaceBar extends StatefulWidget {
  /// The widget displayed behind the sliver app bar (typically an image).
  ///
  /// Passed directly to [FlexibleSpaceBar.background].
  final Widget? background;

  /// The title widget displayed when expanded.
  ///
  /// Passed directly to [FlexibleSpaceBar.title].
  final Widget? title;

  /// Whether to center the title.
  ///
  /// Passed directly to [FlexibleSpaceBar.centerTitle].
  final bool? centerTitle;

  /// Padding for the title.
  ///
  /// Passed directly to [FlexibleSpaceBar.titlePadding].
  final EdgeInsetsGeometry? titlePadding;

  /// How the flexible space bar collapses when scrolling.
  ///
  /// Defaults to [CollapseMode.parallax].
  final CollapseMode collapseMode;

  /// Stretch modes that define how the flexible space expands overscroll.
  ///
  /// Passed directly to [FlexibleSpaceBar.stretchModes].
  /// Defaults to `[StretchMode.zoomBackground]`.
  final List<StretchMode> stretchModes;

  /// Scale factor for the title when expanded.
  ///
  /// Passed directly to [FlexibleSpaceBar.expandedTitleScale].
  /// Defaults to `1.5`.
  final double expandedTitleScale;

  /// Creates a [CueFlexibleSpaceBar].
  const CueFlexibleSpaceBar({
    super.key,
    this.background,
    this.title,
    this.centerTitle,
    this.titlePadding,
    this.collapseMode = CollapseMode.parallax,
    this.stretchModes = const <StretchMode>[StretchMode.zoomBackground],
    this.expandedTitleScale = 1.5,
  });

  @override
  State<CueFlexibleSpaceBar> createState() => _CueFlexibleSpaceBarState();
}

class _CueFlexibleSpaceBarState extends State<CueFlexibleSpaceBar> with SingleTickerProviderStateMixin {
  late final _controller = CueController(vsync: this, motion: .linear(500.ms));

  /// The scroll position this widget is currently listening to.
  ScrollPosition? _scrollPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scrollable = Scrollable.maybeOf(context)?.position;
    assert(
      scrollable != null,
      'CueFlexibleSpaceBar must be placed inside a Scrollable '
      '(typically SliverAppBar / CustomScrollView).',
    );
    if (scrollable == null) return;
    if (scrollable == _scrollPosition) return;
    _scrollPosition?.removeListener(_onScroll);
    _scrollPosition = scrollable;
    _scrollPosition!.addListener(_onScroll);
  }

  void _onScroll() {
    final settings = context.getInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    assert(settings != null, 'FlexibleSpaceBarSettings not found in context');
    if (settings == null) {
      _controller.setProgress(1.0, forward: true);
      return;
    }
    final double deltaExtent = settings.maxExtent - settings.minExtent;
    final double t = clampDouble(
      1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent,
      0.0,
      1.0,
    );
    if (t == _controller.value) return;
    _controller.setProgress(t, forward: true);
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Cue(
      debugLabel: 'CueFlexibleSpaceBar',
      controller: _controller,
      child: FlexibleSpaceBar(
        background: widget.background,
        title: widget.title,
        centerTitle: widget.centerTitle,
        titlePadding: widget.titlePadding,
        collapseMode: widget.collapseMode,
        stretchModes: widget.stretchModes,
        expandedTitleScale: widget.expandedTitleScale,
      ),
    );
  }
}
