/// Ratio Calendar 공통 Enum 정의

/// 캘린더 뷰 타입
enum CalendarViewType {
  day,
  threeDay,  // 기본 뷰
  week,
  month,
  year,      // P1
}

/// 이벤트 반복 타입
enum RecurrenceType {
  never,
  daily,
  weekly,
  monthly,
  yearly,
  custom,
}

/// 알림 타입
enum AlertType {
  none,
  fiveMinutes,
  fifteenMinutes,  // 기본값
  thirtyMinutes,
  oneHour,
  oneDay,
}

/// 비즈니스 모델 플랜
enum SubscriptionPlan {
  free,
  pro,   // $3.99/mo
  team,  // $5.99/user/mo
}
