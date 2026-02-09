import 'package:cue/cue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'examples/three_dots_action.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cue Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: DemoPage(),
      builder: (context, child) {
        if (kDebugMode) {
          return CueDebugTools(
            child: child!,
          );
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cue Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            // SizedBox(height: 400),
            Center(child: ThreeDotsAction()),
            // if (false)
            // Cue.onMount(
            //   debug: true,
            //   child: Actor(
            //     act: widget.act,
            //     child: Container(
            //       width: 50,
            //       height: 50,
            //       color: Colors.blue,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
