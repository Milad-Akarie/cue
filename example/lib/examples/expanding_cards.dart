import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

class ExpandingCards extends StatefulWidget {
  const ExpandingCards({super.key});

  @override
  State<ExpandingCards> createState() => _ExpandingCardsState();
}

class _ExpandingCardsState extends State<ExpandingCards> {
  int _expandedIndex = -1;
  int _previousExpandedIndex = -1;

  final _cardIfno = <(String title, IconData icon)>[
    ('Card One', Icons.sailing_outlined),
    ('Card Two', Icons.sailing_outlined),
    ('Card Three', Icons.sailing_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FractionallySizedBox(
      widthFactor: .8,
      child: Column(
        children: [
          for (var i = 0; i < _cardIfno.length; i++)
            Cue.onToggle(
              // debug: _expandedIndex == i,
              toggled: _expandedIndex == i,
              // simulation: Spring.smooth(),
              child: Builder(
                builder: (context) {
                  final isLast = i == _cardIfno.length - 1;
                  final isActive = i == _expandedIndex;
                  final isPrevious = _expandedIndex - 1 == i;
                  final isNext = _expandedIndex + 1 == i;

                  final wasActive = i == _previousExpandedIndex;
                  final wasPrevious = _previousExpandedIndex - 1 == i;
                  final wasNext = _previousExpandedIndex + 1 == i;

                  // TO (current state)
                  final toTopRadius = i == 0 || isActive || isNext ? const Radius.circular(28) : Radius.zero;
                  final toBottomRadius = isLast || isActive || isPrevious ? const Radius.circular(28) : Radius.zero;

                  // FROM (previous state)
                  final fromTopRadius = i == 0 || wasActive || wasNext ? const Radius.circular(28) : Radius.zero;
                  final fromBottomRadius = isLast || wasActive || wasPrevious ? const Radius.circular(28) : Radius.zero;

                  final decoration = BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: .circular(28),
                  );

                  return Actor(
                    effects: [
                      PaddingEffect(to: const .symmetric(vertical: 12), from: const .symmetric(vertical: 2)),
                      DecorateEffect(
                        from: decoration.copyWith(
                          borderRadius: .vertical(
                            top: fromTopRadius,
                            bottom: fromBottomRadius,
                          ),
                        ),
                        to: decoration.copyWith(
                          borderRadius: .vertical(
                            top: toTopRadius,
                            bottom: toBottomRadius,
                          ),
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
                          _previousExpandedIndex = _expandedIndex;
                          _expandedIndex = i;
                        });
                      },
                      child: Padding(
                        padding: const .fromLTRB(16, 16, 16, 0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(_cardIfno[i].$2, size: 20),
                                SizedBox(width: 12),
                                Expanded(child: Text(_cardIfno[i].$1)),
                                RotateActor.turns(
                                  to: -2,
                                  child: Icon(Icons.expand_more_rounded),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Actor(
                              effects: [
                                // ClipEffect.vertical(),
                                BlurEffect(from: 6),
                                SlideEffect.y(from: .2),
                              ],
                              child: Padding(
                                padding: const .only(left: 8, right: 8, bottom: 8),
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
