import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:gooey/gooey.dart';
import 'package:iconsax/iconsax.dart';

class GooeyBottomBar extends StatefulWidget {
  const GooeyBottomBar({super.key});

  @override
  State<GooeyBottomBar> createState() => _GooeyBottomBarState();
}

class _GooeyBottomBarState extends State<GooeyBottomBar> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _previousIndex = 0;
  PathMotionAct motionAct = PathMotionAct.arc(radius: 1, sweepAngle: 1);

  final icons = <({IconData active, IconData inactive})>[
    (active: Iconsax.home5, inactive: Iconsax.home_1),
    (active: Iconsax.video5, inactive: Iconsax.video),
    (active: Iconsax.activity5, inactive: Iconsax.activity),
    (active: Iconsax.heart5, inactive: Iconsax.heart),
    (active: Iconsax.layer5, inactive: Iconsax.layer),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 11, 0, 29),
      appBar: AppBar(title: const Text('Cue')),
      bottomNavigationBar: GooeyZone(
        color: Colors.white,
        gooiness: 30,
        child: LayoutBuilder(
          builder: (context, constraints) {
            const indicatorSize = 64.0;
            const indicatorPadding = 6.0;
            final totalWidth = constraints.maxWidth - 24; // left+right padding of GooeyBlob
            final itemWidth = totalWidth / 5;
            final offset = 8 + (itemWidth - (indicatorSize + indicatorPadding * 2));

            final currentPos = (itemWidth * _previousIndex) + offset;
            final targetPos = (itemWidth * _selectedIndex) + offset;
            final distnace = (targetPos - currentPos).abs();

            final path = Path()
              ..moveTo(currentPos == targetPos ? 0 : currentPos, 0)
              ..arcToPoint(
                Offset(targetPos, 0.0),
                radius: Radius.circular(distnace * .65),
                clockwise: currentPos < targetPos,
              );

            return Stack(
              children: [
                Cue.onChange(
                  value: _selectedIndex,
                  motion: .easeInOut(300.ms),
                  child: Actor(
                    acts: [PathMotionAct(path: path)],
                    child: GooeyBlob(
                      cutout: true,
                      child: Container(
                        width: indicatorSize,
                        height: indicatorSize,
                        margin: EdgeInsets.all(indicatorPadding),
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.deepPurpleAccent.withValues(alpha: .7),
                              Colors.deepPurpleAccent.withValues(alpha: .6),
                              Colors.deepPurple.shade900,
                            ],
                            stops: [0.0, 0.2, 1.0],
                            focalRadius: 0.2,
                            center: Alignment(0.0, 0.0),
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: .only(top: (indicatorSize + indicatorPadding / 2) / 2),
                  child: GooeyBlob(
                    shape: .rounded(24),
                    child: Padding(
                      padding: .fromLTRB(12, 0, 12, 12),
                      child: SizedBox(
                        height: 88,
                        child: Row(
                          mainAxisAlignment: .spaceAround,
                          crossAxisAlignment: .stretch,
                          children: [
                            for (int i = 0; i < 5; i++)
                              Expanded(
                                child: Cue.onToggle(
                                  toggled: _selectedIndex == i,
                                  motion: .easeInOut(450.ms),
                                  child: Material(
                                    type: .transparency,
                                    child: Center(
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        borderRadius: .circular(24),
                                        onTap: (_selectedIndex == i)
                                            ? null
                                            : () {
                                                setState(() {
                                                  _previousIndex = _selectedIndex;
                                                  _selectedIndex = i;
                                                });
                                              },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Actor(
                                            acts: [.translateY(to: -40), .scale(to: 1.1)],
                                            child: Stack(
                                              children: [
                                                Icon(
                                                  icons[i].active,
                                                  color: Colors.white.withValues(alpha: .85),
                                                ),
                                                Actor(
                                                  acts: [.fadeOut()],
                                                  child: Icon(
                                                    icons[i].inactive,
                                                    color: Color.fromARGB(255, 20, 0, 23),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
