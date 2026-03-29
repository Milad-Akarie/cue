import 'dart:math';

import 'package:cue/cue.dart';
import 'package:example/examples/delete_confirmation.dart';
import 'package:example/examples/expanding_cards.dart';
import 'package:example/examples/horizinally_expanding_cards.dart';
import 'package:example/examples/indicator_to_button.dart';
import 'package:example/examples/options_button.dart';
import 'package:example/examples/slack_style_fab.dart';
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
              // ElevatedButton(
              //   onPressed: () {
              //     showCueModalBottomSheet(
              //       context: context,
              //       showDragHandle: true,
              //       enableDrag: true,
              //       motion: .linear(.4),
              //       builder: (context) => Container(
              //         height: 320,
              //         width: double.infinity,
              //         margin: const EdgeInsets.only(bottom: 8.0),
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(12.0),
              //         ),
              //         child: Center(child: Actor(
              //          motion: .wobbly(),
              //          reverseMotion: .linear(.4),
              //           acts: [
              //             .fadeIn(),
              //             .slideY(from: -8),
              //             .zoomIn(from: .0),
              //           ],
              //           child: Text('Hello World!'))),
              //       ),
              //     );
              //   },
              //   child: Text('Show BottomSheet'),
              // ),

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
              for (var i = 0; i < 20; i++)
                Cue.onScroll(
                  key: ValueKey(i),
                  child: Container(
                    height: 220,
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    width: double.infinity,
                    clipBehavior: .antiAlias,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Actor(
                      motion: .smooth(),
                      acts: [
                        // .slideX(from: -1),
                        .scale(from: 1.0, to: 1.3),
                        .parallax(slide: .3, axis: .vertical),
                      ],
                      child: Image.network(
                        'https://picsum.photos/400/300?random=$i',
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
