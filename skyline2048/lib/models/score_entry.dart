/// Represents one completed-game score entry.
/// Stored in Hive as a plain Map — no TypeAdapter needed.
class ScoreEntry {
  final int score;
  final int dateMs;
  final int highestTileValue;

  ScoreEntry({
    required this.score,
    required this.dateMs,
    required this.highestTileValue,
  });

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(dateMs);

  Map<String, dynamic> toMap() => {
    'score': score,
    'dateMs': dateMs,
    'tile': highestTileValue,
  };

  factory ScoreEntry.fromMap(Map map) => ScoreEntry(
    score: map['score'] as int,
    dateMs: map['dateMs'] as int,
    highestTileValue: map['tile'] as int,
  );
}
