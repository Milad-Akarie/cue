import 'package:cue/cue.dart';
import 'package:example/examples/options_button.dart';
import 'package:example/examples/slack_style_fab.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CueApp());
}

class CueApp extends StatelessWidget {
  const CueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cue',
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
        ),
      ).copyWith(
         splashFactory: InkSparkle.splashFactory
      ),
      themeMode: ThemeMode.light,
      home: BasiceExample(),
      showPerformanceOverlay: false,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (kDebugMode) {
          return CueDebugTools(child: child!);
        }
        return child!;
      },
    );
  }
}

class BasiceExample extends StatefulWidget {
  const BasiceExample({super.key});

  @override
  State<BasiceExample> createState() => _BasiceExampleState();
}

class _BasiceExampleState extends State<BasiceExample> {
  bool _forward = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cue'),
      ),
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Cue.onToggle(
              toggled: _forward,
              motion: .wobbly(),
              acts: [
                .scale(to: 1.2),
                .slideY(to: -1),
                .rotate(to: 180),
                .colorTint(from: Colors.orange, to: Colors.green),
              ],
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _forward = !_forward;
                });
              },
              child: const Text('Toggle Animation'),
            ),
          ],
        ),
      ),
    );
  }
}
