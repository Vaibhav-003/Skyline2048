import 'package:flutter/material.dart';
import 'package:skyline2048/game_board/game_board.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        child: Center(child: GameBoard()),
      ),
    );
  }
}
