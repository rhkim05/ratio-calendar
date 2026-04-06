/// Ratio Calendar 애니메이션 duration 상수
/// "부드러운 전환" 디자인 원칙 — 모든 변화에 애니메이션 적용
abstract final class AppDurations {
  static const instant = Duration(milliseconds: 100);
  static const fast = Duration(milliseconds: 200);
  static const normal = Duration(milliseconds: 300);     // 뷰 전환 기본
  static const slow = Duration(milliseconds: 500);       // Bottom Sheet 등장
  static const pageTransition = Duration(milliseconds: 350);
}
