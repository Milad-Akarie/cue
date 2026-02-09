import 'package:flutter/material.dart';
import 'package:cue/cue.dart';

class ThreeDotsAction extends StatelessWidget {
  const ThreeDotsAction({super.key});

  @override
  Widget build(BuildContext context) {
    return ModalTransition(
      showDebug: false,
      barrierColor: Colors.transparent,
      alignment: Alignment.bottomRight,
      simulation: Spring.iosDefault,
      triggerBuilder: (context, showModal) => FloatingActionButton(
        shape: CircleBorder(),
        onPressed: showModal,
        child: const Icon(Icons.more_vert),
      ),
      builder: (context, rect) {
        return SizedBox(
          width: rect.width,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              FloatingActionButton(
                elevation: 0,
                shape: CircleBorder(),
                onPressed: () => Navigator.of(context).pop(),
                child: Actor(
                  act:
                      Blur(begin: 6, timing: .startAt(.5)) &
                      Fade() &
                      Translate.y(begin: rect.height / 3) &
                      Scale.seq(1, then: [.to(0.8), .to(0.6)]),
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ),
              Actor(
                act: Translate(
                  begin: Offset(0, -(rect.height / 3)),
                  end: Offset(0, -rect.height),
                ),
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    for (var icon in [Icons.add, Icons.edit, Icons.translate])
                      Actor(
                        act:
                            Pad(begin: .all(.5), end: .only(bottom: 10.0)) &
                            Resize(begin: .square(5), end: .square(48)),
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.black,
                          elevation: 1,
                          shape: CircleBorder(),
                          onPressed: () {},
                          child: Actor(
                            act: ClipReveal(borderRadius: .circular(4), alignment: .bottomRight) & Blur(begin: 8),
                            child: Icon(icon, color: Colors.white, size: 24),
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
