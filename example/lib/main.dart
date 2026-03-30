import 'dart:math';

import 'package:cue/cue.dart';
import 'package:example/examples/horizinally_expanding_cards.dart';

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
      // showPerformanceOverlay: true,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: .light,
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
  Offset offset = Offset.zero;
  late final _controller = CueController(vsync: this, motion: .defaultTime);
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainer,
      appBar: AppBar(),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              //  SlackStyleFab(),
              //  DeleteConfirmationDialog(),
              // if(false)
              // IndicatorToButton(),
              //   GestureDetector(
              //     behavior: HitTestBehavior.translucent,
              //     onVerticalDragUpdate: (details) {
              //       setState(() {
              //         offset += details.delta;
              //       });
              //        _animation.setAnimatable(null);
              //     },
              //     onVerticalDragEnd: (details) async{
              //       final animtable = TweenAnimtable(Tween(begin: offset, end: Offset.zero));
              //       _animation.setAnimatable(animtable);
              //         _controller.value = 0;
              //        await _controller.forward();
              //       offset = Offset.zero;
              //     },
              //     child: ListenableBuilder(
              //       listenable: _animation,
              //       builder: (context, _) {
              //         print('build with offset ${_animation.hasAnimatable ? _animation.value : offset}');
              //         return Transform.translate(
              //           offset: _animation.hasAnimatable ? _animation.value : offset,
              //           child: FloatingActionButton(
              //             onPressed: null,
              //             child: Icon(Icons.abc),
              //           ),
              //         );
              //       },
              //     ),
              //   ),
              // Cue.onMount(
              //   child: SizedBox(
              //     width: 300,
              //     height: 300,
              //     child: Card(
              //       clipBehavior: .antiAlias,
              //       child: Actor(
              //         acts: [
              //           ParallaxAct(slide: .8),
              //         ],
              //         child: Image.network(
              //           'https://picsum.photos/400/300?random=1',
              //           fit: BoxFit.cover,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              HorizontallyExpandingCards(),
              if (false)
                for (var i = 0; i < 20; i++)
                  Cue.onScrollVisible(
                    child: Actor(
                      acts: [
                        .rotate3D(
                          from: Rotation3D(x: -30, y: 0, z: 0),
                          to: Rotation3D(x: 0, y: 0, z: 0),
                          alignment: .center,
                          perspective: .002,
                        ),
                      ],
                      child: Container(
                        height: 180,
                        width: 400,
                        clipBehavior: .antiAlias,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        alignment: .center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          'Item $i',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
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

class Box extends StatelessWidget {
  const Box({super.key, required this.color, required this.size});
  final Color color;
  final Size size;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: size.height,
      width: size.width,
      color: color,
    );
  }
}
 