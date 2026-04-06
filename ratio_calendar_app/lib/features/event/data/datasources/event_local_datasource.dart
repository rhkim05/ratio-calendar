import 'package:sqflite/sqflite.dart';
import 'package:ratio_calendar/features/event/data/models/event_isar_model.dart';
import 'package:ratio_calendar/features/event/domain/entities/event_entity.dart';

/// 이벤트 Local DataSource — SQLite 로컬 영구 저장
class EventLocalDataSource {
  EventLocalDataSource(this._db);

  final Database _db;

  static const _table = 'events';

  /// 모든 이벤트 조회
  Future<List<EventEntity>> getAllEvents() async {
    final rows = await _db.query(_table, orderBy: 'date ASC, start_time ASC');
    return rows.map(EventDbConverter.fromMap).toList();
  }

  /// 날짜 범위 기준 이벤트 조회
  Future<List<EventEntity>> getEventsByDateRange(
    DateTime start,
    DateTime end, {
    List<String>? calendarIds,
  }) async {
    final startMs = DateTime(start.year, start.month, start.day)
        .millisecondsSinceEpoch;
    final endMs = DateTime(end.year, end.month, end.day, 23, 59, 59)
        .millisecondsSinceEpoch;

    var where = 'date >= ? AND date <= ?';
    final args = <dynamic>[startMs, endMs];

    if (calendarIds != null && calendarIds.isNotEmpty) {
      final placeholders = List.filled(calendarIds.length, '?').join(', ');
      where += ' AND calendar_id IN ($placeholders)';
      args.addAll(calendarIds);
    }

    final rows = await _db.query(
      _table,
      where: where,
      whereArgs: args,
      orderBy: 'start_time ASC',
    );
    return rows.map(EventDbConverter.fromMap).toList();
  }

  /// 특정 이벤트 조회
  Future<EventEntity?> getEventById(String id) async {
    final rows = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return EventDbConverter.fromMap(rows.first);
  }

  /// 이벤트 저장 (생성/업데이트 — upsert)
  Future<void> saveEvent(EventEntity event) async {
    await _db.insert(
      _table,
      EventDbConverter.toMap(event),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 여러 이벤트 일괄 저장
  Future<void> saveEvents(List<EventEntity> events) async {
    final batch = _db.batch();
    for (final event in events) {
      batch.insert(
        _table,
        EventDbConverter.toMap(event),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// 이벤트 삭제
  Future<void> deleteEvent(String id) async {
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  /// 특정 캘린더의 모든 이벤트 삭제
  Future<void> deleteEventsByCalendarId(String calendarId) async {
    await _db.delete(
      _table,
      where: 'calendar_id = ?',
      whereArgs: [calendarId],
    );
  }

  /// 전체 이벤트 삭제
  Future<void> clearAll() async {
    await _db.delete(_table);
  }
}
