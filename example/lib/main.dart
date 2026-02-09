import 'package:cue/cue.dart';
import 'package:example/examples/three_dots_action.dart';
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
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const DemoPage(),
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Cue Demo'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 400,
          ),
          Center(child: ThreeDotsAction()),
          if (false)
            Center(
              child: Cue.onMount(
                loop: true,
                duration: const Duration(seconds: 1),
                simulation: Spring.bouncy,
                reverseOnLoop: false,
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey,
                  alignment: Alignment.topLeft,
                  child: Actor(
                    acts: [
                      .translate(
                        begin: Offset.zero,
                        then: [
                          .to(Offset(50, 0)),
                          .to(Offset(50, 50)),
                          .to(Offset(0, 50)),
                          .to(Offset(0, 0)),
                        ],
                      ),
                      .fade(
                        begin: 0.0,
                        then: [.to(.2), .to(4.0), .to(1.0)],
                      ),
                    ],
                    child: Container(
                      width: 50,
                      height: 50,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
