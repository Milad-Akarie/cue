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
        child: ListView(
          padding: const EdgeInsets.all(0),
          children:  [
              // ElevatedButton(
              //   onPressed: () {
              //     showCueModalBottomSheet(
              //       context: context,
              //       showDragHandle: true,
              //       enableDrag: true,
              //       motion: .linear(400.ms),
              //       builder: (context) => Container(
              //         height: 320,
              //         width: double.infinity,
              //         margin: const EdgeInsets.only(bottom: 8.0),
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(12.0),
              //         ),
              //         child: Center(child: Actor(
              //          motion: .wobbly(),
              //           acts: [
              //             .fadeIn(),
              //             .slideY(from: -8),
              //             .zoomIn(from: .0),
              //           ],
              //           child: Text('Hello World!'))),
              //       ),
              //       // sheetAnimationStyle: .spring(damping: 20, stiffness: 200), --- IGNORE ---
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
                for (var i = 0; i < 100; i++)
                  Cue.onScrollVisible(
                    key: ValueKey(i),
                    child: Actor(
                      // motion: .smooth(),
                      acts: [
                        .slideX(from: -1, reverse: .to(1)),
                        .scale(from: .5, to: 1.0),
                      ],
                      child: Container(
                        height: 220,
                        margin:  const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
            ],
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
      color:  color,
    
    );
  }
}
