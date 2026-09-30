import 'package:flutter/material.dart';

abstract final class ExpenseMateColors {
  static const ink = Color(0xFF17352E);
  static const forest = Color(0xFF1C5B4D);
  static const forestLight = Color(0xFF327967);
  static const lime = Color(0xFFD2F078);
  static const canvas = Color(0xFFF5F7F3);
  static const white = Color(0xFFFFFFFF);
  static const muted = Color(0xFF7D8A83);
  static const line = Color(0xFFE8ECE7);
  static const mint = Color(0xFFE8F3EC);
  static const coral = Color(0xFFE99575);
  static const yellow = Color(0xFFE7BB51);
  static const blue = Color(0xFF82ADD4);
  static const lilac = Color(0xFFB29AD8);
}

abstract final class ExpenseMateTheme {
  static ThemeData get theme {
    final scheme = ColorScheme.fromSeed(
      seedColor: ExpenseMateColors.forest,
      brightness: Brightness.light,
      surface: ExpenseMateColors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ExpenseMateColors.canvas,
      appBarTheme: const AppBarTheme(
        backgroundColor: ExpenseMateColors.canvas,
        foregroundColor: ExpenseMateColors.ink,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: ExpenseMateColors.ink,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
        ),
        headlineMedium: TextStyle(
          color: ExpenseMateColors.ink,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        titleLarge: TextStyle(
          color: ExpenseMateColors.ink,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: ExpenseMateColors.ink,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: ExpenseMateColors.ink, fontSize: 15),
        bodyMedium: TextStyle(color: ExpenseMateColors.muted, fontSize: 13),
        labelLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ExpenseMateColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: ExpenseMateColors.muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: ExpenseMateColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: ExpenseMateColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: ExpenseMateColors.forest,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFCC584A)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFCC584A), width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.fixed,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
