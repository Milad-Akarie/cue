import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cue/cue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CueFlexibleSpaceBar', () {
    testWidgets('creates with required parameters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: CueFlexibleSpaceBar(
                  background: Container(color: Colors.blue),
                  title: const Text('Title'),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 1000),
              ),
            ],
          ),
        ),
      );

      expect(find.byType(CueFlexibleSpaceBar), findsOneWidget);
      expect(find.byType(FlexibleSpaceBar), findsOneWidget);
    });

    testWidgets('creates with all optional parameters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: CueFlexibleSpaceBar(
                  background: Container(color: Colors.blue),
                  title: const Text('Title'),
                  centerTitle: true,
                  titlePadding: const EdgeInsets.all(16),
                  collapseMode: CollapseMode.pin,
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  expandedTitleScale: 2.0,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 1000),
              ),
            ],
          ),
        ),
      );

      expect(find.byType(CueFlexibleSpaceBar), findsOneWidget);
    });

    testWidgets('respects collapseMode parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: CueFlexibleSpaceBar(
                  background: Container(color: Colors.blue),
                  title: const Text('Title'),
                  collapseMode: CollapseMode.none,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 1000),
              ),
            ],
          ),
        ),
      );

      expect(find.byType(CueFlexibleSpaceBar), findsOneWidget);
    });

    testWidgets('responds to scroll', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: CueFlexibleSpaceBar(
                  background: Container(color: Colors.blue),
                  title: const Text('Title'),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 1000),
              ),
            ],
          ),
        ),
      );

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -100));
      await tester.pump();

      expect(find.byType(CueFlexibleSpaceBar), findsOneWidget);
    });

    testWidgets('clamps progress on extreme scroll', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: CueFlexibleSpaceBar(
                  background: Container(color: Colors.blue),
                  title: const Text('Title'),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 1000),
              ),
            ],
          ),
        ),
      );

      expect(find.byType(CueFlexibleSpaceBar), findsOneWidget);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pump();
    });

    testWidgets('re-instantiates when key changes', (tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: CueFlexibleSpaceBar(
                  key: const ValueKey('initial'),
                  background: Builder(
                    builder: (context) {
                      buildCount++;
                      return Container(color: Colors.blue);
                    },
                  ),
                  title: const Text('Title'),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 1000),
              ),
            ],
          ),
        ),
      );

      final initialBuildCount = buildCount;

      await tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: CueFlexibleSpaceBar(
                  key: const ValueKey('changed'),
                  background: Builder(
                    builder: (context) {
                      buildCount++;
                      return Container(color: Colors.blue);
                    },
                  ),
                  title: const Text('Title'),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 1000),
              ),
            ],
          ),
        ),
      );

      expect(buildCount, greaterThan(initialBuildCount));
    });

    testWidgets('can be removed from tree', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: CueFlexibleSpaceBar(
                  background: Container(color: Colors.blue),
                  title: const Text('Title'),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 1000),
              ),
            ],
          ),
        ),
      );

      expect(find.byType(CueFlexibleSpaceBar), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(CueFlexibleSpaceBar), findsNothing);
    });

    testWidgets('renders without title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: CueFlexibleSpaceBar(
                  background: Container(color: Colors.blue),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 1000),
              ),
            ],
          ),
        ),
      );

      expect(find.byType(CueFlexibleSpaceBar), findsOneWidget);
    });

    testWidgets('renders without background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: CueFlexibleSpaceBar(
                  title: const Text('Title'),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 1000),
              ),
            ],
          ),
        ),
      );

      expect(find.byType(CueFlexibleSpaceBar), findsOneWidget);
    });

    testWidgets('uses default collapseMode parallax', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: CueFlexibleSpaceBar(
                  background: Container(color: Colors.blue),
                  title: const Text('Title'),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 1000),
              ),
            ],
          ),
        ),
      );

      final widget = tester.widget<CueFlexibleSpaceBar>(
        find.byType(CueFlexibleSpaceBar),
      );
      expect(widget.collapseMode, equals(CollapseMode.parallax));
    });

    testWidgets('uses default stretchModes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: CueFlexibleSpaceBar(
                  background: Container(color: Colors.blue),
                  title: const Text('Title'),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 1000),
              ),
            ],
          ),
        ),
      );

      final widget = tester.widget<CueFlexibleSpaceBar>(
        find.byType(CueFlexibleSpaceBar),
      );
      expect(widget.stretchModes, equals(const [StretchMode.zoomBackground]));
    });

    testWidgets('uses default expandedTitleScale', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: CueFlexibleSpaceBar(
                  background: Container(color: Colors.blue),
                  title: const Text('Title'),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 1000),
              ),
            ],
          ),
        ),
      );

      final widget = tester.widget<CueFlexibleSpaceBar>(
        find.byType(CueFlexibleSpaceBar),
      );
      expect(widget.expandedTitleScale, equals(1.5));
    });
  });
}
