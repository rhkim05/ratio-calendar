/// Ratio Calendar 사이즈 상수
/// DESIGN.md "Precision Architect" 기반
///
/// §6 Don't: "rounded corners exceeding 8px (except FABs/Avatars)"
/// §5 Buttons: "sharp-edged (0.25rem = 4px radius)"
/// §5 Event Blocks: "4px left-hand border"
abstract final class AppSizes {
  // ── Padding / Margin ──
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  // ── Border Radius ──
  // §6: max 8px (except FAB/Avatar)
  static const radiusXs = 4.0;       // Buttons — sharp-edged (0.25rem)
  static const radiusSm = 6.0;       // Event blocks, cards
  static const radiusMd = 8.0;       // 일반 최대 radius
  static const radiusSheet = 20.0;   // Bottom Sheet 상단 (modal 예외)
  static const radiusFab = 16.0;     // FAB — generous rounding

  // ── Calendar Specific ──
  static const timeColumnWidth = 52.0;         // 좌측 시간 라벨 너비
  static const hourHeight = 60.0;               // 1시간 블록 높이
  static const eventLeftBorderWidth = 4.0;       // §5: "strong 4px left-hand border"
  static const eventBorderRadius = 6.0;          // 이벤트 블록 radius (< 8px)
  static const currentTimeIndicatorDot = 8.0;    // 빨간 점 지름
  static const dayHeaderHeight = 72.0;            // 요일/날짜 행 높이
  static const todayHighlightSize = 36.0;        // 오늘 날짜 하이라이트 원 지름

  // ── FAB ──
  static const fabSize = 56.0;
  static const fabMargin = 16.0;

  // ── Bottom Sheet ──
  static const sheetDragHandleWidth = 36.0;
  static const sheetDragHandleHeight = 4.0;
  static const sheetMaxHeightFraction = 0.9;
  /// 이벤트 상세 Sheet의 예상 높이 비율 (스크롤 offset 계산용)
  static const sheetEstimatedHeightFraction = 0.6;

  // ── Side Menu ──
  static const sideMenuWidth = 280.0;
  static const calendarDotSize = 10.0;           // Project Layers 색상 pip

  // ── Avatar ──
  static const avatarSmall = 28.0;
  static const avatarMedium = 40.0;
}
