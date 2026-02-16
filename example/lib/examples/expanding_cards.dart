import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

class ExpandingCards extends StatefulWidget {
  const ExpandingCards({super.key});

  @override
  State<ExpandingCards> createState() => _ExpandingCardsState();
}

class _ExpandingCardsState extends State<ExpandingCards> {
  int _expandedIndex = -1;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FractionallySizedBox(
      widthFactor: .8,
      child: Column(
        children: [
          for (final i in [0, 1, 2])
            Cue.onToggle(
              debug: _expandedIndex == i,
              toggled: _expandedIndex == i,
              child: Builder(
                builder: (context) {
                  final isActive = i == _expandedIndex;
                  final isPrevious = i - 1 == _expandedIndex;
                  final isNext = i + 1 == _expandedIndex;

                  final fromTopRadius = isActive || isPrevious || i == 0 ? Radius.circular(28) : Radius.zero;
                  final fromBottomRadius = isActive || isNext || i == 2 ? Radius.circular(28) : Radius.zero;

                  return Actor(
                    acts: [
                      PaddingAct(to: const EdgeInsets.symmetric(vertical: 12)),
                      DecorateAct(
                        from: BoxDecoration(
                          color: theme.colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.vertical(
                            top: fromTopRadius,
                            bottom: fromBottomRadius,
                          ),
                        ),
                        to: BoxDecoration(
                          color: theme.colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                    ],
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () {
                        setState(() {
                          if (_expandedIndex == i) {
                            _expandedIndex = -1;
                            return;
                          }
                          _expandedIndex = i;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.sailing_outlined, size: 20),
                                SizedBox(width: 12),
                                Expanded(child: Text('Header Here')),
                                Actor.rotateTurns(
                                  from: 0,
                                  to: -2,
                                  child: Icon(Icons.expand_more_rounded),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Actor(
                              acts: [
                                ClipRevealAct.vertical(),
                                BlurAct(from: 6),
                                SlideAct.y(from: .2),
                              ],
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                                child: Column(
                                  children: [
                                    Text(
                                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec auctor, nisl eget ultricies lacinia.',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
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
            ),
        ],
      ),
    );
  }
}
