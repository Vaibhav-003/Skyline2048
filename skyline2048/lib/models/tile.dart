

import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class Tile extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int value;

  @HiveField(2)
  final bool isNew;

  @HiveField(3)
  final bool isMerged;

  Tile({
    required this.id,
    required this.value,
    this.isNew = false,
    this.isMerged = false,
  });

    Tile copyWith({int? value, bool? isNew, bool? isMerged}) {
    return Tile(
      id: id,
      value: value ?? this.value,
      isNew: isNew ?? this.isNew,
      isMerged: isMerged ?? this.isMerged,
    );
  }
}
