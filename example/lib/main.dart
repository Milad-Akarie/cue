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
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        splashFactory: InkSparkle.splashFactory,
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

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> with SingleTickerProviderStateMixin {
  bool _toggled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Center(
          child: Cue.onToggle(
            // debug: true,
            // simulation: const Spring.bouncy(),
            toggled: _toggled,
            effects: [
              // ScaleEffect(from: .5, to: 1, reverse: ReverseConfig(from: 1, to: .8)),
              SizeEffect(
                from: .square(50),
                to: Size(.infinity, .infinity),
                reverse: ReverseConfig(
                  from: Size(.infinity, .infinity),
                  to: .square(100),
                ),
              ),
            ],
            child: GestureDetector(
              onTap: () => setState(() => _toggled = !_toggled),
              child: Container(
                width: 200,
                height: 200,
                color: Colors.blue,
              ),
            ),
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
