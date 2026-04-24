import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFFC05B4D);
  static const Color background = Color(0xFFFEFEFE);
  static const Color textColor = Color(0xFF34495E);
  static const Color darkGray = Color(0xFF8A8A8A);
  static const Color lightGray = Color(0xFFE6E6E6);
  static const Color codeBackground = Color(0xFFF8F5EC);
  static const Color codeForeground = Color(0xFFC7254E);
  static const Color accent = Color.fromARGB(255, 77, 136, 192);

  static const double maxContentWidth = 800.0;
  static const double headerHeight = 60.0;

  static const Map<String, TextStyle> solarizedTheme = {
    'root': TextStyle(
      backgroundColor: codeBackground,
      color: textColor,
    ),
    'comment': TextStyle(color: Color(0xFF93A1A1)),
    'keyword': TextStyle(color: Color(0xFF859900)),
    'number': TextStyle(color: Color(0xFF2AA198)),
    'string': TextStyle(color: Color(0xFF2AA198)),
    'title': TextStyle(color: Color(0xFF268BD2)),
    'attribute': TextStyle(color: Color(0xFFB58900)),
    'symbol': TextStyle(color: Color(0xFFCB4B16)),
    'built_in': TextStyle(color: Color(0xFFDC322F)),
    'name': TextStyle(color: Color(0xFF268BD2)),
    'tag': TextStyle(color: Color(0xFF268BD2)),
    'selector-tag': TextStyle(color: Color(0xFF859900)),
    'type': TextStyle(color: Color(0xFFB58900)),
    'literal': TextStyle(color: Color(0xFF2AA198)),
    'meta': TextStyle(color: Color(0xFF93A1A1)),
    'deletion': TextStyle(color: Color(0xFFDC322F)),
    'addition': TextStyle(color: Color(0xFF859900)),
  };

  static ThemeData build() {
    final base = GoogleFonts.sourceSans3TextTheme().apply(
      bodyColor: textColor,
      displayColor: textColor,
    );

    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: primary,
        surface: background,
        onSurface: textColor,
      ),
      scaffoldBackgroundColor: background,
      textTheme: base.copyWith(
        headlineLarge: GoogleFonts.literata(
          fontSize: 26,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        headlineMedium: GoogleFonts.literata(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        headlineSmall: GoogleFonts.literata(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
        titleLarge: GoogleFonts.sourceSans3(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        bodyLarge: GoogleFonts.sourceSans3(
          fontSize: 17,
          color: textColor,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.sourceSans3(
          fontSize: 16,
          color: textColor,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.sourceSans3(
          fontSize: 14,
          color: darkGray,
        ),
      ),
      dividerColor: lightGray,
      dividerTheme: const DividerThemeData(
        color: lightGray,
        thickness: 1,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
