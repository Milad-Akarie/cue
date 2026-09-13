import 'package:cue/cue.dart';
import 'package:material_ui/material_ui.dart';
import 'package:iconsax/iconsax.dart';

class XStyleSideMenu extends StatefulWidget {
  const XStyleSideMenu({super.key});

  @override
  State<XStyleSideMenu> createState() => _XStyleSideMenuState();
}

class _XStyleSideMenuState extends State<XStyleSideMenu> {
  bool _isOpen = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    return ColoredBox(
      color: theme.colorScheme.surfaceContainerLow,
      child: SizedBox.expand(
        child: Cue.onToggle(
          toggled: _isOpen,
          motion: .easeInOut(500.ms),
          // Scrub the animation with horizontal drag
          child: CueDragScrubber(
            distance: 300,
            scrubForwardDirection: .end,
            onAnimationEnd: (forward) {
              setState(() {
                _isOpen = forward;
              });
            },
            child: Stack(
              children: [
                // side menu
                SizedBox(
                  width: 300,
                  child: SafeArea(
                    child: Actor(
                      acts: [
                        .fadeIn(from: .5),
                        .scale(from: .95),
                      ],
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF667EEA),
                                        Color(0xFF764BA2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Iconsax.video_horizontal5,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cue',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Flutter Animations Library',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            thickness: .2,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'MAIN',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                          _MenuItem(
                            icon: Iconsax.home,
                            label: 'Home',
                            isSelected: true,
                          ),
                          _MenuItem(
                            icon: Iconsax.search_normal,
                            label: 'Search',
                          ),
                          _MenuItem(
                            icon: Iconsax.notification,
                            label: 'Notifications',
                            badge: '3',
                          ),
                          _MenuItem(
                            icon: Iconsax.message,
                            label: 'Messages',
                            badge: '12',
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'WORKSPACE',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                          _MenuItem(
                            icon: Iconsax.chart,
                            label: 'Analytics',
                          ),
                          _MenuItem(
                            icon: Iconsax.folder_open,
                            label: 'Projects',
                          ),
                          _MenuItem(
                            icon: Iconsax.task_square,
                            label: 'Tasks',
                          ),
                          const Spacer(),
                          const Divider(thickness: .2),
                          _MenuItem(
                            icon: Iconsax.setting_2,
                            label: 'Settings',
                          ),
                          _MenuItem(
                            icon: Iconsax.logout,
                            label: 'Logout',
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
                // main content
                PositionedActor(
                  from: .fromSTWH(0, 0, size.width, size.height),
                  to: .fromSTWH(300, 0, size.width, size.height),
                  child: CardActor(
                    motion: .linear(50.ms),
                    reverse: .mirror(delay: 450.ms),
                    shape: .tween(
                      RoundedSuperellipseBorder(borderRadius: .circular(64)),
                      RoundedSuperellipseBorder(
                        borderRadius: .circular(64),
                        side: BorderSide(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    elevation: .fixed(0),
                    clipBehavior: .antiAlias,
                    child: Scaffold(
                      appBar: AppBar(
                        title: const Text('Cue Drag Scrubber'),
                        leading: IconButton(
                          icon: const Icon(Iconsax.menu),
                          onPressed: () => setState(() => _isOpen = !_isOpen),
                        ),
                      ),
                      body: Center(
                        child: Text(
                          'Content',
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
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
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final String? badge;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.65);

    return Material(
      type: .transparency,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ListTile(
          leading: Icon(icon, size: 22, color: iconColor),
          title: Text(label),
          trailing: badge != null
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                )
              : null,
          onTap: () {},
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
          dense: true,
          tileColor: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.12) : null,
          selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
    );
  }
}
