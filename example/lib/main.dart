import 'package:cue/cue.dart';
import 'package:example/examples/expanding_cards.dart';
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
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        splashFactory: NoSplash.splashFactory,
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: DemoPage(),
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

class __OnChangeDemoState extends State<_OnChangeDemo> {
  int _notificationsCount = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [ExpandingCards()],
        ),
      ),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> with SingleTickerProviderStateMixin {
  late final _tabsController = CueTabController(length: 5, vsync: this);
  final _pageController = CuePageController(viewportFraction: .1);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabsController,
          tabs: [
            for (int index = 0; index < 5; index++)
              Tab(
                child: Text('Tab ${index + 1}'),
              ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 300,
          child: PageView(
            controller: _pageController,
            children: [
              for (int index = 0; index < 5; index++)
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Cue.indexed(
                    controller: _pageController,
                    targetIndex: index,
                    child: GestureDetector(
                      onTap: () {
                        // _pageController.animateToPage(
                        //   index,
                        //   duration: Duration(milliseconds: 300),
                        //   curve: Curves.linear,
                        // );

                        _pageController.animateToPage(
                          index,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Actor(
                        effects: [
                          ScaleEffect(from: .5, to: 1.2),
                        ],
                        child: Container(
                          color: Colors.primaries[index % Colors.primaries.length].shade200,
                          child: Center(
                            child: Text(
                              'Page ${index + 1}',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                        ),
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

// Center(
// child: ModalTransition(
// // barrierColor: Colors.transparent,
// simulation: Spring.iosDefault,
// showDebug: true,
// duration: Duration(milliseconds: 600),
// triggerBuilder: (context, showModal) {
// return AnimatedBuilder(
// animation: CueScope.of(context).animation,
// builder: (context, _) {
// return Actor.fade(
// timing: .end(0),
// child: GestureDetector(
// onTap: showModal,
// child: ClipRRect(
// borderRadius: BorderRadius.circular(16),
// child: Image.network(
// 'https://picsum.photos/400/200?random=1',
// width: 200,
// height: 100,
// fit: BoxFit.cover,
// ),
// ),
// ),
// );
// },
// );
// },
// builder: (ctx, rect) {
// return Center(
// child: FractionallySizedBox(
// widthFactor: .9,
// child: Column(
// crossAxisAlignment: .start,
// mainAxisAlignment: .center,
// mainAxisSize: .min,
// children: [
// Actor.fade(
// from: 0,
// to: 1,
// timing: .startAt(.4),
// child: Card(
// margin: .zero,
// child: Actor(
// acts: [
// ClipRevealAct.horizontal(
// alignment: .centerLeft,
// from: .2,
// timing: .startAt(.4),
// ),
// ],
// child: SizedBox(
// height: 50,
// child: ListView.builder(
// padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
// scrollDirection: Axis.horizontal,
// shrinkWrap: true,
// itemBuilder: (context, index) {
// return Actor(
// acts: [
// SlideAct(from: Offset(-.5, 0)),
// ScaleAct.keyframes([
//     .key(0, at: .5),
//     .key(.2, at: index * .05),
//     .end(1.0),
// ]),
// ],
// child: Padding(
// padding: const EdgeInsets.symmetric(horizontal: 8),
// child: Center(
// child: Text(
// ['😀', '😎', '🤩', '🥳', '😇', '🙃', '😉', '😍'][index % 7],
// style: TextStyle(fontSize: 32),
// ),
// ),
// ),
// );
// },
// itemCount: 7,
// ),
// ),
// ),
// ),
// ),
//
// SizedBox(height: 12),
// Actor.resize(
// from: rect.size,
// to: Size(300, 150),
// timing: .endAt(.6),
// alignment: .topLeft,
// child: Actor.translateFromGlobal(
// offset: rect.topLeft,
// timing: .endAt(.6),
// child: ClipRRect(
// borderRadius: BorderRadius.circular(16),
// child: Image.network(
// 'https://picsum.photos/400/200?random=1',
// fit: BoxFit.cover,
// ),
// ),
// ),
// ),
// SizedBox(height: 12),
// Actor(
// timing: Timing(start: .4, end: .7),
// acts: [
// FadeAct(),
// BlurAct(from: 10),
// TranslateAct(from: Offset(0, 100)),
// ],
// child: Align(
// alignment: .topLeft,
// child: Card(
// margin: EdgeInsets.zero,
// elevation: .5,
// child: FractionallySizedBox(
// widthFactor: .7,
// child: Column(
// children: [
// ListTile(leading: Icon(Icons.share), title: Text('Share')),
// ListTile(leading: Icon(Icons.edit), title: Text('Edit')),
// ListTile(leading: Icon(Icons.delete), title: Text('Delete')),
// ListTile(leading: Icon(Icons.download), title: Text('Download')),
// ListTile(leading: Icon(Icons.info), title: Text('Details')),
// ],
// ),
// ),
// ),
// ),
// ),
// ],
// ),
// ),
// );
// },
// ),
// ),
