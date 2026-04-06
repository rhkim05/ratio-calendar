import 'package:sqflite/sqflite.dart';

/// Ratio Calendar 로컬 SQLite 데이터베이스
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/ratio_calendar.db';

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        date INTEGER NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER NOT NULL,
        recurrence INTEGER NOT NULL DEFAULT 0,
        alert INTEGER NOT NULL DEFAULT 2,
        description TEXT,
        attendees TEXT NOT NULL DEFAULT '[]',
        calendar_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_events_date ON events(date)
    ''');

    await db.execute('''
      CREATE INDEX idx_events_calendar_id ON events(calendar_id)
    ''');

    await db.execute('''
      CREATE TABLE calendars (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        color_hex TEXT NOT NULL DEFAULT '#007AFF',
        is_visible INTEGER NOT NULL DEFAULT 1,
        workspace_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
