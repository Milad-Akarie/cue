import 'package:cue/cue.dart';
import 'package:example/examples/indicator_to_button.dart';
import 'package:example/examples/slack_style_fab.dart';

import 'package:flutter/foundation.dart';
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SlackStyleFab(),
                  IndicatorToButton(),

            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: .stretch,
                children: [
                  // Expanded(child: ColoredBox(color: Colors.red)),
                  Cue.onToggle(
                    toggled: checked,
                    // motion: Spring.wobbly(damping: 8),
                    // reverseMotion: Spring.smooth(),
                    
                    child: Row(
                      crossAxisAlignment: .stretch,
                      children: [
                        Actor(
                          act: .sizedBox(
                            width: .tween(from: 50, to: 100),
                            motion: Spring.wobbly(damping: 8),
                          ),
                          child: ColoredBox(color: Colors.blue),
                        ),
                         Actor(
                          act: .sizedBox(
                            width: .tween(from: 50, to: 100),
                            motion: Spring.smooth(),
                          ),
                          child: ColoredBox(color: Colors.yellow),
                        ),
                      ],
                    ),
                  ),
                  // Expanded(child: ColoredBox(color: Colors.green)),
                ],
              ),
            ),
            // Align(
            //    alignment: .bottomEnd,
            //   child: SlackStyleFab()),
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
