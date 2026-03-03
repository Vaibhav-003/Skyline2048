import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:skyline2048/providers/game_provider.dart';
import 'package:skyline2048/screens/best_scores.dart';
import 'package:skyline2048/screens/game_page.dart';
import 'package:skyline2048/storage/board_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isGameSaved = false;
  @override
  void initState() {
    super.initState();
    _loadBoard();
  }

  Future<void> _loadBoard() async {
    final board = BoardStorage().loadBoard();
    if (board != null) {
      _isGameSaved = true;
      setState(() {
        context.read<GameProvider>().board = board;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(width * 0.075),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: SvgPicture.asset(
                'assets/skyline_logo.svg',
                height: 400,
                width: double.infinity,
              ),
            ),
            Text(
              'SKYLINE \n2048',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<GameProvider>().resetGame();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GamePage()),
                );
              },
              child: const Text('Play'),
            ),
            if (_isGameSaved) ...{
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GamePage()),
                  );
                },
                child: const Text('Continue'),
              ),
            },
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BestScores()),
                );
              },
              child: const Text('Best Scores'),
            ),
          ],
        ),
      ),
    );
  }
}
