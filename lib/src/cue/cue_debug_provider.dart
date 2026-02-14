import 'dart:math';

import 'package:flutter/material.dart';

class CueDebugTools extends StatefulWidget {
  const CueDebugTools({
    super.key,
    required this.child,
    this.global = true,
    this.baseDuration = const Duration(milliseconds: 500),
  });

  final Widget child;
  final bool global;
  final Duration baseDuration;

  static Widget wrap(BuildContext context, Widget? child) {
    return CueDebugTools(child: child ?? const SizedBox.shrink());
  }

  @override
  State<CueDebugTools> createState() => _CueDebugToolsState();

  static bool isWrappedByDebugProvider(BuildContext context) {
    return context.findAncestorWidgetOfExactType<CueDebugTools>() != null;
  }

  static VoidCallback? showDebugOverlay(BuildContext context) {
    final provider = context.findAncestorStateOfType<_CueDebugToolsState>();
    return provider?.showProgressControllerAsOverlay(context);
  }

  static Animation<double> animationOf(BuildContext context) {
    final provider = context.findAncestorStateOfType<_CueDebugToolsState>();
    return provider?._controller.view ?? AlwaysStoppedAnimation(1.0);
  }
}

class _CueDebugToolsState extends State<CueDebugTools> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _verticalOffset = ValueNotifier<double>(0.0);

  OverlayEntry? _entry;
  final Set<BuildContext> _attachedCallers = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
      duration: widget.baseDuration,
    );

    if (!widget.global) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showProgressControllerAsOverlay(context);
      });
    }
  }

  void _startAutoPlay([bool isLooping = false]) {
    if (isLooping) {
      _controller.repeat();
    } else {
      double startValue = _controller.value;
      if (startValue == 1.0) {
        startValue = 0.0;
      }
      _controller.forward(from: startValue);
    }
  }

  VoidCallback showProgressControllerAsOverlay(BuildContext context) {
    _attachedCallers.add(context);
    void deattachCallback() {
      _attachedCallers.remove(context);
      if (_attachedCallers.isEmpty) {
        _entry?.remove();
        _entry = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.value = 0;
        });
      }
    }

    if (_entry != null) return deattachCallback;
    _entry = OverlayEntry(
      builder: (context) {
        return _DebugOverlay(
          controller: _controller,
          onPlay: _startAutoPlay,
          baseDuration: widget.baseDuration,
          verticalOffset: _verticalOffset,
        );
      },
    );
    Overlay.of(context).insert(_entry!);
    return deattachCallback;
  }

  @override
  void dispose() {
    _controller.dispose();
    _entry?.remove();
    _verticalOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _DebugOverlay extends StatefulWidget {
  const _DebugOverlay({
    required this.controller,
    required this.onPlay,
    required this.baseDuration,
    required this.verticalOffset,
  });

  final ValueNotifier<double> verticalOffset;
  final AnimationController controller;
  final void Function(bool isLooping) onPlay;
  final Duration baseDuration;

  @override
  State<_DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<_DebugOverlay> {
  final _speedIndex = ValueNotifier(0);
  final _isLooping = ValueNotifier(false);

  static const List<int> _speedMultipliers = [1, 2, 4, 8, 16];

  AnimationController get _controller => widget.controller;

  void _togglePlayPause() {
    if (_controller.isAnimating) {
      _controller.stop();
    } else {
      widget.onPlay(_isLooping.value);
    }
  }

  void _onSliderChanged(double value) {
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _controller.value = value;
  }

  void _toggleLoop() {
    _isLooping.value = !_isLooping.value;
    _controller.stop();
    widget.onPlay(_isLooping.value);
  }

  void _cycleSpeed() {
    _speedIndex.value = (_speedIndex.value + 1) % _speedMultipliers.length;
    final speed = _speedMultipliers[_speedIndex.value];
    _setSpeed(speed);
  }

  void _setSpeed(int multiplier) {
    final wasAnimating = _controller.isAnimating;
    _controller.duration = Duration(microseconds: (widget.baseDuration.inMicroseconds * multiplier).round());

    if (wasAnimating) {
      _controller.stop();
    }
    widget.onPlay(_isLooping.value);
  }

  @override
  void dispose() {
    _speedIndex.dispose();
    _isLooping.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: widget.verticalOffset,
      builder: (context, offset, _) {
        return GestureDetector(
          onVerticalDragUpdate: (details) {
            final maxTop = MediaQuery.sizeOf(context).height - 220;
            final minTop = 0.0;
            widget.verticalOffset.value += details.delta.dy.clamp(
              minTop - widget.verticalOffset.value,
              maxTop - widget.verticalOffset.value,
            );
          },
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform(
                transform: Matrix4.translationValues(0, -50 * (1 - value) + offset, 0),
                child: Opacity(opacity: max(.4, value), child: child),
              );
            },
            child: Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Material(
                    color: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .52),
                        width: .5,
                      ),
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: ListenableBuilder(
                        listenable: widget.controller,
                        builder: (context, _) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                                              fontFeatures: [FontFeature.tabularFigures()],
                                            ),
                                          ),
                                          SizedBox(width: 16, height: 12, child: VerticalDivider(thickness: 2)),
                                          Builder(
                                            builder: (context) {
                                              final totalInMs = (widget.controller.duration?.inMilliseconds ?? 0);
                                              final fixedWidth = totalInMs.toString().length;
                                              final currentInMs = ((widget.controller.value * totalInMs).round())
                                                  .toString()
                                                  .padLeft(fixedWidth, '0');
                                              return Text(
                                                '$currentInMs / ${totalInMs}ms',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: 'monospace',
                                                  fontFeatures: [FontFeature.tabularFigures()],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    ValueListenableBuilder(
                                      valueListenable: _speedIndex,
                                      builder: (context, speedIdx, _) {
                                        final speed = _speedMultipliers[speedIdx];
                                        final speedLabel = speedIdx == 0 ? '1X' : '-${speed}X';
                                        return Row(
                                          children: [
                                            InkWell(
                                              onTap: _cycleSpeed,
                                              borderRadius: BorderRadius.circular(32),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
                                                  borderRadius: BorderRadius.circular(32),
                                                ),
                                                child: Text(
                                                  speedLabel,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontFamily: 'monospace',
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 6),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              style: IconButton.styleFrom(
                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              ),
                                              onPressed: () {
                                                final slowestSpeedIndex = _speedMultipliers.length - 1;
                                                if (_speedIndex.value == slowestSpeedIndex) {
                                                  _speedIndex.value = 0;
                                                } else {
                                                  _speedIndex.value = slowestSpeedIndex;
                                                }
                                                _setSpeed(_speedMultipliers[_speedIndex.value]);
                                              },
                                              icon: Icon(Icons.slow_motion_video_outlined),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    ValueListenableBuilder(
                                      valueListenable: _isLooping,
                                      builder: (context, isLooping, _) {
                                        final iconColor =
                                            IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface;
                                        return IconButton(
                                          style: IconButton.styleFrom(
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          icon: Icon(
                                            Icons.loop_rounded,
                                            color: isLooping ? iconColor : iconColor.withValues(alpha: .4),
                                          ),
                                          onPressed: _toggleLoop,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        );
                                      },
                                    ),
                                    SizedBox(width: 8),
                                  ],
                                ),

                                Container(
                                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.surfaceContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      trackShape: _TimelineTickMarkShape(start: 0, end: 1),
                                      tickMarkShape: SliderTickMarkShape.noTickMark,
                                      inactiveTrackColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: .6),
                                      thumbShape: _NeedleThumb(height: 60),
                                    ),
                                    child: Slider(
                                      padding: EdgeInsets.zero,
                                      value: widget.controller.value,
                                      activeColor: Colors.transparent,
                                      thumbColor: Theme.of(context).colorScheme.primary,
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
    canvas.drawLine(Offset(progressX, 20), Offset(progressX, height * .62), progressPaint);
    final dotPaint = Paint()..color = color;
    canvas.drawCircle(Offset(progressX, size.height * .8), 6 + activationAnimation.value * 4, dotPaint);
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
        textPainter.paint(canvas, Offset(i * stepWidth - textPainter.width / 2, 0));
      }

      final height = isFullTick ? tickHeight : halfTickHeight;
      final x = i * stepWidth;
      canvas.drawLine(Offset(x, yOffset), Offset(x, height + yOffset), tickPaint);
    }
  }
}
