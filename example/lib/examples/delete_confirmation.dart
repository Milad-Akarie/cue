import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CueModalTransition(
      alignment: Alignment.bottomRight,
      barrierColor: Colors.transparent,
      hideTriggerOnTransition: true,
      motion: Spring.bouncy(damping: 19),
      triggerBuilder: (context, open) => FloatingActionButton(
        onPressed: open,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.error,
        elevation: .5,
        shape: CircleBorder(),
        child: Icon(Iconsax.trash),
      ),
      builder: (context, rect) {
        return Actor(
          act: .translate(from: Offset(-28, -28)),
          child: Material(
            clipBehavior: .hardEdge,
            borderRadius: BorderRadius.circular(32),
            color: theme.colorScheme.surface,
            elevation: 1,
            shadowColor: Colors.black.withValues(alpha: .3),
            child: Actor(
              act: .compose([
                .sizedClip(from: .size(rect.size), to: .width(220)),
                .slideY(from: 0.4),
              ]),
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Actor(
                        act: .compose([
                          .fadeIn(),
                          .blur(from: 10),
                        ]),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Column(
                            children: [
                              Text(
                                'Are you sure you want to delete this item?',
                                textAlign: .center,
                                style: theme.textTheme.bodyMedium,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'This action cannot be undone.',
                                textAlign: .center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: .5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error.withValues(alpha: .05),
                          foregroundColor: theme.colorScheme.error,
                          padding: .symmetric(horizontal: 20.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        label: Text('Delete Item'),
                        iconAlignment: .end,
                        icon: Actor(
                          act: .compose([
                            .translateFromGlobalRect(rect),
                            .iconTheme(
                              from: IconThemeData(size: 24),
                              to: IconThemeData(size: 20),
                            ),
                          ]),

                          child: Icon(
                            Iconsax.trash,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
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
