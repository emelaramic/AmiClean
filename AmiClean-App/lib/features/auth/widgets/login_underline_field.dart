import 'package:flutter/material.dart';

/// Polje za login karticu — bijeli tekst i donja linija (mockup stil).
class LoginUnderlineField extends StatelessWidget {
  const LoginUnderlineField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.suffix,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffix;
  final String? Function(String?)? validator;

  static const _fieldStyle = TextStyle(color: Colors.white);
  static const _hintStyle = TextStyle(color: Color(0xCCFFFFFF));
  static const _labelStyle = TextStyle(
    color: Color(0xE6FFFFFF),
    fontSize: 13,
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: _fieldStyle,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: _labelStyle,
        hintStyle: _hintStyle,
        prefixIcon: Icon(icon, color: Colors.white, size: 22),
        suffixIcon: suffix,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFFCDD2), width: 1),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFFCDD2), width: 2),
        ),
        errorStyle: const TextStyle(color: Color(0xFFFFE0E0)),
      ),
    );
  }
}
