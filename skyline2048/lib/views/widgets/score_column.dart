import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyline2048/app_theme.dart';
import 'package:skyline2048/viewmodels/game_viewmodel.dart';

enum ScoreType { score, best }

class ScoreColumn extends StatelessWidget {
  final String title;
  final ScoreType scoreType;
  final IconData icon;
  final VoidCallback onPressed;

  const ScoreColumn({
    super.key,
    required this.title,
    required this.scoreType,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width / 4,
      child: Column(
        children: [
          Container(
            width: width / 4,
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: AppTheme.cardRadius(width),
            ),
            padding: EdgeInsets.all(width * 0.05),
            child: Column(
              children: [
                Text(title, style: AppTheme.scoreStyle),
                Consumer<GameViewModel>(
                  builder: (context, gameViewModel, child) {
                    final value = scoreType == ScoreType.score
                        ? gameViewModel.board.score
                        : gameViewModel.bestScore;
                    return Text('$value', style: AppTheme.scoreStyle);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: width * 0.05),
          Container(
            width: width / 4,
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: AppTheme.cardRadius(width),
            ),
            padding: EdgeInsets.all(width * 0.02),
            child: IconButton(onPressed: onPressed, icon: Icon(icon)),
          ),
        ],
      ),
    );
  }
}
