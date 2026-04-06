/// 일정 상세 Bottom Sheet
///
/// PRD 섹션 4.4:
///   - 이벤트 탭 시 하단에서 올라옴
///   - 제목 + 캘린더 라벨 (색상 도트)
///   - DATE / TIME / ALERT / PEOPLE 표시
///   - 참석자: 이니셜 원형 아바타 + "+N" 오버플로우
///   - 헤더에 편집/삭제 아이콘
///
/// 액션:
///   - 편집 아이콘 탭 → EventEditSheet로 전환
///   - 삭제 아이콘 탭 → 확인 다이얼로그 → 삭제
///
/// Providers:
///   - eventDetailProvider(eventId)
///   - deleteEventProvider
