import 'package:example/theme/theme/dart_theme.dart';
import 'package:flutter/material.dart';

abstract class ThemeCustom {
  final ThemeData _baseTheme;

  ThemeData get baseTheme => _baseTheme;

  factory ThemeCustom.dark({ThemeData? baseTheme}) {
    return baseTheme == null
        ? DarkTheme.fromDefault()
        : DarkTheme(baseTheme: baseTheme);
  }
  factory ThemeCustom.light({ThemeData? baseTheme}) {
    return baseTheme == null
        ? DarkTheme.fromDefault()
        : DarkTheme(baseTheme: baseTheme);
  }

  ThemeCustom({
    required ThemeData baseTheme,
  }) : _baseTheme = baseTheme;

  List<ThemeExtension<dynamic>> themeExtensions() {
    return [];
  }

  ThemeExtension<dynamic>? colorExtension() {
    return null;
  }

  ThemeExtension<dynamic>? textExtension() {
    return null;
  }

  TextTheme textTheme() {
    return _baseTheme.textTheme;
  }

  AppBarTheme appBarTheme() {
    return _baseTheme.appBarTheme;
  }

  ColorScheme colorScheme() {
    return _baseTheme.colorScheme;
  }

  IconThemeData iconTheme() {
    return _baseTheme.iconTheme;
  }

  SnackBarThemeData snackBarThemeData() {
    return _baseTheme.snackBarTheme;
  }

  BottomAppBarTheme bottomAppBarTheme() {
    return _baseTheme.bottomAppBarTheme;
  }

  CheckboxThemeData checkboxThemeData() {
    return _baseTheme.checkboxTheme;
  }

  RadioThemeData radioThemeData() {
    return _baseTheme.radioTheme;
  }

  SwitchThemeData switchThemeData() {
    return _baseTheme.switchTheme;
  }
}
