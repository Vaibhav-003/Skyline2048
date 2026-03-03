import 'package:hive/hive.dart';
import 'package:skyline2048/models/tile.dart';

@HiveType(typeId: 0)
class Board extends HiveObject {
  @HiveField(0)
  int score;

  @HiveField(1)
  List<List<Tile>> currentTiles;

  @HiveField(2)
  List<List<Tile>>? previousTiles;

  Board({required this.score, required this.currentTiles, this.previousTiles});
}
