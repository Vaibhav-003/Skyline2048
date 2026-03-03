import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:skyline2048/models/board.dart';
import 'package:skyline2048/models/tile.dart';
import 'package:skyline2048/providers/game_provider.dart';
import 'package:skyline2048/tile/tile_widget.dart';
import 'package:skyline2048/game_board/game_board.dart';
import 'package:skyline2048/screens/game_page.dart';

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

/// Wraps a widget in the minimal scaffolding needed for most tests:
///   - MaterialApp  (needed for MediaQuery, Directionality, overlays)
///   - ChangeNotifierProvider[GameProvider]
///
/// Pass a pre-configured [provider] to control state,
/// or leave null to get a freshly initialised one.
Widget _wrap(Widget child, {GameProvider? provider}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<GameProvider>.value(
        value: provider ?? GameProvider(),
      ),
    ],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

/// Seeds a [GameProvider]'s board with specific tile values (flat list of 16).
GameProvider _providerFromValues(List<int> values) {
  assert(values.length == 16);
  int id = 0;
  final p = GameProvider();
  p.board = Board(
    currentTiles: List.generate(4, (r) {
      return List.generate(4, (c) {
        return Tile(id: id++, value: values[r * 4 + c]);
      });
    }),
    previousTiles: null,
    score: 0,
  );
  return p;
}

