import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';
import 'package:ratio_calendar/core/theme/app_typography.dart';
import 'package:ratio_calendar/features/calendar/presentation/widgets/event_block.dart';
import 'package:ratio_calendar/features/event/domain/entities/event_entity.dart';

/// 24시간 시간 라벨 + 수평 그리드
class TimelineGrid extends StatelessWidget {
  const TimelineGrid({super.key, required this.hourHeight});

  final double hourHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(24, (hour) {
        final label = '${hour.toString().padLeft(2, '0')}:00';
        return SizedBox(
          height: hourHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 시간 라벨 — 매우 연한 회색, 11px
              SizedBox(
                width: AppSizes.timeColumnWidth,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSizes.sm),
                  child: Text(
                    label,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.timeLabel,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),

              // 수평 그리드 라인
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.divider,
                        width: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// 하루 분량의 이벤트를 세로로 배치하는 컬럼
class DayEventsColumn extends StatelessWidget {
  const DayEventsColumn({
    super.key,
    required this.events,
    required this.calendarColors,
    required this.date,
    required this.hourHeight,
    this.highlightStartMin,
    this.highlightEndMin,
    this.highlightedEventId,
    this.onEventTap,
    this.onTapAtMinute,
    this.onLongPressStartAtMinute,
    this.onLongPressMoveToMinute,
    this.onLongPressEnd,
  });

  final List<EventEntity> events;
  final Map<String, Color> calendarColors;
  final DateTime date;
  final double hourHeight;
  final int? highlightStartMin;
  final int? highlightEndMin;
  final String? highlightedEventId;
  final void Function(EventEntity)? onEventTap;
  final void Function(int minute)? onTapAtMinute;
  final void Function(int minute)? onLongPressStartAtMinute;
  final void Function(int minute)? onLongPressMoveToMinute;
  final VoidCallback? onLongPressEnd;

  int _yToMinute(double dy) =>
      (dy / hourHeight * 60).round().clamp(0, 24 * 60);

  @override
  Widget build(BuildContext context) {
    final hasHighlight = highlightStartMin != null && highlightEndMin != null;

    return GestureDetector(
      onTapUp: (details) {
        onTapAtMinute?.call(_yToMinute(details.localPosition.dy));
      },
      onLongPressStart: (details) {
        onLongPressStartAtMinute?.call(_yToMinute(details.localPosition.dy));
      },
      onLongPressMoveUpdate: (details) {
        onLongPressMoveToMinute?.call(_yToMinute(details.localPosition.dy));
      },
      onLongPressEnd: (_) => onLongPressEnd?.call(),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          // 하이라이트 블록 (가변 높이)
          if (hasHighlight)
            Positioned(
              top: highlightStartMin! * hourHeight / 60,
              left: 0,
              right: 0,
              height:
                  (highlightEndMin! - highlightStartMin!) * hourHeight / 60,
              child: const SlotHighlight(),
            ),

          // 이벤트 블록들
          ...events.map((event) {
            final startMinutes =
                event.startTime.hour * 60 + event.startTime.minute;
            final topOffset = startMinutes * hourHeight / 60;
            final color =
                calendarColors[event.calendarId] ?? AppColors.personal;

            return Positioned(
              top: topOffset,
              left: 0,
              right: 0,
              child: EventBlock(
                event: event,
                color: color,
                hourHeight: hourHeight,
                isHighlighted: event.id == highlightedEventId,
                onTap: () => onEventTap?.call(event),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// 빈 슬롯 하이라이트 — 점선 테두리 + 연한 배경
class SlotHighlight extends StatelessWidget {
  const SlotHighlight({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: AppColors.outlineVariant,
          strokeWidth: 1.0,
          dashWidth: 4,
          dashGap: 3,
          borderRadius: AppSizes.eventBorderRadius,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.outlineVariant.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppSizes.eventBorderRadius),
          ),
        ),
      ),
    );
  }
}

/// 점선 테두리 CustomPainter
class DashedBorderPainter extends CustomPainter {
  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
    required this.borderRadius,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final dashedPath = _createDashedPath(path);
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final len = draw ? dashWidth : dashGap;
        if (draw) {
          dest.addPath(
            metric.extractPath(
                distance, (distance + len).clamp(0, metric.length)),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      borderRadius != oldDelegate.borderRadius;
}
