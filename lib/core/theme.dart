import 'package:flutter/material.dart';

class RgtColors {
  static const green = Color(0xFF0C4A29);
  static const greenMid = Color(0xFF157A3F);
  static const greenLight = Color(0xFF3FAF6E);
  static const leaf = Color(0xFF6FBF4A);
  static const gold = Color(0xFFE8C066);
  static const goldDark = Color(0xFF9A6C10);
  static const cream = Color(0xFFF7F6F0);
  static const ink = Color(0xFF1E2620);
  static const grey = Color(0xFF6E766E);
  static const line = Color(0xFFE4EAE0);
  static const blue = Color(0xFF5EA6DC);
  static const purple = Color(0xFF9C8BD6);
  static const red = Color(0xFFDE7A6E);
  static const teal = Color(0xFF5FC7C0);
}

ThemeData rgtTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: RgtColors.greenLight,
      primary: RgtColors.green,
      secondary: RgtColors.gold,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: RgtColors.cream,
  );
  return base.copyWith(
    appBarTheme: const AppBarTheme(
      backgroundColor: RgtColors.green,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: RgtColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: RgtColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: RgtColors.greenLight, width: 1.6),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: RgtColors.green,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    ),
  );
}
