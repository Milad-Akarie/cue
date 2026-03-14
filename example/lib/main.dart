import 'package:cue/cue.dart';
import 'package:example/examples/slack_style_fab.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cue Demo',
      // showPerformanceOverlay: true,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
      ),
      theme: ThemeData(
        splashFactory: NoSplash.splashFactory,
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: _OnChangeDemo(),
      builder: (context, child) {
        if (kDebugMode) {
          return CueDebugTools(child: child!);
        }
        return child!;
      },
    );
  }
}

class _OnChangeDemo extends StatefulWidget {
  const _OnChangeDemo({super.key});

  @override
  State<_OnChangeDemo> createState() => __OnChangeDemoState();
}

class __OnChangeDemoState extends State<_OnChangeDemo> with SingleTickerProviderStateMixin {
  double size = 100.0;
  bool checked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // backgroundColor: Colors.blue,
      appBar: AppBar(),
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.end,
            // crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // SlackStyleFab(),
              // DeleteConfirmationDialog(),
              Cue.onToggle(
                toggled: checked,
                motion: .curved(500.ms, curve: Curves.elasticOut),

                // reverseMotion: Spring.smooth(),
                child: Column(
                  children: [
                    Actor(
                      // act: SizedBoxAct.keyframes([
                      //   .key(Size(100, .infinity), motion: .smooth()),
                      //   .key(Size(50, .infinity), motion: .linear(300.ms)),
                      //   .key(Size(150, .infinity), motion: .bouncy()),
                      // ]),
                      act: SlideAct.fractionalKeyframes([
                        .key(Offset(0, 0), at: 0.0),
                        .key(Offset(1, .2), at: 0.5, curve: Curves.elasticOut),
                        .key(Offset(2, 0), at: 1.0),
                      ],reverse: .keyframes([
                        .key(Offset(2, 0), motion: .bouncy()),
                        .key(Offset(1, .2), motion: .bouncy()),
                        .key(Offset(0, 0), motion: .bouncy()),
                      ])),
                      // act: SlideAct.keyframes([
                      //   .key(Offset(-1, 0), motion: .wobbly()),
                      //   .key(Offset(0, 0), motion: .wobbly()),
                      //   .key(Offset(1, 0), motion: .wobbly()),
                      // .key(Offset(2, 0), motion: .wobbly()),
                      // ]),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: ColoredBox(color: Colors.blue),
                      ),
                    ),
                    // Actor(
                    //   act: .slide(
                    //      to: const Offset(2, 0),
                    //   ),
                    //   child: SizedBox(
                    //     width: 50,
                    //     height: 50,
                    //     child: ColoredBox(color: Colors.yellow),
                    //   ),
                    // ),
                  ],
                ),
              ),

              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    checked = !checked;
                  });
                },
                child: Text('Toggle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class SpringCurve extends Curve {
//   final SimulationBuildData buildData;
//   final Simulation _sim;

//   SpringCurve([this.buildData = const SimulationBuildData()]) : _sim = Spring.wobbly(damping: 8).build(buildData);

//   @override
//   double transformInternal(double t) {
//     if(!buildData.forward){
//        t = 1.0 - t;
//     }
//     return _sim.x(t * 0.7833333333333341);
//   }
// }
