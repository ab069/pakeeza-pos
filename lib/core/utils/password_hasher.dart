import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Local offline password hashing (salt + SHA-256). Suitable for single-shop POS.
class PasswordHasher {
  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String hash(String password, String salt) {
    final bytes = utf8.encode('$salt:$password');
    return base64UrlEncode(sha256.convert(bytes).bytes);
  }

  static bool verify(String password, String salt, String storedHash) {
    return hash(password, salt) == storedHash;
  }
}
