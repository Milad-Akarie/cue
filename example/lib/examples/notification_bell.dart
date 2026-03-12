import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _notificationsCount = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Cue.onChange(
          value: _notificationsCount,
          motion: Spring.gentle(),
          child: SizedBox.square(
            dimension: 38,
            child: Stack(
              clipBehavior: .none,
              children: [
                Actor(
                  act: RotateAct.keyframes(
                    [
                      .begin(0.0),
                      .key(20, at: .2),
                      .key(-18, at: .4),
                      .key(14, at: .6),
                      .key(-10, at: .8),
                      .end(0.0),
                    ],
                    unit: .degrees,
                    alignment: .topCenter,
                  ),
                  child: Icon(Iconsax.notification_bing4, size: 32),
                ),
                Positioned(
                  top: -7,
                  right: 2,
                  child: Actor(
                    act: .compose([
                      PathMotionAct.arc(
                        radius: 5,
                        startAngle: -12,
                        sweepAngle: 100,
                      ),
                      ScaleAct.keyframes([
                        .begin(1),
                        .key(1.3, at: .5),
                        .end(1),
                      ]),
                    ]),

                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      constraints: BoxConstraints(minWidth: 18),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: .center,
                      child: Text(
                        '$_notificationsCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _notificationsCount++;
            });
          },
          child: Text('Increment Notifications'),
        ),
      ],
    );
  }
}
