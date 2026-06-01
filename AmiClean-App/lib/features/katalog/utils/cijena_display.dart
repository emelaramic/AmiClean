import 'package:flutter/material.dart';

/// Formatiranje cijena — uključujući KM/m² s kvadratnim eksponentom.
class CijenaDisplay {
  CijenaDisplay._();

  static String km(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toInt()} KM';
    }
    return '${value.toStringAsFixed(2)} KM';
  }

  static String kmPoM2(double value) {
    final iznos = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
    return '$iznos KM/m²';
  }

  /// Prikaz cijene s Unicode superscript ² (3.20 KM/m²).
  static Widget kmPoM2Widget(
    double value, {
    TextStyle? style,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    final iznos = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
    return Text.rich(
      TextSpan(
        style: style?.copyWith(fontWeight: fontWeight) ??
            TextStyle(fontWeight: fontWeight),
        children: [
          TextSpan(text: '$iznos KM/m'),
          const TextSpan(
            text: '²',
            style: TextStyle(fontFeatures: []),
          ),
        ],
      ),
    );
  }

  static Widget kmWidget(
    double value, {
    TextStyle? style,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return Text(
      km(value),
      style: style?.copyWith(fontWeight: fontWeight) ??
          TextStyle(fontWeight: fontWeight),
    );
  }
}
