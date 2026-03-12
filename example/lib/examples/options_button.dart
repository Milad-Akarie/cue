import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

class OptionsButton extends StatelessWidget {
  const OptionsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelLarge!;
    return CueModalTransition(
      barrierColor: Colors.transparent,
      alignment: Alignment.center,
      motion: Spring.smooth(),
      triggerBuilder: (context, showModal) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceContainer,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            minimumSize: Size(48, 48),
          ),
          onPressed: showModal,
          child: Text('Options'),
        );
      },
      builder: (context, rect) {
        return Padding(
          padding: const .all(2.0),
          child: FractionallySizedBox(
            widthFactor: .8,
            child: Center(
              child: Material(
                color: theme.colorScheme.surfaceContainer,
                shape: RoundedSuperellipseBorder(
                  borderRadius: .circular(32),
                ),
                elevation: 1,
                child: Actor(
                  act: .sizedClip(from: .size(rect.size)),
                  child: Column(
                    mainAxisSize: .min,
                    crossAxisAlignment: .start,
                    children: [
                      Actor(
                        act: .compose([
                          .translateFromGlobal(offset: rect.topLeft),
                          .textStyle(
                            from: labelStyle.copyWith(color: theme.primaryColor),
                            to: labelStyle.copyWith(fontSize: 22),
                          ),
                        ]),
                        child: Padding(
                          padding: .symmetric(horizontal: 24, vertical: 14),
                          child: Text('Options'),
                        ),
                      ),
                      Actor(
                        act: .compose([
                          .focus(),
                          .zoomIn(from: .8),
                          .fadeIn(),
                          .slideUp(),
                        ]),
                        child: Padding(
                          padding: const .fromLTRB(16, 0, 16, 16),
                          child: Column(
                            children: [
                              for (var i = 0; i < 4; i++)
                                Actor(
                                  act: .compose([
                                    .translateY(from: 10 * (i + 1)),
                                    .zoomIn(from: i * -.1),
                                  ]),
                                  child: Card(
                                    clipBehavior: .hardEdge,
                                    elevation: 0,
                                    child: ListTile(
                                      onTap: () => Navigator.of(context).pop(),
                                      leading: Icon(
                                        [
                                          Icons.animation,
                                          Icons.access_alarm_outlined,
                                          Icons.sailing_outlined,
                                          Icons.sanitizer_outlined,
                                        ][i],
                                      ),
                                      title: Text('Option ${i + 1}'),
                                      subtitle: Text('Subtitle text goes here'),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
