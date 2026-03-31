import 'package:cue/cue.dart';
import 'package:cue/src/timeline/track/track.dart';
import 'package:cue/src/timeline/track/track_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class CueDebugTools extends StatefulWidget {
  const CueDebugTools({super.key, required this.child});

  final Widget child;

  @override
  State<CueDebugTools> createState() => _CueDebugToolsState();

  static bool isWrappedByDebugProvider(BuildContext context) {
    return context.findAncestorWidgetOfExactType<CueDebugTools>() != null;
  }

  static VoidCallback? attachDebugTarget(
    BuildContext context, {
    required String id,
    required CueTrack track,
  }) {
    final provider = context.findAncestorStateOfType<_CueDebugToolsState>();
    return provider?.attachDebugTarget(context, id: id, track: track);
  }

  static DebugDataProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DebugDataProvider>();
    if (scope == null) {
      throw Exception('No CueDebugTools found in context. Make sure to wrap your widget tree with CueDebugTools.');
    }
    return scope;
  }

  static DebugDataProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DebugDataProvider>();
  }
}

class _CueDebugToolsState extends State<CueDebugTools> with SingleTickerProviderStateMixin {
  late final CueController _controller;

  final _overlayData = ValueNotifier<_OverlayData>(
    _OverlayData(
      isLooping: false,
      isMinimized: true,
      verticalOffset: 0,
      activeTargetId: null,
      isSlowMode: timeDilation != 1.0,
    ),
  );

  OverlayEntry? _entry;

  @override
  void initState() {
    super.initState();
    _controller = CueController(vsync: this, motion: .linear(300.ms));
  }

  void _startAutoPlay() {
    if (_overlayData.value.isLooping) {
      _controller.repeat(reverse: true);
    } else {
      double startValue = _controller.value;
      if (_overlayData.value.forward) {
        if (startValue == 1.0) {
          startValue = 0.0;
        }
        _controller.forward(from: startValue);
      } else {
        if (startValue == 0.0) {
          startValue = 1.0;
        }
        _controller.reverse(from: startValue);
      }
    }
  }

