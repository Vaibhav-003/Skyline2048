import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyline2048/providers/game_provider.dart';
import 'package:skyline2048/splash/splash_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => GameProvider())],
      child: MaterialApp(home: SplashScreen()),
    );
  }
}
