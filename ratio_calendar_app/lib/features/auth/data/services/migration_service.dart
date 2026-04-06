import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ratio_calendar/features/event/domain/entities/event_entity.dart';
import 'package:uuid/uuid.dart';

/// 로컬 → Firestore 마이그레이션 서비스
///
/// 로그인 성공 시:
/// 1. 기본 워크스페이스 생성 (Personal / Work / Shared 캘린더)
/// 2. 로컬 이벤트를 Firestore로 마이그레이션
class MigrationService {
  MigrationService({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  static const _defaultCalendars = [
    {'name': 'Personal', 'colorHex': '#007AFF'},
    {'name': 'Work', 'colorHex': '#FF3B30'},
    {'name': 'Shared', 'colorHex': '#34C759'},
  ];

  /// 기본 워크스페이스 + 캘린더 3개 생성
  Future<void> createDefaultWorkspace({
    required String workspaceId,
    required String userId,
  }) async {
    final batch = _firestore.batch();

    // 워크스페이스 문서
    final workspaceRef =
        _firestore.collection('workspaces').doc(workspaceId);
    batch.set(workspaceRef, {
      'name': 'My Workspace',
      'ownerId': userId,
      'members': [userId],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // 기본 캘린더 3개
    for (final cal in _defaultCalendars) {
      final calId = const Uuid().v4();
      final calRef = workspaceRef.collection('calendars').doc(calId);
      batch.set(calRef, {
        'name': cal['name'],
        'colorHex': cal['colorHex'],
        'isVisible': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// 로컬 이벤트를 Firestore로 마이그레이션
  ///
  /// 로컬 이벤트는 calendarId가 비어있거나 로컬용이므로
  /// 첫 번째 캘린더(Personal)에 일괄 배치
  Future<void> migrateLocalEvents({
    required String workspaceId,
    required List<EventEntity> events,
  }) async {
    if (events.isEmpty) return;

    // Personal 캘린더 ID 조회
    final calSnap = await _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('calendars')
        .where('name', isEqualTo: 'Personal')
        .limit(1)
        .get();

    if (calSnap.docs.isEmpty) return;

    final personalCalId = calSnap.docs.first.id;
    final eventsRef = _firestore
        .collection('workspaces')
        .doc(workspaceId)
        .collection('calendars')
        .doc(personalCalId)
        .collection('events');

    // 배치 쓰기 (Firestore 배치 최대 500개)
    const batchSize = 500;
    for (var i = 0; i < events.length; i += batchSize) {
      final batch = _firestore.batch();
      final chunk = events.skip(i).take(batchSize);

      for (final event in chunk) {
        final docRef = eventsRef.doc(event.id);
        batch.set(docRef, {
          'title': event.title,
          'date': Timestamp.fromDate(event.date),
          'startTime': Timestamp.fromDate(event.startTime),
          'endTime': Timestamp.fromDate(event.endTime),
          'recurrence': event.recurrence.name,
          'alert': event.alert.name,
          'description': event.description,
          'attendees': event.attendees,
          'calendarId': personalCalId,
          'createdAt': Timestamp.fromDate(event.createdAt),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    }
  }
}
