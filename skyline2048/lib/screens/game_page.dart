import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:skyline2048/game_board/game_board.dart';
import 'package:skyline2048/game_board/score_column.dart';
import 'package:skyline2048/providers/game_provider.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(width * 0.075),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ScoreColumn(
                      title: 'Score',
                      scoreType: ScoreType.score,
                      icon: Icons.refresh,
                      onPressed: context.read<GameProvider>().resetGame,
                    ),
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(width * 0.02),
                          child: SvgPicture.asset(
                            'assets/tile_14.svg',
                            width: width / 4,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: width * 0.02),
                        ),
                        Text(
                          'SKYLINE \n2048',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ScoreColumn(
                      title: 'Best',
                      scoreType: ScoreType.best,
                      icon: Icons.undo,
                      onPressed: context.read<GameProvider>().undoMove,
                    ),
                  ],
                ),
                Expanded(child: Center(child: GameBoard())),
                Padding(padding: EdgeInsets.symmetric(vertical: width * 0.02)),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: width * 0.02),
                  child: SizedBox(
                    // height: 100,
                    width: double.infinity,
                    child: Consumer<GameProvider>(
                      builder: (context, gameProvider, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlue.shade100,
                                    borderRadius: BorderRadius.circular(
                                      width * 0.02,
                                    ),
                                  ),
                                  child: IconButton(
                                    iconSize: 40,
                                    onPressed: () {
                                      gameProvider.moveUp();
                                      Future.delayed(
                                        const Duration(milliseconds: 200),
                                        () {
                                          gameProvider.addNewTile();
                                        },
                                      );
                                    },
                                    icon: Icon(Icons.swipe_up),
                                  ),
                                ),
                                Text('UP'),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlue.shade100,
                                    borderRadius: BorderRadius.circular(
                                      width * 0.02,
                                    ),
                                  ),
                                  child: IconButton(
                                    iconSize: 40,
                                    onPressed: () {
                                      gameProvider.moveDown();
                                      Future.delayed(
                                        const Duration(milliseconds: 200),
                                        () {
                                          gameProvider.addNewTile();
                                        },
                                      );
                                    },
                                    icon: Icon(Icons.swipe_down),
                                  ),
                                ),
                                Text('DOWN'),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlue.shade100,
                                    borderRadius: BorderRadius.circular(
                                      width * 0.02,
                                    ),
                                  ),
                                  child: IconButton(
                                    iconSize: 40,
                                    onPressed: () {
                                      gameProvider.moveLeft();
                                      Future.delayed(
                                        const Duration(milliseconds: 200),
                                        () {
                                          gameProvider.addNewTile();
                                        },
                                      );
                                    },
                                    icon: Icon(Icons.swipe_left),
                                  ),
                                ),
                                Text('LEFT'),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlue.shade100,
                                    borderRadius: BorderRadius.circular(
                                      width * 0.02,
                                    ),
                                  ),
                                  child: IconButton(
                                    iconSize: 40,
                                    onPressed: () {
                                      gameProvider.moveRight();
                                      Future.delayed(
                                        const Duration(milliseconds: 200),
                                        () {
                                          gameProvider.addNewTile();
                                        },
                                      );
                                    },
                                    icon: Icon(Icons.swipe_right),
                                  ),
                                ),
                                Text('RIGHT'),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
