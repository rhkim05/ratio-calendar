import 'package:ratio_calendar/features/event/domain/entities/event_entity.dart';

/// 이벤트 Repository 인터페이스
abstract class EventRepository {
  Future<List<EventEntity>> getAllEvents();
  Future<List<EventEntity>> getEventsByDateRange(
    DateTime start,
    DateTime end, {
    List<String>? calendarIds,
  });
  Future<EventEntity?> getEventById(String id);
  Future<void> createEvent(EventEntity event);
  Future<void> updateEvent(EventEntity event);
  Future<void> deleteEvent(String id);
}
