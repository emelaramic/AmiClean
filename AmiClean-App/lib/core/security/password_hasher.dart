import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Privremeno rješenje dok backend ne implementira BCrypt/Argon2.
/// Lozinka se ne šalje u plain textu preko mreže u polju koje očekuje hash.
class PasswordHasher {
  static String hash(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }
}
