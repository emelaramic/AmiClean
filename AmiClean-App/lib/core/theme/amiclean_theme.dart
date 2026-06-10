import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
    );

    final textTheme = GoogleFonts.montserratTextTheme(base.textTheme).apply(
      bodyColor: AmiCleanColors.darkBlue,
      displayColor: AmiCleanColors.darkBlue,
    );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      scaffoldBackgroundColor: AmiCleanColors.lightBlue,
      appBarTheme: AppBarTheme(
        backgroundColor: AmiCleanColors.darkBlue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AmiCleanColors.darkBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
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
