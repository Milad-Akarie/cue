import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

class AirPlanePathDemo extends StatelessWidget {
  AirPlanePathDemo({super.key});
  final paint = Paint()
    ..color = Colors.white38
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 160,
          width: 380,
          child: Card(
            color: Colors.indigo.shade900,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: Cue.onMount(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // defining the path for the plane
                    final path = Path()
                      ..moveTo(16, -16)
                      ..arcToPoint(
                        Offset(constraints.maxWidth - 36, -14),
                        radius: Radius.circular(constraints.maxWidth * .58),
                      );
                    final metrics = path.shift(Offset(12, 12)).computeMetrics().first;
                    return Row(
                      mainAxisAlignment: .spaceBetween,
                      crossAxisAlignment: .end,
                      children: [
                        Stack(
                          alignment: .center,
                          children: [
                            Icon(Icons.circle, size: 16, color: Colors.white),
                            Actor(
                              acts: [
                                // paint the path
                                PaintAct(
                                  painter: .paint((canvas, size, progress) {
                                    final extractPath = metrics.extractPath(0, metrics.length * progress);
                                    canvas.drawPath(extractPath, paint);
                                  }),
                                ),
                                // animating the plane along the path
                                PathMotionAct(path: path, autoRotate: true),
                              ],
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: Icon(
                                  Icons.airplanemode_active,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.circle, size: 16, color: Colors.white),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
