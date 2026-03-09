import 'package:cue/cue.dart';
import 'package:example/examples/indicator_to_button_2.dart';

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
  final _sheetController = DraggableScrollableController();
  final _pageController = CuePageController(viewportFraction: .85);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    BoxDecoration;
    return Scaffold(
      // backgroundColor: Colors.blue,
      appBar: AppBar(),
      bottomSheet: DraggableScrollableSheet(
        controller: _sheetController,
        expand: false,
        initialChildSize: 0.2,
        minChildSize: 0.2,
        maxChildSize: .6,
        snapAnimationDuration: const Duration(milliseconds: 300),
        builder: (context, scrollController) {
          return Cue.onProgress(
            listenable: _sheetController,
            progress: () => _sheetController.isAttached ? _sheetController.size : 0.0,
            min: 0.2,
            max: 0.8,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  for (var i = 6; i > 0; i--)
                    Actor(
                      act: .compose([
                        .slideY(from: -.8 * i,),
                        .scale(to: .5 + i * (.5/5), from: 0),
                      
                    ]),
                    child: Card(
                      elevation: i * .5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: BorderSide(color: theme.colorScheme.primary, width: 1.0),
                      ),
                      child: ListTile(
                        leading: const Icon(Iconsax.box),
                        title: Text('Item $i'),
                        subtitle: const Text('Subtitle'),
                      ),
                    ),
                  ),
              ]
            ),
            ),
          );
        },
      ),
      body: IndicatorToButton2(),
    );
  }
}
