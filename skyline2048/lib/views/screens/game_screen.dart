import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:skyline2048/viewmodels/game_viewmodel.dart';
import 'package:skyline2048/views/widgets/game_board.dart';
import 'package:skyline2048/views/widgets/score_column.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
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
                    onPressed: context.read<GameViewModel>().resetGame,
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
                    onPressed: context.read<GameViewModel>().undoMove,
                  ),
                ],
              ),
              Expanded(child: Center(child: GameBoard())),
              Padding(padding: EdgeInsets.symmetric(vertical: width * 0.02)),
              Padding(
                padding: EdgeInsets.symmetric(vertical: width * 0.02),
                child: SizedBox(
                  width: double.infinity,
                  child: Consumer<GameViewModel>(
                    builder: (context, gameViewModel, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _DirectionButton(
                            icon: Icons.swipe_up,
                            label: 'UP',
                            onPressed: () {
                              gameViewModel.moveUp();
                              _addTileAfterDelay(gameViewModel);
                            },
                          ),
                          _DirectionButton(
                            icon: Icons.swipe_down,
                            label: 'DOWN',
                            onPressed: () {
                              gameViewModel.moveDown();
                              _addTileAfterDelay(gameViewModel);
                            },
                          ),
                          _DirectionButton(
                            icon: Icons.swipe_left,
                            label: 'LEFT',
                            onPressed: () {
                              gameViewModel.moveLeft();
                              _addTileAfterDelay(gameViewModel);
                            },
                          ),
                          _DirectionButton(
                            icon: Icons.swipe_right,
                            label: 'RIGHT',
                            onPressed: () {
                              gameViewModel.moveRight();
                              _addTileAfterDelay(gameViewModel);
                            },
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
    );
  }

  void _addTileAfterDelay(GameViewModel vm) {
    Future.delayed(const Duration(milliseconds: 200), vm.addNewTile);
  }
}

/// Small reusable direction button widget — keeps GameScreen build() clean.
class _DirectionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _DirectionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.lightBlue.shade100,
            borderRadius: BorderRadius.circular(width * 0.02),
          ),
          child: IconButton(
            iconSize: 40,
            onPressed: onPressed,
            icon: Icon(icon),
          ),
        ),
        Text(label),
      ],
    );
  }
}
