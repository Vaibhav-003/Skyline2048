import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyline2048/providers/game_provider.dart';
import 'package:skyline2048/tile/tile_widget.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final boardSize = width * 0.8;
    final gap = width * 0.025;
    final padding = gap; // proportional to screen width, same unit as gap

    // Cell size derived from board geometry.
    final cellSize = (boardSize - 2 * padding - 3 * gap) / 4;
    final borderRadius = gap;

    // Helpers to convert row/col → pixel offsets inside the board Stack.
    double left(int col) => padding + col * (cellSize + gap);
    double top(int row) => padding + row * (cellSize + gap);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Merge bricks to build the Burj Khalifa!',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: width * 0.02),
        Consumer<GameProvider>(
          builder: (context, gameProvider, child) => GestureDetector(
            // ── Swipe detection ──────────────────────────────────────────────
            onVerticalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity > 0) {
                gameProvider.moveDown();
              } else if (velocity < 0) {
                gameProvider.moveUp();
              }
              if (velocity != 0) {
                Future.delayed(const Duration(milliseconds: 200), () {
                  gameProvider.addNewTile();
                });
              }
            },
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity > 0) {
                gameProvider.moveRight();
              } else if (velocity < 0) {
                gameProvider.moveLeft();
              }
              if (velocity != 0) {
                Future.delayed(const Duration(milliseconds: 200), () {
                  gameProvider.addNewTile();
                });
              }
            },

            // ── Board container ───────────────────────────────────────────────
            child: Container(
              width: boardSize,
              height: boardSize,
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade100,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Stack(
                children: [
                  // ── 1. Static background cells (empty slots) ──────────────
                  ...List.generate(4, (row) {
                    return List.generate(4, (col) {
                      return Positioned(
                        left: left(col),
                        top: top(row),
                        width: cellSize,
                        height: cellSize,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 182, 202, 211),
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                        ),
                      );
                    });
                  }).expand((list) => list),

                  // ── 2. Animated tiles ─────────────────────────────────────
                  // Each tile is tracked by its unique [Tile.id] via ValueKey.
                  // AnimatedPositioned slides the tile when its row/col changes.
                  // TileWidget handles the spawn pop and merge pulse internally.
                  ...gameProvider.tilePositions.map((entry) {
                    return AnimatedPositioned(
                      key: ValueKey(entry.tile.id),
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOut,
                      left: left(entry.col),
                      top: top(entry.row),
                      width: cellSize,
                      height: cellSize,
                      child: TileWidget(
                        tile: entry.tile,
                        size: cellSize,
                        borderRadius: borderRadius,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
