import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyline2048/app_theme.dart';
import 'package:skyline2048/viewmodels/game_viewmodel.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Dialog(
      backgroundColor: AppTheme.cardColor,
      child: Padding(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/game_over_vector.png', height: 150),
            const SizedBox(height: 16),
            const Text('Game Over', style: AppTheme.dialogHeadingStyle),
            const SizedBox(height: 8),
            Consumer<GameViewModel>(
              builder: (context, vm, _) => Column(
                children: [
                  Text('Score: ${vm.board.score}', style: AppTheme.scoreStyle),
                  Text('Best: ${vm.bestScore}', style: AppTheme.scoreStyle),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<GameViewModel>().resetGame(),
              child: const Text('Play Again'),
            ),
          ],
        ),
      ),
    );
  }
}
