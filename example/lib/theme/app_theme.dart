import 'package:example/theme/theme/theme_contract.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    final baseDarkTheme = ThemeData.dark();
    return _copyFromTheme(
      themeData: baseDarkTheme,
      themeCustom: ThemeCustom.dark(baseTheme: baseDarkTheme),
    );
  }

  static ThemeData light() {
    final baseLightTheme = ThemeData.light();
    return _copyFromTheme(
      themeData: baseLightTheme,
      themeCustom: ThemeCustom.light(baseTheme: baseLightTheme),
    );
  }

  static ThemeData _copyFromTheme({
    required ThemeData themeData,
    ThemeCustom? themeCustom,
  }) {
    if (themeCustom == null) {
      return themeData;
    }
    return themeData.copyWith(
      extensions: themeCustom.themeExtensions(),
      colorScheme: themeCustom.colorScheme(),
      iconTheme: themeCustom.iconTheme(),
      textTheme: themeCustom.textTheme(),
      snackBarTheme: themeCustom.snackBarThemeData(),
      appBarTheme: themeCustom.appBarTheme(),
      bottomAppBarTheme: themeCustom.bottomAppBarTheme(),
      checkboxTheme: themeCustom.checkboxThemeData(),
      radioTheme: themeCustom.radioThemeData(),
      switchTheme: themeCustom.switchThemeData(),
    );
  }
}
