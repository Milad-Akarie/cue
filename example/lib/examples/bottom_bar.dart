import 'package:cue/cue.dart';
import 'package:material_ui/material_ui.dart';
import 'package:iconsax/iconsax.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _activeTab = 0;

  final _tabs = <({String label, IconData icon})>[
    (label: 'Home', icon: Iconsax.home),
    (label: 'Group', icon: Iconsax.profile_2user),
    (label: 'Settings', icon: Iconsax.setting),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              width: 300,
              decoration: BoxDecoration(borderRadius: .circular(32), color: Colors.black),
              padding: const EdgeInsets.all(4),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final collapsedWidth = constraints.maxWidth / (_tabs.length + 1);
                  final expandedWidth = collapsedWidth * 2; // expanded takes 2x space
                  final slideStep = collapsedWidth / expandedWidth;
                  return Stack(
                    children: [
                      Cue.onChange(
                        value: _activeTab,
                        // this will have cue behave as an implicitly animated widget
                        // still the animation will trigger only when the value changes,
                        //it will animate from the current position ignoring any provided 'from' value
                        fromCurrentValue: true,
                        motion: .easeInOut(300.ms),
                        acts: [.slideX(to: slideStep * _activeTab)],
                        child: Container(
                          width: expandedWidth,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                      ),
                      OverflowBox(
                        // allow the row to breathe a bit
                        // 2 tabs switching midway would cause an overflow by a few pixels
                        maxWidth: constraints.maxWidth + 10,
                        child: Row(
                          crossAxisAlignment: .stretch,
                          children: [
                            for (int i = 0; i < _tabs.length; i++)
                              InkWell(
                                borderRadius: .circular(32),
                                onTap: () {
                                  setState(() {
                                    _activeTab = i;
                                  });
                                },
                                child: Cue.onToggle(
                                  toggled: _activeTab == i,
                                  motion: .smooth(),
                                  child: Actor(
                                    acts: [
                                      .sizedClip(from: .width(collapsedWidth), to: .width(expandedWidth)),
                                      .colorTint(from: Colors.white60, to: Colors.black),
                                    ],
                                    child: Row(
                                      mainAxisAlignment: .center,
                                      children: [
                                        Icon(_tabs[i].icon, color: Colors.white),
                                        Actor(
                                          acts: [
                                            // clip the text so the icon is centered in the collapsed state
                                            .clipWidth(),
                                            .fadeIn(),
                                            .scale(from: .7),
                                          ],
                                          child: Padding(
                                            padding: const .symmetric(horizontal: 8.0),
                                            child: Text(
                                              _tabs[i].label,
                                              maxLines: 1,
                                              overflow: .fade,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(width: 32),
          SizedBox.square(
            dimension: 56,
            child: FloatingActionButton(
              shape: CircleBorder(),
              elevation: 0,
              backgroundColor: Colors.black,
              child: Icon(Iconsax.activity, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
