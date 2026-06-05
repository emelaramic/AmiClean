import 'package:flutter/material.dart';

/// Brand tipografija — font Calma iz `assets/fonts/`.
abstract final class AmiCleanTextStyles {
  static const _fallback = ['Georgia', 'Times New Roman', 'serif'];

  static TextStyle brandTitle({
    double fontSize = 32,
    Color color = Colors.white,
  }) {
    return TextStyle(
      fontFamily: 'Calma',
      fontFamilyFallback: _fallback,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 1.5,
      height: 1.05,
    );
  }

  static TextStyle brandSubtitle({
    Color color = const Color(0xD9FFFFFF),
  }) {
    return TextStyle(
      fontFamily: 'Calma',
      fontFamilyFallback: _fallback,
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: color,
      letterSpacing: 0.4,
    );
  }
}
