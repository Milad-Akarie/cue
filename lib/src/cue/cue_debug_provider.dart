import 'package:cue/cue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CueDebugTools extends StatefulWidget {
  const CueDebugTools({super.key, required this.child});

  final Widget child;

  @override
  State<CueDebugTools> createState() => _CueDebugToolsState();

  static bool isWrappedByDebugProvider(BuildContext context) {
    return context.findAncestorWidgetOfExactType<CueDebugTools>() != null;
  }

  static void openOverlay(BuildContext context) {
    final provider = context.findAncestorStateOfType<_CueDebugToolsState>();
    provider?.openOverlay(context);
  }

  static VoidCallback? attachDebugTarget(
    BuildContext context, {
    required String id,
    required Duration duration,
    Curve? curve,
    CueSimulation? simulation,
  }) {
    final provider = context.findAncestorStateOfType<_CueDebugToolsState>();
    provider?.openOverlay(context);
    return provider?.attachDebugTarget(
      context,
      id: id,
      curve: curve,
      duration: duration,
      simulation: simulation,
    );
  }

  static DebugDataProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DebugDataProvider>();
    if (scope == null) {
      throw Exception('No CueDebugTools found in context. Make sure to wrap your widget tree with CueDebugTools.');
    }
    return scope;
  }
}

class _CueDebugToolsState extends State<CueDebugTools> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _overlayData = ValueNotifier<_OverlayData>(
    _OverlayData(
      speedMultiplier: 1,
      isLooping: false,
      isMinimized: true,
      verticalOffset: 0,
      isSelectMode: false,
      activeTargetId: null,
      highlightedTargetId: null,
      targets: const {},
    ),
  );

  OverlayEntry? _entry;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _startAutoPlay() {
    if (_overlayData.value.isLooping) {
      _controller.repeat();
    } else {
      double startValue = _controller.value;
      if (startValue == 1.0) {
        startValue = 0.0;
      }
      _controller.forward(from: startValue);
    }
  }

  VoidCallback attachDebugTarget(
    BuildContext context, {
    required String id,
    required Duration duration,
    Curve? curve,
    CueSimulation? simulation,
  }) {
    final target = _DebugTarget(
      id: id,
      curve: curve,
      simulation: simulation,
      duration: duration,
    );
    _overlayData.value = _overlayData.value.copyWith(
      targets: {
        ..._overlayData.value.targets,
        id: target,
      },
      activeTargetId: _overlayData.value.activeTargetId ?? id,
    );

    _controller.duration = duration;

    _overlayData.value = _overlayData.value.copyWith(
      isMinimized: false,
      isSelectMode: false,
      activeTargetId: id,
    );
    void deattachCallback() {
      final updatedTargets = Map<String, _DebugTarget>.from(_overlayData.value.targets)..remove(id);
      _overlayData.value = _overlayData.value.copyWith(targets: updatedTargets);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.value = 0;
      });
    }

    if (_entry != null) return deattachCallback;
    openOverlay(context);
    return deattachCallback;
  }

  void openOverlay(BuildContext context) {
    if (_entry != null) return;
    _entry = OverlayEntry(
      builder: (context) {
        return _DebugOverlay(
          controller: _controller,
          onPlay: _startAutoPlay,
          overlayData: _overlayData,
          baseDuration: const Duration(milliseconds: 500),
        );
      },
    );
    Overlay.of(context).insert(_entry!);
  }

  @override
  void dispose() {
    _controller.dispose();
    _entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _overlayData,
      builder: (context, _) {
        return DebugDataProvider(
          highlightedTargetId: _overlayData.value.highlightedTargetId,
          activeTargetId: _overlayData.value.activeTargetId,
          animation: _controller.view,
          isMinimized: _overlayData.value.isMinimized,
          isSelectMode: _overlayData.value.isSelectMode,
          child: widget.child,
        );
      },
    );
  }
}

class _DebugOverlay extends StatefulWidget {
  const _DebugOverlay({
    required this.controller,
    required this.onPlay,
    required this.baseDuration,
    required this.overlayData,
  });

  final ValueNotifier<_OverlayData> overlayData;

