import 'package:example/theme/color/app_colors.dart';
import 'package:example/theme/text/font_sizes.dart';
import 'package:flutter/material.dart';

class TextThemeExtension extends ThemeExtension<TextThemeExtension>{
  final AppColorsExtension colors;
  final TextStyle title;
  final TextStyle size42;
  final TextStyle size39;
  final TextStyle size35;
  final TextStyle size33;
  final TextStyle size31;
  final TextStyle size26;
  final TextStyle size25;
  final TextStyle size24;
  final TextStyle size23;
  final TextStyle size22;
  final TextStyle size21;
  final TextStyle size20;
  final TextStyle size19;
  final TextStyle size18;
  final TextStyle size17;
  final TextStyle size16;
  final TextStyle size15;
  final TextStyle size14;
  final TextStyle size13;
  final TextStyle size12;
  final TextStyle size11;
  final TextStyle size10;
  final TextStyle size10n5;
  final TextStyle size9;
  final TextStyle size9n5;
  final TextStyle size8;

  TextThemeExtension._({
    required this.colors,
    required this.size8,
    required this.size9,
    required this.size9n5,
    required this.size10n5,
    required this.size10,
    required this.size11,
    required this.size12,
    required this.size13,
    required this.size14,
    required this.size15,
    required this.size16,
    required this.size17,
    required this.size18,
    required this.size19,
    required this.size20,
    required this.size21,
    required this.size22,
    required this.size23,
    required this.size24,
    required this.size25,
    required this.size26,
    required this.size31,
    required this.size33,
    required this.size35,
    required this.size39,
    required this.size42,
  }) : title = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w400,
    color: colors.primary,
  );

  factory TextThemeExtension({required AppColorsExtension colors}) {
    final normalRegular = TextStyle(
      fontWeight: FontWeight.w400,
      color: colors.primaryText,
    );
    return TextThemeExtension._(
      size8: const TextStyle(fontSize: FontSizes.pt8).merge(normalRegular),
      size9: const TextStyle(fontSize: FontSizes.pt9).merge(normalRegular),
      size9n5: const TextStyle(fontSize: FontSizes.pt9n5).merge(normalRegular),
      size10: const TextStyle(fontSize: FontSizes.pt10).merge(normalRegular),
      size10n5: const TextStyle(fontSize: FontSizes.pt10n5).merge(normalRegular),
      size11: const TextStyle(fontSize: FontSizes.pt11).merge(normalRegular),
      size12: const TextStyle(fontSize: FontSizes.pt12).merge(normalRegular),
      size13: const TextStyle(fontSize: FontSizes.pt13).merge(normalRegular),
      size14: const TextStyle(fontSize: FontSizes.pt14).merge(normalRegular),
      size15: const TextStyle(fontSize: FontSizes.pt15).merge(normalRegular),
      size16: const TextStyle(fontSize: FontSizes.pt16).merge(normalRegular),
      size17: const TextStyle(fontSize: FontSizes.pt17).merge(normalRegular),
      size18: const TextStyle(fontSize: FontSizes.pt18).merge(normalRegular),
      size19: const TextStyle(fontSize: FontSizes.pt19).merge(normalRegular),
      size20: const TextStyle(fontSize: FontSizes.pt20).merge(normalRegular),
      size21: const TextStyle(fontSize: FontSizes.pt21).merge(normalRegular),
      size22: const TextStyle(fontSize: FontSizes.pt22).merge(normalRegular),
      size23: const TextStyle(fontSize: FontSizes.pt23).merge(normalRegular),
      size24: const TextStyle(fontSize: FontSizes.pt24).merge(normalRegular),
      size25: const TextStyle(fontSize: FontSizes.pt25).merge(normalRegular),
      size26: const TextStyle(fontSize: FontSizes.pt26).merge(normalRegular),
      size31: const TextStyle(fontSize: FontSizes.pt31).merge(normalRegular),
      size33: const TextStyle(fontSize: FontSizes.pt33).merge(normalRegular),
      size35: const TextStyle(fontSize: FontSizes.pt35).merge(normalRegular),
      size39: const TextStyle(fontSize: FontSizes.pt39).merge(normalRegular),
      size42: const TextStyle(fontSize: FontSizes.pt42).merge(normalRegular),
      colors: colors,
    );
  }


  @override
  ThemeExtension<TextThemeExtension> copyWith() {
    return TextThemeExtension(colors: colors);
  }

  @override
  ThemeExtension<TextThemeExtension> lerp(ThemeExtension<TextThemeExtension>? other, double t) {
    if (other is! TextThemeExtension) {
      return this;
    }
    return TextThemeExtension(colors: colors.lerp(other.colors, t));
  }
}

extension TextStyleExt on TextStyle {
  TextStyle get regular => weight(FontWeight.normal);

  TextStyle get medium => weight(FontWeight.w500);

  TextStyle get bold => weight(FontWeight.w700);

  /*TextStyle get w => size(fontSize!.w);

  TextStyle get h => size(fontSize!.h);

  TextStyle get sm => size(fontSize!.sm);*/

  TextStyle comfort() => copyWith(height: 1.4);

  TextStyle dense() => copyWith(height: 1.2);

  TextStyle fit() => copyWith(height: 1.0);

  TextStyle size(double size) => copyWith(fontSize: size);

  TextStyle textColor(Color v) => copyWith(color: v);

  TextStyle weight(FontWeight v) => copyWith(fontWeight: v);

  /// Auto set color for profit loss value.
  /// - value > 0 => red color
  /// - value < 0 => blue
  /// - other => primaryText color
  TextStyle profitColor(BuildContext context, dynamic value) {
    final colors = Theme.of(context).extension<AppColorsExtension>()!;
    final valueNumber = double.tryParse(value.toString());
    if (valueNumber == null || valueNumber == 0) {
      return copyWith(color: colors.primaryText);
    }
    if (valueNumber > 0) {
      return copyWith(color: colors.increase);
    }
    return copyWith(color: colors.decrease);
  }
}
