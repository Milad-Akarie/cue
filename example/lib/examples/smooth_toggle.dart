import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

class SmoothSwitch extends StatefulWidget {
  const SmoothSwitch({super.key});

  @override
  State<SmoothSwitch> createState() => _SmoothSwitchState();
}

class _SmoothSwitchState extends State<SmoothSwitch> {
  bool _toggled = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final height = 52.0;
    final width = height * 2;
    final trackColor = theme.colorScheme.surface;
    final thumbColor = theme.colorScheme.onSurface;
    return Cue.onToggle(
      toggled: _toggled,
      motion:  .linear(200.ms),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _toggled = !_toggled;
          });
        },
        onHorizontalDragUpdate: (details) {
          setState(() {
            _toggled = details.localPosition.dx > width / 2;
          });
        },
        child: Actor(
          act: ScaleAct.keyframes([
            // KeyframeBase(1, at: .0),
            // KeyframeBase(.90, at: .45),
            // KeyframeBase(.99, at: .65),
            // KeyframeBase(1.0, at: 1.0),
          ]),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: trackColor,
              borderRadius: .circular(32),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: .1),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              fit: .expand,
              children: [
                PositionActor.keyframes(
                  frames: [
                    // KeyframeBase(.fill(end: .5), at: .0),
                    // KeyframeBase(.fill(end: 0, top: .15, bottom: .15), at: .45),
                    // KeyframeBase(.fill(end: 0, top: .15, bottom: .15), at: .55),
                    // KeyframeBase(.fill(start: .5), at: 1.0),
                  ],
                  relativeTo: Size(width, height),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: thumbColor,
                      borderRadius: .circular(32),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: DecoratedBoxActor(
                        shape: .circle,
                        color: .tween(from: trackColor, to: thumbColor),
                        // timing: .endAt(.5),
                        child: SizedBox.square(dimension: width * .16),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: DecoratedBoxActor(
                          color: .tween(from: trackColor, to: thumbColor),
                          borderRadius: .tween(from: .circular(width * .2), to: .circular(width * .2)),
                          // timing: .startAt(.5),
                          child: SizedBox(width: width * .08, height: width * .22),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