  VoidCallback attachDebugTarget(BuildContext context, {required String id, required CueTrack track}) {
    _overlayData.value = _overlayData.value.copyWith(activeTargetId: id);
    _controller.timeline.resetTracks(
      TrackConfig(
        motion: track.motion,
        reverseMotion: track.reverseMotion,
      ),
    );
    _controller.setProgress(track.progress, forward: _overlayData.value.forward);

    void deattachCallback() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.setProgress(0, forward: _overlayData.value.forward);
        timeDilation = 1.0;
        _overlayData.value = _overlayData.value.copyWith(
          activeTargetId: '',
          isMinimized: true,
          isSlowMode: timeDilation != 1.0,
        );
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
          activeTargetId: _overlayData.value.activeTargetId,
          timeline: _controller.timeline,
          isMinimized: _overlayData.value.isMinimized,
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

  final CueController controller;
  final VoidCallback onPlay;
  final Duration baseDuration;

  @override
  State<_DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<_DebugOverlay> {
  CueController get _controller => widget.controller;
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
    _controller.setProgress(value, forward: _data.forward);
  }

  void _toggleLoop() {
    _dataNotifier.value = _data.copyWith(isLooping: !_data.isLooping);
    _controller.stop();
    widget.onPlay();
  }

  void _toggleSlowMode() {
    if (timeDilation == 1.0) {
      timeDilation = 5.0;
      _dataNotifier.value = _data.copyWith(isSlowMode: true);
    } else {
      timeDilation = 1.0;
      _dataNotifier.value = _data.copyWith(isSlowMode: false);
    }
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
                  minimum: .only(top: 16),
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
                              listenable: _controller,
                              builder: (context, _) {
                                if (_data.isMinimized) {
                                  return IconButton(
                                    style: IconButton.styleFrom(
                                      tapTargetSize: .shrinkWrap,
                                      shape: CircleBorder(),
                                      minimumSize: .square(40),
                                    ),
                                    icon: Icon(Icons.play_circle),
                                    onPressed: _data.activeTargetId != null && _data.activeTargetId!.isNotEmpty
                                        ? () {
                                            _dataNotifier.value = _data.copyWith(isMinimized: false);
                                          }
                                        : null,
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
                                              widget.controller.isAnimating && _data.forward
                                                  ? Icons.pause_circle_outline_rounded
                                                  : Icons.play_circle_outline_rounded,
                                            ),
                                            style: IconButton.styleFrom(
                                              iconSize: 28,
                                              foregroundColor: !_data.forward
                                                  ? theme.primaryColor.withValues(alpha: .4)
                                                  : theme.primaryColor,
                                            ),
                                            onPressed: () {
                                              _dataNotifier.value = _data.copyWith(forward: true);
                                              _togglePlayPause();
                                            },
                                            padding: EdgeInsets.zero,
                                          ),
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
                                                  width: 8,
                                                  height: 12,
                                                  child: VerticalDivider(
                                                    thickness: 1.2,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Builder(
                                                  builder: (context) {
                                                    final duration = _data.forward
                                                        ? widget.controller.timeline.forwardDuration
                                                        : widget.controller.timeline.reverseDuration;

                                                    final progress = _data.forward
                                                        ? widget.controller.value
                                                        : 1 - widget.controller.value;
                                                    final durationInSeconds = duration * progress;
                                                    final durationInMs = durationInSeconds * 1000;
                                                    final maxChars = ( duration * 1000).toStringAsFixed(0).length;
                                                    return Text(
                                                      '${durationInMs.toStringAsFixed(0).padLeft(maxChars, '0')}ms',
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
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.zero,
                                          ),
                                          SizedBox(width: 8),
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
                                              timeDilation = 1.0;
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          SizedBox(width: 8),
                                          SizedBox(
                                            width: 4,
                                            height: 14,
                                            child: VerticalDivider(
                                              thickness: 1.2,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Transform.flip(
                                              flipX: true,
                                              child: Icon(
                                                widget.controller.isAnimating && !_data.forward
                                                    ? Icons.pause_circle_outline_rounded
                                                    : Icons.play_circle_outline_rounded,
                                              ),
                                            ),
                                            style: IconButton.styleFrom(
                                              iconSize: 28,
                                              foregroundColor: _data.forward
                                                  ? theme.primaryColor.withValues(alpha: .4)
                                                  : theme.primaryColor,
                                            ),
                                            onPressed: () {
                                              _dataNotifier.value = _data.copyWith(forward: false);
                                              _togglePlayPause();
                                            },
                                            padding: EdgeInsets.zero,
                                          ),
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
                                            value: _controller.value,
                                            activeColor: Colors.transparent,
                                            thumbColor: theme.colorScheme.primary,
                                            overlayColor: WidgetStatePropertyAll(Colors.transparent),
                                            onChanged: _onSliderChanged,
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
  final bool isSlowMode;
  final bool isLooping;
  final bool isMinimized;
  final double verticalOffset;
  final String? activeTargetId;
  final bool forward;

  _OverlayData({
    required this.isSlowMode,
    required this.isLooping,
    required this.isMinimized,
    required this.verticalOffset,
    required this.activeTargetId,
    this.forward = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _OverlayData &&
          runtimeType == other.runtimeType &&
          isSlowMode == other.isSlowMode &&
          isLooping == other.isLooping &&
          isMinimized == other.isMinimized &&
          verticalOffset == other.verticalOffset &&
          forward == other.forward &&
          activeTargetId == other.activeTargetId;

  @override
  int get hashCode => Object.hash(
    isSlowMode,
    isLooping,
    isMinimized,
    verticalOffset,
    activeTargetId,
    forward,
  );

  _OverlayData copyWith({
    bool? isLooping,
    bool? isMinimized,
    double? verticalOffset,
    String? activeTargetId,
    bool? forward,
    bool? isSlowMode,
  }) {
    return _OverlayData(
      isSlowMode: isSlowMode ?? this.isSlowMode,
      isLooping: isLooping ?? this.isLooping,
      isMinimized: isMinimized ?? this.isMinimized,
      verticalOffset: verticalOffset ?? this.verticalOffset,
      forward: forward ?? this.forward,
      activeTargetId: activeTargetId ?? this.activeTargetId,
    );
  }
}

class DebugDataProvider extends InheritedWidget {
  const DebugDataProvider({
    super.key,
    required this.timeline,
    required this.isMinimized,
    required this.activeTargetId,
    required super.child,
  });

  final CueTimeline timeline;
  final bool isMinimized;
  final String? activeTargetId;
  @override
  bool updateShouldNotify(covariant DebugDataProvider oldWidget) {
    return timeline != oldWidget.timeline ||
        isMinimized != oldWidget.isMinimized ||
        activeTargetId != oldWidget.activeTargetId;
  }
}
