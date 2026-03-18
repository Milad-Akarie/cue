import 'package:cue/cue.dart';
import 'package:example/examples/delete_confirmation.dart';
import 'package:example/examples/expanding_cards.dart';
import 'package:example/examples/horizinally_expanding_cards.dart';
import 'package:example/examples/indicator_to_button.dart';
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
  late final _controller = CueController(vsync: this, motion: .wobbly());

  late final _animation = DeferredCueAnimation<Offset>(
    parent: _controller.timeline.mainTrack,
    context: ActContext(motion: _controller.timeline.mainTrack.motion),
  );

  Offset offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // backgroundColor: Colors.blue,
      appBar: AppBar(),
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //  SlackStyleFab(),
              //  DeleteConfirmationDialog(),
              // IndicatorToButton(),
              Cue.onToggle(
                toggled: checked,
                motion: .linear(300.ms),
                // motion: .smooth(),
                child: Column(
                  children: [
                    Actor(
                      act: .compose([
                        .slideX(to: 1, delay: 300.ms),
                      ]),
                      child: Container(
                        height: 100,
                        width: 100,
                        color: Colors.blue,
                      ),
                    ),
                    Actor(
                      act: .compose([
                        .slideX(to: 1),
                      ]),
                      child: Container(
                        height: 100,
                        width: 100,
                        color: Colors.red,
                      ),
                    ),

                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => setState(() => checked = !checked),
                      child: Text('Toggle'),
                    ),
                  ],
                ),
              ),

              //  SlackStyleFab(),
              //  DeleteConfirmationDialog(),
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

              // for (var i = 0; i < 20; i++)
              //   Cue.onScrollVisible(
              //     key: ValueKey(i),
              //     act: .compose([
              //       .zoomIn(from: .75),
              //       .slideY(from: 0, reverse: .to(1.1)),
              //       .fadeOut(reverse: .exclusive()),
              //     ],motion: .curved(.zero,curve:  Curves.easeInOut)),
              //     child: Container(
              //       height: 220,
              //       width: double.infinity,
              //       margin: const EdgeInsets.only(bottom: 8.0),

              //       decoration: BoxDecoration(
              //         color: Colors.green,
              //         borderRadius: BorderRadius.circular(12.0),
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.black.withOpacity(0.3),
              //             blurRadius: 8.0,
              //             offset: const Offset(0, 4),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
