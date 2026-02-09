import 'package:flutter/material.dart';
import 'package:cue/cue.dart';

class ThreeDotsAction extends StatelessWidget {
  const ThreeDotsAction({super.key});

  @override
  Widget build(BuildContext context) {
    return ModalTransition(
      showDebug: true,
      barrierColor: Colors.transparent,
      alignment: Alignment.bottomRight,
      createSimulation: (bool forward) {
        return Spring.buildIosStyle(forward: forward);
      },
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
                  acts: [
                    .blur(begin: 6, end: 0),
                    .fade(begin: 0, end: 1),
                    .translate(begin: Offset(0, rect.height / 3), end: Offset.zero),
                  ],
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ),
              Actor.translate(
                begin: Offset(0, -(rect.height / 3)),
                end: Offset(0, -rect.height),
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    for (var icon in [Icons.add, Icons.edit, Icons.translate])
                      Actor(
                        acts: [
                          .pad(
                            begin: EdgeInsets.all(.5),
                            end: const EdgeInsets.only(bottom: 10.0),
                          ),
                          .resize(
                            begin: .square(5),
                            end: .square(48),
                          ),
                        ],
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.black,
                          elevation: 1,
                          shape: CircleBorder(),
                          onPressed: () {},
                          child: Actor(
                            acts: [
                              .clipReveal(
                                borderRadius: BorderRadius.circular(4),
                                alignment: Alignment.bottomRight,
                              ),
                              .blur(begin: 8),
                            ],
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
