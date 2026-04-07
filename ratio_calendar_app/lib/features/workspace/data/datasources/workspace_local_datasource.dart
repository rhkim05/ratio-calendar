import 'package:sqflite/sqflite.dart';
import 'package:ratio_calendar/features/workspace/data/models/workspace_db_converter.dart';
import 'package:ratio_calendar/features/workspace/domain/entities/workspace_entity.dart';

/// 워크스페이스 Local DataSource — SQLite 로컬 영구 저장
class WorkspaceLocalDataSource {
  WorkspaceLocalDataSource(this._db);

  final Database _db;

  static const _table = 'workspaces';

  Future<List<WorkspaceEntity>> getAllWorkspaces() async {
    final rows = await _db.query(_table, orderBy: 'created_at ASC');
    return rows.map(WorkspaceDbConverter.fromMap).toList();
  }

  Future<WorkspaceEntity?> getWorkspaceById(String id) async {
    final rows = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return WorkspaceDbConverter.fromMap(rows.first);
  }

  Future<void> saveWorkspace(WorkspaceEntity workspace) async {
    await _db.insert(
      _table,
      WorkspaceDbConverter.toMap(workspace),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteWorkspace(String id) async {
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
