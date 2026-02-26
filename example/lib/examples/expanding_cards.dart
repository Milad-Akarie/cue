import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ExpandingCards extends StatefulWidget {
  const ExpandingCards({super.key});

  @override
  State<ExpandingCards> createState() => _ExpandingCardsState();
}

class _ExpandingCardsState extends State<ExpandingCards> {
  int _expandedIndex = -1;

  final _cardIfno = <(String title, IconData icon)>[
    ('Expandable Cards', Iconsax.card_edit),
    ('Flutter is Awesome', Iconsax.cup),
    ('Smooth Animations', Iconsax.battery_charging),
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
              toggled: _expandedIndex == i,
              motion: .simulation(Spring.smooth(damping: 23)),
              child: Builder(
                builder: (context) {
                  final isLast = i == _cardIfno.length - 1;
                  final isActive = i == _expandedIndex;
                  final isPrevious = _expandedIndex - 1 == i;
                  final isNext = _expandedIndex + 1 == i;

                  final fromTopRadius = isActive || i == 0 || isNext ? 24.0 : 0.0;
                  final fromBottomRadius = isActive || isLast || isPrevious ? 24.0 : 0.0;

                  return Actor(
                    effects: [
                      PaddingEffect(to: const .symmetric(vertical: 12)),
                      ScaleEffect(from: 1.0, to: 1.01),
                    ],
                    child: Material(
                      clipBehavior: .hardEdge,
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: .vertical(
                        top: Radius.circular(fromTopRadius),
                        bottom: Radius.circular(fromBottomRadius),
                      ),
                      child: InkWell(
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
                          padding: const .fromLTRB(20, 16, 16, 0),
                          child: Column(
                            spacing: 12,
                            children: [
                              Row(
                                children: [
                                  Icon(_cardIfno[i].$2, size: 20),
                                  SizedBox(width: 12),
                                  Expanded(child: Text(_cardIfno[i].$1)),
                                  RotateActor.degrees(
                                    to: -180,
                                    child: Icon(
                                      Icons.expand_more_rounded,
                                      color: theme.colorScheme.onSurface.withValues(alpha: .6),
                                    ),
                                  ),
                                ],
                              ),
                              Actor(
                                effects: [
                                  FadeEffect(),
                                  ClipEffect.vertical(),
                                  BlurEffect(from: 8),
                                  SlideEffect.y(from: .5),
                                ],
                                child: Padding(
                                  padding: const .only(left: 8, right: 8, bottom: 12),
                                  child: Text(
                                    'Lorem ipsum dolor sit amet, consectetur for on adipiscing elit. Donec auctor, nisl eget ultricies lacinia.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: .7),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
