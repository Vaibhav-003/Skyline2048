import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skyline2048/models/board.dart';

class GameProvider extends ChangeNotifier {
  static const List<int> randomTileIndexes = [1, 2, 1, 2, 1];

  static List<int> generateTwoRandomTileIndexes(int length) {
    final random = Random();
    final int firstIndex = random.nextInt(length);
    int secondIndex;
    do {
      secondIndex = random.nextInt(length);
    } while (secondIndex == firstIndex);

    return [firstIndex, secondIndex];
  }

  static List<int> randomIndexes = generateTwoRandomTileIndexes(16);

  static List<int> randomTileValues = generateTwoRandomTileIndexes(5);

  Board board = Board(
    currentTiles: {
      randomIndexes[0]: randomTileIndexes[randomTileValues[0]],
      randomIndexes[1]: randomTileIndexes[randomTileValues[1]],
    },
    previousTiles: null,
    score: 0,
  );

  
} 