import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';

/// 현재 시각 인디케이터
///
/// 빨간 점(●) + 수평선
/// - 빨간 점: 8px 지름
/// - 색상: #FF3B30
/// - 수평선: 전체 너비, 1px 두께
/// - 위치: 현재 시각에 따라 실시간 이동 (1분마다 갱신)
class CurrentTimeIndicator extends StatefulWidget {
  const CurrentTimeIndicator({
    super.key,
    required this.columnCount,
    required this.todayColumnIndex,
    required this.hourHeight,
  });

  /// 표시 중인 날짜 열 수 (3-Day: 3)
  final int columnCount;

  /// 오늘 날짜가 위치한 열 인덱스 (-1이면 오늘 안 보임)
  final int todayColumnIndex;

  /// 1시간 블록 높이 (핀치 줌으로 동적 변경)
  final double hourHeight;

  @override
  State<CurrentTimeIndicator> createState() => _CurrentTimeIndicatorState();
}

class _CurrentTimeIndicatorState extends State<CurrentTimeIndicator> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  double get _topOffset {
    return (_now.hour * 60 + _now.minute) * widget.hourHeight / 60;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.todayColumnIndex < 0) return const SizedBox.shrink();

    final columnWidth =
        (MediaQuery.of(context).size.width - AppSizes.timeColumnWidth) /
            widget.columnCount;

    final dotSize = AppSizes.currentTimeIndicatorDot;
    final leftOffset =
        AppSizes.timeColumnWidth + (widget.todayColumnIndex * columnWidth);

    return Positioned(
      top: _topOffset - dotSize / 2,
      left: 0,
      right: 0,
      child: Row(
        children: [
          // 좌측 시간 컬럼 영역까지 빈 공간
          SizedBox(width: leftOffset - dotSize / 2),

          // 빨간 점
          Container(
            width: dotSize,
            height: dotSize,
            decoration: const BoxDecoration(
              color: AppColors.currentTimeIndicator,
              shape: BoxShape.circle,
            ),
          ),

          // 수평선 (오늘 컬럼부터 오른쪽 끝까지)
          Expanded(
            child: Container(
              height: 1.5,
              color: AppColors.currentTimeIndicator,
            ),
          ),
        ],
      ),
    );
  }
}
