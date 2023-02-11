import 'package:example/theme/color/app_colors.dart';
import 'package:example/theme/text/text_theme_extension.dart';
import 'package:example/theme/theme/theme_contract.dart';
import 'package:flutter/material.dart';

class DarkTheme extends ThemeCustom {
  final AppColors _appColors = AppColors.dark();

  DarkTheme({required super.baseTheme});

  factory DarkTheme.fromDefault() => DarkTheme(baseTheme: ThemeData.dark());

  @override
  ColorScheme colorScheme() {
    return _appColors.colorsScheme;
  }

  @override
  ThemeExtension? colorExtension() {
    return _appColors.colorsExtension;
  }
  @override
  ThemeExtension? textExtension() {
    return TextThemeExtension(colors: colorExtension() as AppColorsExtension);
  }
  @override
  AppBarTheme appBarTheme() {
    return baseTheme.appBarTheme.copyWith(
      foregroundColor: (colorExtension() as AppColorsExtension)
          .primaryText, //appbar color text
    );
  }
}
