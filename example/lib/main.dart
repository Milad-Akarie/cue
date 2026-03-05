import 'package:cue/cue.dart';
import 'package:example/examples/bottom_bar.dart';
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
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    BoxDecoration;
    return Scaffold(
      // backgroundColor: theme.colorScheme.surfaceContainer,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 48, bottom: 48, left: 24, right: 24),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SlackStyleFab(),
            ],
          ),
        ),
      ),
    );
  }
}
