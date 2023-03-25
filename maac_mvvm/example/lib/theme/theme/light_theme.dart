import 'package:example/theme/color/app_colors.dart';
import 'package:example/theme/theme/theme_contract.dart';
import 'package:flutter/material.dart';

class LightTheme extends ThemeCustom {
  final AppColors _appColors = AppColors.light();

  LightTheme({required super.baseTheme});

  factory LightTheme.fromDefault() => LightTheme(baseTheme: ThemeData.light());

  @override
  ColorScheme colorScheme() {
    return _appColors.colorsScheme;
  }

 @override
  ThemeExtension? colorExtension() {
    return _appColors.colorsExtension;
  }
}
