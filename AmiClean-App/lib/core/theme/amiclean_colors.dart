import 'package:flutter/material.dart';

/// AmiClean brand paleta — plave nijanse.
abstract final class AmiCleanColors {
  static const Color lightBlue = Color(0xFFBDD8E9);
  static const Color mediumBlue = Color(0xFF49769F);
  static const Color darkBlue = Color(0xFF0A4174);

  /// Proširena paleta (iz brand smjernica).
  static const Color skyBlue = Color(0xFF75A4C5);
  static const Color softBlue = Color(0xFF97BCD7);
  static const Color mistBlue = Color(0xFFCADBE7);
  static const Color slateBlue = Color(0xFF507FA9);
  static const Color navyBlue = Color(0xFF1B4769);

  static const LinearGradient heroBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      darkBlue,
      navyBlue,
      slateBlue,
    ],
  );

  static const LinearGradient pageBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      lightBlue,
      Color(0xFFD4E8F2),
      Color(0xFF9CBFD4),
    ],
  );

  static const LinearGradient loginCard = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF5A849F),
      mediumBlue,
      Color(0xFF3D6580),
    ],
  );
}
