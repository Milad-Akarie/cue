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
          height: 200,
          child: PageView.builder(
            controller: _cuePageController,
            itemCount: 5,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Cue.indexed(
                index: index,
                controller: _cuePageController,
                child: Actor(
                  act: .zoomIn(from: .8),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    elevation: .2,
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: 88,
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
                            act: .compose([
                              .resize(
                                from: .square(10),
                                to: isLast ? .height(44) : NSize(w: 38, h: 10),
                              ),
                              if (isLast) .zoomIn(),
                              if (isLast) .slideX(from: -1),
                            ]),
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
