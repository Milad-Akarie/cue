import 'package:cue/cue.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ImageGridModal extends StatelessWidget {
  const ImageGridModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Gallery'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final titles = ['Beach', 'Mountain', 'City', 'Forest', 'Desert', 'Lake'];
          final title = titles[index % titles.length];
          return _ImageCard(imageId: index, title: title);
        },
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final int imageId;
  final String title;

  const _ImageCard({required this.imageId, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CueModalTransition(
            // motion: .easeInOut(300.ms),
            motion: .smooth(),
            hideTriggerOnTransition: true,
            barrierColor: Colors.black.withValues(alpha: .9),
            triggerBuilder: (context, open) => GestureDetector(
              onTap: open,
              child: Image.network(
                'https://picsum.photos/id/${60 + imageId}/400/500',
                fit: BoxFit.cover,
              ),
            ),
            builder: (context, rect) {
              return _ImageModalContent(
                imageId: imageId,
                title: title,
                triggerRect: rect,
              );
            },
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: IgnorePointer(
              child: Container(
                padding: const .symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: .circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Iconsax.heart,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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

class _ImageModalContent extends StatelessWidget {
  final int imageId;
  final String title;
  final Rect triggerRect;

  const _ImageModalContent({
    required this.imageId,
    required this.title,
    required this.triggerRect,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: .center,
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: kToolbarHeight),
            child: ClipRect(
              child: Actor(
                acts: [
                  .translateFromGlobalRect(triggerRect),
                  .sizedBox(width: .tween(triggerRect.width, .infinity)),
                ],
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 0.8,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        'https://picsum.photos/id/${60 + imageId}/400/500',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: SafeArea(
            child: Actor(
              delay: 100.ms,
              reverseMotion: .spatialFast(),
              acts: [
                .fadeIn(),
                .slideY(from: -0.2),
              ],
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Iconsax.close_circle, color: Colors.white, size: 32),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.heart, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.share, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 50,
          child: Actor(
            acts: [
              .slideY(from: 1),
              .fadeIn(),
            ],
            delay: 200.ms,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Beautiful destination',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'Book Now',
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
          ),
        ),
      ],
    );
  }
}
