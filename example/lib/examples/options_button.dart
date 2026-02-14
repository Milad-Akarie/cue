import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

class OptionsButton extends StatelessWidget {
  const OptionsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ModalTransition(
      barrierColor: Colors.transparent,
      alignment: Alignment.center,
      simulation: Spring.smooth,
      duration: Duration(milliseconds: 300),
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
        return Actor.clipReveal(
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
                    Actor.translateFromGlobal(
                      offset: rect.topLeft,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        child: Actor.textStyle(
                          from: theme.textTheme.labelLarge!.copyWith(
                            color: theme.primaryColor,
                          ),
                          to: theme.textTheme.labelLarge!.copyWith(fontSize: 22),
                          child: Text('Options'),
                        ),
                      ),
                    ),
                    Actor(
                      acts: [
                        FadeAct(),
                        ScaleAct(from: .2),
                        BlurAct(from: 10),
                        SlideAct(from: Offset(0, 1)),
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
                              ].staggerActs(
                                (int index) => [
                                  TranslateAct(from: Offset(0, 10 * (index + 1))),
                                  ScaleAct(from: index * -.1),
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
