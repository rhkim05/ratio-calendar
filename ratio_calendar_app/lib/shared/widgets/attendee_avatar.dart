import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ratio_calendar/core/constants/app_sizes.dart';
import 'package:ratio_calendar/core/theme/app_colors.dart';

/// 참석자 이니셜 원형 아바타
class AttendeeAvatar extends StatelessWidget {
  const AttendeeAvatar({
    super.key,
    required this.name,
    this.size = AppSizes.avatarSmall,
    this.backgroundColor,
  });

  final String name;
  final double size;
  final Color? backgroundColor;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    final trimmed = name.trim();
    return trimmed.isNotEmpty ? trimmed[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.surfaceHighest;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: GoogleFonts.dmSans(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          height: 1.0,
        ),
      ),
    );
  }
}

/// 참석자 아바타 행 — 최대 표시 수 초과 시 "+N" 오버플로우
class AttendeeAvatarRow extends StatelessWidget {
  const AttendeeAvatarRow({
    super.key,
    required this.names,
    this.maxVisible = 3,
    this.avatarSize = AppSizes.avatarSmall,
    this.overlap = 6.0,
  });

  final List<String> names;
  final int maxVisible;
  final double avatarSize;
  final double overlap;

  static const _avatarColors = [
    Color(0xFFB7E3FB),
    Color(0xFFE8CDFD),
    Color(0xFFDCE2F9),
    Color(0xFFFFF7ED),
    Color(0xFFF0FDFA),
  ];

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) return const SizedBox.shrink();

    final visible = names.take(maxVisible).toList();
    final overflow = names.length - maxVisible;

    return SizedBox(
      height: avatarSize,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 겹치는 아바타 스택
          SizedBox(
            width: avatarSize + (visible.length - 1) * (avatarSize - overlap),
            child: Stack(
              children: [
                for (var i = 0; i < visible.length; i++)
                  Positioned(
                    left: i * (avatarSize - overlap),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.background,
                          width: 1.5,
                        ),
                      ),
                      child: AttendeeAvatar(
                        name: visible[i],
                        size: avatarSize,
                        backgroundColor:
                            _avatarColors[i % _avatarColors.length],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // "+N" 오버플로우
          if (overflow > 0) ...[
            const SizedBox(width: 6),
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.background,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '+$overflow',
                style: GoogleFonts.dmSans(
                  fontSize: avatarSize * 0.35,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  height: 1.0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
