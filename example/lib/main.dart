import 'package:cue/cue.dart';
import 'package:example/examples/on_scroll_parallax.dart';
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
      title: 'Cue',
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: const OnScrollParallax(),
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (kDebugMode) {
          // return CueDebugTools(child: child!);
        }
        return child!;
      },
    );
  }
}

 