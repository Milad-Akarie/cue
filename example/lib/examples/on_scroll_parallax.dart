import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class OnScrollParallax extends StatelessWidget {
  const OnScrollParallax({super.key});

  static final _cards = [
    (
      imageId: 1015,
      title: 'Mountain Adventure',
      subtitle: 'Explore the wild peaks',
      icon: Iconsax.arrow_circle_up,
      location: 'Swiss Alps',
    ),
    (
      imageId: 1016,
      title: 'Ocean Sunset',
      subtitle: 'Golden hour at the beach',
      icon: Iconsax.sun_1,
      location: 'Maldives',
    ),
    (
      imageId: 1018,
      title: 'Forest Trail',
      subtitle: 'Walk through ancient woods',
      icon: Iconsax.tree,
      location: 'Black Forest',
    ),
    (
      imageId: 1019,
      title: 'Desert Dunes',
      subtitle: 'Ride the golden sands',
      icon: Iconsax.sun_fog,
      location: 'Sahara',
    ),
    (
      imageId: 1020,
      title: 'City Lights',
      subtitle: 'Nightlife in the metropolis',
      icon: Iconsax.buildings,
      location: 'Tokyo',
    ),
    (
      imageId: 1021,
      title: 'Snowy Peaks',
      subtitle: 'Winter wonderland awaits',
      icon: Iconsax.cloud_snow,
      location: 'Alaska',
    ),
    (
      imageId: 1022,
      title: 'Tropical Paradise',
      subtitle: 'Relax in paradise',
      icon: Iconsax.emoji_happy,
      location: 'Hawaii',
    ),
    (
      imageId: 1024,
      title: 'Waterfall Trek',
      subtitle: 'Discover hidden cascades',
      icon: Iconsax.building,
      location: 'Iceland',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Destinations', style: Theme.of(context).textTheme.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final card = _cards[index];
          return _ParallaxCard(
            imageId: card.imageId,
            title: card.title,
            subtitle: card.subtitle,
            icon: card.icon,
            location: card.location,
            index: index,
          );
        },
      ),
    );
  }
}

class _ParallaxCard extends StatelessWidget {
  final int imageId;
  final String title;
  final String subtitle;
  final IconData icon;
  final String location;
  final int index;

  const _ParallaxCard({
    required this.imageId,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.location,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Cue.onScroll(
      acts: [
        // uncomment to add a subtle 3D rotation effect to the parallax card
        // Rotate3DAct.keyframed(
        //   frames: .fractional([
        //     .key(Rotation3D(x: 60, y: 20, z: 10), at: 0.0),
        //     .key(Rotation3D.zero, at: 0.5),
        //     .key(Rotation3D(x: -60, y: -20, z: -10), at: 1.0),
        //   ]),
        // ),
      ],
      child: Container(
        height: 280,
        margin: .symmetric(vertical: 8),
        decoration: BoxDecoration(borderRadius: .circular(24)),
        clipBehavior: .hardEdge,
        child: Stack(
          fit: .expand,
          children: [
            Container(
              foregroundDecoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: .topCenter,
                  end: .bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
              child: Actor(
                acts: [.parallax(slide: .4, axis: .vertical)],
                child: Image.network(
                  'https://picsum.photos/id/$imageId/600/600',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 18,
                        ),
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
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
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
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Iconsax.location,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        location,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Explore',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
