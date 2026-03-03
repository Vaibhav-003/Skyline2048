import 'package:hive/hive.dart';
import 'package:skyline2048/models/board.dart';

class BoardRepository {
  Box get _boardBox => Hive.box('board');
  Box get _scoreBox => Hive.box('bestScores');

  static Future<void> openBoxes() async {
    await Hive.openBox('board');
    await Hive.openBox('bestScores');
  }

  void saveBoard(Board board) {
    _boardBox.put('board', board);
  }

  Board? loadBoard() {
    return _boardBox.get('board');
  }

  void saveBestScore(int score) {
    var bestScores = loadBestScores();
    if (bestScores != null) {
      bestScores.add(score);
      bestScores.sort((a, b) => b.compareTo(a));
    } else {
      bestScores = [score];
    }
    _scoreBox.put('bestScores', bestScores);
  }

  List<int>? loadBestScores() {
    return _scoreBox.get('bestScores');
  }
}
