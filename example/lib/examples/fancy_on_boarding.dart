import 'package:cue/cue.dart';
import 'package:material_ui/material_ui.dart';

const pageInfo = <(String title, String description)>[
  (
    'Meet Cue',
    'A physics-first animation framework built on primitives, not presets.',
  ),
  (
    'Fluid by Default',
    'Spring-driven motion that feels alive — no easing curves to fiddle with.',
  ),
  (
    'You Own Every Frame',
    'Compose actors, acts, and cues to build exactly the motion you have in mind.',
  ),
  (
    'Start Cueing',
    'Drop in an Actor, wire up a Cue, and watch your UI come to life.',
  ),
];

class FancyOnBoarding extends StatefulWidget {
  const FancyOnBoarding({super.key});

  @override
  State<FancyOnBoarding> createState() => _FancyOnBoardingState();
}

class _FancyOnBoardingState extends State<FancyOnBoarding> {
  final _pageController = CuePageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    colors.surface,
                    colors.surface.withValues(alpha: 0),
                    colors.surface.withValues(alpha: 0),
                    colors.surface,
                  ],
                  stops: const [0.0, 0.15, 0.8, .9],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Align(
                  alignment: .bottomCenter,
                  child: Padding(
                    padding: const .only(top: 16),
                    child: Cue.onProgress(
                      listenable: _pageController,
                      progress: () => _pageController.globalOffset,
                      max: 3,
                      acts: [
                        SlideAct.keyframed(
                          frames: .fractional([
                            .key(const Offset(0, .25), at: 0.0),
                            .key(const Offset(-.25, .35), at: 0.33),
                            .key(const Offset(0, -.25), at: 0.66),
                            .key(const Offset(0, 0), at: 1.0),
                          ]),
                        ),
                        ScaleAct.keyframed(
                          frames: .fractional([
                            .key(1.3, at: 0.0),
                            .key(1.5, at: 0.33),
                            .key(1.4, at: 0.66),
                            .key(0.85, at: 1.0),
                          ]),
                        ),
                      ],
                      child: IPhoneFrame(
                        child: Image.asset(
                          'assets/images/screenshot.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: ColoredBox(
              color: colors.surface,
              child: Cue.indexed(
                index: 3,
                controller: _pageController,
                acts: [.slideY(to: -.25)],
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const ClampingScrollPhysics(),
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: pageInfo.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  pageInfo[_currentPage].$1,
                                  style: text.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  pageInfo[_currentPage].$2,
                                  style: text.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const .fromLTRB(28, 12, 28, 24),
                      child: Row(
                        mainAxisAlignment: .center,
                        children: List.generate(
                          pageInfo.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? colors.primary : colors.onSurface.withValues(alpha: .3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Actor(
                      acts: [.fadeIn(), .slideUp()],
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        label: Text("Let's Go"),
                        iconAlignment: .end,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.primary,
                          side: BorderSide(color: colors.primary),
                        ),
                        icon: Icon(Icons.arrow_forward_ios_outlined, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IPhoneFrame extends StatelessWidget {
  final Widget child;

  const IPhoneFrame({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 19.5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.grey[900]!, width: 3),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(38),
          child: child,
        ),
      ),
    );
  }
}
