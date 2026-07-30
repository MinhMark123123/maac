import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.light,
      primary: const Color(0xFF6750A4),
      secondary: const Color(0xFF625B71),
      surface: const Color(0xFFFEF7FF),
    ),
    scaffoldBackgroundColor: const Color(0xFFFEF7FF),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(color: Color(0xFF1C1B1F), fontSize: 22, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: const Color(0xFF79747E).withValues(alpha: 0.12), width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1C1B1F)),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1C1B1F), letterSpacing: 0.1),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Color(0xFF49454F), height: 1.5),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFD0BCFF),
      brightness: Brightness.dark,
      primary: const Color(0xFFD0BCFF),
      secondary: const Color(0xFFCCC2DC),
      surface: const Color(0xFF141218),
    ),
    scaffoldBackgroundColor: const Color(0xFF141218),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(color: Color(0xFFE6E1E5), fontSize: 22, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF1D1B20),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: const Color(0xFF49454F).withValues(alpha: 0.5), width: 1),
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFE6E1E5)),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFE6E1E5), letterSpacing: 0.1),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Color(0xFFCAC4D0), height: 1.5),
    ),
  );
}
