import 'package:flutter/material.dart';

class BestScores extends StatelessWidget {
  const BestScores({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Best Scores',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ListView.separated(
          itemCount: 10,
          itemBuilder: (context, index) {
            return Text('Best Score $index');
          },
          separatorBuilder: (context, index) {
            return const Divider();
          },
        ),
      ],
    );
  }
}
