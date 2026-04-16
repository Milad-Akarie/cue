import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:gooey/gooey.dart';

class GooeyFab extends StatefulWidget {
  const GooeyFab({super.key});

  @override
  State<GooeyFab> createState() => _GooeyFabState();
}

class _GooeyFabState extends State<GooeyFab> {
  bool _open = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingActionButtonTheme(
      data: theme.floatingActionButtonTheme.copyWith(
        backgroundColor: Colors.black,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        shape: const CircleBorder(),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Gooey FAB')),
        body: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Align(
              alignment: Alignment.center,
              child: Cue.onToggle(
                toggled: _open,
                skipFirstAnimation: false,
                motion: .smooth(),
                acts: [.slideY(to: .1)],
                child: GooeyZone(
                  color: Colors.black,
                  blurRadius: 14,
                  threshold: .5,
                  shouldSnapshot: false,
                  child: Column(
                    mainAxisAlignment: .center,
                    crossAxisAlignment: .center,
                    spacing: 8,
                    children: [
                      Padding(
                        padding: const .only(left: 32),
                        child: Actor(
                          acts: [
                            .slideY(to: 1),
                            .scale(to: 0, alignment: .bottomCenter, motion: .bouncy()),
                            .unfocus(),
                          ],
                          child: GooeyBlob(
                            child: IconButton(
                              style: IconButton.styleFrom(
                                padding: .all(8),
                                tapTargetSize: .shrinkWrap,
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                              ),
                              icon: Icon(Iconsax.more),
                              onPressed: () {
                                setState(() {
                                  _open = !_open;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      GooeyBlob(
                        shape: .superEllipse(.circular(32)),
                        child: Actor(
                          acts: [
                            .sizedClip(from: .zero, alignment: .bottomCenter),
                            .fadeIn(),
                            .focus(from: 6),
                            .zoomIn(),
                          ],
                          child: _MenuItems(
                            onItemTap: () {
                              setState(() {
                                _open = false;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: CueModalTransition(
          alignment: .bottomCenter,
          motion: .bouncy(),
          hideTriggerOnTransition: true,
          triggerBuilder: (_, showModal) {
            return FloatingActionButton(
              onPressed: showModal,
              child: const Icon(Iconsax.add),
            );
          },
          builder: (context, rect) {
            return GooeyZone(
              color: Colors.black,
              threshold: .6,
              blurRadius: 6,
              sharpness: .5,
              overpaintFactor: 0,
              shouldSnapshot: false,
              child: Column(
                mainAxisSize: .min,
                spacing: 8,
                children: [
                  for (var index = 0; index < 3; index++)
                    Actor(
                      acts: [
                        .translateFromGlobalRect(rect),
                        .slideX(from: index.isEven ? .1 : -.15, motion: .bouncy()),
                        .scale(from: .3 * index),
                        StretchAct.keyframed(
                          frames: .fractional(
                            [
                              .key(Stretch(y: 1.2), at: 0.5),
                              .key(Stretch.none, at: 1.0),
                            ],
                            duration: 250.ms,
                            curve: Curves.easeInOut,
                          ),
                        ),
                      ],
                      child: GooeyBlob(
                        child: FloatingActionButton.small(
                          backgroundColor: Colors.transparent,
                          heroTag: 'icon_$index',
                          child: Actor(
                            acts: [
                              .zoomIn(),
                              .fadeIn(),
                              .focus(),
                            ],
                            child: Icon([Iconsax.edit, Iconsax.layer, Iconsax.filter][index], size: 20),
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  Actor(
                    acts: [
                      // stretch a bit for better gooey effect
                      StretchAct.keyframed(
                        alignment: .bottomCenter,
                        frames: .fractional(
                          [
                            .key(Stretch(y: 1.2, x: .9), at: 0.5),
                            .key(Stretch.none, at: 1.0),
                          ],
                          duration: 250.ms,
                          curve: Curves.easeInOut,
                        ),
                      ),
                    ],
                    child: GooeyBlob(
                      child: FloatingActionButton(
                        onPressed: () => Navigator.pop(context),
                        child: Actor(
                          acts: [
                            .scale(to: 1.2),
                            .rotate(to: 45),
                          ],
                          child: const Icon(Iconsax.add),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MenuItems extends StatelessWidget {
  const _MenuItems({ required this.onItemTap});
  final VoidCallback onItemTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SizedBox(
      width: 200,
      child: Padding(
        padding: .symmetric(vertical: 8, horizontal: 4),
        child: Material(
          type: .transparency,
          shape: RoundedSuperellipseBorder(
            borderRadius: .circular(24),
          ),
          clipBehavior: .hardEdge,
          child: Column(
            children: [
              for (var index = 0; index < 3; index++)
                ListTile(
                  visualDensity: VisualDensity(vertical: -2),
                  leading: Icon(
                    [Iconsax.edit, Iconsax.layer, Iconsax.filter][index],
                    color: colors.onPrimary,
                    size: 20,
                  ),
                  title: Text(
                    ['Edit', 'Layers', 'Filter'][index],
                    style: theme.textTheme.bodyLarge?.copyWith(color: colors.onPrimary),
                  ),
                  onTap: onItemTap
                ),
            ],
          ),
        ),
      ),
    );
  }
}
