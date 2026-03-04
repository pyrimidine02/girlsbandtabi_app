/// EN: Admin operations center page.
/// KO: 운영/관리자 센터 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/result.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/navigation/gbt_segmented_tab_bar.dart';
import '../../../../features/settings/application/settings_controller.dart';
import '../../../settings/domain/entities/user_profile.dart';
import '../../application/admin_ops_controller.dart';
import '../../domain/entities/admin_ops_entities.dart';

/// EN: Admin operations page with overview/report moderation tabs.
/// KO: 개요/신고 관리 탭을 제공하는 관리자 페이지.
class AdminOpsPage extends ConsumerWidget {
  const AdminOpsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(userProfileControllerProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('운영 센터'),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(44),
            child: GBTSegmentedTabBar(
              height: 44,
              margin: EdgeInsets.symmetric(horizontal: GBTSpacing.md2),
              tabs: [
                Tab(text: '개요'),
                Tab(text: '신고 관리'),
              ],
            ),
          ),
        ),
        body: profileState.when(
          loading: () => const Center(child: GBTLoading(message: '권한 확인 중...')),
          error: (error, _) => Center(
            child: Padding(
              padding: GBTSpacing.paddingPage,
              child: GBTErrorState(
                message: '권한 정보를 확인하지 못했어요',
                onRetry: () => ref
                    .read(userProfileControllerProvider.notifier)
                    .load(forceRefresh: true),
              ),
            ),
          ),
          data: (profile) {
            if (!_canAccess(profile)) {
              return const _AccessDeniedView();
            }

            return const TabBarView(children: [_OverviewTab(), _ReportsTab()]);
          },
        ),
      ),
    );
  }

  bool _canAccess(UserProfile? profile) {
    return hasAdminOpsAccessRole(profile?.role);
  }
}

class _AccessDeniedView extends StatelessWidget {
  const _AccessDeniedView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: GBTSpacing.paddingPage,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 56, color: GBTColors.warning),
            const SizedBox(height: GBTSpacing.md),
            Text(
              '접근 권한이 없습니다',
              style: GBTTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: GBTSpacing.sm),
            Text(
              '관리자 또는 앱 매니저 권한이 필요합니다.',
              style: GBTTypography.bodyMedium.copyWith(
                color: isDark
                    ? GBTColors.darkTextSecondary
                    : GBTColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminDashboardControllerProvider);

    return state.when(
      loading: () => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          GBTLoading(message: '운영 지표를 불러오는 중...'),
        ],
      ),
      error: (error, _) => RefreshIndicator(
        onRefresh: () => ref
            .read(adminDashboardControllerProvider.notifier)
            .load(forceRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: GBTSpacing.paddingPage,
          children: [
            const SizedBox(height: 80),
            GBTErrorState(
              message: '운영 지표를 불러오지 못했어요',
              onRetry: () => ref
                  .read(adminDashboardControllerProvider.notifier)
                  .load(forceRefresh: true),
            ),
          ],
        ),
      ),
      data: (summary) => RefreshIndicator(
        onRefresh: () => ref
            .read(adminDashboardControllerProvider.notifier)
            .load(forceRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: GBTSpacing.paddingPage,
          children: [
            _HeadlineCard(summary: summary),
            const SizedBox(height: GBTSpacing.md),
            _StatGrid(summary: summary),
            if (summary.extraMetrics.isNotEmpty) ...[
              const SizedBox(height: GBTSpacing.md),
              _ExtraMetricsSection(extraMetrics: summary.extraMetrics),
            ],
            const SizedBox(height: GBTSpacing.xl),
          ],
        ),
      ),
    );
  }
}

// ========================================
// EN: Headline card — dark slate background with urgent badge and admin icon
// KO: 헤드라인 카드 — 다크 슬레이트 배경, 긴급 배지, 관리자 아이콘
// ========================================

class _HeadlineCard extends StatelessWidget {
  const _HeadlineCard({required this.summary});