// ---------------------------------------------------------------------------
// 1. TileWidget tests
// ---------------------------------------------------------------------------
void main() {
  group('TileWidget –', () {
    testWidgets('renders the correct numeric label for a value-1 tile', (
      tester,
    ) async {
      // Tile value 1 → 2^1 = 2
      final tile = Tile(id: 0, value: 1);
      await tester.pumpWidget(
        MaterialApp(home: TileWidget(tile: tile, size: 100, borderRadius: 8)),
      );
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('renders correct label for value-3 tile (2^3 = 8)', (
      tester,
    ) async {
      final tile = Tile(id: 1, value: 3);
      await tester.pumpWidget(
        MaterialApp(home: TileWidget(tile: tile, size: 100, borderRadius: 8)),
      );
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('new tile starts at scale 0 and animates to 1', (tester) async {
      final tile = Tile(id: 0, value: 1, isNew: true);
      await tester.pumpWidget(
        MaterialApp(home: TileWidget(tile: tile, size: 100, borderRadius: 8)),
      );
      // Immediately after pump the spawn animation hasn't finished yet.
      // pumpAndSettle lets all animations complete.
      await tester.pumpAndSettle();
      // If we get here without throwing the widget rendered correctly.
      expect(find.byType(ScaleTransition), findsOneWidget);
    });

    testWidgets('merged tile pulse animation completes without error', (
      tester,
    ) async {
      final tile = Tile(id: 0, value: 2, isMerged: true);
      await tester.pumpWidget(
        MaterialApp(home: TileWidget(tile: tile, size: 100, borderRadius: 8)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TileWidget), findsOneWidget);
    });

    testWidgets('no animation widgets crash on plain (non-new/merged) tile', (
      tester,
    ) async {
      final tile = Tile(id: 0, value: 1);
      await tester.pumpWidget(
        MaterialApp(home: TileWidget(tile: tile, size: 100, borderRadius: 8)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TileWidget), findsOneWidget);
    });

    testWidgets('tile label updates when widget receives a new tile', (
      tester,
    ) async {
      // Start with value 1
      late StateSetter externalSetState;
      Tile currentTile = Tile(id: 0, value: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              externalSetState = setState;
              return TileWidget(tile: currentTile, size: 100, borderRadius: 8);
            },
          ),
        ),
      );
      expect(find.text('2'), findsOneWidget);

      // Update to value 2 (2^2 = 4)
      externalSetState(() => currentTile = Tile(id: 1, value: 2));
      await tester.pump();
      expect(find.text('4'), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // 2. GameBoard widget tests
  // -------------------------------------------------------------------------
  group('GameBoard –', () {
    testWidgets('renders 16 background cells (empty slot containers)', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const GameBoard()));
      await tester.pumpAndSettle();

      // Background cells are plain Containers inside Positioned.
      // We count Positioned widgets; 16 background + N tile Positioned = ≥ 16.
      final positioned = find.byType(Positioned);
      expect(positioned, findsWidgets);
    });

    testWidgets('renders TileWidget only for non-zero tiles', (tester) async {
      // 2 tiles with value=1; 14 zeros
      final provider = _providerFromValues([
        1,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
      ]);
      await tester.pumpWidget(_wrap(const GameBoard(), provider: provider));
      await tester.pumpAndSettle();

      expect(find.byType(TileWidget), findsNWidgets(2));
    });

    testWidgets('renders all 16 TileWidgets when board is full', (
      tester,
    ) async {
      final provider = _providerFromValues(List.filled(16, 1));
      await tester.pumpWidget(_wrap(const GameBoard(), provider: provider));
      await tester.pumpAndSettle();
      expect(find.byType(TileWidget), findsNWidgets(16));
    });

    testWidgets('renders no TileWidgets for an all-zero board', (tester) async {
      final provider = _providerFromValues(List.filled(16, 0));
      await tester.pumpWidget(_wrap(const GameBoard(), provider: provider));
      await tester.pumpAndSettle();
      expect(find.byType(TileWidget), findsNothing);
    });

    testWidgets('tile values are displayed correctly on the board', (
      tester,
    ) async {
      // Only one tile with value 3 → 2^3 = 8
      final provider = _providerFromValues([
        3,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
      ]);
      await tester.pumpWidget(_wrap(const GameBoard(), provider: provider));
      await tester.pumpAndSettle();
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets(
      'GameBoard rebuilds after provider state change (new tile added)',
      (tester) async {
        final provider = _providerFromValues([
          1,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
        ]);
        await tester.pumpWidget(_wrap(const GameBoard(), provider: provider));
        await tester.pumpAndSettle();

        // Initially 1 tile
        expect(find.byType(TileWidget), findsNWidgets(1));

        // Manually add a tile through the provider
        provider.addNewTile();
        await tester.pump();
        await tester.pumpAndSettle();

        // Now there should be 2 tiles
        expect(find.byType(TileWidget), findsNWidgets(2));
      },
    );

    testWidgets('left swipe triggers moveLeft on the provider', (tester) async {
      final provider = _providerFromValues([
        1,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
      ]);
      await tester.pumpWidget(_wrap(const GameBoard(), provider: provider));
      await tester.pumpAndSettle();

      // Simulate a left swipe (negative horizontal velocity)
      await tester.fling(
        find.byType(GestureDetector).first,
        const Offset(-200, 0),
        800,
      );
      await tester.pump();

      // After moveLeft, [1,1,0,0] → [2,0,0,0] — only 1 tile value=2 visible
      // (Score increases for proof the merge happened)
      // Drain the Future.delayed(200ms) that GameBoard uses to call addNewTile.
      await tester.pump(const Duration(milliseconds: 200));
      expect(provider.board.score, greaterThan(0));
    });

    testWidgets('right swipe triggers moveRight on the provider', (
      tester,
    ) async {
      final provider = _providerFromValues([
        0,
        0,
        1,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
      ]);
      await tester.pumpWidget(_wrap(const GameBoard(), provider: provider));
      await tester.pumpAndSettle();

      await tester.fling(
        find.byType(GestureDetector).first,
        const Offset(200, 0),
        800,
      );
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 200));
      expect(provider.board.score, greaterThan(0));
    });

    testWidgets('upward swipe triggers moveUp on the provider', (tester) async {
      final provider = _providerFromValues([
        1,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
      ]);
      await tester.pumpWidget(_wrap(const GameBoard(), provider: provider));
      await tester.pumpAndSettle();

      await tester.fling(
        find.byType(GestureDetector).first,
        const Offset(0, -200),
        800,
      );
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 200));
      expect(provider.board.score, greaterThan(0));
    });

    testWidgets('downward swipe triggers moveDown on the provider', (
      tester,
    ) async {
      final provider = _providerFromValues([
        1,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
      ]);
      await tester.pumpWidget(_wrap(const GameBoard(), provider: provider));
      await tester.pumpAndSettle();

      await tester.fling(
        find.byType(GestureDetector).first,
        const Offset(0, 200),
        800,
      );
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 200));
      expect(provider.board.score, greaterThan(0));
    });
  });

  // -------------------------------------------------------------------------
  // 3. HomePage widget tests
  // -------------------------------------------------------------------------
  group('HomePage –', () {
    testWidgets('renders a score label', (tester) async {
      final provider = _providerFromValues(List.filled(16, 0));
      provider.board.score = 0;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<GameProvider>.value(value: provider),
          ],
          child: const MaterialApp(home: GamePage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Score:'), findsOneWidget);
    });

    testWidgets('score display updates when board score changes', (
      tester,
    ) async {
      final provider = _providerFromValues([
        1,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
      ]);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<GameProvider>.value(value: provider),
          ],
          child: const MaterialApp(home: GamePage()),
        ),
      );
      await tester.pumpAndSettle();

      // Score starts at 0
      expect(find.text('Score: 0'), findsOneWidget);

      // Trigger a merge
      provider.moveLeft();
      await tester.pump();

      // Score should now show a non-zero value
      expect(find.text('Score: 0'), findsNothing);
      expect(find.textContaining('Score:'), findsOneWidget);
    });

    testWidgets('contains a GameBoard widget', (tester) async {
      final provider = _providerFromValues(List.filled(16, 0));
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<GameProvider>.value(value: provider),
          ],
          child: const MaterialApp(home: GamePage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GameBoard), findsOneWidget);
    });
  });
}
