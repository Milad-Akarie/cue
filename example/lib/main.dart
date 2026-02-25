import 'package:cue/cue.dart';
import 'package:example/examples/three_dots_action.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Curves.elasticIn;
    return MaterialApp(
      title: 'Cue Demo',
      // showPerformanceOverlay: true,
      darkTheme: ThemeData.dark(),
      theme: ThemeData(
        splashFactory: NoSplash.splashFactory,
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: _OnChangeDemo(),
      builder: (context, child) {
        if (kDebugMode) {
          return CueDebugTools(child: child!);
        }
        return child!;
      },
    );
  }
}

class _OnChangeDemo extends StatefulWidget {
  const _OnChangeDemo({super.key});

  @override
  State<_OnChangeDemo> createState() => __OnChangeDemoState();
}

class __OnChangeDemoState extends State<_OnChangeDemo> {
  int _notificationsCount = 0;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainer,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: .center,
            crossAxisAlignment: .end,
            children: [
              CueModalTransition(
                alignment: Alignment.bottomRight,
                barrierColor: Colors.transparent,
                hideTriggerOnTransition: true,
                simulation: Spring.bouncy(damping: 19),
                triggerBuilder: (context, open) => FloatingActionButton(
                  onPressed: open,
                  backgroundColor: theme.colorScheme.surface,
                  foregroundColor: theme.colorScheme.error,
                  elevation: .5,
                  shape: CircleBorder(),
                  child: Icon(Iconsax.trash, size: 24),
                ),
                builder: (context, rect) {
                  return TranslateActor(
                    to: Offset(-28, -28),
                    from: .zero,
                    child: Material(
                      clipBehavior: .hardEdge,
                      borderRadius: BorderRadius.circular(32),
                      color: theme.colorScheme.surface,
                      elevation: 1,
                      shadowColor: Colors.black.withValues(alpha: .3),
                      child: SizeActor(
                        from: rect.size,
                        to: Size(220, 180),
                        allowOverflow: true,
                        alignment: Alignment.bottomRight,
                        child: SlideActor.y(
                          from: 0.4,
                          child: Column(
                            mainAxisSize: .min,
                            crossAxisAlignment: .end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Actor(
                                    effects: [
                                      BlurEffect(from: 10),
                                      FadeEffect(),
                                    ],
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Are you sure you want to delete this item?',
                                            textAlign: .center,
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'This action cannot be undone.',
                                            textAlign: .center,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.colorScheme.onSurface.withValues(alpha: .5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  TextButton.icon(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.error.withValues(alpha: .05),
                                      foregroundColor: theme.colorScheme.error,
                                      padding: .symmetric(horizontal: 20.0, vertical: 12.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                    ),
                                    label: Text('Delete Item'),
                                    iconAlignment: .end,
                                    icon: Actor(
                                      effects: [
                                        TranslateEffect.fromGlobal(
                                          offset: rect.center - Offset(12, 12),
                                        ),
                                        IconThemeEffect(
                                          from: IconThemeData(size: 24),
                                          to: IconThemeData(size: 20),
                                        ),
                                      ],
                                      child: Icon(
                                        Iconsax.trash,
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: Text('Show Sheet'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(),
                            body: Cue.onTransition(
                              child: Center(
                                child: SlideActor.y(
                                  from: 10.0,
                                  child: Text('Hello from the new page!'),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
