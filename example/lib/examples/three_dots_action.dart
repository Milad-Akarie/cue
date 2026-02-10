import 'package:flutter/material.dart';
import 'package:cue/cue.dart';

class ThreeDotsAction extends StatelessWidget {
  const ThreeDotsAction({super.key});

  @override
  Widget build(BuildContext context) {
    return ModalTransition(
      showDebug: true,
      barrierColor: Colors.black12,
      alignment: Alignment.bottomRight,
      simulation: Spring.iosDefault,
      triggerBuilder: (context, showModal) => FloatingActionButton(
        shape: CircleBorder(),
        onPressed: showModal,
        child: CustomPaint(
          painter: _DotsPainter(),
        ),
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
                    Blur(begin: 6),
                    Fade(),
                    Translate.y(begin: rect.height / 3),
                  ],
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ),
              Actor(
                acts: [
                  Translate(
                    begin: Offset(0, -(rect.height / 3)),
                    end: Offset(0, -rect.height),
                  ),
                ],
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    for (var icon in [Icons.add, Icons.edit, Icons.translate])
                      Actor(
                        acts: [
                          Pad(begin: .all(1), end: .only(bottom: 10.0)),
                          Resize(begin: .square(5), end: .square(48)),
                        ],
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.black,
                          elevation: 1,
                          shape: CircleBorder(),
                          onPressed: () {},
                          child: Actor(
                            acts: [
                              ClipReveal(borderRadius: .circular(5), alignment: .center),
                              Blur(begin: 8),
                              Fade(),
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

class _DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final radius = 2.5;
    final spacing = 2.0;
    double yAnchor = -spacing;
    for (int i = 0; i < 3; i++) {
      final offset = Offset(size.width / 2, (size.height / 2 + (i - 1) * radius * 2) + yAnchor);
      yAnchor += spacing;
      canvas.drawCircle(offset, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
