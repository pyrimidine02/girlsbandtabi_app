/// EN: Unit detail page — shows unit info header + full member/VA roster.
/// KO: 유닛 상세 페이지 — 유닛 정보 헤더 + 전체 멤버/성우 로스터.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/palette_utils.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../projects/application/projects_controller.dart';
import '../../../projects/domain/entities/project_entities.dart';

/// EN: Unit detail page — wiki-style unit profile with member roster.
/// KO: 유닛 상세 페이지 — 위키 스타일 유닛 프로필 + 멤버 로스터.
class UnitDetailPage extends ConsumerWidget {
  const UnitDetailPage({
    super.key,
    required this.projectId,
    required this.unitIdentifier,
    this.initialUnit,
  });

  final String projectId;
  final String unitIdentifier;
  final Unit? initialUnit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitState = ref.watch(
      unitDetailProvider((projectId, unitIdentifier)),
    );
    final unit =
        unitState.valueOrNull ??
        initialUnit ??
        Unit(id: unitIdentifier, code: unitIdentifier, displayName: '유닛');
    final resolvedUnitIdentifier = unit.code.isNotEmpty ? unit.code : unit.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paletteColor = paletteColorFromSeed(unit.displayName);
    final textPrimary = isDark
        ? GBTColors.darkTextPrimary
        : GBTColors.textPrimary;
    final textSecondary = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;
    final textTertiary = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;
    final surfaceVariant = isDark
        ? GBTColors.darkSurfaceVariant
        : GBTColors.surfaceVariant;

    final membersState = ref.watch(
      unitMembersControllerProvider((projectId, resolvedUnitIdentifier)),
    );

