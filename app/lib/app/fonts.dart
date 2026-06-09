import 'package:flutter/material.dart';

/// 本地打包字体的统一入口，替代 google_fonts 的运行时下载。
///
/// - [AppFont.inter]：无衬线，用于导航、按钮、标签、计量、表单等 UI chrome。
/// - [AppFont.newsreader]：衬线，用于书名、Hero、封面标题、阅读器正文、统计数字。
///
/// 字体在 `pubspec.yaml` 中以可变字体（variable font）单文件注册，
/// Flutter 会根据 [fontWeight] 自动映射到 `wght` 轴，无需逐字重声明。
class AppFont {
  AppFont._();

  static const String interFamily = 'Inter';
  static const String newsreaderFamily = 'Newsreader';

  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    Color? decorationColor,
    Color? backgroundColor,
    List<Shadow>? shadows,
    Paint? foreground,
    TextBaseline? textBaseline,
  }) {
    return TextStyle(
      fontFamily: interFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      fontStyle: fontStyle,
      decoration: decoration,
      decorationColor: decorationColor,
      backgroundColor: backgroundColor,
      shadows: shadows,
      foreground: foreground,
      textBaseline: textBaseline,
    );
  }

  static TextStyle newsreader({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    Color? decorationColor,
    Color? backgroundColor,
    List<Shadow>? shadows,
    Paint? foreground,
    TextBaseline? textBaseline,
  }) {
    return TextStyle(
      fontFamily: newsreaderFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      fontStyle: fontStyle,
      decoration: decoration,
      decorationColor: decorationColor,
      backgroundColor: backgroundColor,
      shadows: shadows,
      foreground: foreground,
      textBaseline: textBaseline,
    );
  }

  /// 以 Inter 作为基础字体族的默认 [TextTheme]，替代
  /// `GoogleFonts.interTextTheme()`，供 `ThemeData.textTheme` 使用。
  static TextTheme interTextTheme([TextTheme? base]) {
    final TextTheme b =
        base ?? Typography.material2021().englishLike.merge(Typography.material2021().black);
    return b.apply(fontFamily: interFamily);
  }
}
