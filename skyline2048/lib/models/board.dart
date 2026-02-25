class Board {
  final Map<int, int> currentTiles;
  final Map<int, int>? previousTiles;
  final int score;

  Board({required this.currentTiles, this.previousTiles, required this.score});
}
