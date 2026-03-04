/// EN: Member detail page — character profile + voice actor section (wiki-style).
/// KO: 멤버 상세 페이지 — 캐릭터 프로필 + 성우 섹션 (위키 스타일).
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../projects/domain/entities/project_entities.dart';

// EN: Deterministic palette — same as info_page for visual consistency.
// KO: 일관성을 위해 info_page와 동일한 결정적 팔레트.
const _kPalette = [
  Color(0xFF6366F1),
  Color(0xFF3B82F6),
  Color(0xFFEC4899),
  Color(0xFFF59E0B),
  Color(0xFF10B981),
  Color(0xFF8B5CF6),
  Color(0xFFEF4444),
  Color(0xFF14B8A6),
];

Color _pc(String seed) => _kPalette[seed.hashCode.abs() % _kPalette.length];

// EN: Parse birthdate string → days until next birthday. Null if unparseable.
// KO: 생일 문자열 → 다음 생일까지 남은 일수. 파싱 불가 시 null.
int? _daysUntilBirthday(String? birthdate) {
  if (birthdate == null || birthdate.isEmpty) return null;
  try {
    final parts = birthdate.replaceAll('/', '-').split('-');
    if (parts.length < 2) return null;
    final now = DateTime.now();
    final month = int.parse(parts.length >= 3 ? parts[1] : parts[0]);
    final day = int.parse(parts.length >= 3 ? parts[2] : parts[1]);
    var next = DateTime(now.year, month, day);
    if (next.isBefore(DateTime(now.year, now.month, now.day))) {
      next = DateTime(now.year + 1, month, day);
    }
    return next.difference(DateTime(now.year, now.month, now.day)).inDays;
  } catch (_) {
    return null;
  }
}

/// EN: Member detail page — shows character card + voice actor section.
/// KO: 멤버 상세 페이지 — 캐릭터 카드 + 성우 섹션 표시.
class MemberDetailPage extends StatelessWidget {
  const MemberDetailPage({
    super.key,
    required this.member,
    required this.unit,
  });

  final UnitMember member;
  final Unit unit;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paletteColor = _pc(member.name);
    final textPrimary = isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary;
    final textSecondary = isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;
    final textTertiary = isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;
    final surfaceColor = isDark ? GBTColors.darkSurface : GBTColors.surface;
    final surfaceVariant = isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant;
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;

    final hasImage = member.imageUrl != null && member.imageUrl!.isNotEmpty;
    final initial = member.name.isNotEmpty ? member.name[0] : '?';
    final hasVA = member.voiceActorName != null && member.voiceActorName!.isNotEmpty;

    final birthdayDays = _daysUntilBirthday(member.birthdate);