    return Scaffold(
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // EN: Collapsible hero header with unit palette color.
          // KO: 유닛 팔레트 색상 콜랩서블 히어로 헤더.
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.fromLTRB(
                GBTSpacing.pageHorizontal,
                0,
                GBTSpacing.pageHorizontal,
                GBTSpacing.md,
              ),
              title: Text(
                unit.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      paletteColor,
                      paletteColor.withValues(alpha: 0.75),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: GBTSpacing.xl),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          unit.displayName.isNotEmpty
                              ? unit.displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // EN: Unit info chips (code badge).
          // KO: 유닛 정보 칩 (코드 배지).
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                GBTSpacing.pageHorizontal,
                GBTSpacing.md,
                GBTSpacing.pageHorizontal,
                GBTSpacing.xs,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: GBTSpacing.sm,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: paletteColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                        GBTSpacing.radiusFull,
                      ),
                      border: Border.all(
                        color: paletteColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      unit.code.isNotEmpty ? unit.code : unit.id,
                      style: GBTTypography.labelSmall.copyWith(
                        color: paletteColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (unit.status != null && unit.status!.isNotEmpty) ...[
                    const SizedBox(width: GBTSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GBTSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (unit.status == 'ACTIVE'
                                    ? GBTColors.success
                                    : GBTColors.textTertiary)
                                .withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(
                          GBTSpacing.radiusFull,
                        ),
                      ),
                      child: Text(
                        unit.status!,
                        style: GBTTypography.labelSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          color: unit.status == 'ACTIVE'
                              ? GBTColors.success
                              : GBTColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (unit.description != null && unit.description!.trim().isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  GBTSpacing.pageHorizontal,
                  GBTSpacing.sm,
                  GBTSpacing.pageHorizontal,
                  0,
                ),
                child: Text(
                  unit.description!.trim(),
                  style: GBTTypography.bodySmall.copyWith(color: textSecondary),
                ),
              ),
            ),

          // EN: Section header — Members.
          // KO: 섹션 헤더 — 멤버.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                GBTSpacing.pageHorizontal,
                GBTSpacing.lg,
                GBTSpacing.pageHorizontal,
                GBTSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(Icons.groups_outlined, size: 16, color: textSecondary),
                  const SizedBox(width: GBTSpacing.xs),
                  Text(
                    '멤버 · 성우',
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

          // EN: Member cards list loaded from API.
          // KO: API에서 불러온 멤버 카드 목록.
          membersState.when(
            loading: () => SliverToBoxAdapter(
              child: GBTShimmer(
                child: Padding(
                  padding: const EdgeInsets.all(GBTSpacing.md),
                  child: Column(
                    children: List.generate(
                      4,
                      (_) => Padding(
                        padding: const EdgeInsets.only(bottom: GBTSpacing.sm),
                        child: GBTShimmerContainer(
                          width: double.infinity,
                          height: 80,
                          borderRadius: GBTSpacing.radiusMd,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            error: (_, __) => SliverToBoxAdapter(
              child: Padding(
                padding: GBTSpacing.paddingPage,
                child: Text(
                  '멤버 정보를 불러오지 못했어요',
                  style: GBTTypography.bodySmall.copyWith(color: textTertiary),
                ),
              ),
            ),
            data: (members) {
              if (members.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: GBTSpacing.paddingPage,
                    child: Text(
                      '멤버 정보가 없습니다',
                      style: GBTTypography.bodySmall.copyWith(
                        color: textTertiary,
                      ),
                    ),
                  ),
                );
              }

              final sorted = [...members]
                ..sort((a, b) {
                  if (a.order != null && b.order != null) {
                    return a.order!.compareTo(b.order!);
                  }
                  return a.name.compareTo(b.name);
                });

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final member = sorted[index];
                  return _MemberCard(
                    member: member,
                    unit: unit,
                    projectId: projectId,
                    paletteColor: paletteColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    textTertiary: textTertiary,
                    surfaceVariant: surfaceVariant,
                    isDark: isDark,
                  );
                }, childCount: sorted.length),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: GBTSpacing.xl)),
        ],
      ),
    );
  }
}

/// EN: Member card row on unit detail page — tappable to open member detail.
/// KO: 유닛 상세의 멤버 카드 행 — 탭 시 멤버 상세로 이동.
class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.member,
    required this.unit,
    required this.projectId,
    required this.paletteColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.surfaceVariant,
    required this.isDark,
  });

  final UnitMember member;
  final Unit unit;
  final String projectId;
  final Color paletteColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color surfaceVariant;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final initial = member.name.isNotEmpty ? member.name[0] : '?';

    return InkWell(
      onTap: () => context.goToMemberDetail(
        unit: unit,
        member: member,
        projectId: projectId,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: GBTSpacing.pageHorizontal,
          vertical: GBTSpacing.xs,
        ),
        child: Container(
          padding: const EdgeInsets.all(GBTSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? GBTColors.darkSurface : GBTColors.surface,
            borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
            border: Border.all(
              color: isDark ? GBTColors.darkBorder : GBTColors.border,
            ),
          ),
          child: Row(
            children: [
              // EN: Member avatar — image or palette initial.
              // KO: 멤버 아바타 — 이미지 또는 팔레트 이니셜.
              _AvatarCircle(
                imageUrl: member.imageUrl,
                initial: initial,
                paletteColor: paletteColor,
                size: 52,
              ),
              const SizedBox(width: GBTSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // EN: Character name + VA name on same line.
                    // KO: 캐릭터명 + 성우명 동일 행.
                    Row(
                      children: [
                        Text(
                          member.name,
                          style: GBTTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        if (member.voiceActorName != null &&
                            member.voiceActorName!.isNotEmpty) ...[
                          const SizedBox(width: GBTSpacing.xs),
                          Container(
                            width: 1,
                            height: 12,
                            color: textTertiary.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: GBTSpacing.xs),
                          Icon(
                            Icons.mic_rounded,
                            size: 12,
                            color: paletteColor.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              member.voiceActorName!,
                              style: GBTTypography.bodySmall.copyWith(
                                color: textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    // EN: Role / instrument tags row.
                    // KO: 역할 / 악기 태그 행.
                    Wrap(
                      spacing: GBTSpacing.xs,
                      runSpacing: GBTSpacing.xs,
                      children: [
                        if (member.instrument != null)
                          _Tag(label: member.instrument!, color: paletteColor),
                        if (member.role != null &&
                            member.role != member.instrument)
                          _Tag(label: member.role!, color: paletteColor),
                      ],
                    ),
                    // EN: Birthday countdown when within 7 days.
                    // KO: 7일 이내 생일 카운트다운.
                    Builder(
                      builder: (_) {
                        final days = daysUntilBirthday(member.birthdate);
                        if (days == null || days > 7) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            days == 0 ? '🎂 오늘 생일!' : '🎂 $days일 후 생일',
                            style: GBTTypography.labelSmall.copyWith(
                              color: days == 0
                                  ? GBTColors.secondary
                                  : GBTColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: textTertiary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// EN: Avatar circle — shows network image or palette initial fallback.
/// KO: 아바타 원 — 네트워크 이미지 또는 팔레트 이니셜 폴백.
class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.imageUrl,
    required this.initial,
    required this.paletteColor,
    required this.size,
  });

  final String? imageUrl;
  final String initial;
  final Color paletteColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: paletteColor, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.38,
          ),
        ),
      ),
    );
  }
}

/// EN: Compact tag chip.
/// KO: 컴팩트 태그 칩.
class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: GBTTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
