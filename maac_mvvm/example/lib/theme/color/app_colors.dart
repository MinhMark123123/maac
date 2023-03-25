import 'package:example/theme/color/dark_color.dart';
import 'package:example/theme/color/light_color.dart';
import 'package:flutter/material.dart';

abstract class AppColors {
  final ColorScheme _colorsScheme;
  final ThemeExtension<AppColorsExtension>? _colorsExtension;
  final Color? _focusColor;

  ColorScheme get colorsScheme => _colorsScheme;

  Color? get focusColor => _focusColor;

  ThemeExtension<AppColorsExtension>? get colorsExtension => _colorsExtension;

  factory AppColors.dark() => DarkColors();

  factory AppColors.light() => LightColors();

  AppColors({
    required ColorScheme colorScheme,
    Color? focusColor,
    ThemeExtension<AppColorsExtension>? extension,
  })  : _colorsScheme = colorScheme,
        _focusColor = focusColor,
        _colorsExtension = extension;
}

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color? accent;
  final Color? primary;
  final Color? background;
  final Color? bottomNav;
  final Color? primaryText;
  final Color? selectedText;
  final Color? subText;
  final Color? secondaryText;
  final Color? container;
  final Color? tabBGActivate;
  final Color? tabBG;
  final Color? divider;
  final Color? badge;
  final Color? highlightSelected;
  final Color? decrease;
  final Color? increase;
  final Color? border;
  final Color? shadow;
  final Color? credit;
  final Color? disabled;
  final Color? textDisabled;
  final Color? boxShadow;
  final Color? loadingBackground;
  final Color? buttonCalculatorColor;
  final Color? itemCurrencySelected;
  final Color? actual;
  final Color? future;
  final Color? op;
  final Color? dialogSurface;
  final Color? important;
  final Color? trackColorSwitch;
  final Color? tradeBan;
  final Color? itemCurrency;
  final Color? decreaseOpacity10;
  final Color? increaseOpacity10;
  final Color? whiteOpacity10;
  final Color? stockIncrease;
  final Color? stockDecrease;
  final Color? flashed;

  AppColorsExtension({
    required this.accent,
    required this.primary,
    required this.background,
    required this.bottomNav,
    required this.primaryText,
    required this.selectedText,
    required this.subText,
    required this.secondaryText,
    required this.container,
    required this.tabBGActivate,
    required this.tabBG,
    required this.divider,
    required this.badge,
    required this.highlightSelected,
    required this.decrease,
    required this.increase,
    required this.border,
    required this.shadow,
    required this.credit,
    required this.disabled,
    required this.textDisabled,
    required this.boxShadow,
    required this.loadingBackground,
    required this.buttonCalculatorColor,
    required this.itemCurrencySelected,
    required this.actual,
    required this.future,
    required this.op,
    required this.dialogSurface,
    required this.important,
    required this.trackColorSwitch,
    required this.tradeBan,
    required this.itemCurrency,
    required this.decreaseOpacity10,
    required this.increaseOpacity10,
    required this.whiteOpacity10,
    required this.stockIncrease,
    required this.stockDecrease,
    required this.flashed,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? accent,
    Color? primary,
    Color? background,
    Color? primaryText,
    Color? selectedText,
    Color? container,
    Color? bottomNav,
    Color? tabBGActivate,
    Color? tabBG,
    Color? divider,
    Color? badge,
    Color? highlightSelected,
    Color? increase,
    Color? decrease,
    Color? bodyBG,
    Color? border,
    Color? shadow,
    Color? credit,
    Color? disabled,
    Color? textDisabled,
    Color? subText,
    Color? secondaryText,
    Color? boxShadow,
    Color? loadingBackground,
    Color? buttonCalculatorColor,
    Color? itemCurrencySelected,
    Color? actual,
    Color? future,
    Color? op,
    Color? dialogSurface,
    Color? important,
    Color? trackColorSwitch,
    Color? tradeBan,
    Color? itemCurrency,
    Color? decreaseOpacity10,
    Color? increaseOpacity10,
    Color? whiteOpacity10,
    Color? stockIncrease,
    Color? stockDecrease,
    Color? flashed,
  }) {
    return AppColorsExtension(
      accent: accent ?? this.accent,
      primary: primary ?? this.primary,
      background: background ?? this.background,
      primaryText: primaryText ?? this.primaryText,
      selectedText: selectedText ?? this.selectedText,
      container: container ?? this.container,
      bottomNav: bottomNav ?? this.bottomNav,
      tabBGActivate: tabBGActivate ?? this.tabBGActivate,
      tabBG: tabBG ?? this.tabBG,
      divider: divider ?? this.divider,
      badge: badge ?? this.badge,
      highlightSelected: highlightSelected ?? this.highlightSelected,
      increase: increase ?? this.increase,
      decrease: decrease ?? this.decrease,
      border: border ?? this.border,
      shadow: shadow ?? this.shadow,
      credit: credit ?? this.credit,
      disabled: disabled ?? this.disabled,
      textDisabled: textDisabled ?? this.textDisabled,
      subText: subText ?? this.subText,
      boxShadow: boxShadow ?? this.boxShadow,
      loadingBackground: loadingBackground ?? this.loadingBackground,
      buttonCalculatorColor:
          buttonCalculatorColor ?? this.buttonCalculatorColor,
      itemCurrencySelected: itemCurrencySelected ?? this.itemCurrencySelected,
      actual: actual ?? this.actual,
      future: future ?? this.future,
      op: op ?? this.op,
      secondaryText: secondaryText ?? this.secondaryText,
      dialogSurface: dialogSurface ?? this.dialogSurface,
      important: important ?? this.important,
      trackColorSwitch: trackColorSwitch ?? this.trackColorSwitch,
      tradeBan: tradeBan ?? this.tradeBan,
      itemCurrency: itemCurrency ?? this.itemCurrency,
      decreaseOpacity10: decreaseOpacity10 ?? this.decreaseOpacity10,
      increaseOpacity10: increaseOpacity10 ?? this.increaseOpacity10,
      whiteOpacity10: whiteOpacity10 ?? this.whiteOpacity10,
      stockIncrease: stockIncrease ?? this.stockIncrease,
      stockDecrease: stockDecrease ?? this.stockDecrease,
      flashed: flashed ?? this.flashed,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      accent: Color.lerp(accent, other.accent, t),
      primary: Color.lerp(primary, other.primary, t),
      background: Color.lerp(background, other.background, t),
      primaryText: Color.lerp(primaryText, other.primaryText, t),
      selectedText: Color.lerp(selectedText, other.selectedText, t),
      container: Color.lerp(container, other.container, t),
      bottomNav: Color.lerp(bottomNav, other.bottomNav, t),
      tabBGActivate: Color.lerp(tabBGActivate, other.tabBGActivate, t),
      tabBG: Color.lerp(tabBG, other.tabBG, t),
      divider: Color.lerp(divider, other.divider, t),
      badge: Color.lerp(badge, other.badge, t),
      highlightSelected:
          Color.lerp(highlightSelected, other.highlightSelected, t),
      increase: Color.lerp(increase, other.increase, t),
      decrease: Color.lerp(decrease, other.decrease, t),
      border: Color.lerp(border, other.border, t),
      shadow: Color.lerp(shadow, other.shadow, t),
      credit: Color.lerp(credit, other.credit, t),
      disabled: Color.lerp(disabled, other.disabled, t),
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t),
      subText: Color.lerp(subText, other.subText, t),
      boxShadow: Color.lerp(boxShadow, other.boxShadow, t),
      loadingBackground:
          Color.lerp(loadingBackground, other.loadingBackground, t),
      buttonCalculatorColor:
          Color.lerp(buttonCalculatorColor, other.buttonCalculatorColor, t),
      itemCurrencySelected:
          Color.lerp(itemCurrencySelected, other.itemCurrencySelected, t),
      actual: Color.lerp(actual, other.actual, t),
      future: Color.lerp(future, other.future, t),
      op: Color.lerp(op, other.op, t),
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t),
      dialogSurface: Color.lerp(dialogSurface, other.dialogSurface, t),
      important: Color.lerp(important, other.important, t),
      trackColorSwitch: Color.lerp(trackColorSwitch, other.trackColorSwitch, t),
      tradeBan: Color.lerp(tradeBan, other.tradeBan, t),
      itemCurrency: Color.lerp(itemCurrency, other.itemCurrency, t),
      decreaseOpacity10:
          Color.lerp(decreaseOpacity10, other.decreaseOpacity10, t),
      increaseOpacity10:
          Color.lerp(increaseOpacity10, other.increaseOpacity10, t),
      whiteOpacity10: Color.lerp(whiteOpacity10, other.whiteOpacity10, t),
      stockIncrease: Color.lerp(stockIncrease, other.stockIncrease, t),
      stockDecrease: Color.lerp(stockDecrease, other.stockDecrease, t),
      flashed: Color.lerp(flashed, other.flashed, t),
    );
  }
}
