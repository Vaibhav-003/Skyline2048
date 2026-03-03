import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:skyline2048/screens/home_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/splash_updated.json',
          animate: true,
          onLoaded: (p0) {
            Future.delayed(const Duration(seconds: 3), () {
              if (!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            });
          },
        ),
      ),
    );
  }
}
