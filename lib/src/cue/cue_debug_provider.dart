import 'dart:math';

import 'package:flutter/material.dart';

class CueDebugProvider extends StatefulWidget {
  const CueDebugProvider({super.key, required this.child, this.global = true});

  final Widget child;
  final bool global;

  static Widget wrap(BuildContext context, Widget? child) {
    return CueDebugProvider(child: child ?? const SizedBox.shrink());
  }

  @override
  State<CueDebugProvider> createState() => _CueDebugProviderState();

  static bool isWrappedByDebugProvider(BuildContext context) {
    return context.findAncestorWidgetOfExactType<CueDebugProvider>() != null;
  }

  static VoidCallback? showDebugOverlay(BuildContext context) {
    final provider = context.findAncestorStateOfType<_CueDebugProviderState>();
    return provider?.showProgressControllerAsOverlay(context);
  }

  static Animation<double> animationOf(BuildContext context) {
    final provider = context.findAncestorStateOfType<_CueDebugProviderState>();
    return provider?._controller.view ?? AlwaysStoppedAnimation(1.0);
  }
}

class _CueDebugProviderState extends State<CueDebugProvider> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _isLooping = ValueNotifier(false);
  final _speedIndex = ValueNotifier(0);
  final _verticalOffset = ValueNotifier<double>(0.0);
  OverlayEntry? _entry;
  final Set<BuildContext> _attachedCallers = {};
  static const List<int> _speedMultipliers = [1, 2, 4, 8, 16];
  static const Duration _baseDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, lowerBound: 0.0, upperBound: 1.0, duration: _baseDuration);

    if (!widget.global) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showProgressControllerAsOverlay(context);
      });
    }
  }

  void _togglePlayPause() {
    if (_controller.isAnimating) {
      _controller.stop();
    } else {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    if (_isLooping.value) {
      _controller.repeat();
    } else {
      double startValue = _controller.value;
      if (startValue == 1.0) {
        startValue = 0.0;
      }
      _controller.forward(from: startValue);
    }
  }

  void _onSliderChanged(double value) {
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _controller.value = value;
  }

  void _toggleLoop() {
    final wasAnimating = _controller.isAnimating;
    _isLooping.value = !_isLooping.value;
    if (wasAnimating) {
      _controller.stop();
      _startAutoPlay();
    }
  }

  void _cycleSpeed() {
    _speedIndex.value = (_speedIndex.value + 1) % _speedMultipliers.length;
    final speed = _speedMultipliers[_speedIndex.value];
    _setSpeed(speed);
  }

  void _setSpeed(int multiplier) {
    final wasAnimating = _controller.isAnimating;
    _controller.duration = Duration(microseconds: (_baseDuration.inMicroseconds * multiplier).round());

    if (wasAnimating) {
      _controller.stop();
    }
    _startAutoPlay();
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

    if (_entry?.mounted == true) return deattachCallback;
    _entry = OverlayEntry(
      builder: (context) {
        return ValueListenableBuilder<double>(
          valueListenable: _verticalOffset,
          builder: (context, offset, _) {
            return GestureDetector(
              onVerticalDragUpdate: (details) {
                _verticalOffset.value += details.delta.dy;
              },
              child: TweenAnimationBuilder(
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
                    child: Material(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: .85),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .5),
                          width: .5,
                        ),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: ListenableBuilder(
                          listenable: _controller,
                          builder: (context, _) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(_controller.isAnimating ? Icons.pause : Icons.play_arrow),
                                          style: IconButton.styleFrom(iconSize: 32),
                                          onPressed: _togglePlayPause,
                                          padding: EdgeInsets.zero,
                                        ),
                                        Expanded(
                                          child: Slider.adaptive(value: _controller.value, onChanged: _onSliderChanged),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: RotatedBox(
                                            quarterTurns: 2,
                                            child: Icon(_controller.isAnimating ? Icons.pause : Icons.play_arrow),
                                          ),
                                          style: IconButton.styleFrom(iconSize: 32),
                                          onPressed: () {
                                            if (_controller.isAnimating) {
                                              _controller.stop();
                                              return;
                                            }
                                            double startValue = _controller.value;
                                            if (startValue == 0.0) {
                                              startValue = 1.0;
                                            }
                                            _controller.reverse(from: startValue);
                                          },
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text(
                                              '${_controller.value.toStringAsFixed(2)} ',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'monospace',
                                                fontFeatures: [FontFeature.tabularFigures()],
                                              ),
                                            ),
                                            SizedBox(width: 16, height: 12, child: VerticalDivider(thickness: 2)),
                                            Builder(
                                              builder: (context) {
                                                final totalInMs = (_controller.duration?.inMilliseconds ?? 0);
                                                final fixedWidth = totalInMs.toString().length;
                                                final currentInMs = ((_controller.value * totalInMs).round())
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
                                                borderRadius: BorderRadius.circular(4),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  child: Text(speedLabel, style: const TextStyle(fontSize: 14)),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              IconButton(
                                                onPressed: () {
                                                  final slowestSpeedIndex = _speedMultipliers.length - 1;
                                                  if (_speedIndex.value == slowestSpeedIndex) {
                                                    _speedIndex.value = 0;
                                                  } else {
                                                    _speedIndex.value = slowestSpeedIndex;
                                                  }
                                                  _setSpeed(_speedMultipliers[_speedIndex.value]);
                                                },
                                                icon: Icon(Icons.slow_motion_video),
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
                                            icon: Icon(
                                              isLooping ? Icons.repeat_one : Icons.repeat,
                                              color: isLooping ? iconColor : iconColor.withValues(alpha: .4),
                                            ),
                                            onPressed: _toggleLoop,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          );
                                        },
                                      ),
                                    ],
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
            );
          },
        );
      },
    );
    Overlay.of(context).insert(_entry!);
    _startAutoPlay();
    return deattachCallback;
  }

  @override
  void dispose() {
    _controller.dispose();
    _entry?.remove();
    _isLooping.dispose();
    _speedIndex.dispose();
    _verticalOffset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
