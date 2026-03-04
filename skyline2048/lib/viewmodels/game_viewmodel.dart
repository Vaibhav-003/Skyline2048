import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skyline2048/data/repositories/board_repository.dart';
import 'package:skyline2048/models/board.dart';
import 'package:skyline2048/models/score_entry.dart';
import 'package:skyline2048/models/tile.dart';

/// ViewModel for the game. Holds all game state and business logic.
/// Views observe this class via Consumer[GameViewModel] / [context.watch<GameViewModel>()].
class GameViewModel extends ChangeNotifier {
  final double _l1Probability = 0.95;

  static List<int> _twoDistinctIndexes(int length) {
    final rng = Random();
    final int a = rng.nextInt(length);
    int b;
    do {
      b = rng.nextInt(length);
    } while (b == a);
    return [a, b];
  }

  // ------- identity counter -------
  int _idCounter = 0;
  int _nextId() => _idCounter++;

  // ------- state -------
  late Board board;

  /// Prevents saving the same game-over moment twice.
  bool _scoreAlreadySaved = false;

  int _bestScore = 0;
  int get bestScore {
    if (board.score > _bestScore) {
      _bestScore = board.score;
    }
    return _bestScore;
  }

  GameViewModel() {
    _initBoard();
  }

  void _initBoard() {
    final positions = _twoDistinctIndexes(16);
    final bestScores = BoardRepository().loadBestScores();
    if (bestScores != null) {
      _bestScore = bestScores.first;
    }
    board = Board(
      currentTiles: List.generate(4, (row) {
        return List.generate(4, (col) {
          final flat = row * 4 + col;
          if (flat == positions[0]) {
            return Tile(
              id: _nextId(),
              value: _l1Probability > Random().nextDouble() ? 1 : 2,
              isNew: true,
            );
          }
          if (flat == positions[1]) {
            return Tile(
              id: _nextId(),
              value: _l1Probability > Random().nextDouble() ? 1 : 2,
              isNew: true,
            );
          }
          return Tile(id: _nextId(), value: 0);
        });
      }),
      previousTiles: null,
      score: 0,
    );
  }

  double get _probability {
    final probability = _l1Probability - (board.score ~/ 200) * 0.05;
    return probability > 0.5 ? probability : 0.5;
  }

  // ------- getters -------

  /// Flat list of all 16 tiles (including empty ones, value == 0).
  List<Tile> get tiles => board.currentTiles.expand((row) => row).toList();

