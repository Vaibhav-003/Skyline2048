import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyline2048/providers/game_provider.dart';
import 'package:skyline2048/tile/tile_widget.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  Widget? _buildTile(int index, GameProvider gameProvider) {
    final tileIndexes = gameProvider.board.currentTiles.keys.toList();

    return (tileIndexes.contains(index))
        ? Tile(tileIndex: gameProvider.board.currentTiles[tileIndexes[0]] ?? 1)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlue.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width - 60,
        height: MediaQuery.of(context).size.width - 60,

        child: Consumer<GameProvider>(
          builder: (context, gameProvider, child) => GridView.builder(
            itemCount: 16,
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              crossAxisCount: 4,
            ),
            itemBuilder: (context, index) {
              final currentTiles = gameProvider.board.currentTiles;
              print('currentTiles: $currentTiles');
              final tileIndexes = currentTiles.keys.toList();
              print('tileIndexes: $tileIndexes');
              List<Widget> tiles = List.filled(16, SizedBox.shrink());
              for (var index in tileIndexes) {
                print('index: $index');
                print('currentTiles[$index]: ${currentTiles[index]}');
                tiles[index] = Tile(tileIndex: (currentTiles[index] ?? 0));
              }
              return GestureDetector(
                onVerticalDragEnd: (details) {
                  print(details);
                },
                onHorizontalDragEnd: (details) {
                  print(details);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 182, 202, 211),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: tiles[index],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
