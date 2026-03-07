import 'package:cue/cue.dart';
import 'package:example/examples/bottom_bar.dart';
import 'package:example/examples/horizinally_expanding_cards.dart';
import 'package:example/examples/options_button.dart';
import 'package:example/examples/slack_style_fab.dart';
import 'package:example/examples/smooth_toggle.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Curves.elasticIn;
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

    BoxDecoration;
    return Scaffold(
      // backgroundColor: theme.colorScheme.surfaceContainer,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 0, left: 24, right: 24),
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.end,
            // crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 10; i++)
                Cue.onScrollVisible(
                  key: ValueKey(i),
                  act: .compose([
                    .fadeIn(),
                    .zoomIn(from: .5),
                    .slideDown(),
                  ]),
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.red,
                    margin: EdgeInsets.only(bottom: 8),
                  ),
                ),
              // Cue.onChange(
              //   fromCurrentValue: true,
              //   value: size,
              //   act: .clipSize(
              //     from: .square(20),
              //     to: .square(size),
              //   ),
              //   child: Container(width: 50, height: 50, color: Colors.red),
              // ),

              // ElevatedButton(
              //   onPressed: () {
              //     setState(() {
              //       size = size + 50;
              //     });
              //   },
              //   child: Text('resize'),
              // ),
              // Center(
              //   child: SizedBox(
              //     width: 200,
              //     child: Cue.onToggle(
              //       toggled: checked,
              //       motion: .simulation(Spring.wobbly()),
              //       child: Column(
              //         children: [
              //           Actor(
              //             act: .size(width: .tween(from: 100, to: 200)),
              //             child: Container(
              //               width: size,
              //               height: size,
              //               color: Colors.blue,
              //             ),
              //           ),
              //           SizedBox(height: 24),
              //           ElevatedButton(
              //             onPressed: () {
              //               setState(() {
              //                 checked = !checked;
              //               });
              //             },
              //             child: Text('Toggle'),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              // SlackStyleFab(),
              // HorizontallyExpandingCards(),
            ],
          ),
        ),
      ),
    );
  }
}
