import 'package:hive/hive.dart';
import 'package:skyline2048/models/board.dart';

class BoardStorage {
  final boardBox = Hive.box('board');

  final scoreBox = Hive.box('bestScores');

  static Future<void> openBoxes() async {
    await Hive.openBox('board');
    await Hive.openBox('bestScores');
  }

  void saveBoard(Board board) {
    boardBox.put('board', board);
  }

  Board? loadBoard() {
    return boardBox.get('board');
  }

  void saveBestScore(int score) {
    var bestScores = loadBestScores();
    if (bestScores != null) {
      bestScores.add(score);
      bestScores.sort((a, b) => b.compareTo(a));
    } else {
      bestScores = [score];
    }
    scoreBox.put('bestScores', bestScores);
  }

  List<int>? loadBestScores() {
    return scoreBox.get('bestScores');
  }
}
