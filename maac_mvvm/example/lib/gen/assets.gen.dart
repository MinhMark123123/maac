/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal

import 'package:flutter/widgets.dart';

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// File path: assets/fonts/NotoSansCJKjp-Medium.ttf
  String get notoSansCJKjpMedium => 'assets/fonts/NotoSansCJKjp-Medium.ttf';

  /// File path: assets/fonts/NotoSansJP-Medium.otf
  String get notoSansJPMedium => 'assets/fonts/NotoSansJP-Medium.otf';

  /// File path: assets/fonts/NotoSansJP-Regular.otf
  String get notoSansJPRegular => 'assets/fonts/NotoSansJP-Regular.otf';

  /// File path: assets/fonts/Questrial-Regular.ttf
  String get questrialRegular => 'assets/fonts/Questrial-Regular.ttf';

  /// File path: assets/fonts/Roboto-Bold.ttf
  String get robotoBold => 'assets/fonts/Roboto-Bold.ttf';

  /// File path: assets/fonts/Roboto-Medium.ttf
  String get robotoMedium => 'assets/fonts/Roboto-Medium.ttf';

  /// File path: assets/fonts/Roboto-Regular.ttf
  String get robotoRegular => 'assets/fonts/Roboto-Regular.ttf';

  /// List of all assets
  List<String> get values => [
        notoSansCJKjpMedium,
        notoSansJPMedium,
        notoSansJPRegular,
        questrialRegular,
        robotoBold,
        robotoMedium,
        robotoRegular
      ];
}

class Assets {
  Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider() => AssetImage(_assetName);

  String get path => _assetName;

  String get keyName => _assetName;
}
