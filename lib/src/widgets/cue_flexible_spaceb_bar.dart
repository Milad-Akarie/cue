import 'dart:ui' show clampDouble;

import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

class CueFlexibleSpaceBar extends StatefulWidget {
  final Widget? background;
  final Widget? title;
  final bool? centerTitle;
  final EdgeInsetsGeometry? titlePadding;
  final CollapseMode collapseMode;
  final List<StretchMode> stretchModes;
  final double expandedTitleScale;

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
