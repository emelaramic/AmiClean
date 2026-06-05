import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand tipografija — Playfair Display (elegantan serif, sličan Calma).
abstract final class AmiCleanTextStyles {
  static TextStyle brandTitle({
    double fontSize = 32,
    Color color = Colors.white,
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 1.2,
      height: 1.05,
    );
  }

  static TextStyle brandSubtitle({
    Color color = const Color(0xD9FFFFFF),
  }) {
    return GoogleFonts.playfairDisplay(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: color,
      letterSpacing: 0.4,
    );
  }
}
