import 'package:flutter/material.dart';

abstract final class ExpenseMateColors {
  static const forest = Color(0xFF1C5B4D);
  static const forestLight = Color(0xFF327967);
  static const lime = Color(0xFFD2F078);
  static const coral = Color(0xFFE99575);
  static const yellow = Color(0xFFE7BB51);
  static const blue = Color(0xFF82ADD4);
  static const lilac = Color(0xFFB29AD8);
}

abstract final class ExpenseMateTheme {
  static ThemeData get theme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    const lightCanvas = Color(0xFFF5F7F3);
    const lightSurface = Color(0xFFFFFFFF);
    const lightInk = Color(0xFF17352E);
    const lightMuted = Color(0xFF7D8A83);
    const lightLine = Color(0xFFE8ECE7);
    const darkCanvas = Color(0xFF101815);
    const darkSurface = Color(0xFF1B2822);
    const darkInk = Color(0xFFE7F0EA);
    const darkMuted = Color(0xFFA9B8AF);
    const darkLine = Color(0xFF34443B);

    final canvas = isDark ? darkCanvas : lightCanvas;
    final surface = isDark ? darkSurface : lightSurface;
    final ink = isDark ? darkInk : lightInk;
    final muted = isDark ? darkMuted : lightMuted;
    final line = isDark ? darkLine : lightLine;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: ExpenseMateColors.forest,
          brightness: brightness,
          surface: surface,
        ).copyWith(
          surface: surface,
          onSurface: ink,
          onSurfaceVariant: muted,
          outline: line,
          outlineVariant: line,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      dividerColor: line,
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: ink,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
        ),
        headlineMedium: TextStyle(
          color: ink,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        titleLarge: TextStyle(
          color: ink,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: ink,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: ink, fontSize: 15),
        bodyMedium: TextStyle(color: muted, fontSize: 13),
        labelLarge: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: muted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: ExpenseMateColors.forestLight,
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
        backgroundColor: isDark ? darkSurface : lightInk,
        contentTextStyle: TextStyle(color: isDark ? darkInk : Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(backgroundColor: surface),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
