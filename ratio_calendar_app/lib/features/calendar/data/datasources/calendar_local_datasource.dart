import 'package:sqflite/sqflite.dart';
import 'package:ratio_calendar/features/calendar/data/models/calendar_isar_model.dart';
import 'package:ratio_calendar/features/calendar/domain/entities/calendar_entity.dart';

/// 캘린더 Local DataSource — SQLite 로컬 영구 저장
class CalendarLocalDataSource {
  CalendarLocalDataSource(this._db);

  final Database _db;

  static const _table = 'calendars';

  /// 모든 캘린더 조회
  Future<List<CalendarEntity>> getAllCalendars() async {
    final rows = await _db.query(_table, orderBy: 'created_at ASC');
    return rows.map(CalendarDbConverter.fromMap).toList();
  }

  /// 워크스페이스별 캘린더 조회
  Future<List<CalendarEntity>> getCalendarsByWorkspace(
    String workspaceId,
  ) async {
    final rows = await _db.query(
      _table,
      where: 'workspace_id = ?',
      whereArgs: [workspaceId],
      orderBy: 'created_at ASC',
    );
    return rows.map(CalendarDbConverter.fromMap).toList();
  }

  /// 특정 캘린더 조회
  Future<CalendarEntity?> getCalendarById(String id) async {
    final rows = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return CalendarDbConverter.fromMap(rows.first);
  }

  /// 캘린더 저장 (생성/업데이트 — upsert)
  Future<void> saveCalendar(CalendarEntity calendar) async {
    await _db.insert(
      _table,
      CalendarDbConverter.toMap(calendar),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 여러 캘린더 일괄 저장
  Future<void> saveCalendars(List<CalendarEntity> calendars) async {
    final batch = _db.batch();
    for (final calendar in calendars) {
      batch.insert(
        _table,
        CalendarDbConverter.toMap(calendar),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// 캘린더 삭제
  Future<void> deleteCalendar(String id) async {
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  /// 전체 캘린더 삭제
  Future<void> clearAll() async {
    await _db.delete(_table);
  }
}
