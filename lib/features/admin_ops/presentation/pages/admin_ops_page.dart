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
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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

class _HeadlineCard extends StatelessWidget {
  const _HeadlineCard({required this.summary});

  final AdminDashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F2937), Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(GBTSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '운영 대기 항목',
            style: GBTTypography.labelLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
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
    );
  }
}

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

    return Wrap(
      spacing: GBTSpacing.sm,
      runSpacing: GBTSpacing.sm,
      children: cards
          .map(
            (data) => SizedBox(
              width:
                  (MediaQuery.sizeOf(context).width -
                      (GBTSpacing.md * 2) -
                      GBTSpacing.sm) /
                  2,
              child: _StatCard(data: data),
            ),
          )
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
              Text(
                '${data.value}',
                style: GBTTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: GBTSpacing.sm),
          Text(
            data.label,
            style: GBTTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExtraMetricsSection extends StatelessWidget {
  const _ExtraMetricsSection({required this.extraMetrics});

  final Map<String, int> extraMetrics;

  @override
  Widget build(BuildContext context) {
    final entries = extraMetrics.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
          for (final entry in entries)
            ListTile(
              dense: true,
              title: Text(entry.key, style: GBTTypography.bodySmall),
              trailing: Text(
                '${entry.value}',
                style: GBTTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
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

class _ReportFilterRow extends ConsumerWidget {
  const _ReportFilterRow({required this.selected});

  final AdminReportFilter selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AdminReportFilter.values
            .map(
              (filter) => Padding(
                padding: const EdgeInsets.only(right: GBTSpacing.xs),
                child: ChoiceChip(
                  label: Text(filter.label),
                  selected: filter == selected,
                  onSelected: (_) => ref
                      .read(adminReportsControllerProvider.notifier)
                      .load(filter: filter, forceRefresh: true),
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _ReportCard extends ConsumerWidget {
  const _ReportCard({required this.report, required this.isMutating});

  final AdminCommunityReport report;
  final bool isMutating;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = _paletteFor(report.status);

    return Card(
      margin: const EdgeInsets.only(top: GBTSpacing.sm),
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
              const SizedBox(height: GBTSpacing.sm),
              Text(
                report.reason,
                style: GBTTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (report.previewText != null && report.previewText!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: GBTSpacing.xs),
                  child: Text(
                    report.previewText!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GBTTypography.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              const SizedBox(height: GBTSpacing.sm),
              Text(
                _metaLine(report),
                style: GBTTypography.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _metaLine(AdminCommunityReport report) {
    final dateText = DateFormat('yyyy.MM.dd HH:mm').format(report.createdAt);
    final reporter = report.reporterName ?? '알 수 없는 사용자';
    final assignee = report.assigneeName ?? '미할당';
    return '신고자: $reporter · 담당: $assignee · $dateText';
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

class _ReportActionSheet extends StatelessWidget {
  const _ReportActionSheet({required this.report});

  final AdminCommunityReport report;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: GBTSpacing.sm),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
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
          ListTile(
            leading: const Icon(Icons.person_add_alt_1),
            title: const Text('나에게 할당'),
            subtitle: Text(report.assigneeName ?? '현재 미할당'),
            onTap: () => Navigator.of(context).pop(_ReportAction.assignToMe),
          ),
          ListTile(
            leading: const Icon(Icons.rule),
            title: const Text('검토 중으로 변경'),
            onTap: () => Navigator.of(context).pop(_ReportAction.markInReview),
          ),
          ListTile(
            leading: const Icon(Icons.check_circle, color: GBTColors.success),
            title: const Text('조치 완료로 변경'),
            onTap: () => Navigator.of(context).pop(_ReportAction.markResolved),
          ),
          ListTile(
            leading: const Icon(Icons.block, color: GBTColors.error),
            title: const Text('반려 처리'),
            onTap: () => Navigator.of(context).pop(_ReportAction.reject),
          ),
          const SizedBox(height: GBTSpacing.sm),
        ],
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
