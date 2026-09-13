import 'package:material_ui/material_ui.dart';
import 'package:cue/cue.dart';

class ThreeDotsAction extends StatelessWidget {
  const ThreeDotsAction({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CueModalTransition(
      barrierColor: Colors.black12,
      motion: .bouncy(),
      reverseMotion: .snappy(),
      alignment: Alignment.bottomCenter,
      triggerBuilder: (context, showModal) => FloatingActionButton(
        shape: CircleBorder(),
        heroTag: null,
        elevation: 1,
        onPressed: showModal,
        child: Column(
          spacing: 2,
          mainAxisSize: MainAxisSize.min,
          children: [
            // we use specific sized dots for easier transition
            for (var i = 0; i < 3; i++)
              CircleAvatar(
                radius: 2.5,
                backgroundColor: colors.onSurface,
              ),
          ],
        ),
      ),
      builder: (context, rect) {
        return SizedBox(
          width: rect.width,
          child: Stack(
            alignment: .bottomCenter,
            fit: StackFit.loose,
            children: [
              FloatingActionButton(
                elevation: 0,
                shape: CircleBorder(),
                onPressed: () => Navigator.of(context).pop(),
                child: Actor(
                  acts: [
                    .fadeIn(from: 0),
                    .focus(from: 8),
                    .slideY(from: 1),
                  ],
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ),
              Actor(
                acts: [
                  .translateY(
                    from: -rect.height / 3,
                    to: -rect.height - 4, // 4 is little extra padding
                  ),
                ],
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    for (var icon in [
                      Icons.near_me_outlined,
                      Icons.draw_outlined,
                      Icons.translate,
                    ])
                      Actor(
                        acts: [
                          .padding(from: .all(1), to: .only(bottom: 10.0)),
                          .sizedBox(
                            width: .tween(5, 44),
                            height: .tween(5, 44),
                          ),
                        ],
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: colors.onSurface,
                          elevation: 1,
                          shape: CircleBorder(),
                          heroTag: null,
                          onPressed: () {},
                          child: Actor(
                            acts: [
                              .focus(from: 8),
                              .zoomIn(),
                              .fadeIn(),
                            ],
                            child: Icon(icon, color: colors.onPrimary, size: 20),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
