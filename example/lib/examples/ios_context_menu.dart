import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class IosContextMenu extends StatelessWidget {
  const IosContextMenu({super.key});

  static const emojis = ['💜', '😂', '😮', '😢', '✊🏽', '🤢', '🤯', '👋🏽'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        final imageCard = Align(
          alignment: .centerLeft,
          child: SizedBox(
            width: 320,
            height: 360,
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 0,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: theme.dividerColor.withValues(alpha: .3), width: 1),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Image.network(
                'https://picsum.photos/seed/${index + 99}/650/500',
                fit: BoxFit.cover,
              ),
            ),
          ),
        );

        return CueModalTransition(
          barrierColor: Colors.transparent,
          motion: .smooth(),
          reverseMotion: .snappy(),
          hideTriggerOnTransition: true,
          backdrop: Actor(
            motion: .linear(200.ms),
            acts: [.backdropBlur(to: 8)],
            child: ColoredBox(color: Colors.black.withValues(alpha: .1)),
          ),
          triggerBuilder: (context, open) {
            return GestureDetector(onTap: open, child: imageCard);
          },
          builder: (context, rect) {
            final isInTopHalf = rect.center.dy < MediaQuery.sizeOf(context).height / 2;
            return Padding(
              padding: EdgeInsets.only(
                top: kToolbarHeight + MediaQuery.viewPaddingOf(context).top,
              ),
              child: ClipRect(
                child: Column(
                  verticalDirection: VerticalDirection.up,
                  mainAxisAlignment: isInTopHalf ? .end : .start,
                  crossAxisAlignment: .start,
                  children: [
                    SizedBox(height: 40),
                    SizedBox(
                      width: 300,
                      child: Actor(
                        acts: [
                          .fadeIn(delay: 100.ms),
                          .zoomIn(reverse: .none()),
                          .slide(from: Offset(0, -2)),
                        ],
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          color: theme.cardColor.withValues(alpha: .8),
                          shape: RoundedSuperellipseBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: theme.dividerColor.withValues(alpha: .3), width: .5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                            child: Column(
                              mainAxisSize: .min,
                              children: [
                                _OptionTile(title: 'Attach Sticker', icon: Iconsax.sticker),
                                Divider(thickness: .5, indent: 2),
                                _OptionTile(title: 'Copy', icon: Iconsax.copy),
                                _OptionTile(title: 'Share', icon: Iconsax.export),
                                _OptionTile(title: 'More', icon: Iconsax.more_2),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Actor(
                      acts: [.translateFromGlobal(offset: rect.topLeft - const Offset(0, 24 + 4))],
                      child: Column(
                        crossAxisAlignment: .start,
                        children: [
                          Actor(
                            acts: [
                              .fadeIn(),
                              .slideY(from: 2),
                            ],
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              color: theme.cardColor.withValues(alpha: .80),
                              margin: const EdgeInsets.only(right: 16, left: 16, bottom: 4),
                              elevation: 0,
                              shape: RoundedSuperellipseBorder(
                                borderRadius: BorderRadius.circular(32),
                                side: BorderSide(color: theme.dividerColor.withValues(alpha: .3), width: .5),
                              ),
                              child: Actor(
                                acts: [
                                  .sizedClip(
                                    from: .square(24),
                                    to: .height(68),
                                    delay: 150.ms,
                                  ),
                                  .fadeIn(),
                                  .slideY(from: 2),
                                ],
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  children: [
                                    for (var i = 0; i < emojis.length; i++)
                                      Center(
                                        child: Actor(
                                          delay: 200.ms,
                                          motion: .wobbly(),
                                          reverseMotion: .snappy(),
                                          acts: [
                                            .scale(from: .5),
                                            .rotate(from: -50, delay: 10.ms * i),
                                          ],
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                            child: Text(emojis[i], style: const TextStyle(fontSize: 34)),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          imageCard,
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String title;
  final IconData icon;

  const _OptionTile({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
        ],
      ),
    );
  }
}
