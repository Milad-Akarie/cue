import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

class OptionsButton extends StatelessWidget {
  const OptionsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CueModalTransition(
      barrierColor: Colors.transparent,
      alignment: Alignment.center,
      simulation: const Spring.smooth(),
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
        return ClipActor(
          fromSize: rect.size,
          borderRadius: BorderRadius.circular(32),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: FractionallySizedBox(
              widthFactor: .8,
              child: Material(
                color: theme.colorScheme.surfaceContainer,
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                elevation: 1,
                child: Column(
                  mainAxisSize: .min,
                  crossAxisAlignment: .start,
                  children: [
                    Actor(
                      effects: [
                        TranslateEffect.fromGlobal(offset: rect.topLeft),
                        TextStyleEffect(
                          from: theme.textTheme.labelLarge!.copyWith(
                            color: theme.primaryColor,
                          ),
                          to: theme.textTheme.labelLarge!.copyWith(fontSize: 22),
                        ),
                      ],
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        child: Text('Options'),
                      ),
                    ),
                    Actor(
                      effects: [
                        OpacityEffect(),
                        ScaleEffect.from(.2),
                        BlurEffect(from: 10),
                        SlideEffect.fromY(1),
                      ],
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          children:
                              [
                                for (var i = 0; i < 4; i++)
                                  Card(
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
                              ].staggerEffects(
                                (int index) => [
                                  TranslateEffect.y(from: 10 * (index + 1)),
                                  ScaleEffect.from(index * -.1),
                                ],
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
