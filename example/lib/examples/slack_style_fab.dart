import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SlackStyleFab extends StatelessWidget {
  const SlackStyleFab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CueModalTransition(
      barrierColor: Colors.transparent,
      alignment: .bottomRight,
      barrierDismissible: true,
      motion: .smooth(damping: 18),
      reverseMotion: .iosDefaultSpring(),
      hideTriggerOnTransition: true,
      triggerBuilder: (_, showModal) {
        return CueModalTransition(
          alignment: .bottomCenter,
          barrierColor: Colors.black87,
          hideTriggerOnTransition: true,
          barrierDismissible: true,
          motion: .wobbly(),
          triggerBuilder: (context, showModal2) {
            return GestureDetector(
              onLongPress: showModal2,
              child: FloatingActionButton(
                onPressed: showModal,
                heroTag: 'btn1',
                shape: CircleBorder(),
                elevation: 1,
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                child: Icon(Icons.add),
              ),
            );
          },
          builder: (context, rect) {
            return _LongPressContent(triggerRect: rect);
          },
        );
      },
      builder: (context, rect) {
        return Card(
          margin: .zero,
          clipBehavior: .hardEdge,
          color: theme.colorScheme.surfaceContainer,
          elevation: 0,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(32),
            side: BorderSide(color: theme.primaryColor.withValues(alpha: .2), width: .4),
          ),
          child: Actor(
            act: .sizedClip(
              from: .size(rect.size),
              to: NSize(w: 300),
              alignment: .bottomRight,
            ),
            child: Actor(
              act: .padding(
                to: .symmetric(horizontal: 16, vertical: 12),
              ),
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .end,
                spacing: 4,
                children: [
                  Actor(
                    act: .compose([
                      .slide(from: Offset(.8, .8)),
                      .fadeIn(),
                      .focus(),
                    ]),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity(vertical: -4),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Iconsax.headphone,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                      title: Text('Huddle', style: theme.textTheme.titleMedium?.copyWith(height: 1.2)),
                      subtitle: Text('Start an audio or video chat', style: theme.textTheme.bodySmall),
                    ),
                  ),
                  Actor(
                    act: .sizedBox(
                      width: .tween(from: rect.width, to: .infinity),
                      height: .tween(from: rect.height, to: 44),
                      alignment: .bottomEnd,
                    ),
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        minimumSize: .zero,
                      ),
                      child: Row(
                        mainAxisSize: .min,
                        mainAxisAlignment: .center,
                        children: [
                          Actor(
                            act: .compose([
                              .focus(),
                              .fadeIn(),
                              .clipWidth(),
                            ]),
                            child: Row(
                              mainAxisSize: .min,
                              mainAxisAlignment: .center,
                              children: [
                                Icon(Iconsax.edit),
                                SizedBox(width: 8),
                                Text('Message'),
                              ],
                            ),
                          ),
                          Actor(
                            act: .compose(
                              [
                                .unfocus(),
                                .fadeOut(),
                                .slideX(to: -2, ),
                                .rotate(to: 90),
                                .fadeIn()
                              ],
                              delay: 100.ms,
                            ),
                            child: Icon(Icons.add, size: 24),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LongPressContent extends StatelessWidget {
  const _LongPressContent({required this.triggerRect});

  final Rect triggerRect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Actor(
            act: .compose([
              .translateFromGlobal(
                offset: Offset(triggerRect.left - 64, triggerRect.top),
                toLocal: Offset(-40, 0),
              ),
              .fadeIn(),
              .focus(from: 6),
            ]),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Jhon Doe',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://i.pravatar.cc/150?img=${i + 60}',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ),
        SizedBox(height: 12),
        FloatingActionButton(
          shape: CircleBorder(),
          elevation: 0,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          child: Actor(
            act: .rotate(to: .5, unit: .quarterTurns),
            child: Icon(Icons.add),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
