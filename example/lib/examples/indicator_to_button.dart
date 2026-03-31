import 'package:cue/cue.dart';
import 'package:flutter/material.dart';

class IndicatorToButton extends StatefulWidget {
  const IndicatorToButton({super.key});

  @override
  State<IndicatorToButton> createState() => _IndicatorToButtonState();
}

class _IndicatorToButtonState extends State<IndicatorToButton> {
  final _cuePageController = CuePageController(viewportFraction: .8);

  @override
  dispose() {
    _cuePageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 400,
          child: PageView.builder(
            controller: _cuePageController,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Cue.indexed(
                index: index,
                controller: _cuePageController,
                child: Actor(
                  acts: [
                    .rotate(
                      from: 4.5,
                      alignment: .bottomCenter,
                      reverse: .to(-4.5),
                    ),
                  ],
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    elevation: .2,
                    clipBehavior: .antiAlias,
                    shape: RoundedSuperellipseBorder(borderRadius: .circular(32)),
                    child: Actor(
                      acts: [.parallax(slide: .15, axis: .vertical)],
                      child: Image.network(
                        'https://picsum.photos/400/300?random=$index',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 5; i++)
                Builder(
                  builder: (context) {
                    final isLast = i == 4;
                    return Cue.indexed(
                      index: i,
                      controller: _cuePageController,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Actor(
                            acts: [
                              .sizedClip(
                                from: .square(10),
                                to: isLast ? .height(44) : NSize(w: 38, h: 10),
                              ),
                              if (isLast) .zoomIn(),
                              if (isLast) .slideX(from: -1),
                            ],
                            child: isLast
                                ? Padding(
                                    padding: const .symmetric(horizontal: 16),
                                    child: Row(
                                      mainAxisAlignment: .center,
                                      children: [
                                        Text(
                                          'Let’s Go',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white, fontSize: 15),
                                        ),
                                        SizedBox(width: 6),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
