import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

class HorizontallyExpandingCards extends StatefulWidget {
  const HorizontallyExpandingCards({super.key});

  @override
  State<HorizontallyExpandingCards> createState() => _HorizontallyExpandingCardsState();
}

class _HorizontallyExpandingCardsState extends State<HorizontallyExpandingCards> {
  int _expandedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 400,
      child: Cue.onMount(
        acts: [
          ResizeAct.fractional(
            from: Size(.1, 1),
            to: Size(.5, 1),
          ),
        ],
        child: Container(
          height: 200,
          width: 200,
          color: Colors.red,
          child: Text('Hello there this is some text that should be visible when the card is expanded.'),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 200,
        child: Row(
          mainAxisAlignment: .center,
          children: [
            for (final i in [0, 1, 2])
              Cue.onToggle(
                // debug: _expandedIndex == i,
                toggled: i == _expandedIndex,
                duration: const Duration(milliseconds: 500),
                child: Card(
                  elevation: .5,
                  clipBehavior: .antiAlias,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      if (_expandedIndex == i) {
                        _expandedIndex = -1;
                        return;
                      }
                      _expandedIndex = i;
                    }),
                    child: Actor(
                      acts: [
                        ResizeAct.fractional(
                          from: Size(.1, 1),
                          to: Size(.6, 1),
                        ),
                      ],
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: [Colors.red, Colors.green, Colors.blue][i].shade400,
                          image: DecorationImage(
                            image: NetworkImage('https://picsum.photos/id/${i + 400}/400/300'),
                            fit: BoxFit.cover,
                            opacity: .5,
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
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: .end,
                              crossAxisAlignment: .center,
                              children: [
                                Actor(
                                  acts: [
                                    TranslateAct.y(from: 20, timing: .startAt(.2)),
                                    RotateAct.turns(from: -1),
                                    AlignAct(
                                      from: Alignment.bottomCenter,
                                      to: Alignment.bottomLeft,
                                      timing: .endAt(.2),
                                    ),
                                  ],
                                  child: Text(
                                    ['Cool', 'Elegant', 'Awesome'][i],
                                    style: textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Actor(
                                  acts: [
                                    FadeAct(),
                                    TranslateAct.y(from: 50, timing: .startAt(.5)),
                                  ],
                                  child: Text(
                                    'This is a bunch of text that should only be visible when the card is expanded.',
                                    style: textTheme.bodyMedium?.copyWith(color: Colors.white),
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
              ),
          ],
        ),
      ),
    );
  }
}
