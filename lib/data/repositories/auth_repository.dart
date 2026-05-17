import 'package:pakeeza_pos/core/constants/app_constants.dart';
import 'package:pakeeza_pos/core/utils/password_hasher.dart';
import 'package:pakeeza_pos/data/database/database_helper.dart';
import 'package:pakeeza_pos/data/models/models.dart';
import 'package:sqflite/sqflite.dart';

class AuthRepository {
  Future<bool> hasAnyUser() async {
    final db = await DatabaseHelper.instance.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM users'),
    );
    return (count ?? 0) > 0;
  }

  Future<UserModel> signUp({
    required String username,
    required String password,
    required String displayName,
    String role = AppConstants.roleCashier,
    bool forceOwner = false,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final exists = await hasAnyUser();
    final effectiveRole =
        !exists || forceOwner ? AppConstants.roleOwner : role;

    final normalized = username.trim().toLowerCase();
    if (normalized.length < 3) {
      throw AuthException('Username must be at least 3 characters.');
    }
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters.');
    }

    final duplicate = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [normalized],
      limit: 1,
    );
    if (duplicate.isNotEmpty) {
      throw AuthException('Username already exists.');
    }

    final salt = PasswordHasher.generateSalt();
    final hash = PasswordHasher.hash(password, salt);
    final id = await db.insert('users', {
      'username': normalized,
      'display_name': displayName.trim(),
      'password_hash': hash,
      'salt': salt,
      'role': effectiveRole,
      'created_at': DateTime.now().toIso8601String(),
    });

    return UserModel(
      id: id,
      username: normalized,
      displayName: displayName.trim(),
      role: effectiveRole,
    );
  }

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final normalized = username.trim().toLowerCase();
    final rows = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [normalized],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw AuthException('Invalid username or password.');
    }

    final row = rows.first;
    final ok = PasswordHasher.verify(
      password,
      row['salt'] as String,
      row['password_hash'] as String,
    );
    if (!ok) {
      throw AuthException('Invalid username or password.');
    }

    return UserModel.fromMap(row);
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
