import 'dart:developer';

import 'package:cue/cue.dart';
import 'package:example/examples/delete_confirmation.dart';
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
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: .light,
      theme: ThemeData(
        splashFactory: NoSplash.splashFactory,
        colorScheme: .fromSeed(seedColor: const Color(0xFF6C63FF)),
      ),
      home: const DemoPage(),
      builder: (context, child) {
        if (kDebugMode) {
          return CueDebugTools(child: child!);
        }
        return child!;
      },
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cue Demo')),
      body: Row(
        children: [
         Cue.onMount(
          motion: .wobbly(),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: Actor(
                      acts: [
                        .fadeIn(),
                        .translateY(from: 16),
                      ],
                      delay: 0.ms,
                      child: Text("Hello", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  TextSpan(text: " "),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: Actor(
                      acts: [
                        .fadeIn(),
                        .translateY(from: 16),
                      ],
                      delay: 50.ms,
                      child: Text("World", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
