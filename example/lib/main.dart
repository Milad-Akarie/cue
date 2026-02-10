import 'package:cue/cue.dart';
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
      darkTheme: ThemeData.dark(),
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
      body: Align(
        alignment: .center,
        child: Cue.onMount(
          debug: true,
          duration: Duration(seconds: 2),
          child: Actor(
            acts: [
              Translate.keyframes([
                .begin(Offset(0, 0)),
                .key(Offset(0, -120), at: 0.25),
                .key(Offset(0, 0), at: 0.5),
                .key(Offset(0, -80), at: 0.65),
                .key(Offset(0, 0), at: 0.8),
                .key(Offset(0, -40), at: 0.9),
                .end(Offset(0, 0)),
              ]),
              Scale.keyframes([
                .begin(1.0),
                .key(1.5, at: 0.25),
                .key(1.0, at: 0.5),
                .key(1.25, at: 0.65),
                .key(1.0, at: 0.8),
                .key(1.125, at: 0.9),
                .end(1.0),
              ]),
            ],
            child: TweenActor(
              timing: .startAt(.5),
              tween: ColorTween(begin: Colors.deepPurple, end: Colors.green),
              builder: (context, value, _) {
                return Container(
                  width: 50,
                  height: 50,
                  color: value,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
