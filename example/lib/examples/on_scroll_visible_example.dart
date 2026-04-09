import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class OnScrollVisibleExample extends StatelessWidget {
  const OnScrollVisibleExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('On Scroll Visible'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: .all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: .symmetric(vertical: 8),
            child: Cue.onScrollVisible(
              acts: [
                // forward from Offset(-.6, 0) to  Offset.zero
                // reverse from Offset.zero to Offset(0, .8)
                .slide(from: Offset(-.6, 0), reverse: .to(Offset(0, .8))),
                .scale(from: 0.85),
                .fadeIn(),
              ],
              child: _BigCard(index: index),
            ),
          );
        },
      ),
    );
  }
}

class _BigCard extends StatelessWidget {
  final int index;

  const _BigCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final titles = ['Mountain View', 'Ocean Breeze', 'Forest Walk', 'City Skyline', 'Desert Sun'];
    final subtitles = [
      'Discover amazing places',
      'Experience nature',
      'Urban adventure',
      'Tropical escape',
      'Winter wonder',
    ];
    final icons = [Iconsax.arrow_circle_up, Iconsax.drop, Iconsax.tree, Iconsax.buildings, Iconsax.cloud_snow];

    final title = titles[index % titles.length];
    final subtitle = subtitles[index % subtitles.length];
    final icon = icons[index % icons.length];

    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://picsum.photos/id/${index + 160}/800/600',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Explore',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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
  }
}
