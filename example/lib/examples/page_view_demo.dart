import 'package:cue/cue.dart';
import 'package:example/examples/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class PageViewDemo extends StatefulWidget {
  const PageViewDemo({super.key});

  @override
  State<PageViewDemo> createState() => _PageViewDemoState();
}

class _PageViewDemoState extends State<PageViewDemo> {
  final _controller = CuePageController(viewportFraction: 0.7);

  final _pages = [
    (
      thumbnails: List.generate(5, (i) => 'https://picsum.photos/seed/11$i/200/150'),
      title: 'Mountain Adventure',
      description: 'Explore the breathtaking mountain landscapes and discover hidden trails through the wilderness.',
      icon: Iconsax.home,
    ),
    (
      thumbnails: List.generate(5, (i) => 'https://picsum.photos/seed/12$i/200/150'),
      title: 'Ocean Paradise',
      description: 'Dive into crystal clear waters and experience the serenity of pristine beach destinations.',
      icon: Iconsax.gallery_add,
    ),
    (
      thumbnails: List.generate(5, (i) => 'https://picsum.photos/seed/13$i/200/150'),
      title: 'Urban Exploration',
      description: 'Discover vibrant cityscapes and immerse yourself in local cultures around the world.',
      icon: Iconsax.buildings,
    ),
    (
      thumbnails: List.generate(5, (i) => 'https://picsum.photos/seed/14$i/200/150'),
      title: 'Forest Retreat',
      description: 'Find peace among ancient trees and reconnect with nature in lush green forests.',
      icon: Iconsax.tree,
    ),
    (
      thumbnails: List.generate(5, (i) => 'https://picsum.photos/seed/15$i/200/150'),
      title: 'Desert Safari',
      description: 'Embark on an unforgettable journey across golden sand dunes and star-filled nights.',
      icon: Iconsax.sun_1,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indexed Cue'),
        backgroundColor: Colors.transparent,
      ),
      bottomNavigationBar: SafeArea(child: BottomBar()),
      body: Padding(
        padding: const EdgeInsets.only(top: 100.0),
        child: FractionallySizedBox(
          heightFactor: .95,
          child: PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Cue.indexed(
                index: index,
                controller: _controller,
                acts: [
                  .scale(from: .85),
                  .slideY(to: -.05),
                  .rotate3D(
                    from: Rotation3D(y: 20),
                    to: Rotation3D.zero,
                    reverse: .to(Rotation3D(y: -20)),
                    perspective: -.001,
                  ),
                ],
                child: Card(
                  color: colors.surfaceContainer,
                  margin: const .symmetric(vertical: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: .circular(20),
                    side: BorderSide(color: colors.onSurface.withValues(alpha: 0.1), width: .5),
                  ),
                  elevation: 8,
                  shadowColor: const Color.fromARGB(255, 84, 83, 84).withValues(alpha: 0.2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          clipBehavior: .hardEdge,
                          width: .infinity,
                          decoration: BoxDecoration(
                            borderRadius: .circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Actor(
                            acts: [.parallax(slide: .2, axis: .vertical)],
                            child: Image.network(
                              'https://picsum.photos/seed/${index + 100}/700/800',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Actor(
                        acts: [
                          .clipHeight(alignment: .bottomCenter),
                          .scale(from: .85),
                          .fadeIn(from: .5),
                        ],
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: SizedBox(
                            height: 50,
                            child: ListView.separated(
                              scrollDirection: .horizontal,
                              itemCount: page.thumbnails.length,
                              padding: .symmetric(horizontal: 16),
                              separatorBuilder: (context, index) => const SizedBox(width: 8.2),
                              itemBuilder: (context, thumbIndex) {
                                return ClipRRect(
                                  borderRadius: .circular(8),
                                  child: SizedBox.square(
                                    dimension: 50,
                                    child: Image.network(
                                      page.thumbnails[thumbIndex],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: .fromLTRB(16, 8, 16, 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(page.icon, size: 24, color: colors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    page.title,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              page.description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Actor(
                              acts: [.fadeIn(), .slideUp()],
                              child: IconTheme(
                                data: IconThemeData(
                                  color: colors.primary,
                                  size: 20,
                                ),
                                child: Row(
                                  children: [
                                    Icon(Iconsax.heart, color: colors.error),
                                    const SizedBox(width: 4),
                                    Text('${(index + 1) * 123}', style: theme.textTheme.bodySmall),
                                    const SizedBox(width: 16),
                                    Icon(Iconsax.eye),
                                    const SizedBox(width: 4),
                                    Text('${(index + 1) * 456}', style: theme.textTheme.bodySmall),
                                    const Spacer(),
                                    Icon(Iconsax.bookmark, color: colors.secondary),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