  final AdminDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    // EN: Show urgent red badge when there are open reports
    // KO: 접수된 신고가 있을 때 빨간 긴급 배지 표시
    final hasUrgent = summary.openReports > 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(GBTSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '운영 대기 항목',
                      style: GBTTypography.labelLarge.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    if (hasUrgent) ...[
                      const SizedBox(width: GBTSpacing.xs),
                      // EN: Urgent badge — shown when openReports > 0
                      // KO: 긴급 배지 — openReports > 0일 때 표시
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: GBTSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: GBTColors.error,
                          borderRadius: BorderRadius.circular(
                            GBTSpacing.radiusFull,
                          ),
                        ),
                        child: Text(
                          '긴급',
                          style: GBTTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: GBTSpacing.sm),
                Text(
                  '${summary.totalPendingItems}',
                  style: GBTTypography.displaySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: GBTSpacing.xs),
                Text(
                  '신고/이의제기/권한 요청을 한 화면에서 점검하세요',
                  style: GBTTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: GBTSpacing.md),
          // EN: 36px admin icon container on the right side
          // KO: 우측 36px 관리자 아이콘 컨테이너
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              size: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// EN: Stat grid — 2-column GridView for metric cards
// KO: 통계 그리드 — 지표 카드를 위한 2열 GridView
// ========================================

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.summary});

  final AdminDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final cards = <_StatCardData>[
      _StatCardData(
        label: '신규 신고',
        value: summary.openReports,
        color: GBTColors.error,
        icon: Icons.flag,
      ),
      _StatCardData(
        label: '검토 중 신고',
        value: summary.inReviewReports,
        color: GBTColors.warning,
        icon: Icons.rule,
      ),
      _StatCardData(
        label: '역할 요청',
        value: summary.pendingRoleRequests,
        color: GBTColors.info,
        icon: Icons.manage_accounts,
      ),
      _StatCardData(
        label: '인증 이의제기',
        value: summary.pendingVerificationAppeals,
        color: GBTColors.secondary,
        icon: Icons.gavel,
      ),
      _StatCardData(
        label: '삭제 요청',
        value: summary.pendingMediaDeletionRequests,
        color: GBTColors.accent,
        icon: Icons.photo_library_outlined,
      ),
      _StatCardData(
        label: '활성 제재',
        value: summary.activeSanctions,
        color: GBTColors.success,
        icon: Icons.policy,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      mainAxisSpacing: GBTSpacing.sm,
      crossAxisSpacing: GBTSpacing.sm,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards
          .map((data) => _StatCard(data: data))
          .toList(growable: false),
    );
  }
}

class _StatCardData {
  const _StatCardData({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final int value;
  final Color color;
  final IconData icon;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // EN: Show colored left accent border when value > 0
    // KO: 값이 있을 때 왼쪽 컬러 accent 테두리 표시
    final hasValue = data.value > 0;

    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? GBTColors.darkSurfaceElevated : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.all(GBTSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(data.icon, size: 16, color: data.color),
              ),
              const Spacer(),
              // EN: Apply color to value text when value > 0
              // KO: 값이 있으면 값 텍스트에 해당 색상 적용
              Text(
                '${data.value}',
                style: GBTTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: hasValue ? data.color : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: GBTSpacing.sm),
          Text(
            data.label,
            style: GBTTypography.bodySmall.copyWith(
              color: isDark
                  ? GBTColors.darkTextSecondary
                  : GBTColors.textSecondary,
            ),
          ),
        ],
      ),
        ),
        // EN: Left accent bar overlay when value > 0
        // KO: 값이 있을 때 왼쪽 컬러 accent 바 오버레이
        if (hasValue)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Container(width: 3, color: data.color),
            ),
          ),
      ],
    );
  }
}

// ========================================
// EN: Extra metrics section — custom Row layout with Divider
// KO: 추가 지표 섹션 — 구분선이 있는 커스텀 Row 레이아웃
// ========================================

class _ExtraMetricsSection extends StatelessWidget {
  const _ExtraMetricsSection({required this.extraMetrics});

  final Map<String, int> extraMetrics;

  @override
  Widget build(BuildContext context) {
    final entries = extraMetrics.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary;
    final textSecondary =
        isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;
    final dividerColor =
        isDark ? GBTColors.darkBorder : GBTColors.divider;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? GBTColors.darkSurfaceElevated : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? GBTColors.darkBorder : GBTColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              GBTSpacing.md,
              GBTSpacing.md,
              GBTSpacing.md,
              GBTSpacing.sm,
            ),
            child: Text('추가 지표', style: GBTTypography.titleSmall),
          ),
          for (int i = 0; i < entries.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: GBTSpacing.md,
                endIndent: GBTSpacing.md,
                color: dividerColor,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GBTSpacing.md,
                vertical: GBTSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entries[i].key,
                      style: GBTTypography.bodySmall.copyWith(
                        color: textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    '${entries[i].value}',
                    style: GBTTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: GBTSpacing.xs),
        ],
      ),
    );
  }
}

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminReportsControllerProvider);

    return RefreshIndicator(
      onRefresh: () => ref
          .read(adminReportsControllerProvider.notifier)
          .load(forceRefresh: true),
      child: state.reports.when(
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: GBTSpacing.paddingPage,
          children: [
            _ReportFilterRow(selected: state.filter),
            const SizedBox(height: GBTSpacing.xl),
            const GBTLoading(message: '신고 목록을 불러오는 중...'),
          ],
        ),
        error: (error, _) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: GBTSpacing.paddingPage,
          children: [
            _ReportFilterRow(selected: state.filter),
            const SizedBox(height: GBTSpacing.xl),
            GBTErrorState(
              message: '신고 목록을 불러오지 못했어요',
              onRetry: () => ref
                  .read(adminReportsControllerProvider.notifier)
                  .load(forceRefresh: true),
            ),
          ],
        ),
        data: (reports) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: GBTSpacing.paddingPage,
          children: [
            _ReportFilterRow(selected: state.filter),
            const SizedBox(height: GBTSpacing.sm),
            if (reports.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 96),
                child: GBTEmptyState(message: '현재 처리할 신고가 없습니다'),
              )
            else
              ...reports.map(
                (report) =>
                    _ReportCard(report: report, isMutating: state.isMutating),
              ),
            const SizedBox(height: GBTSpacing.xl),
          ],
        ),
      ),
    );
  }
}

