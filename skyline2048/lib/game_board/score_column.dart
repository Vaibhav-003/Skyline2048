import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyline2048/providers/game_provider.dart';

enum ScoreType { score, best }

class ScoreColumn extends StatelessWidget {
  final String title;
  final ScoreType scoreType;
  final IconData icon;
  final VoidCallback onPressed;
  const ScoreColumn({super.key, required this.title, required this.scoreType, required this.icon, required this.onPressed});

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
              color: Colors.lightBlue.shade100,
              borderRadius: BorderRadius.circular(width * 0.02),
            ),
            padding: EdgeInsets.all(width * 0.05),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Consumer<GameProvider>(
                  builder: (context, gameProvider, child) {
                    return Text(
                      "${scoreType == ScoreType.score ? gameProvider.board.score : gameProvider.bestScore}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: width * 0.05),
          Container(
            width: width / 4,
            decoration: BoxDecoration(
              color: Colors.lightBlue.shade100,
              borderRadius: BorderRadius.circular(width * 0.02),
            ),
            padding: EdgeInsets.all(width * 0.02),
            child: IconButton(onPressed: onPressed, icon: Icon(icon)),
          ),
        ],
      ),
    );
  }
}
