import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand tipografija — Montserrat.
abstract final class AmiCleanTextStyles {
  static TextStyle brandTitle({
    double fontSize = 32,
    Color color = Colors.white,
  }) {
    return GoogleFonts.montserrat(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: 0.8,
      height: 1.05,
    );
  }

  static TextStyle brandSubtitle({
    Color color = const Color(0xD9FFFFFF),
  }) {
    return GoogleFonts.montserrat(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: color,
      letterSpacing: 0.3,
    );
  }
}
