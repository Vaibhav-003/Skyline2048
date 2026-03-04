import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyline2048/viewmodels/game_viewmodel.dart';

class ExitGameDialog extends StatelessWidget {
  const ExitGameDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Exit Game?'),
      content: const Text('Are you sure you want to exit the game?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () {
            // Save the current score before leaving, then go back.
            context.read<GameViewModel>().saveCurrentScore();
            Navigator.pop(context); // close dialog
            Navigator.pop(context); // pop game screen
          },
          child: const Text('Yes'),
        ),
      ],
    );
  }
}
