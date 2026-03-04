import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyline2048/app_theme.dart';
import 'package:skyline2048/viewmodels/game_viewmodel.dart';
import 'package:skyline2048/views/widgets/tile_widget.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final boardSize = width * 0.8;
    final gap = width * 0.025;
    final padding = gap;

    final cellSize = (boardSize - 2 * padding - 3 * gap) / 4;
    final borderRadius = gap;

    double left(int col) => padding + col * (cellSize + gap);
    double top(int row) => padding + row * (cellSize + gap);

    return Center(
      child: Consumer<GameViewModel>(
        builder: (context, gameViewModel, child) => GestureDetector(
          // ── Swipe detection ─────────────────────────────────────────────
          onVerticalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity > 0) {
              gameViewModel.moveDown();
            } else if (velocity < 0) {
              gameViewModel.moveUp();
            }
            if (velocity != 0) {
              Future.delayed(const Duration(milliseconds: 200), () {
                gameViewModel.addNewTile();
              });
            }
          },
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;
            if (velocity > 0) {
              gameViewModel.moveRight();
            } else if (velocity < 0) {
              gameViewModel.moveLeft();
            }
            if (velocity != 0) {
              Future.delayed(const Duration(milliseconds: 200), () {
                gameViewModel.addNewTile();
              });
            }
          },

          // ── Board container ───────────────────────────────────────────
          child: Container(
            width: boardSize,
            height: boardSize,
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Stack(
              children: [
                // ── 1. Static background cells (empty slots) ─────────────
                ...List.generate(4, (row) {
                  return List.generate(4, (col) {
                    return Positioned(
                      left: left(col),
                      top: top(row),
                      width: cellSize,
                      height: cellSize,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.boardCellColor,
                          borderRadius: BorderRadius.circular(borderRadius),
                        ),
                      ),
                    );
                  });
                }).expand((list) => list),

                // ── 2. Animated tiles ─────────────────────────────────────
                ...gameViewModel.tilePositions.map((entry) {
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
    );
  }
}
