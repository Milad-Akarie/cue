import 'package:cue/cue.dart';
import 'package:example/examples/horizinally_expanding_cards.dart';
import 'package:example/examples/smooth_toggle.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Cue.onMount(
              acts: [
                PathMotionAct.circular(radius: 80)
              ],
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            CueModalTransition(
              triggerBuilder: (context, open) {
                return InkWell(
                  onTap: open,
                  child: Card(
                    child: SizedBox.square(
                      dimension: 200,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text('Hello, Cue!'),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              alignment: .center,
              hideTriggerOnTransition: true,
              motion: .smooth(),
              builder: (context, rect) {
                return Actor(
                  acts: [
                    .rotate3D(from: Rotation3D(y: 180)),
                    .sizedBox(
                      width: .tween(from: rect.width, to: 400),
                      height: .tween(from: rect.height, to: 300),
                    ),
                  ],
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Actor(
                            acts: [
                              .slideY(from: -2),
                              .fadeIn(),
                            ],
                            child: Text('Hello, Cue!'),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Actor(
                              delay: 100.ms,
                              acts: [
                                .clip(borderRadius: BorderRadius.circular(16), alignment: .bottomCenter),
                                .fadeIn(),
                                .slideUp(),
                              ],
                              child: SizedBox(
                                width: double.infinity,
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
