import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:skyline2048/providers/game_provider.dart';
import 'package:skyline2048/splash/splash_screen.dart';
import 'package:skyline2048/storage/board_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await BoardStorage.openBoxes();
  runApp(const Skyline2048App());
}

class Skyline2048App extends StatelessWidget {
  const Skyline2048App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => GameProvider())],
      child: MaterialApp(
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