  final AnimationController controller;
  final VoidCallback onPlay;
  final Duration baseDuration;

  @override
  State<_DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<_DebugOverlay> {
  AnimationController get _controller => widget.controller;

  ValueNotifier<_OverlayData> get _dataNotifier => widget.overlayData;

  _OverlayData get _data => widget.overlayData.value;

  void _togglePlayPause() {
    if (_controller.isAnimating) {
      _controller.stop();
    } else {
      widget.onPlay();
    }
  }

  void _onSliderChanged(double value) {
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _controller.value = value;
  }

  void _toggleLoop() {
    _dataNotifier.value = _data.copyWith(isLooping: !_data.isLooping);
    _controller.stop();
    widget.onPlay();
  }

  void _toggleSlowMode() {
    final targetSpeed = _data.speedMultiplier == 1 ? 5 : 1;
    _setSpeed(targetSpeed);
  }

  void _setSpeed(int multiplier) {
    _dataNotifier.value = _data.copyWith(speedMultiplier: multiplier);
    final wasAnimating = _controller.isAnimating;
    _controller.duration = Duration(
      microseconds: (widget.baseDuration.inMicroseconds * multiplier).round(),
    );
    if (wasAnimating) {
      _controller.stop();
    }
    widget.onPlay();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: widget.overlayData,
      builder: (context, _) {
        return GestureDetector(
          onVerticalDragUpdate: (details) {
            final maxTop = MediaQuery.sizeOf(context).height - 240;
            final minTop = 0.0;
            _dataNotifier.value = _data.copyWith(
              verticalOffset:
                  _data.verticalOffset +
                  details.delta.dy.clamp(
                    minTop - _data.verticalOffset,
                    maxTop - _data.verticalOffset,
                  ),
            );
          },
          child: Transform.translate(
            offset: Offset(0, _data.verticalOffset),
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 200),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(opacity: value, child: child);
              },
              child: Align(
                alignment: Alignment.topLeft,
                child: SafeArea(
                  child: IconTheme(
                    data: theme.iconTheme.copyWith(color: theme.primaryColor, size: 20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Material(
                        color: theme.colorScheme.surface,
                        animationDuration: const Duration(milliseconds: 200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            _dataNotifier.value.isMinimized ? 32 : 16,
                          ),
                          side: BorderSide(
                            color: theme.colorScheme.onSurface.withValues(alpha: .52),
                            width: .5,
                          ),
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 200),
                            alignment: .topLeft,
                            child: ListenableBuilder(
                              listenable: widget.controller,
                              builder: (context, _) {
                                if (_data.isMinimized) {
                                  return IconButton(
                                    style: IconButton.styleFrom(
                                      tapTargetSize: .shrinkWrap,
                                      shape: CircleBorder(),
                                      minimumSize: .square(40),
                                    ),
                                    icon: Icon(Icons.play_circle),
                                    onPressed: () {
                                      _dataNotifier.value = _data.copyWith(
                                        isMinimized: false,
                                        isSelectMode: _data.activeTargetId == null,
                                      );
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  );
                                }

                                return Padding(
                                  padding: const .fromLTRB(8, 4, 8, 8),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              widget.controller.isAnimating
                                                  ? Icons.pause_circle_outline_rounded
                                                  : Icons.play_circle_outline_rounded,
                                            ),
                                            style: IconButton.styleFrom(iconSize: 32),
                                            onPressed: _togglePlayPause,
                                            padding: EdgeInsets.zero,
                                          ),
                                          SizedBox(width: 4),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Text(
                                                  '${widget.controller.value.toStringAsFixed(2)} ',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontFamily: 'monospace',
                                                    fontFeatures: [
                                                      FontFeature.tabularFigures(),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 16,
                                                  height: 14,
                                                  child: VerticalDivider(
                                                    thickness: 1.2,
                                                  ),
                                                ),
                                                Builder(
                                                  builder: (context) {
                                                    final totalInMs = (widget.controller.duration?.inMilliseconds ?? 0);
                                                    final fixedWidth = totalInMs.toString().length;
                                                    final currentInMs = ((widget.controller.value * totalInMs).round())
                                                        .toString()
                                                        .padLeft(fixedWidth, '0');
                                                    return Text(
                                                      '${currentInMs}ms',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontFamily: 'monospace',
                                                        fontFeatures: [
                                                          FontFeature.tabularFigures(),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            style: IconButton.styleFrom(tapTargetSize: .shrinkWrap),
                                            constraints: const BoxConstraints(),
                                            onPressed: _data.isSelectMode
                                                ? null
                                                : () async {
                                                    _dataNotifier.value = _data.copyWith(isSelectMode: true);
                                                    final RenderBox button = context.findRenderObject() as RenderBox;
                                                    final Offset position = button.localToGlobal(Offset.zero);
                                                    final rect = position & button.size;
                                                    showGeneralDialog(
                                                      context: context,
                                                      barrierDismissible: true,
                                                      barrierLabel: 'Select Target',
                                                      barrierColor: Colors.black.withValues(alpha: 0.05),
                                                      pageBuilder: (context, animation, secondaryAnimation) {
                                                        return Material(
                                                          color: Colors.transparent,
                                                          child: Align(
                                                            alignment: Alignment.topLeft,
                                                            child: Transform.translate(
                                                              offset: Offset(rect.right - 220, rect.bottom + 8),
                                                              child: Container(
                                                                width: 220,
                                                                constraints: BoxConstraints(
                                                                  maxHeight: 400,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                  color: theme.colorScheme.surface,
                                                                  borderRadius: BorderRadius.circular(16),
                                                                ),
                                                                child: ListenableBuilder(
                                                                  listenable: _dataNotifier,
                                                                  builder: (context, _) {
                                                                    return Column(
                                                                      mainAxisSize: MainAxisSize.min,
                                                                      children: [
                                                                        ListView(
                                                                          padding: EdgeInsets.only(top: 8, bottom: 8),
                                                                          shrinkWrap: true,
                                                                          children: [
                                                                            for (final target in _data.targets.values)
                                                                              GestureDetector(
                                                                                child: Container(
                                                                                  alignment: Alignment.centerLeft,
                                                                                  color:
                                                                                      _data.highlightedTargetId ==
                                                                                          target.id
                                                                                      ? Colors.orange.withValues(
                                                                                          alpha: .1,
                                                                                        )
                                                                                      : null,
                                                                                  padding: const EdgeInsets.symmetric(
                                                                                    horizontal: 12,
                                                                                    vertical: 4,
                                                                                  ),
                                                                                  child: Text(
                                                                                    target.id,
                                                                                    style: TextStyle(fontSize: 13),
                                                                                    maxLines: 1,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                ),
                                                                                onTap: () {
                                                                                  final isHighlighted =
                                                                                      _data.highlightedTargetId ==
                                                                                      target.id;
                                                                                  if (isHighlighted) {
                                                                                    _dataNotifier.value = _data
                                                                                        .copyWith(
                                                                                          activeTargetId: target.id,
                                                                                          isSelectMode: false,
                                                                                          highlightedTargetId: null,
                                                                                        );
                                                                                    Navigator.of(context).pop();
                                                                                  } else {
                                                                                    _dataNotifier.value = _data
                                                                                        .copyWith(
                                                                                          highlightedTargetId:
                                                                                              target.id,
                                                                                        );
                                                                                  }
                                                                                },
                                                                              ),
                                                                          ],
                                                                        ),
                                                                        OutlinedButton(
                                                                          onPressed: () {
                                                                            if (_data.highlightedTargetId != null) {
                                                                              _dataNotifier.value = _data.copyWith(
                                                                                activeTargetId:
                                                                                    _data.highlightedTargetId,
                                                                                isSelectMode: false,
                                                                                highlightedTargetId: null,
                                                                              );
                                                                            }
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          style: OutlinedButton.styleFrom(
                                                                            tapTargetSize: .shrinkWrap,
                                                                            minimumSize: Size(180, 32),
                                                                          ),
                                                                          child: Text('Done'),
                                                                        ),
                                                                        SizedBox(height: 12),
                                                                      ],
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ).whenComplete(
                                                      () => _dataNotifier.value = _data.copyWith(isSelectMode: false),
                                                    );
                                                  },

                                            icon: Icon(
                                              Icons.ads_click,
                                              color: _data.isSelectMode
                                                  ? Colors.blue
                                                  : IconTheme.of(context).color?.withValues(alpha: .4),
                                            ),
                                          ),
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            style: IconButton.styleFrom(tapTargetSize: .shrinkWrap),
                                            onPressed: _toggleSlowMode,
                                            icon: Icon(
                                              Icons.alarm_rounded,
                                              color: _data.isSlowMode
                                                  ? Colors.blue
                                                  : IconTheme.of(context).color?.withValues(alpha: .4),
                                            ),
                                          ),
                                          IconButton(
                                            style: IconButton.styleFrom(
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            icon: Icon(
                                              Icons.change_circle_outlined,
                                              color:
                                                  IconTheme.of(
                                                    context,
                                                  ).color?.withValues(
                                                    alpha: _data.isLooping ? 1 : .4,
                                                  ),
                                            ),
                                            onPressed: _toggleLoop,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          SizedBox(
                                            width: 16,
                                            height: 14,
                                            child: VerticalDivider(
                                              thickness: 1.2,
                                            ),
                                          ),
                                          IconButton(
                                            style: IconButton.styleFrom(
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            icon: Icon(
                                              Icons.remove_circle_outline,
                                            ),
                                            onPressed: () {
                                              _dataNotifier.value = _data.copyWith(
                                                isMinimized: true,
                                              );
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          SizedBox(width: 8),
                                        ],
                                      ),

                                      Container(
                                        padding: const .fromLTRB(20, 12, 20, 4),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surfaceContainer,
                                          borderRadius: .circular(10),
                                        ),
                                        child: SliderTheme(
                                          data: SliderThemeData(
                                            trackShape: _TimelineTickMarkShape(start: 0, end: 1),
                                            tickMarkShape: SliderTickMarkShape.noTickMark,
                                            inactiveTrackColor: Theme.of(
                                              context,
                                            ).colorScheme.onSurface.withValues(alpha: .6),
                                            thumbShape: _NeedleThumb(height: 60),
                                          ),
                                          child: Slider(
                                            padding: EdgeInsets.zero,
                                            value: widget.controller.value,
                                            activeColor: Colors.transparent,
                                            thumbColor: theme.colorScheme.primary,
                                            overlayColor: WidgetStatePropertyAll(Colors.transparent),
                                            onChanged: _data.isSelectMode ? null : _onSliderChanged,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NeedleThumb extends SliderComponentShape {
  final double height;

  const _NeedleThumb({this.height = 60});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(height, height);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final size = parentBox.size;
    final canvas = context.canvas;
    final progressX = value * size.width;
    final color = sliderTheme.thumbColor ?? Colors.purple;
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2 + activationAnimation.value * 1;
    canvas.drawLine(
      Offset(progressX, 20),
      Offset(progressX, height * .62),
      progressPaint,
    );
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(
      Offset(progressX, size.height * .8),
      6 + activationAnimation.value * 4,
      dotPaint,
    );
  }
}

class _TimelineTickMarkShape extends SliderTrackShape {
  final double start;
  final double end;

  const _TimelineTickMarkShape({required this.start, required this.end});

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool? isEnabled,
    bool? isDiscrete,
  }) => offset & parentBox.size;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool? isEnabled,
    bool? isDiscrete,
    required TextDirection textDirection,
  }) => _paintTimeline(
    parentBox: parentBox,
    context: context,
    sliderTheme: sliderTheme,
    start: start,
    end: end,
  );

  void _paintTimeline({
    required RenderBox parentBox,
    required PaintingContext context,
    required SliderThemeData sliderTheme,
    required double start,
    required double end,
  }) {
    final tickHeight = 14.0;
    final halfTickHeight = 8.0;

    final size = parentBox.size;
    final canvas = context.canvas;
    final color = sliderTheme.inactiveTrackColor?.withValues(alpha: .6) ?? Colors.grey.withValues(alpha: .6);

    final tickPaint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final count = ((end - start) * 10) * 2;
    final stepWidth = size.width / count;

    final labelStyle = TextStyle(
      color: color,
      fontSize: 11,
      fontFamily: 'monospace',
      fontFeatures: [FontFeature.tabularFigures()],
    );

    final defLayout = TextPainter(
      text: TextSpan(text: '0.0', style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final yOffset = defLayout.height + 6;

    for (var i = 0; i <= count; i++) {
      final isFullTick = (i % 2 == 0);

      // draw small labels for every full tick
      if (isFullTick) {
        final labelValue = (start + (i / count) * (end - start)).toStringAsFixed(1);
        final textPainter = TextPainter(
          text: TextSpan(
            text: labelValue,
            style: labelStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          Offset(i * stepWidth - textPainter.width / 2, 0),
        );
      }

      final height = isFullTick ? tickHeight : halfTickHeight;
      final x = i * stepWidth;
      canvas.drawLine(
        Offset(x, yOffset),
        Offset(x, height + yOffset),
        tickPaint,
      );
    }
  }
}

class _OverlayData {
  final int speedMultiplier;
  final bool isLooping;
  final bool isMinimized;
  final double verticalOffset;
  final bool isSelectMode;
  final String? activeTargetId;
  final String? highlightedTargetId;
  final Map<String, _DebugTarget> targets;

  _OverlayData({
    required this.speedMultiplier,
    required this.isLooping,
    required this.isMinimized,
    required this.verticalOffset,
    required this.isSelectMode,
    required this.activeTargetId,
    required this.targets,
    required this.highlightedTargetId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _OverlayData &&
          runtimeType == other.runtimeType &&
          speedMultiplier == other.speedMultiplier &&
          isLooping == other.isLooping &&
          isMinimized == other.isMinimized &&
          isSelectMode == other.isSelectMode &&
          verticalOffset == other.verticalOffset &&
          activeTargetId == other.activeTargetId &&
          mapEquals(targets, other.targets) &&
          highlightedTargetId == other.highlightedTargetId;

  @override
  int get hashCode => Object.hash(
    speedMultiplier,
    isLooping,
    isMinimized,
    verticalOffset,
    isSelectMode,
    activeTargetId,
    highlightedTargetId,
    Object.hashAll(targets.values),
  );

  bool get isSlowMode => speedMultiplier > 1;

  _OverlayData copyWith({
    int? speedMultiplier,
    bool? isLooping,
    bool? isMinimized,
    double? verticalOffset,
    bool? isSelectMode,
    String? activeTargetId,
    String? highlightedTargetId,
    Map<String, _DebugTarget>? targets,
  }) {
    return _OverlayData(
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      isLooping: isLooping ?? this.isLooping,
      isMinimized: isMinimized ?? this.isMinimized,
      verticalOffset: verticalOffset ?? this.verticalOffset,
      isSelectMode: isSelectMode ?? this.isSelectMode,
      highlightedTargetId: highlightedTargetId ?? this.highlightedTargetId,
      activeTargetId: activeTargetId ?? this.activeTargetId,
      targets: targets ?? this.targets,
    );
  }
}

class DebugDataProvider extends InheritedWidget {
  const DebugDataProvider({
    super.key,
    required this.animation,
    required this.isMinimized,
    required this.isSelectMode,
    required this.activeTargetId,
    required this.highlightedTargetId,
    required super.child,
  });

  final Animation<double> animation;
  final bool isMinimized;
  final bool isSelectMode;
  final String? activeTargetId;
  final String? highlightedTargetId;

  @override
  bool updateShouldNotify(covariant DebugDataProvider oldWidget) {
    return animation != oldWidget.animation ||
        isMinimized != oldWidget.isMinimized ||
        isSelectMode != oldWidget.isSelectMode ||
        activeTargetId != oldWidget.activeTargetId ||
        highlightedTargetId != oldWidget.highlightedTargetId;
  }
}

class _DebugTarget {
  final String id;
  final Duration duration;
  final Curve? curve;
  final CueSimulation? simulation;

  _DebugTarget({
    required this.id,
    required this.duration,
    this.curve,
    this.simulation,
  });
}
