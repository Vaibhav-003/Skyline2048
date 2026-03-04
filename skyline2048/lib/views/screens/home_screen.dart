import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:skyline2048/data/repositories/board_repository.dart';
import 'package:skyline2048/viewmodels/game_viewmodel.dart';
import 'package:skyline2048/views/screens/best_scores_screen.dart';
import 'package:skyline2048/views/screens/game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isGameSaved = false;

  @override
  void initState() {
    super.initState();
    _loadBoard();
  }

  Future<void> _loadBoard() async {
    final board = BoardRepository().loadBoard();
    if (board != null) {
      _isGameSaved = true;
      setState(() {
        context.read<GameViewModel>().board = board;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.all(width * 0.075),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  'assets/skyline_logo.svg',
                  height: 200,
                  width: double.infinity,
                ),
                Text(
                  'SKYLINE \n2048',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<GameViewModel>().resetGame();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GameScreen(),
                      ),
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
                        MaterialPageRoute(
                          builder: (context) => const GameScreen(),
                        ),
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
                      MaterialPageRoute(
                        builder: (context) => const BestScoresScreen(),
                      ),
                    );
                  },
                  child: const Text('Best Scores'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
