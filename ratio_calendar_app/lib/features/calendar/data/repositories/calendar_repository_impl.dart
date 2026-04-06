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
  @override
  Future<void> ensureDefaults() async {
    final existing = await localDataSource.getAllCalendars();
    if (existing.isNotEmpty) return;

    final now = DateTime.now();
    final defaults = [
      CalendarEntity(
        id: 'personal',
        name: 'Personal',
        colorHex: '#007AFF',
        workspaceId: 'local',
        createdAt: now,
        updatedAt: now,
      ),
      CalendarEntity(
        id: 'work',
        name: 'Work',
        colorHex: '#34C759',
        workspaceId: 'local',
        createdAt: now,
        updatedAt: now,
      ),
      CalendarEntity(
        id: 'shared',
        name: 'Shared',
        colorHex: '#FF9500',
        workspaceId: 'local',
        createdAt: now,
        updatedAt: now,
      ),
    ];
    await localDataSource.saveCalendars(defaults);
  }
}
