import 'package:ratio_calendar/features/event/data/datasources/event_local_datasource.dart';
import 'package:ratio_calendar/features/event/domain/entities/event_entity.dart';
import 'package:ratio_calendar/features/event/domain/repositories/event_repository.dart';

/// 이벤트 Repository 구현체
/// 미로그인: Isar만 사용
/// 로그인: Isar(로컬 캐시) + Firestore 동기화 (TODO: Phase 2)
class EventRepositoryImpl implements EventRepository {
  EventRepositoryImpl({required this.localDataSource});

  final EventLocalDataSource localDataSource;

  @override
  Future<List<EventEntity>> getAllEvents() {
    return localDataSource.getAllEvents();
  }

  @override
  Future<List<EventEntity>> getEventsByDateRange(
    DateTime start,
    DateTime end, {
    List<String>? calendarIds,
  }) {
    return localDataSource.getEventsByDateRange(
      start,
      end,
      calendarIds: calendarIds,
    );
  }

  @override
  Future<EventEntity?> getEventById(String id) {
    return localDataSource.getEventById(id);
  }

  @override
  Future<void> createEvent(EventEntity event) {
    return localDataSource.saveEvent(event);
  }

  @override
  Future<void> updateEvent(EventEntity event) {
    return localDataSource.saveEvent(event);
  }

  @override
  Future<void> deleteEvent(String id) {
    return localDataSource.deleteEvent(id);
  }
}
