import 'package:flutter/material.dart';
import 'package:likenovel/app/fonts.dart';

class ElSpacing {
  ElSpacing._();
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
}

class ElRadius {
  ElRadius._();
  static const double control = 13;
  static const double card = 18;
  static const double sheet = 26;
  static const double frame = 40;
  static final BorderRadius controlR = BorderRadius.circular(control);
  static final BorderRadius cardR = BorderRadius.circular(card);
  static final BorderRadius sheetR = BorderRadius.circular(sheet);
  static final BorderRadius frameR = BorderRadius.circular(frame);
}

typedef ElColors = ElTheme;

class ElTheme {
  ElTheme._();

  static const Color primary = Color(0xFF8B2252);
  static const Color primaryPress = Color(0xFF6E1A41);
  static const Color primaryInk = Color(0xFF5C1536);
  static const Color primarySoft = Color(0xFFFCEEF2);
  static const Color gold = Color(0xFFD4A853);
  static const Color goldSoft = Color(0xFFFDF6E3);
  static const Color success = Color(0xFF2E8B57);
  static const Color onPrimary = Color(0xFFFFFBF5);

  static const Color bg = Color(0xFFFAF7F2);
  static const Color surface = Color(0xFFFEFCFA);
  static const Color surface2 = Color(0xFFF4F0EA);
  static const Color surface3 = Color(0xFFEBE6DE);
  static const Color line = Color(0xFFE2DBD2);
  static const Color lineStrong = Color(0xFFD1C9BD);
  static const Color ink = Color(0xFF2E1F2E);
  static const Color muted = Color(0xFF6B5A6B);
  static const Color faint = Color(0xFF8A7A8A);

  static ThemeData lightTheme() {
    final textTheme = AppFont.interTextTheme().copyWith(
      displayLarge: AppFont.newsreader(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      displayMedium: AppFont.newsreader(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      headlineLarge: AppFont.newsreader(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      headlineMedium: AppFont.newsreader(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      titleLarge: AppFont.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      titleMedium: AppFont.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      bodyLarge: AppFont.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: ink,
      ),
      bodyMedium: AppFont.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: ink,
      ),
      bodySmall: AppFont.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: muted,
      ),
      labelLarge: AppFont.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      labelSmall: AppFont.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: muted,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        secondary: gold,
        onSecondary: ink,
        surface: surface,
        onSurface: ink,
        outline: line,
        outlineVariant: lineStrong,
        error: const Color(0xFFB3261E),
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        titleTextStyle: AppFont.newsreader(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppFont.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppFont.inter(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: AppFont.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: line),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: line, width: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface2,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: const DividerThemeData(
        color: line,
        thickness: 0.5,
      ),
    );
  }
}