  /// Only non-empty tiles with their row/col position — used by GameBoard
  /// for AnimatedPositioned rendering.
  List<({int row, int col, Tile tile})> get tilePositions {
    final result = <({int row, int col, Tile tile})>[];
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        final t = board.currentTiles[r][c];
        if (t.value != 0) result.add((row: r, col: c, tile: t));
      }
    }
    return result;
  }

  // ------- internal helpers -------

  void _clearFlags() {
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        final t = board.currentTiles[r][c];
        if (t.isNew || t.isMerged) {
          board.currentTiles[r][c] = t.copyWith(isNew: false, isMerged: false);
        }
      }
    }
  }

  // ------- public API -------

  void addNewTile() {
    if (isGameOver) return;
    final empty = <(int, int)>[];
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        if (board.currentTiles[r][c].value == 0) empty.add((r, c));
      }
    }
    if (empty.isEmpty) return;

    final pick = empty[Random().nextInt(empty.length)];
    final randomDouble = Random().nextDouble();
    board.currentTiles[pick.$1][pick.$2] = Tile(
      id: _nextId(),
      value: _probability > randomDouble ? 1 : 2,
      isNew: true,
    );

    // Save top score the first time game-over is detected.
    if (isGameOver && !_scoreAlreadySaved) {
      saveCurrentScore();
    }
    notifyListeners();
  }

  /// Persists the current score as a [ScoreEntry] in the top-5 list.
  /// Called automatically on game-over, and also when the user exits mid-game.
  void saveCurrentScore() {
    if (_scoreAlreadySaved || board.score == 0) return;
    _scoreAlreadySaved = true;
    final highestTile = tiles
        .map((t) => t.value)
        .fold(0, (max, v) => v > max ? v : max);
    BoardRepository().saveTopScore(
      ScoreEntry(
        score: board.score,
        dateMs: DateTime.now().millisecondsSinceEpoch,
        highestTileValue: highestTile,
      ),
    );
  }

  /// Exposes the persisted top-5 score entries for the Best Scores screen.
  List<ScoreEntry> get topScores => BoardRepository().loadTopScores();

  List<List<Tile>> _transposedTiles(List<List<Tile>> tiles) {
    return List.generate(4, (col) {
      return List.generate(4, (row) {
        return tiles[row][col];
      });
    });
  }

  List<List<Tile>> _mirroredTiles(List<List<Tile>> tiles) {
    return List.generate(4, (row) {
      return List.generate(4, (col) {
        return tiles[row][3 - col];
      });
    });
  }

  bool get isGameOver {
    if (board.currentTiles.any(
      (element) => element.any((element) => element.value == 0),
    )) {
      return false;
    }
    return !_canMergeAnyTile();
  }

  bool _canMergeAnyTile() {
    final horizontal = board.currentTiles.any((row) {
      for (int i = 1; i < row.length; i++) {
        if (row[i - 1].value == row[i].value) return true;
      }
      return false;
    });
    final vertical = _transposedTiles(board.currentTiles).any((row) {
      for (int i = 1; i < row.length; i++) {
        if (row[i - 1].value == row[i].value) return true;
      }
      return false;
    });
    return horizontal || vertical;
  }

  List<List<Tile>> _mergeLeft(List<List<Tile>> tiles) {
    final result = <List<Tile>>[];
    for (var row in tiles) {
      final nonZeroTiles = row.where((tile) => tile.value != 0).toList();
      final zeroTiles = row.where((tile) => tile.value == 0).toList();
      row = [...nonZeroTiles, ...zeroTiles];

      // Phase 1: merge adjacent equal tiles (left to right), skip consumed tile
      for (var i = 0; i < row.length - 1; i++) {
        if (row[i].value != 0 && row[i].value == row[i + 1].value) {
          row[i] = Tile(id: _nextId(), value: row[i].value + 1, isMerged: true);
          row[i + 1] = Tile(id: _nextId(), value: 0);
          board.score += pow(2, row[i].value).toInt();
          i++; // skip the consumed tile so it can't be re-merged
        }
      }

      // Phase 2: compact — push zeros to the right
      final nonZero = row.where((t) => t.value != 0).toList();
      final zeros = row.where((t) => t.value == 0).toList();
      row = [...nonZero, ...zeros];
      result.add(row);
    }
    return result;
  }

  void moveUp() {
    _clearFlags();
    if (_canMergeAnyTile()) {
      final mergedBoard = _mergeLeft(_transposedTiles(board.currentTiles));
      board.previousTiles = board.currentTiles;
      board.currentTiles = _transposedTiles(mergedBoard);
    }
    notifyListeners();
  }

  void moveDown() {
    _clearFlags();
    if (_canMergeAnyTile()) {
      final mergedBoard = _mergeLeft(
        _mirroredTiles(_transposedTiles(board.currentTiles)),
      );
      board.previousTiles = board.currentTiles;
      board.currentTiles = _transposedTiles(_mirroredTiles(mergedBoard));
    }
    notifyListeners();
  }

  void moveRight() {
    _clearFlags();
    if (_canMergeAnyTile()) {
      final mergedBoard = _mergeLeft(_mirroredTiles(board.currentTiles));
      board.previousTiles = board.currentTiles;
      board.currentTiles = _mirroredTiles(mergedBoard);
    }
    notifyListeners();
  }

  void moveLeft() {
    _clearFlags();
    if (_canMergeAnyTile()) {
      board.previousTiles = board.currentTiles;
      board.currentTiles = _mergeLeft(board.currentTiles);
    }
    notifyListeners();
  }

  void resetGame() {
    _scoreAlreadySaved = false;
    _initBoard();
    notifyListeners();
  }

  void undoMove() {
    if (board.previousTiles != null) {
      board.currentTiles = board.previousTiles!;
      notifyListeners();
    }
  }
}
