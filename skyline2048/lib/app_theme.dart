import 'package:flutter/material.dart';

abstract final class AppTheme {
  /// Light-blue card / container background used throughout the UI.
  static const Color cardColor = Color(0xFFB3E5FC);

  /// Empty cell slots on the board.
  static const Color boardCellColor = Color(0xFFB6CAD3);

  /// Semi-transparent backdrop behind the game-over dialog overlay.
  static const Color overlayColor = Color(0x8A000000); // black54

  /// Score labels and score column title.
  static const TextStyle scoreStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  /// Game title ("SKYLINE\n2048") displayed in the header.
  static const TextStyle titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  /// Large heading inside dialogs (e.g. "Game Over").
  static const TextStyle dialogHeadingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  /// Small direction-button labels (UP / DOWN / LEFT / RIGHT).
  static const TextStyle directionLabelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  /// Returns a consistent border-radius that scales with screen width.
  static BorderRadius cardRadius(double width) =>
      BorderRadius.circular(width * 0.02);

  static ThemeData get themeData => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF29B6F6)),
    useMaterial3: true,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF29B6F6),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    dialogTheme: const DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );
}
