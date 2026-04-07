import 'package:ratio_calendar/features/calendar/data/datasources/calendar_local_datasource.dart';
import 'package:ratio_calendar/features/calendar/domain/entities/calendar_entity.dart';
import 'package:ratio_calendar/features/calendar/domain/repositories/calendar_repository.dart';

/// 캘린더 Repository 구현체
/// 미로그인: Isar만 사용
/// 로그인: Isar(로컬 캐시) + Firestore 동기화 (TODO: Phase 2)
class CalendarRepositoryImpl implements CalendarRepository {
  CalendarRepositoryImpl({required this.localDataSource});

  final CalendarLocalDataSource localDataSource;

  @override
  Future<List<CalendarEntity>> getAllCalendars() {
    return localDataSource.getAllCalendars();
  }

  @override
  Future<List<CalendarEntity>> getCalendarsByWorkspace(String workspaceId) {
    return localDataSource.getCalendarsByWorkspace(workspaceId);
  }

  @override
  Future<CalendarEntity?> getCalendarById(String id) {
    return localDataSource.getCalendarById(id);
  }

  @override
  Future<void> createCalendar(CalendarEntity calendar) {
    return localDataSource.saveCalendar(calendar);
  }

  @override
  Future<void> updateCalendar(CalendarEntity calendar) {
    return localDataSource.saveCalendar(calendar);
  }

  @override
  Future<void> deleteCalendar(String id) {
    return localDataSource.deleteCalendar(id);
  }

  /// 기본 캘린더(Personal, Work, Shared)가 없으면 자동 생성
  /// 해당 워크스페이스에 캘린더가 없을 때만 생성
  @override
  Future<void> ensureDefaults(String workspaceId) async {
    final existing = await localDataSource.getCalendarsByWorkspace(workspaceId);
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    final defaults = [
      CalendarEntity(
        id: '${workspaceId}_personal',
        name: 'Personal',
        colorHex: '#007AFF',
        workspaceId: workspaceId,
        createdAt: now,
        updatedAt: now,
      ),
      CalendarEntity(
        id: '${workspaceId}_work',
        name: 'Work',
        colorHex: '#FF3B30',
        workspaceId: workspaceId,
        createdAt: now.add(const Duration(milliseconds: 1)),
        updatedAt: now.add(const Duration(milliseconds: 1)),
      ),
      CalendarEntity(
        id: '${workspaceId}_shared',
        name: 'Shared',
        colorHex: '#34C759',
        workspaceId: workspaceId,
        createdAt: now.add(const Duration(milliseconds: 2)),
        updatedAt: now.add(const Duration(milliseconds: 2)),
      ),
    ];
    await localDataSource.saveCalendars(defaults);
  }
}
