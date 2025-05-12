import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;

    final path = await getDatabasesPath();
    final dbPath = join(path, 'skin_diary.db');

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE preferences (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');
      },
    );

    return _db!;
  }

  static Future<void> setPreference(String key, String value) async {
    final db = await getDatabase();
    await db.insert(
      'preferences',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> getPreference(String key) async {
    final db = await getDatabase();
    final result = await db.query(
      'preferences',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (result.isNotEmpty) {
      return result.first['value'] as String;
    }
    return null;
  }

  static Future<void> removePreference(String key) async {
    final db = await getDatabase();
    await db.delete(
      'preferences',
      where: 'key = ?',
      whereArgs: [key],
    );
  }
  static Future<Map<String, String>> getAllPreferences() async {
    final db = await getDatabase();
    final result = await db.query('preferences');
    return {
      for (var row in result)
        row['key'] as String: row['value'] as String
    };
  }
}
