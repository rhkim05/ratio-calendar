import 'package:flutter/material.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';
import 'package:ratio_calendar/core/theme/app_typography.dart';
import 'package:ratio_calendar/features/event/domain/entities/event_entity.dart';

/// 이벤트별 배경색 매핑
/// DESIGN.md §5: "highly desaturated background tints (e.g., blue-50)
///                with a strong 4px left-hand border (e.g., blue-600)"
final _backgroundColors = <Color, Color>{
  AppColors.blueBorder: AppColors.blueBackground,
  AppColors.tealBorder: AppColors.tealBackground,
  AppColors.amberBorder: AppColors.amberBackground,
  AppColors.orangeBorder: AppColors.orangeBackground,
};

/// 강조 상태 배경색 매핑 (opacity 2~3배 — -50 → -100)
final _highlightBackgroundColors = <Color, Color>{
  AppColors.blueBorder: AppColors.blueBackgroundHighlight,
  AppColors.tealBorder: AppColors.tealBackgroundHighlight,
  AppColors.amberBorder: AppColors.amberBackgroundHighlight,
  AppColors.orangeBorder: AppColors.orangeBackgroundHighlight,
};

/// 이벤트 블록 위젯
/// - 연한 파스텔 배경 + 좌측 4px 컬러 보더
/// - border-radius ≤ 8px (DESIGN.md §6)
/// - 그림자 없음 — Tonal Layering (DESIGN.md §4)
class EventBlock extends StatelessWidget {
  const EventBlock({
    super.key,
    required this.event,
    required this.color,
    required this.hourHeight,
    this.onTap,
    this.isHighlighted = false,
  });

  final EventEntity event;
  final Color color;
  final double hourHeight;
  final VoidCallback? onTap;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final durationMinutes =
        event.endTime.difference(event.startTime).inMinutes;
    const verticalInset = 2.0;
    final rawHeight = durationMinutes * hourHeight / 60;
    final height = (rawHeight - verticalInset * 2).clamp(0.0, double.infinity); // 상하 2px씩 축소, 음수 방지
    final isCompact = height < 40;

    final bgColor = isHighlighted
        ? (_highlightBackgroundColors[color] ?? color.withValues(alpha: 0.15))
        : (_backgroundColors[color] ?? color.withValues(alpha: 0.06));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        margin: const EdgeInsets.only(left: 2, right: 2, top: verticalInset),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.eventBorderRadius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            color: bgColor,
            child: Row(
              children: [
                Container(
                  width: AppSizes.eventLeftBorderWidth,
                  color: color,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: isCompact
                        ? _CompactContent(event: event, color: color)
                        : _FullContent(event: event, color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FullContent extends StatelessWidget {
  const _FullContent({required this.event, required this.color});

  final EventEntity event;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Text(
            event.title,
            style: AppTypography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CompactContent extends StatelessWidget {
  const _CompactContent({required this.event, required this.color});

  final EventEntity event;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      event.title,
      style: AppTypography.caption.copyWith(
        color: color,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

