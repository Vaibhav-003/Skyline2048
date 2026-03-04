import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skyline2048/app_theme.dart';
import 'package:skyline2048/data/repositories/board_repository.dart';
import 'package:skyline2048/viewmodels/game_viewmodel.dart';
import 'package:skyline2048/views/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await BoardRepository.openBoxes();
  runApp(const Skyline2048App());
}

class Skyline2048App extends StatelessWidget {
  const Skyline2048App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => GameViewModel())],
      child: MaterialApp(
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themeData,
      ),
    );
  }
}
