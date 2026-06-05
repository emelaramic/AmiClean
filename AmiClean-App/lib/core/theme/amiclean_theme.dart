import 'package:flutter/material.dart';

import 'amiclean_colors.dart';

abstract final class AmiCleanTheme {
  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AmiCleanColors.darkBlue,
      onPrimary: Colors.white,
      secondary: AmiCleanColors.mediumBlue,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: AmiCleanColors.darkBlue,
      error: Color(0xFFB3261E),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AmiCleanColors.lightBlue,
      appBarTheme: const AppBarTheme(
        backgroundColor: AmiCleanColors.darkBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AmiCleanColors.darkBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AmiCleanColors.mediumBlue,
            width: 2,
          ),
        ),
      ),
    );
  }
}
