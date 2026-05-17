import 'dart:io';

import 'package:pakeeza_pos/data/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class SettingsRepository {
  Future<Map<String, String>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('settings');
    return {for (final r in rows) r['key']! as String: r['value']! as String};
  }

  Future<void> saveAll(Map<String, String> settings) async {
    final db = await DatabaseHelper.instance.database;
    final batch = db.batch();
    settings.forEach((key, value) {
      batch.insert(
        'settings',
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit(noResult: true);
  }

  Future<String> exportDatabaseCopy(String destinationPath) async {
    final source = await DatabaseHelper.instance.databasePath;
    await File(source).copy(destinationPath);
    return destinationPath;
  }

  Future<String> getDatabasePath() async {
    return DatabaseHelper.instance.databasePath;
  }
}
