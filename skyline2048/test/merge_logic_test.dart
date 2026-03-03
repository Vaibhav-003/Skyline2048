import 'package:flutter_test/flutter_test.dart';
import 'package:skyline2048/models/board.dart';
import 'package:skyline2048/models/tile.dart';
import 'package:skyline2048/viewmodels/game_viewmodel.dart';

// ---------------------------------------------------------------------------
// Helper to seed a GameViewModel with an arbitrary 4×4 grid of values.
// Pass a flat list of 16 ints (0 = empty).
// ---------------------------------------------------------------------------
GameViewModel _providerFromValues(List<int> values) {
  assert(values.length == 16);
  int idSeed = 0;
  final provider = GameViewModel();
  provider.board = Board(
    currentTiles: List.generate(4, (r) {
      return List.generate(4, (c) {
        return Tile(id: idSeed++, value: values[r * 4 + c]);
      });
    }),
    previousTiles: null,
    score: 0,
  );
  return provider;
}

List<int> _values(GameViewModel p) =>
    p.board.currentTiles.expand((row) => row).map((t) => t.value).toList();

List<bool> _mergedFlags(GameViewModel p) =>
    p.board.currentTiles.expand((row) => row).map((t) => t.isMerged).toList();

void main() {
  // -------------------------------------------------------------------------
  // moveLeft
  // -------------------------------------------------------------------------
  group('moveLeft –', () {
    test('single pair merges correctly', () {
      final p = _providerFromValues([
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
      p.moveLeft();
      expect(_values(p).sublist(0, 4), [2, 0, 0, 0]);
    });

    test('double pair in one row — THE critical scenario [2,2,1,1]', () {
      final p = _providerFromValues([
        2,
        2,
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
      p.moveLeft();
      expect(_values(p).sublist(0, 4), [3, 2, 0, 0]);
    });

    test('double pair [1,1,1,1] → [2,2,0,0]', () {
      final p = _providerFromValues([
        1,
        1,
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
      p.moveLeft();
      expect(_values(p).sublist(0, 4), [2, 2, 0, 0]);
    });

    test('three-in-a-row [1,1,1,0] → leftmost pair merges: [2,1,0,0]', () {
      final p = _providerFromValues([
        1,
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
      ]);
      p.moveLeft();
      expect(_values(p).sublist(0, 4), [2, 1, 0, 0]);
    });

    test('no adjacent matches — only compacts [0,1,0,2]', () {
      final p = _providerFromValues([
        0,
        1,
        0,
        2,
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
      p.moveLeft();
      expect(_values(p).sublist(0, 4), [1, 2, 0, 0]);
    });

    test('zeros between matches [1,0,1,0] → [2,0,0,0]', () {
      final p = _providerFromValues([
        1,
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
        0,
        0,
      ]);
      p.moveLeft();
      expect(_values(p).sublist(0, 4), [2, 0, 0, 0]);
    });

    test('already sorted, no match [1,2,3,4] → unchanged', () {
      final p = _providerFromValues([
        1,
        2,
        3,
        4,
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
      p.moveLeft();
      expect(_values(p).sublist(0, 4), [1, 2, 3, 4]);
    });

    test('all zeros row unchanged', () {
      final p = _providerFromValues([
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
        0,
      ]);
      p.moveLeft();
      expect(_values(p).sublist(0, 4), [0, 0, 0, 0]);
    });

    test('full board [2,2,1,1] on every row — all rows merge correctly', () {
      final p = _providerFromValues([
        2,
        2,
        1,
        1,
        2,
        2,
        1,
        1,
        2,
        2,
        1,
        1,
        2,
        2,
        1,
        1,
      ]);
      p.moveLeft();
      final v = _values(p);
      for (int r = 0; r < 4; r++) {
        expect(v.sublist(r * 4, r * 4 + 4), [
          3,
          2,
          0,
          0,
        ], reason: 'row $r should be [3,2,0,0]');
      }
    });

    test('score increases correctly on merge', () {
      final p = _providerFromValues([
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
      p.moveLeft();
      expect(p.board.score, 4);
    });

    test('double pair score: [2,2,1,1] → 2^3 + 2^2 = 8+4 = 12', () {
      final p = _providerFromValues([
        2,
        2,
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
      p.moveLeft();
      expect(p.board.score, 12);
    });

    test('merged tile has isMerged=true', () {
      final p = _providerFromValues([
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
      p.moveLeft();
      expect(p.board.currentTiles[0][0].isMerged, isTrue);
    });

    test('non-merged tiles do NOT have isMerged=true', () {
      final p = _providerFromValues([
        1,
        2,
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
      p.moveLeft();
      expect(_mergedFlags(p).any((f) => f), isFalse);
    });

    test('chained scenario [0,0,1,1] → [2,0,0,0]', () {
      final p = _providerFromValues([
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
      p.moveLeft();
      expect(_values(p).sublist(0, 4), [2, 0, 0, 0]);
    });
  });

  // -------------------------------------------------------------------------
  // moveRight
  // -------------------------------------------------------------------------
  group('moveRight –', () {
    test('single pair [0,0,1,1] → [0,0,0,2]', () {
      final p = _providerFromValues([
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
      p.moveRight();
      expect(_values(p).sublist(0, 4), [0, 0, 0, 2]);
    });

    test('double pair [2,2,1,1] → [0,0,3,2]', () {
      final p = _providerFromValues([
        2,
        2,
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
      p.moveRight();
      expect(_values(p).sublist(0, 4), [0, 0, 3, 2]);
    });

    test('[1,1,1,1] → [0,0,2,2]', () {
      final p = _providerFromValues([
        1,
        1,
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
      p.moveRight();
      expect(_values(p).sublist(0, 4), [0, 0, 2, 2]);
    });

    test('no match, compacts right [1,0,2,0] → [0,0,1,2]', () {
      final p = _providerFromValues([
        1,
        0,
        2,
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
      p.moveRight();
      expect(_values(p).sublist(0, 4), [0, 0, 1, 2]);
    });
  });

  // -------------------------------------------------------------------------
  // moveUp
  // -------------------------------------------------------------------------
  group('moveUp –', () {
    test('single pair in column merges upward', () {
      final p = _providerFromValues([
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
      p.moveUp();
      final col0 = [
        0,
        1,
        2,
        3,
      ].map((r) => p.board.currentTiles[r][0].value).toList();
      expect(col0, [2, 0, 0, 0]);
    });

    test('double pair [2,2,1,1] vertically → [3,2,0,0] in col', () {
      final p = _providerFromValues([
        2,
        0,
        0,
        0,
        2,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
      ]);
      p.moveUp();
      final col0 = [
        0,
        1,
        2,
        3,
      ].map((r) => p.board.currentTiles[r][0].value).toList();
      expect(col0, [3, 2, 0, 0]);
    });

    test('[1,1,1,1] vertically → [2,2,0,0] in col', () {
      final p = _providerFromValues([
        1,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
      ]);
      p.moveUp();
      final col0 = [
        0,
        1,
        2,
        3,
      ].map((r) => p.board.currentTiles[r][0].value).toList();
      expect(col0, [2, 2, 0, 0]);
    });
  });

  // -------------------------------------------------------------------------
  // moveDown
  // -------------------------------------------------------------------------
  group('moveDown –', () {
    test('single pair merges downward', () {
      final p = _providerFromValues([
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
      p.moveDown();
      final col0 = [
        0,
        1,
        2,
        3,
      ].map((r) => p.board.currentTiles[r][0].value).toList();
      expect(col0, [0, 0, 0, 2]);
    });

    test('double pair vertically → downward [0,0,3,2]', () {
      final p = _providerFromValues([
        2,
        0,
        0,
        0,
        2,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
      ]);
      p.moveDown();
      final col0 = [
        0,
        1,
        2,
        3,
      ].map((r) => p.board.currentTiles[r][0].value).toList();
      expect(col0, [0, 0, 3, 2]);
    });
  });

  // -------------------------------------------------------------------------
  // Edge cases
  // -------------------------------------------------------------------------
  group('Edge cases –', () {
    test('empty board stays empty after any move', () {
      final p = _providerFromValues(List.filled(16, 0));
      p.moveLeft();
      expect(_values(p), List.filled(16, 0));
    });

    test('single tile slides left', () {
      final p = _providerFromValues([
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
        0,
      ]);
      p.moveLeft();
      expect(_values(p).sublist(0, 4), [1, 0, 0, 0]);
    });

    test('[1,0,0,1] → [2,0,0,0]', () {
      final p = _providerFromValues([
        1,
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
        0,
      ]);
      p.moveLeft();
      expect(_values(p).sublist(0, 4), [2, 0, 0, 0]);
    });

    test('[1,1,1,0] → [2,1,0,0]', () {
      final p = _providerFromValues([
        1,
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
      ]);
      p.moveLeft();
      expect(_values(p).sublist(0, 4), [2, 1, 0, 0]);
    });

    test('multiple rows are independent', () {
      final p = _providerFromValues([
        1,
        1,
        0,
        0,
        2,
        2,
        0,
        0,
        3,
        3,
        0,
        0,
        4,
        4,
        0,
        0,
      ]);
      p.moveLeft();
      final v = _values(p);
      expect(v.sublist(0, 4), [2, 0, 0, 0]);
      expect(v.sublist(4, 8), [3, 0, 0, 0]);
      expect(v.sublist(8, 12), [4, 0, 0, 0]);
      expect(v.sublist(12, 16), [5, 0, 0, 0]);
    });
  });
}
