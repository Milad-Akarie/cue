import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

class HorizontallyExpandingCards extends StatefulWidget {
  const HorizontallyExpandingCards({super.key});

  @override
  State<HorizontallyExpandingCards> createState() => _HorizontallyExpandingCardsState();
}

const cardsInfo = <({String title, String imageUrl})>[
  (
    title: 'Elegant',
    imageUrl: 'https://images.pexels.com/photos/261181/pexels-photo-261181.jpeg',
  ),
  (
    title: 'Awesome',
    imageUrl: 'https://images.pexels.com/photos/1166209/pexels-photo-1166209.jpeg',
  ),
  (
    title: 'Glamorous',
    imageUrl: 'https://images.pexels.com/photos/313032/pexels-photo-313032.jpeg',
  ),
];

class _HorizontallyExpandingCardsState extends State<HorizontallyExpandingCards> {
  int _expandedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: .symmetric(horizontal: 16),
      child: SizedBox(
        height: 200,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final spacing = 8.0;
            final availableWidth = constraints.maxWidth - (spacing * 2);
            return Row(
              spacing: spacing,
              mainAxisAlignment: .center,
              children: [
                for (var i = 0; i < cardsInfo.length; i++)
                  Cue.onToggle(
                    toggled: i == _expandedIndex,
                    motion: .simulation(const Spring.smooth()),
                    child: Card(
                      margin: .zero,
                      elevation: 0,
                      shape: RoundedSuperellipseBorder(borderRadius: .circular(20)),
                      clipBehavior: .antiAlias,
                      child: SizeActor(
                        from: .fromWidth(availableWidth * 0.16),
                        to: .fromWidth(availableWidth * 0.6),
                        allowOverflow: true,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: .3), .color),
                              image: NetworkImage(cardsInfo[i].imageUrl),
                              fit: .cover,
                              opacity: .8,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => setState(() {
                              if (_expandedIndex == i) {
                                _expandedIndex = -1;
                                return;
                              }
                              _expandedIndex = i;
                            }),
                            child: Padding(
                              padding: .fromLTRB(14, 14, 14, 0),
                              child: Column(
                                mainAxisAlignment: .end,
                                crossAxisAlignment: .start,
                                children: [
                                  Actor(
                                    effects: [
                                      AlignEffect(from: .bottomCenter, to: .bottomLeft),
                                      RotateLayoutEffect.turns(from: -1),
                                    ],
                                    child: Text(
                                      cardsInfo[i].title,
                                      style: textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: .bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Flexible(
                                    child: Actor(
                                      effects: [
                                        FadeEffect(),
                                        ClipEffect.vertical(from: .3),
                                      ],
                                      child: Padding(
                                        padding: .only(bottom: 14),
                                        child: Text(
                                          'This is a bunch of text that should only be visible when the card is expanded.',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: Colors.white,
                                            fontWeight: .w600,
                                          ),
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
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
