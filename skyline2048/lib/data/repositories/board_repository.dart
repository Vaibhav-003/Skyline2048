import 'package:hive/hive.dart';
import 'package:skyline2048/models/board.dart';
import 'package:skyline2048/models/score_entry.dart';

class BoardRepository {
  Box get _boardBox => Hive.box('board');
  Box get _scoreBox => Hive.box('bestScores');
  Box get _topScoresBox => Hive.box('topScores');

  static Future<void> openBoxes() async {
    await Hive.openBox('board');
    await Hive.openBox('bestScores');
    await Hive.openBox('topScores');
  }

  void saveBoard(Board board) => _boardBox.put('board', board);

  Board? loadBoard() => _boardBox.get('board');

  void saveBestScore(List<int> bestScores) =>
      _scoreBox.put('bestScores', bestScores);

  List<int>? loadBestScores() => _scoreBox.get('bestScores');

  // ── Top-5 score entries stored as List<Map> ────────────────────────────────

  /// Inserts [entry], keeps only the top 5 by score, persists to Hive.
  void saveTopScore(ScoreEntry entry) {
    final entries = loadTopScores();
    entries.add(entry);
    entries.sort((a, b) => b.score.compareTo(a.score));
    final top5 = entries.take(5).map((e) => e.toMap()).toList();
    _topScoresBox.put('scores', top5);
  }

  /// Returns the stored top scores sorted highest-first (empty list if none).
  List<ScoreEntry> loadTopScores() {
    final raw = _topScoresBox.get('scores');
    if (raw == null) return [];
    return (raw as List).map((m) => ScoreEntry.fromMap(m as Map)).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
  }
}
