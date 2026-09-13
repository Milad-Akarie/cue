import 'package:cue/cue.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:gooey/gooey.dart';

void main() => runApp(
  MaterialApp(
    home: FabExample(),
    builder: (context, child) {
      if (kDebugMode) {
        return CueDebugTools(alignment: .bottomRight, child: child!);
      }
      return child!;
    },
  ),
);

class FabExample extends StatefulWidget {
  const FabExample({super.key});

  @override
  State<FabExample> createState() => _FabExampleState();
}

class _FabExampleState extends State<FabExample> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButtonTheme(
      data: const FloatingActionButtonThemeData(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
        elevation: 1.0,
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('FAB Example')),
        body: Center(
          child: SizedBox.square(
            dimension: 140,
            child: Cue.onToggle(
              toggled: _isOpen,
              motion: .wobbly(),
              reverseMotion: .smooth(),
              child: GooeyZone(
                color: Colors.black,
                gooiness: 16,
                child: Stack(
                  children: [
                    Actor(
                      acts: [.align(to: .topLeft)],
                      child: GooeyBlob(
                        child: FloatingActionButton.small(
                          onPressed: () {},
                          child: Actor(
                            acts: const [
                              .zoomIn(),
                              .fadeIn(),
                            ],
                            child: const Icon(Icons.layers),
                          ),
                        ),
                      ),
                    ),
                    Actor(
                      acts: [.align(to: .topRight)],
                      child: GooeyBlob(
                        child: FloatingActionButton.small(
                          onPressed: () {},
                          child: Actor(
                            acts: const [
                              .zoomIn(),
                              .fadeIn(),
                            ],
                            child: const Icon(Icons.edit),
                          ),
                        ),
                      ),
                    ),
                    Actor(
                      acts: [.align(to: .bottomLeft)],
                      child: GooeyBlob(
                        child: FloatingActionButton.small(
                          onPressed: () {},
                          child: Actor(
                            acts: const [
                              .zoomIn(),
                              .fadeIn(),
                            ],
                            child: const Icon(Icons.delete),
                          ),
                        ),
                      ),
                    ),
                    Actor(
                      acts: [.align(to: .bottomRight)],
                      child: GooeyBlob(
                        child: FloatingActionButton.small(
                          onPressed: () {},
                          child: Actor(
                            acts: const [
                              .zoomIn(),
                              .fadeIn(),
                            ],
                            child: const Icon(Icons.share),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: GooeyBlob(
                        child: FloatingActionButton(
                          onPressed: () {
                            setState(() {
                              _isOpen = !_isOpen;
                            });
                          },
                          child: Actor(
                            acts: const [
                              .rotate(to: 45),
                            ],
                            child: const Icon(Icons.add),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
