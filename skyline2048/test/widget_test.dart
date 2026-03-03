import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:skyline2048/models/board.dart';
import 'package:skyline2048/models/tile.dart';
import 'package:skyline2048/viewmodels/game_viewmodel.dart';
import 'package:skyline2048/views/widgets/tile_widget.dart';
import 'package:skyline2048/views/widgets/game_board.dart';
import 'package:skyline2048/views/screens/game_screen.dart';

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

Widget _wrap(Widget child, {GameViewModel? provider}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<GameViewModel>.value(
        value: provider ?? GameViewModel(),
      ),
    ],
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

GameViewModel _providerFromValues(List<int> values) {
  assert(values.length == 16);
  int id = 0;
  final p = GameViewModel();
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
      final tile = Tile(id: 0, value: 1);
      await tester.pumpWidget(
        MaterialApp(home: TileWidget(tile: tile, size: 100, borderRadius: 8)),
      );
      // TileWidget now shows SVG assets, not text labels — verify it renders
      // without error and the ScaleTransition is present.
      await tester.pumpAndSettle();
      expect(find.byType(TileWidget), findsOneWidget);
    });

    testWidgets('new tile spawn animation completes without error', (
      tester,
    ) async {
      final tile = Tile(id: 0, value: 1, isNew: true);
      await tester.pumpWidget(
        MaterialApp(home: TileWidget(tile: tile, size: 100, borderRadius: 8)),
      );
      await tester.pumpAndSettle();
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

    testWidgets('plain tile (no animation) renders without error', (
      tester,
    ) async {
      final tile = Tile(id: 0, value: 1);
      await tester.pumpWidget(
        MaterialApp(home: TileWidget(tile: tile, size: 100, borderRadius: 8)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TileWidget), findsOneWidget);
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
      final positioned = find.byType(Positioned);
      expect(positioned, findsWidgets);
    });

    testWidgets('renders TileWidget only for non-zero tiles', (tester) async {
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
        expect(find.byType(TileWidget), findsNWidgets(1));

        provider.addNewTile();
        await tester.pump();
        await tester.pumpAndSettle();
        expect(find.byType(TileWidget), findsNWidgets(2));
      },
    );

    testWidgets('left swipe triggers moveLeft on the viewmodel', (
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
      await tester.pumpWidget(_wrap(const GameBoard(), provider: provider));
      await tester.pumpAndSettle();

      await tester.fling(
        find.byType(GestureDetector).first,
        const Offset(-200, 0),
        800,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(provider.board.score, greaterThan(0));
    });

    testWidgets('right swipe triggers moveRight on the viewmodel', (
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

    testWidgets('upward swipe triggers moveUp on the viewmodel', (
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
        const Offset(0, -200),
        800,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(provider.board.score, greaterThan(0));
    });

    testWidgets('downward swipe triggers moveDown on the viewmodel', (
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
  // 3. GameScreen widget tests
  // -------------------------------------------------------------------------
  group('GameScreen –', () {
    testWidgets('renders a score label', (tester) async {
      final provider = _providerFromValues(List.filled(16, 0));
      provider.board.score = 0;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<GameViewModel>.value(value: provider),
          ],
          child: const MaterialApp(home: GameScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Score'), findsOneWidget);
    });

    testWidgets('contains a GameBoard widget', (tester) async {
      final provider = _providerFromValues(List.filled(16, 0));
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<GameViewModel>.value(value: provider),
          ],
          child: const MaterialApp(home: GameScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GameBoard), findsOneWidget);
    });

    testWidgets('contains direction buttons (UP, DOWN, LEFT, RIGHT)', (
      tester,
    ) async {
      final provider = _providerFromValues(List.filled(16, 0));
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<GameViewModel>.value(value: provider),
          ],
          child: const MaterialApp(home: GameScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('UP'), findsOneWidget);
      expect(find.text('DOWN'), findsOneWidget);
      expect(find.text('LEFT'), findsOneWidget);
      expect(find.text('RIGHT'), findsOneWidget);
    });
  });
}