// ========================================
// EN: Report filter row — custom InkWell chip style (no ChoiceChip)
// KO: 신고 필터 행 — ChoiceChip 없이 커스텀 InkWell 칩 스타일
// ========================================

class _ReportFilterRow extends ConsumerWidget {
  const _ReportFilterRow({required this.selected});

  final AdminReportFilter selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? GBTColors.darkPrimary : GBTColors.primary;
    final surfaceVariantColor =
        isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant;
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;
    final textSecondary =
        isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AdminReportFilter.values
            .map(
              (filter) {
                final isSelected = filter == selected;
                return Padding(
                  padding: const EdgeInsets.only(right: GBTSpacing.xs),
                  child: InkWell(
                    onTap: () => ref
                        .read(adminReportsControllerProvider.notifier)
                        .load(filter: filter, forceRefresh: true),
                    borderRadius:
                        BorderRadius.circular(GBTSpacing.radiusFull),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GBTSpacing.md,
                        vertical: GBTSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        // EN: Selected chip — indigo background, unselected — surfaceVariant
                        // KO: 선택된 칩 — indigo 배경, 미선택 — surfaceVariant
                        color: isSelected
                            ? primary.withValues(alpha: 0.14)
                            : surfaceVariantColor,
                        borderRadius:
                            BorderRadius.circular(GBTSpacing.radiusFull),
                        border: Border.all(
                          color: isSelected
                              ? primary.withValues(alpha: 0.45)
                              : borderColor,
                        ),
                      ),
                      child: Text(
                        filter.label,
                        style: GBTTypography.labelMedium.copyWith(
                          color: isSelected ? primary : textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
            .toList(growable: false),
      ),
    );
  }
}

// ========================================
// EN: Report card — Material + Container + InkWell, improved meta row
// KO: 신고 카드 — Material + Container + InkWell, 메타라인 Row 개선
// ========================================

class _ReportCard extends ConsumerWidget {
  const _ReportCard({required this.report, required this.isMutating});

  final AdminCommunityReport report;
  final bool isMutating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _paletteFor(report.status);
    final textSecondary =
        isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;
    final surfaceColor =
        isDark ? GBTColors.darkSurfaceElevated : Colors.white;
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;

    return Padding(
      padding: const EdgeInsets.only(top: GBTSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: isMutating
                ? null
                : () => _showReportActionsSheet(context, ref, report),
            child: Padding(
              padding: const EdgeInsets.all(GBTSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: GBTSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: palette.background,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          report.status.label,
                          style: GBTTypography.labelSmall.copyWith(
                            color: palette.foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: GBTSpacing.xs),
                      Text(
                        report.targetLabel,
                        style: GBTTypography.labelSmall.copyWith(
                          color: textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: GBTSpacing.sm),
                  Text(
                    report.reason,
                    style: GBTTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (report.previewText != null &&
                      report.previewText!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: GBTSpacing.xs),
                      child: Text(
                        report.previewText!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GBTTypography.bodySmall.copyWith(
                          color: textSecondary,
                        ),
                      ),
                    ),
                  const SizedBox(height: GBTSpacing.sm),
                  // EN: Meta row — date and assignee with icons
                  // KO: 메타 행 — 날짜와 담당자를 아이콘과 함께 표시
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        DateFormat('yyyy.MM.dd HH:mm').format(report.createdAt),
                        style: GBTTypography.bodySmall.copyWith(
                          color: textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: GBTSpacing.sm),
                      Icon(
                        Icons.person_outline,
                        size: 12,
                        color: textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          report.assigneeName ?? '미할당',
                          style: GBTTypography.bodySmall.copyWith(
                            color: textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showReportActionsSheet(
    BuildContext context,
    WidgetRef ref,
    AdminCommunityReport report,
  ) async {
    final action = await showModalBottomSheet<_ReportAction>(
      context: context,
      builder: (_) => _ReportActionSheet(report: report),
    );
    if (!context.mounted || action == null) {
      return;
    }

    final notifier = ref.read(adminReportsControllerProvider.notifier);
    final profile = ref.read(userProfileControllerProvider).valueOrNull;

    Result<void> result;
    switch (action) {
      case _ReportAction.assignToMe:
        final userId = profile?.id;
        if (userId == null || userId.isEmpty) {
          _showSnackBar(context, '담당자 할당을 위해 사용자 정보가 필요해요');
          return;
        }
        result = await notifier.assignToUser(
          reportId: report.id,
          assigneeUserId: userId,
        );
      case _ReportAction.markInReview:
        result = await notifier.updateStatus(
          reportId: report.id,
          status: AdminReportStatus.inReview,
        );
      case _ReportAction.markResolved:
        result = await notifier.updateStatus(
          reportId: report.id,
          status: AdminReportStatus.resolved,
        );
      case _ReportAction.reject:
        result = await notifier.updateStatus(
          reportId: report.id,
          status: AdminReportStatus.rejected,
        );
    }

    if (!context.mounted) {
      return;
    }

    if (result is Success<void>) {
      _showSnackBar(context, '요청이 반영되었습니다');
      return;
    }

    if (result is Err<void>) {
      _showSnackBar(context, result.failure.userMessage);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _ReportAction { assignToMe, markInReview, markResolved, reject }

// ========================================
// EN: Report action sheet — styled action items with icon containers
// KO: 신고 처리 액션 시트 — 아이콘 컨테이너가 있는 스타일링된 액션 항목
// ========================================

class _ReportActionSheet extends StatelessWidget {
  const _ReportActionSheet({required this.report});

  final AdminCommunityReport report;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: GBTSpacing.sm),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              GBTSpacing.md,
              GBTSpacing.md,
              GBTSpacing.md,
              GBTSpacing.sm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('신고 처리', style: GBTTypography.titleMedium),
            ),
          ),
          _ActionSheetItem(
            icon: Icons.person_add_alt_1,
            iconColor: GBTColors.info,
            title: '나에게 할당',
            subtitle: report.assigneeName ?? '현재 미할당',
            onTap: () => Navigator.of(context).pop(_ReportAction.assignToMe),
          ),
          _ActionSheetItem(
            icon: Icons.rule,
            iconColor: GBTColors.warning,
            title: '검토 중으로 변경',
            onTap: () => Navigator.of(context).pop(_ReportAction.markInReview),
          ),
          _ActionSheetItem(
            icon: Icons.check_circle,
            iconColor: GBTColors.success,
            title: '조치 완료로 변경',
            onTap: () => Navigator.of(context).pop(_ReportAction.markResolved),
          ),
          _ActionSheetItem(
            icon: Icons.block,
            iconColor: GBTColors.error,
            title: '반려 처리',
            onTap: () => Navigator.of(context).pop(_ReportAction.reject),
          ),
          const SizedBox(height: GBTSpacing.sm),
        ],
      ),
    );
  }
}

/// EN: Action sheet item with 36px icon container, title and optional subtitle.
/// KO: 36px 아이콘 컨테이너, 타이틀, 선택적 서브타이틀을 포함한 액션 시트 항목.
class _ActionSheetItem extends StatelessWidget {
  const _ActionSheetItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary;
    final textSecondary =
        isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: GBTSpacing.md,
          vertical: GBTSpacing.sm,
        ),
        child: Row(
          children: [
            // EN: 36px icon container with tinted background
            // KO: 색조 배경이 있는 36px 아이콘 컨테이너
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: GBTSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GBTTypography.bodyMedium.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: GBTTypography.labelSmall.copyWith(
                        color: textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

AdminReportStatusPalette _paletteFor(AdminReportStatus status) {
  switch (status) {
    case AdminReportStatus.open:
      return const AdminReportStatusPalette(
        foreground: GBTColors.errorDark,
        background: GBTColors.errorLight,
      );
    case AdminReportStatus.inReview:
      return const AdminReportStatusPalette(
        foreground: GBTColors.warningDark,
        background: GBTColors.warningLight,
      );
    case AdminReportStatus.resolved:
      return const AdminReportStatusPalette(
        foreground: GBTColors.successDark,
        background: GBTColors.successLight,
      );
    case AdminReportStatus.rejected:
    case AdminReportStatus.duplicate:
    case AdminReportStatus.dismissed:
      return const AdminReportStatusPalette(
        foreground: GBTColors.textSecondary,
        background: GBTColors.surfaceVariant,
      );
    case AdminReportStatus.unknown:
      return const AdminReportStatusPalette(
        foreground: GBTColors.infoDark,
        background: GBTColors.infoLight,
      );
  }
}
