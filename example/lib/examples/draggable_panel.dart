import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

class DraggablePanel extends StatefulWidget {
  const DraggablePanel({super.key});

  @override
  State<DraggablePanel> createState() => _DraggablePanelState();
}

class _DraggablePanelState extends State<DraggablePanel> {
  final _dragExtent = 250.0;
  bool _isDraggedDown = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Cue.onToggle(
      toggled: _isDraggedDown,
      onEnd: (forward) {
        setState(() {
          _isDraggedDown = forward;
        });
      },
      motion: .easeInOut(400.ms),
      child: CardTheme(
        data: theme.cardTheme.copyWith(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: theme.colorScheme.surfaceContainerHigh,
        ),
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 16,
              left: 24,
              right: 24,
              height: _dragExtent - 32,
              child: Row(
                crossAxisAlignment: .stretch,
                spacing: 8,
                children: [
                  Expanded(
                    child: Actor(
                      acts: [
                        .scale(from: 1.1),
                        .slideY(from: .3),
                      ],
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Drag the cover card up and down to see the animation'),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Actor(
                      acts: [
                        .scale(from: 1.1),
                        .slideY(from: .3),
                      ],
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text('Drag the cover card up and down to see the animation'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            PositionedActor(
              from: .fill(),
              to: .fromSTEB(20, _dragExtent, 20, 24),
              child: CueDragScrubber(
                distance: _dragExtent,
                axisDirection: .down,
                scrubDirection: .forward,
                child: CardActor(
                  clipBehavior: .antiAlias,
                  elevation: .fixed(.3),
                  borderRadius: .tween(
                    BorderRadius.circular(24),
                    BorderRadius.circular(48),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Actor(
                        acts: [.parallax(slide: .2, axis: .horizontal)],
                        child: Image.network(
                          'https://cdn.pixabay.com/photo/2024/10/06/11/55/cow-9099854_1280.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Actor(
                            acts: [
                              .slideUp(),
                              .focus(),
                              .fadeIn(),
                              .scale(from: 1.3),
                              .clipHeight(),
                            ],
                            child: Column(
                              crossAxisAlignment: .start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Cute Cow',
                                  style: theme.textTheme.headlineMedium!.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: .5),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'This is a cute cow. It is very cute and friendly. It loves to eat grass and play with other cows.',
                                  style: theme.textTheme.bodyLarge!.copyWith(
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: .5),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
