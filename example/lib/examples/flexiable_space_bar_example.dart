// this is just fun example to show how Cue can be used in a more complex scenario,
// it's not meant to be a real world example as alot of hardcoded values and images are used,
// it's just to show the capabilities of Cue and Gooey and how it can be used to create complex animations with ease.
import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:gooey/gooey.dart';

class FlexibleSpaceBarExample extends StatelessWidget {
  const FlexibleSpaceBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 165,
            pinned: true,
            toolbarHeight: 50,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigoAccent, Colors.deepOrange],
                  begin: .topLeft,
                  end: .bottomRight,
                ),
              ),
              child: GooeyZone(
                color: Colors.black,
                gooiness: 25,
                child: Stack(
                  alignment: .topCenter,
                  fit: .expand,
                  children: [
                    // a fake dynamic island that's a gooey blob.
                    Positioned(
                      top: MediaQuery.viewInsetsOf(context).top + 16,
                      child: GooeyBlob(
                        shape: .rounded(32),
                        child: SizedBox(width: 125, height: 34),
                      ),
                    ),
                    Positioned.fill(
                      child: CueFlexibleSpaceBar(
                        expandedTitleScale: 1.35,
                        title: Column(
                          mainAxisSize: .min,
                          children: [
                            Text(
                              'Milad Akarie',
                              style: textTheme.titleSmall!.copyWith(color: Colors.white, height: 1.15),
                            ),
                            Text(
                              'Gooey Cue Expert',
                              style: textTheme.bodySmall!.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                        background: Center(
                          child: Actor(
                            acts: [
                              .slideY(to: -.07),
                              .zoomOut(alignment: .topCenter),
                              .fadeOut(),
                              .unfocus(to: 8, delay: 75.ms),
                            ],
                            child: GooeyBlob(
                              child: Actor(
                                acts: [.scale(to: .65)],
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.saturation(0),
                                  child: CircleAvatar(
                                    radius: 44,
                                    backgroundImage: NetworkImage(
                                      'https://pbs.twimg.com/profile_images/1781812346102456321/N7RaCdD3_400x400.jpg',
                                    ),
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
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverList.builder(
              itemCount: 50,
              itemBuilder: (context, index) => Card(
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: Colors.black12, width: .5),
                ),
                elevation: 0,
                child: ListTile(
                  title: Text(['Hello', 'World', 'Flutter', 'Cue', 'Gooey'][index % 5]),
                  subtitle: Text(
                    [
                      'This is a subtitle',
                      'Another subtitle',
                      'Flutter is awesome',
                      'Cue is amazing',
                      'Gooey is fun',
                    ][index % 5],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
