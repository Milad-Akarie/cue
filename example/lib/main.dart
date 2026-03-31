import 'package:cue/cue.dart';
import 'package:example/examples/delete_confirmation.dart';
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

class _DemoPageState extends State<DemoPage> {
  bool toggled = false;
  final focuseNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cue Demo'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                toggled = !toggled;
              });
            },
            icon: const Icon(Icons.toggle_on),
          ),
        ],
      ),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 10; i++)
                Cue.onScrollVisible(
                  acts: [.slideY(from: 1, reverse: .to(-1))],
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
