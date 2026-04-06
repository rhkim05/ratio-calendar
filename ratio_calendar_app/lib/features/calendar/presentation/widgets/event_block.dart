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

/// 이벤트 블록 위젯
/// - 연한 파스텔 배경 + 좌측 4px 컬러 보더
/// - border-radius ≤ 8px (DESIGN.md §6)
/// - 그림자 없음 — Tonal Layering (DESIGN.md §4)
class EventBlock extends StatelessWidget {
  const EventBlock({
    super.key,
    required this.event,
    required this.color,
    this.onTap,
  });

  final EventEntity event;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final durationMinutes =
        event.endTime.difference(event.startTime).inMinutes;
    const verticalInset = 2.0;
    final rawHeight = durationMinutes * AppSizes.hourHeight / 60;
    final height = rawHeight - verticalInset * 2; // 상하 2px씩 축소
    final isCompact = height < 40;

    final bgColor = _backgroundColors[color] ?? color.withValues(alpha: 0.06);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        margin: const EdgeInsets.only(left: 2, right: 2, top: verticalInset),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.eventBorderRadius),
          child: Container(
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
            style: AppTypography.eventTitle.copyWith(
              color: color,
              fontSize: 12,
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
      style: AppTypography.eventTitle.copyWith(
        color: color,
        fontSize: 10,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