    return Scaffold(
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // EN: Hero header with character avatar + gradient background.
          // KO: 캐릭터 아바타 + 그라데이션 배경 히어로 헤더.
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.fromLTRB(
                GBTSpacing.pageHorizontal,
                0,
                GBTSpacing.pageHorizontal,
                GBTSpacing.md,
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 4, color: Colors.black38)],
                    ),
                  ),
                  if (hasVA)
                    Text(
                      'CV: ${member.voiceActorName}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                        shadows: const [Shadow(blurRadius: 4, color: Colors.black38)],
                      ),
                    ),
                ],
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // EN: Gradient from palette color.
                  // KO: 팔레트 색상 그라데이션.
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          paletteColor.withValues(alpha: 0.9),
                          paletteColor.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                  // EN: Character avatar centered in header.
                  // KO: 헤더 중앙 캐릭터 아바타.
                  Positioned(
                    top: 56,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: hasImage
                          ? GBTImage(
                              imageUrl: member.imageUrl!,
                              width: 100,
                              height: 100,
                              borderRadius: BorderRadius.circular(50),
                              fit: BoxFit.cover,
                              semanticLabel: '${member.name} 캐릭터 이미지',
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 42,
                                    shadows: [
                                      Shadow(blurRadius: 2, color: Colors.black26),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // EN: Character detail section.
          // KO: 캐릭터 상세 섹션.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                GBTSpacing.pageHorizontal,
                GBTSpacing.lg,
                GBTSpacing.pageHorizontal,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // EN: Unit badge + character name + tags.
                  // KO: 유닛 배지 + 캐릭터 이름 + 태그.
                  Wrap(
                    spacing: GBTSpacing.xs,
                    runSpacing: GBTSpacing.xs,
                    children: [
                      // EN: Unit label chip.
                      // KO: 유닛 레이블 칩.
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: GBTSpacing.sm,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: paletteColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
                          border: Border.all(
                            color: paletteColor.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          unit.displayName,
                          style: GBTTypography.labelSmall.copyWith(
                            color: paletteColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (member.instrument != null)
                        _Chip(label: member.instrument!, color: paletteColor),
                      if (member.role != null && member.role != member.instrument)
                        _Chip(label: member.role!, color: paletteColor),
                    ],
                  ),

                  // EN: Birthday countdown info.
                  // KO: 생일 카운트다운 정보.
                  if (birthdayDays != null && birthdayDays <= 30) ...[
                    const SizedBox(height: GBTSpacing.sm),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          birthdayDays == 0
                              ? '🎂 오늘 생일이에요!'
                              : '🎂 $birthdayDays일 후 생일',
                          style: GBTTypography.labelMedium.copyWith(
                            color: birthdayDays == 0
                                ? GBTColors.secondary
                                : birthdayDays <= 7
                                ? GBTColors.accent
                                : textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // EN: Character description if available.
                  // KO: 캐릭터 설명 (있는 경우).
                  if (member.description != null && member.description!.isNotEmpty) ...[
                    const SizedBox(height: GBTSpacing.md),
                    Text(
                      member.description!,
                      style: GBTTypography.bodyMedium.copyWith(
                        color: textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // EN: Profile info table (birthdate, role, etc.)
          // KO: 프로필 정보 테이블 (생일, 역할 등)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                GBTSpacing.pageHorizontal,
                GBTSpacing.lg,
                GBTSpacing.pageHorizontal,
                0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: surfaceVariant,
                  borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                ),
                child: Column(
                  children: [
                    if (member.birthdate != null && member.birthdate!.isNotEmpty)
                      _InfoRow(
                        icon: Icons.cake_outlined,
                        label: '생일',
                        value: member.birthdate!,
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textTertiary: textTertiary,
                        borderColor: borderColor,
                        showDivider: true,
                      ),
                    if (member.instrument != null)
                      _InfoRow(
                        icon: Icons.music_note_outlined,
                        label: '담당',
                        value: member.instrument!,
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textTertiary: textTertiary,
                        borderColor: borderColor,
                        showDivider: member.role != null &&
                            member.role != member.instrument,
                      ),
                    if (member.role != null && member.role != member.instrument)
                      _InfoRow(
                        icon: Icons.badge_outlined,
                        label: '역할',
                        value: member.role!,
                        isDark: isDark,
                        textPrimary: textPrimary,
                        textTertiary: textTertiary,
                        borderColor: borderColor,
                        showDivider: false,
                      ),
                  ],
                ),
              ),
            ),
          ),

          // EN: Voice actor section — only shown when VA name is available.
          // KO: 성우 섹션 — 성우 이름이 있을 때만 표시.
          if (hasVA) ...[
            // EN: VA section header.
            // KO: 성우 섹션 헤더.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  GBTSpacing.pageHorizontal,
                  GBTSpacing.xl,
                  GBTSpacing.pageHorizontal,
                  GBTSpacing.sm,
                ),
                child: Row(
                  children: [
                    Icon(Icons.mic_rounded, size: 16, color: textSecondary),
                    const SizedBox(width: GBTSpacing.xs),
                    Text(
                      '성우 정보',
                      style: GBTTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // EN: VA card — avatar initial + name + CV label.
            // KO: 성우 카드 — 아바타 이니셜 + 이름 + CV 레이블.
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: GBTSpacing.pageHorizontal,
                ),
                child: Container(
                  padding: const EdgeInsets.all(GBTSpacing.md),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      // EN: VA avatar using voice actor name initial.
                      // KO: 성우 이름 이니셜 아바타.
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: GBTColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.mic_rounded,
                            size: 26,
                            color: GBTColors.primary.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(width: GBTSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // EN: CV label + character name context.
                            // KO: CV 레이블 + 캐릭터 이름 맥락.
                            Text(
                              'CV: ${member.voiceActorName}',
                              style: GBTTypography.bodyLarge.copyWith(
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${member.name} 담당 성우',
                              style: GBTTypography.labelSmall.copyWith(
                                color: textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const SliverToBoxAdapter(
            child: SizedBox(height: GBTSpacing.xl2),
          ),
        ],
      ),
    );
  }
}

/// EN: Info row for the profile table (icon + label + value).
/// KO: 프로필 테이블 정보 행 (아이콘 + 레이블 + 값).
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    required this.textPrimary,
    required this.textTertiary,
    required this.borderColor,
    required this.showDivider,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color textPrimary;
  final Color textTertiary;
  final Color borderColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GBTSpacing.md,
            vertical: GBTSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: textTertiary),
              const SizedBox(width: GBTSpacing.sm),
              SizedBox(
                width: 56,
                child: Text(
                  label,
                  style: GBTTypography.labelMedium.copyWith(
                    color: textTertiary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: GBTTypography.bodySmall.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, indent: GBTSpacing.md, endIndent: GBTSpacing.md, color: borderColor),
      ],
    );
  }
}

/// EN: Compact chip for character attribute tags.
/// KO: 캐릭터 속성 태그용 컴팩트 칩.
class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GBTTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
