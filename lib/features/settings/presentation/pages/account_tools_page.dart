/// EN: Account tools page for blocks, role requests, and appeals.
/// KO: 차단/권한요청/이의제기를 관리하는 계정 도구 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/navigation/gbt_segmented_tab_bar.dart';
import '../../../projects/application/projects_controller.dart';
import '../../../projects/domain/entities/project_entities.dart';
import '../../../settings/application/settings_controller.dart';
import '../../../settings/domain/entities/account_tools.dart';
import '../../../verification/application/failed_attempt_service.dart';
import '../../../verification/domain/entities/failed_verification_attempt.dart';

enum _AccountToolsTab { blocks, roleRequests, appeals }

class AccountToolsPage extends ConsumerStatefulWidget {
  const AccountToolsPage({super.key});

  @override
  ConsumerState<AccountToolsPage> createState() => _AccountToolsPageState();
}

class _AccountToolsPageState extends ConsumerState<AccountToolsPage>
    with SingleTickerProviderStateMixin {
  _AccountToolsTab _tab = _AccountToolsTab.blocks;
  late final TabController _tabController;
  final _justificationController = TextEditingController();
  final _appealDescriptionController = TextEditingController();
  String? _selectedAppealTargetId;
  String? _selectedAppealTargetLabel;

  String _requestedRole = 'EDITOR';
  String _appealTargetType = 'PLACE_VISIT';
  String _appealReason = 'FALSE_REJECTION';
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: _AccountToolsTab.values.length, vsync: this)
          ..addListener(() {
            if (!mounted) return;
            final next = _AccountToolsTab.values[_tabController.index];
            if (next != _tab) {
              setState(() => _tab = next);
            }
          });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _justificationController.dispose();
    _appealDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _refreshCurrentTab() async {
    switch (_tab) {
      case _AccountToolsTab.blocks:
        await ref
            .read(userBlocksControllerProvider.notifier)
            .load(forceRefresh: true);
      case _AccountToolsTab.roleRequests:
        await ref
            .read(projectRoleRequestsControllerProvider.notifier)
            .load(forceRefresh: true);
      case _AccountToolsTab.appeals:
        await ref
            .read(verificationAppealsControllerProvider.notifier)
            .load(forceRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectsState = ref.watch(projectsControllerProvider);
    final blocksState = ref.watch(userBlocksControllerProvider);
    final roleRequestsState = ref.watch(projectRoleRequestsControllerProvider);
    final appealsState = ref.watch(verificationAppealsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('계정 도구'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: '새로고침',
            onPressed: _refreshCurrentTab,
          ),
        ],
      ),
      body: Column(
        children: [
          // EN: Tab selector
          // KO: 탭 선택기
          Padding(
            padding: const EdgeInsets.fromLTRB(
              GBTSpacing.md,
              GBTSpacing.sm,
              GBTSpacing.md,
              GBTSpacing.sm,
            ),
            child: GBTSegmentedTabBar(
              controller: _tabController,
              height: 42,
              tabs: const [
                Tab(text: '차단'),
                Tab(text: '권한 요청'),
                Tab(text: '이의제기'),
              ],
            ),
          ),
          Expanded(
            child: switch (_tab) {
              _AccountToolsTab.blocks => _BlocksTab(
                state: blocksState,
                onRefresh: _refreshCurrentTab,
                isDark: isDark,
                onUnblock: (targetUserId) async {
                  final result = await ref
                      .read(userBlocksControllerProvider.notifier)
                      .unblock(targetUserId);
                  if (!context.mounted) return;
                  if (result is Err<void>) {
                    _showErrorSnackBar(context, result.failure.userMessage);
                    return;
                  }
                  _showInfoSnackBar(context, '차단을 해제했습니다');
                },
              ),
              _AccountToolsTab.roleRequests => _RoleRequestsTab(
                state: roleRequestsState,
                projectsState: projectsState,
                selectedProjectId: _selectedProjectId,
                requestedRole: _requestedRole,
                justificationController: _justificationController,
                isDark: isDark,
                onProjectChanged: (projectId) {
                  setState(() => _selectedProjectId = projectId);
                },
                onRoleChanged: (role) {
                  setState(() => _requestedRole = role);
                },
                onSubmit: () async {
                  final projectId = _resolveProjectId(projectsState);
                  final justification = _justificationController.text.trim();
                  if (projectId == null || projectId.isEmpty) {
                    _showErrorSnackBar(context, '프로젝트를 선택해주세요');
                    return;
                  }
                  if (justification.length < 20) {
                    _showErrorSnackBar(context, '사유를 20자 이상 입력해주세요');
                    return;
                  }
                  final result = await ref
                      .read(projectRoleRequestsControllerProvider.notifier)
                      .create(
                        projectId: projectId,
                        requestedRole: _requestedRole,
                        justification: justification,
                      );
                  if (!context.mounted) return;
                  if (result is Err<ProjectRoleRequest>) {
                    _showErrorSnackBar(context, result.failure.userMessage);
                    return;
                  }
                  _justificationController.clear();
                  _showInfoSnackBar(context, '권한 요청을 등록했습니다');
                },
                onCancel: (requestId) async {
                  final result = await ref
                      .read(projectRoleRequestsControllerProvider.notifier)
                      .cancel(requestId);
                  if (!context.mounted) return;
                  if (result is Err<void>) {
                    _showErrorSnackBar(context, result.failure.userMessage);
                    return;
                  }
                  _showInfoSnackBar(context, '권한 요청을 취소했습니다');
                },
                onRefresh: _refreshCurrentTab,
              ),
              _AccountToolsTab.appeals => _AppealsTab(
                state: appealsState,
                targetType: _appealTargetType,
                reason: _appealReason,
                selectedTargetId: _selectedAppealTargetId,
                selectedTargetLabel: _selectedAppealTargetLabel,
                descriptionController: _appealDescriptionController,
                isDark: isDark,
                onTargetTypeChanged: (value) {
                  setState(() {
                    _appealTargetType = value;
                    _selectedAppealTargetId = null;
                    _selectedAppealTargetLabel = null;
                  });
                },
                onReasonChanged: (value) {
                  setState(() => _appealReason = value);
                },
                onTargetSelected: (id, label) {
                  setState(() {
                    _selectedAppealTargetId = id;
                    _selectedAppealTargetLabel = label;
                  });
                },
                onSubmit: () async {
                  final targetId = _selectedAppealTargetId;
                  if (targetId == null || targetId.isEmpty) {
                    _showErrorSnackBar(context, '대상 인증 기록을 선택해주세요');
                    return;
                  }
                  final result = await ref
                      .read(verificationAppealsControllerProvider.notifier)
                      .create(
                        targetType: _appealTargetType,
                        targetId: targetId,
                        reason: _appealReason,
                        description: _appealDescriptionController.text.trim(),
                      );
                  if (!context.mounted) return;
                  if (result is Err<VerificationAppeal>) {
                    _showErrorSnackBar(context, result.failure.userMessage);
                    return;
                  }
                  setState(() {
                    _selectedAppealTargetId = null;
                    _selectedAppealTargetLabel = null;
                  });
                  _appealDescriptionController.clear();
                  _showInfoSnackBar(context, '이의제기를 접수했습니다');
                },
                onRefresh: _refreshCurrentTab,
              ),
            },
          ),
        ],
      ),
    );
  }

  String? _resolveProjectId(AsyncValue<List<Project>> projectsState) {
    if (_selectedProjectId != null && _selectedProjectId!.isNotEmpty) {
      return _selectedProjectId;
    }
    return projectsState.maybeWhen(
      data: (projects) => projects.isNotEmpty ? projects.first.id : null,
      orElse: () => null,
    );
  }
}

// ========================================
// EN: Blocks Tab
// KO: 차단 탭
// ========================================

class _BlocksTab extends StatelessWidget {
  const _BlocksTab({
    required this.state,
    required this.onRefresh,
    required this.isDark,
    required this.onUnblock,
  });

  final AsyncValue<List<UserBlock>> state;
  final Future<void> Function() onRefresh;
  final bool isDark;
  final Future<void> Function(String targetUserId) onUnblock;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: state.when(
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 80),
            GBTLoading(message: '차단 목록을 불러오는 중...'),
          ],
        ),
        error: (error, _) {
          final message = error is Failure
              ? error.userMessage
              : '차단 목록을 불러오지 못했어요';
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 80),
              GBTErrorState(message: message, onRetry: onRefresh),
            ],
          );
        },
        data: (items) {
          if (items.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 80),
                GBTEmptyState(message: '차단한 사용자가 없습니다'),
              ],
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: GBTSpacing.md,
              vertical: GBTSpacing.xs,
            ),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: GBTSpacing.xs),
            itemBuilder: (context, index) {
              final item = items[index];
              return _BlockItemRow(
                item: item,
                isDark: isDark,
                onUnblock: () => onUnblock(item.blockedUser.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _BlockItemRow extends StatelessWidget {
  const _BlockItemRow({
    required this.item,
    required this.isDark,
    required this.onUnblock,
  });

  final UserBlock item;
  final bool isDark;
  final VoidCallback onUnblock;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark
        ? GBTColors.darkSurfaceElevated
        : GBTColors.surface;
    final borderColor = isDark ? GBTColors.darkBorderSubtle : GBTColors.border;
    final textPrimary = isDark
        ? GBTColors.darkTextPrimary
        : GBTColors.textPrimary;
    final textTertiary = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;

    return Container(
      padding: const EdgeInsets.all(GBTSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          // EN: User avatar
          // KO: 사용자 아바타
          ClipOval(
            child: item.blockedUser.avatarUrl != null
                ? GBTImage(
                    imageUrl: item.blockedUser.avatarUrl!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 44,
                    height: 44,
                    color: isDark
                        ? GBTColors.darkSurfaceVariant
                        : GBTColors.surfaceVariant,
                    alignment: Alignment.center,
                    child: Text(
                      item.blockedUser.displayName.characters.first,
                      style: GBTTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textTertiary,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: GBTSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.blockedUser.displayName,
                  style: GBTTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_dateLabel(item.createdAt)}'
                  '${item.reason != null ? ' · ${item.reason}' : ''}',
                  style: GBTTypography.labelSmall.copyWith(color: textTertiary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: GBTSpacing.sm),
          // EN: Unblock button
          // KO: 차단 해제 버튼
          OutlinedButton(
            onPressed: onUnblock,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.sm),
              side: BorderSide(
                color: const Color(0xFFEF4444).withValues(alpha: 0.4),
              ),
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('해제'),
          ),
        ],
      ),
    );
  }
}

// ========================================
// EN: Role Requests Tab
// KO: 권한 요청 탭
// ========================================

class _RoleRequestsTab extends StatelessWidget {
  const _RoleRequestsTab({
    required this.state,
    required this.projectsState,
    required this.selectedProjectId,
    required this.requestedRole,
    required this.justificationController,
    required this.isDark,
    required this.onProjectChanged,
    required this.onRoleChanged,
    required this.onSubmit,
    required this.onCancel,
    required this.onRefresh,
  });

  final AsyncValue<List<ProjectRoleRequest>> state;
  final AsyncValue<List<Project>> projectsState;
  final String? selectedProjectId;
  final String requestedRole;
  final TextEditingController justificationController;
  final bool isDark;
  final ValueChanged<String> onProjectChanged;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onSubmit;
  final Future<void> Function(String requestId) onCancel;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final projects = projectsState.maybeWhen(
      data: (items) => items,
      orElse: () => const <Project>[],
    );
    final initialProjectId =
        selectedProjectId ?? (projects.isNotEmpty ? projects.first.id : null);
    final surfaceColor = isDark
        ? GBTColors.darkSurfaceElevated
        : GBTColors.surface;
    final borderColor = isDark ? GBTColors.darkBorderSubtle : GBTColors.border;
    final textPrimary = isDark
        ? GBTColors.darkTextPrimary
        : GBTColors.textPrimary;
    final textSecondary = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;
    final projectOptions = projects
        .map(
          (project) => _SelectionOption(
            value: project.id,
            label: project.name,
            caption: project.code,
          ),
        )
        .toList(growable: false);
    Project? selectedProject;
    for (final project in projects) {
      if (project.id == initialProjectId) {
        selectedProject = project;
        break;
      }
    }
    const roleOptions = <_SelectionOption>[
      _SelectionOption(value: 'VIEWER', label: '뷰어', caption: '읽기 전용'),
      _SelectionOption(value: 'EDITOR', label: '에디터', caption: '편집 가능'),
      _SelectionOption(value: 'MODERATOR', label: '모더레이터', caption: '관리 가능'),
    ];

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: GBTSpacing.md,
          vertical: GBTSpacing.xs,
        ),
        children: [
          // EN: Submit form card
          // KO: 제출 폼 카드
          Container(
            padding: const EdgeInsets.all(GBTSpacing.md),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          GBTSpacing.radiusSm,
                        ),
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        size: 18,
                        color: Color(0xFF6366F1),
                      ),
                    ),
                    const SizedBox(width: GBTSpacing.sm),
                    Text(
                      '권한 요청 보내기',
                      style: GBTTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: GBTSpacing.md),
                _SelectionField(
                  label: '프로젝트',
                  isDark: isDark,
                  valueText: selectedProject?.name,
                  placeholder: projects.isEmpty ? '프로젝트가 없습니다' : '프로젝트 선택',
                  onTap: projects.isEmpty
                      ? null
                      : () async {
                          final selected = await _showSelectionPicker(
                            context,
                            title: '프로젝트 선택',
                            options: projectOptions,
                            selectedValue: initialProjectId,
                          );
                          if (selected != null && selected.isNotEmpty) {
                            onProjectChanged(selected);
                          }
                        },
                ),
                const SizedBox(height: GBTSpacing.sm),
                _SelectionField(
                  label: '요청 권한',
                  isDark: isDark,
                  valueText: _translateRole(requestedRole),
                  placeholder: '권한 선택',
                  onTap: () async {
                    final selected = await _showSelectionPicker(
                      context,
                      title: '요청 권한 선택',
                      options: roleOptions,
                      selectedValue: requestedRole,
                    );
                    if (selected != null && selected.isNotEmpty) {
                      onRoleChanged(selected);
                    }
                  },
                ),
                const SizedBox(height: GBTSpacing.sm),
                TextField(
                  controller: justificationController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: '요청 사유 (20자 이상)',
                  ),
                ),
                const SizedBox(height: GBTSpacing.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: onSubmit,
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('요청 제출'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: GBTSpacing.lg),

          // EN: My requests section header
          // KO: 내 요청 섹션 헤더
          Padding(
            padding: const EdgeInsets.only(
              left: GBTSpacing.xs,
              bottom: GBTSpacing.xs,
            ),
            child: Text(
              '내 권한 요청',
              style: GBTTypography.labelSmall.copyWith(
                color: textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          state.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: GBTSpacing.lg),
              child: GBTLoading(message: '권한 요청 내역을 불러오는 중...'),
            ),
            error: (error, _) {
              final message = error is Failure
                  ? error.userMessage
                  : '권한 요청 내역을 불러오지 못했어요';
              return GBTErrorState(message: message, onRetry: onRefresh);
            },
            data: (items) {
              if (items.isEmpty) {
                return const GBTEmptyState(message: '등록된 권한 요청이 없습니다');
              }
              return Column(
                children: items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: GBTSpacing.xs),
                        child: _RoleRequestItemRow(
                          item: item,
                          isDark: isDark,
                          onCancel: onCancel,
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
          const SizedBox(height: GBTSpacing.lg),
        ],
      ),
    );
  }
}

class _RoleRequestItemRow extends StatelessWidget {
  const _RoleRequestItemRow({
    required this.item,
    required this.isDark,
    required this.onCancel,
  });

  final ProjectRoleRequest item;
  final bool isDark;
  final Future<void> Function(String requestId) onCancel;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark
        ? GBTColors.darkSurfaceElevated
        : GBTColors.surface;
    final borderColor = isDark ? GBTColors.darkBorderSubtle : GBTColors.border;
    final textPrimary = isDark
        ? GBTColors.darkTextPrimary
        : GBTColors.textPrimary;
    final textTertiary = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;

    return Container(
      padding: const EdgeInsets.all(GBTSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.projectName ?? item.projectSlug ?? '프로젝트',
                  style: GBTTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    _RoleBadge(role: item.requestedRole),
                    const SizedBox(width: GBTSpacing.xs),
                    Text(
                      _dateLabel(item.createdAt),
                      style: GBTTypography.labelSmall.copyWith(
                        color: textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: GBTSpacing.sm),
          item.canCancel
              ? OutlinedButton(
                  onPressed: () => onCancel(item.id),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(
                      horizontal: GBTSpacing.sm,
                    ),
                  ),
                  child: const Text('취소'),
                )
              : _StatusBadge(status: item.status),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
      ),
      child: Text(
        _translateRole(role),
        style: GBTTypography.labelSmall.copyWith(
          color: const Color(0xFF6366F1),
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

// ========================================
// EN: Appeals Tab
// KO: 이의제기 탭
// ========================================

class _AppealsTab extends StatelessWidget {
  const _AppealsTab({
    required this.state,
    required this.targetType,
    required this.reason,
    required this.selectedTargetId,
    required this.selectedTargetLabel,
    required this.descriptionController,
    required this.isDark,
    required this.onTargetTypeChanged,
    required this.onReasonChanged,
    required this.onTargetSelected,
    required this.onSubmit,
    required this.onRefresh,
  });

  final AsyncValue<List<VerificationAppeal>> state;
  final String targetType;
  final String reason;
  final String? selectedTargetId;
  final String? selectedTargetLabel;
  final TextEditingController descriptionController;
  final bool isDark;
  final ValueChanged<String> onTargetTypeChanged;
  final ValueChanged<String> onReasonChanged;
  final void Function(String id, String label) onTargetSelected;
  final VoidCallback onSubmit;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark
        ? GBTColors.darkSurfaceElevated
        : GBTColors.surface;
    final borderColor = isDark ? GBTColors.darkBorderSubtle : GBTColors.border;
    final textPrimary = isDark
        ? GBTColors.darkTextPrimary
        : GBTColors.textPrimary;
    final textSecondary = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;
    const targetTypeOptions = <_SelectionOption>[
      _SelectionOption(value: 'PLACE_VISIT', label: '장소 방문 인증'),
      _SelectionOption(value: 'LIVE_EVENT', label: '라이브 출석 인증'),
    ];
    const reasonOptions = <_SelectionOption>[
      _SelectionOption(value: 'FALSE_REJECTION', label: '오탐 거절'),
      _SelectionOption(value: 'GPS_INACCURACY', label: 'GPS 오차'),
      _SelectionOption(value: 'NETWORK_ISSUE', label: '네트워크 문제'),
      _SelectionOption(value: 'DEVICE_ISSUE', label: '기기 문제'),
      _SelectionOption(value: 'LOCATION_ERROR', label: '위치 오류'),
      _SelectionOption(value: 'OTHER', label: '기타'),
    ];

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: GBTSpacing.md,
          vertical: GBTSpacing.xs,
        ),
        children: [
          // EN: Submit form card
          // KO: 제출 폼 카드
          Container(
            padding: const EdgeInsets.all(GBTSpacing.md),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
              border: Border.all(color: borderColor, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          GBTSpacing.radiusSm,
                        ),
                      ),
                      child: const Icon(
                        Icons.gavel_rounded,
                        size: 18,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(width: GBTSpacing.sm),
                    Text(
                      '인증 이의제기 제출',
                      style: GBTTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: GBTSpacing.md),
                _SelectionField(
                  label: '대상 유형',
                  isDark: isDark,
                  valueText: _appealTargetTypeLabel(targetType),
                  placeholder: '대상 유형 선택',
                  onTap: () async {
                    final selected = await _showSelectionPicker(
                      context,
                      title: '대상 유형 선택',
                      options: targetTypeOptions,
                      selectedValue: targetType,
                    );
                    if (selected != null && selected.isNotEmpty) {
                      onTargetTypeChanged(selected);
                    }
                  },
                ),
                const SizedBox(height: GBTSpacing.sm),
                _TargetSelectorRow(
                  targetType: targetType,
                  selectedLabel: selectedTargetLabel,
                  isDark: isDark,
                  onTap: () async {
                    final result =
                        await showModalBottomSheet<(String, String)?>(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          builder: (_) =>
                              _TargetPickerSheet(targetType: targetType),
                        );
                    if (result != null) {
                      onTargetSelected(result.$1, result.$2);
                    }
                  },
                ),
                const SizedBox(height: GBTSpacing.sm),
                _SelectionField(
                  label: '사유',
                  isDark: isDark,
                  valueText: _appealReasonLabel(reason),
                  placeholder: '사유 선택',
                  onTap: () async {
                    final selected = await _showSelectionPicker(
                      context,
                      title: '사유 선택',
                      options: reasonOptions,
                      selectedValue: reason,
                    );
                    if (selected != null && selected.isNotEmpty) {
                      onReasonChanged(selected);
                    }
                  },
                ),
                const SizedBox(height: GBTSpacing.sm),
                TextField(
                  controller: descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: '상세 설명 (선택)'),
                ),
                const SizedBox(height: GBTSpacing.md),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: onSubmit,
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text('이의제기 제출'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: GBTSpacing.lg),

          // EN: My appeals section header
          // KO: 내 이의제기 섹션 헤더
          Padding(
            padding: const EdgeInsets.only(
              left: GBTSpacing.xs,
              bottom: GBTSpacing.xs,
            ),
            child: Text(
              '내 이의제기 내역',
              style: GBTTypography.labelSmall.copyWith(
                color: textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          state.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: GBTSpacing.lg),
              child: GBTLoading(message: '이의제기 내역을 불러오는 중...'),
            ),
            error: (error, _) {
              final message = error is Failure
                  ? error.userMessage
                  : '이의제기 내역을 불러오지 못했어요';
              return GBTErrorState(message: message, onRetry: onRefresh);
            },
            data: (items) {
              if (items.isEmpty) {
                return const GBTEmptyState(message: '등록된 이의제기가 없습니다');
              }
              return Column(
                children: items
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: GBTSpacing.xs),
                        child: _AppealItemRow(item: item, isDark: isDark),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
          const SizedBox(height: GBTSpacing.lg),
        ],
      ),
    );
  }
}

class _AppealItemRow extends StatelessWidget {
  const _AppealItemRow({required this.item, required this.isDark});

  final VerificationAppeal item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final surfaceColor = isDark
        ? GBTColors.darkSurfaceElevated
        : GBTColors.surface;
    final borderColor = isDark ? GBTColors.darkBorderSubtle : GBTColors.border;
    final textPrimary = isDark
        ? GBTColors.darkTextPrimary
        : GBTColors.textPrimary;
    final textTertiary = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;

    final targetTypeLabel = _appealTargetTypeLabel(item.targetType);
    final reasonLabel = _appealReasonLabel(item.reason);

    return Container(
      padding: const EdgeInsets.all(GBTSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  targetTypeLabel,
                  style: GBTTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      reasonLabel,
                      style: GBTTypography.labelSmall.copyWith(
                        color: textTertiary,
                      ),
                    ),
                    Text(
                      ' · ${_dateLabel(item.createdAt)}',
                      style: GBTTypography.labelSmall.copyWith(
                        color: textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: GBTSpacing.sm),
          _StatusBadge(status: item.status),
        ],
      ),
    );
  }
}

// ========================================
// EN: Status badge widget
// KO: 상태 배지 위젯
// ========================================

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase();
    final text = switch (normalized) {
      'PENDING' => '대기',
      'IN_REVIEW' => '검토중',
      'APPROVED' => '승인',
      'REJECTED' => '반려',
      _ => status,
    };

    final color = switch (normalized) {
      'APPROVED' => const Color(0xFF10B981),
      'REJECTED' => const Color(0xFFEF4444),
      'IN_REVIEW' => const Color(0xFF3B82F6),
      _ => const Color(0xFFF59E0B),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
      ),
      child: Text(
        text,
        style: GBTTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SelectionOption {
  const _SelectionOption({
    required this.value,
    required this.label,
    this.caption,
  });

  final String value;
  final String label;
  final String? caption;
}

class _SelectionField extends StatelessWidget {
  const _SelectionField({
    required this.label,
    required this.isDark,
    required this.placeholder,
    this.valueText,
    this.onTap,
  });

  final String label;
  final bool isDark;
  final String placeholder;
  final String? valueText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;
    final textPrimary = isDark
        ? GBTColors.darkTextPrimary
        : GBTColors.textPrimary;
    final textSecondary = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: GBTSpacing.md,
            vertical: GBTSpacing.sm,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 0.5),
            borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GBTTypography.labelSmall.copyWith(
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      valueText ?? placeholder,
                      style: GBTTypography.bodyMedium.copyWith(
                        color: valueText != null && enabled
                            ? textPrimary
                            : textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: GBTSpacing.xs),
              Icon(
                Icons.arrow_drop_down_rounded,
                color: enabled
                    ? textSecondary
                    : textSecondary.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String?> _showSelectionPicker(
  BuildContext context, {
  required String title,
  required List<_SelectionOption> options,
  String? selectedValue,
}) {
  return showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (sheetContext) => _SelectionPickerSheet(
      title: title,
      options: options,
      selectedValue: selectedValue,
    ),
  );
}

class _SelectionPickerSheet extends StatelessWidget {
  const _SelectionPickerSheet({
    required this.title,
    required this.options,
    this.selectedValue,
  });

  final String title;
  final List<_SelectionOption> options;
  final String? selectedValue;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? GBTColors.darkBorder : GBTColors.divider;
    final selectedColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;
    final textPrimary = isDark
        ? GBTColors.darkTextPrimary
        : GBTColors.textPrimary;
    final textSecondary = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.56,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                GBTSpacing.md,
                GBTSpacing.sm,
                GBTSpacing.md,
                GBTSpacing.sm,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(title, style: GBTTypography.titleMedium),
              ),
            ),
            Divider(height: 1, color: dividerColor),
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: dividerColor),
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option.value == selectedValue;
                  return ListTile(
                    dense: true,
                    title: Text(
                      option.label,
                      style: GBTTypography.bodyMedium.copyWith(
                        color: textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    subtitle: option.caption == null
                        ? null
                        : Text(
                            option.caption!,
                            style: GBTTypography.labelSmall.copyWith(
                              color: textSecondary,
                            ),
                          ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: selectedColor,
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(option.value),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// EN: Translates server-side role strings to Korean display labels.
/// KO: 서버 역할 문자열을 한글 표시 레이블로 변환합니다.
String _translateRole(String role) => switch (role.toUpperCase()) {
  'VIEWER' => '뷰어',
  'EDITOR' => '에디터',
  'MODERATOR' => '모더레이터',
  _ => role,
};

String _appealTargetTypeLabel(String value) => switch (value.toUpperCase()) {
  'PLACE_VISIT' => '장소 방문 인증',
  'LIVE_EVENT' => '라이브 출석 인증',
  _ => value,
};

String _appealReasonLabel(String value) => switch (value.toUpperCase()) {
  'FALSE_REJECTION' => '오탐 거절',
  'GPS_INACCURACY' => 'GPS 오차',
  'NETWORK_ISSUE' => '네트워크 문제',
  'DEVICE_ISSUE' => '기기 문제',
  'LOCATION_ERROR' => '위치 오류',
  _ => '기타',
};

// ========================================
// EN: Target selector row — tappable field showing selected verification record
// KO: 선택된 인증 기록을 보여주는 탭 가능한 선택 필드
// ========================================

class _TargetSelectorRow extends StatelessWidget {
  const _TargetSelectorRow({
    required this.targetType,
    required this.selectedLabel,
    required this.isDark,
    required this.onTap,
  });

  final String targetType;
  final String? selectedLabel;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = targetType == 'PLACE_VISIT'
        ? '실패한 방문 인증 기록'
        : '실패한 이벤트 출석 기록';

    return _SelectionField(
      label: label,
      valueText: selectedLabel,
      placeholder: '탭하여 선택',
      isDark: isDark,
      onTap: onTap,
    );
  }
}

// ========================================
// EN: Target picker bottom sheet — searchable list of failed verification attempts
// KO: 실패한 인증 기록을 검색하고 선택하는 바텀 시트
// ========================================

class _TargetPickerSheet extends ConsumerStatefulWidget {
  const _TargetPickerSheet({required this.targetType});

  final String targetType;

  @override
  ConsumerState<_TargetPickerSheet> createState() => _TargetPickerSheetState();
}

class _TargetPickerSheetState extends ConsumerState<_TargetPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;
    final isPlaceVisit = widget.targetType == 'PLACE_VISIT';

    // EN: Watch the full list and filter by targetType in the UI.
    // KO: 전체 목록을 구독하고 UI에서 targetType으로 필터링합니다.
    final attemptsAsync = ref.watch(failedVerificationAttemptsProvider);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.78,
      child: Column(
        children: [
          // EN: Handle bar
          // KO: 핸들 바
          const SizedBox(height: GBTSpacing.sm),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
            ),
          ),

          // EN: Sheet title
          // KO: 시트 제목
          Padding(
            padding: const EdgeInsets.fromLTRB(
              GBTSpacing.md,
              GBTSpacing.md,
              GBTSpacing.md,
              GBTSpacing.sm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                isPlaceVisit ? '실패한 방문 인증 기록 선택' : '실패한 이벤트 출석 기록 선택',
                style: GBTTypography.titleMedium,
              ),
            ),
          ),

          // EN: Search field
          // KO: 검색 필드
          Padding(
            padding: const EdgeInsets.fromLTRB(
              GBTSpacing.md,
              0,
              GBTSpacing.md,
              GBTSpacing.sm,
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: isPlaceVisit ? '장소 이름으로 검색' : '이벤트 이름으로 검색',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                isDense: true,
              ),
            ),
          ),

          // EN: Failed attempt list
          // KO: 실패 기록 목록
          Expanded(child: _buildAttemptList(attemptsAsync, isDark)),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildAttemptList(
    AsyncValue<List<FailedVerificationAttempt>> attemptsAsync,
    bool isDark,
  ) {
    final textPrimary = isDark
        ? GBTColors.darkTextPrimary
        : GBTColors.textPrimary;
    final textTertiary = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;

    return attemptsAsync.when(
      loading: () => const Center(child: GBTLoading(message: '기록을 불러오는 중...')),
      error: (_, __) => Center(child: GBTErrorState(message: '기록을 불러오지 못했어요')),
      data: (all) {
        // EN: Filter by targetType then apply search query.
        // KO: targetType으로 필터 후 검색어 적용.
        final forType = all
            .where((a) => a.targetType == widget.targetType)
            .toList(growable: false);

        final filtered = _query.isEmpty
            ? forType
            : forType
                  .where(
                    (a) =>
                        (a.targetName?.toLowerCase() ?? '').contains(_query) ||
                        a.targetId.toLowerCase().contains(_query),
                  )
                  .toList(growable: false);

        if (forType.isEmpty) {
          return Center(
            child: Padding(
              padding: GBTSpacing.paddingPage,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_outlined, size: 48, color: textTertiary),
                  const SizedBox(height: GBTSpacing.md),
                  Text(
                    '최근 30일 내 실패한 인증 기록이 없습니다',
                    textAlign: TextAlign.center,
                    style: GBTTypography.bodyMedium.copyWith(
                      color: isDark
                          ? GBTColors.darkTextSecondary
                          : GBTColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (filtered.isEmpty) {
          return const Center(
            child: GBTEmptyState(
              icon: Icons.search_off_rounded,
              message: '검색 결과가 없습니다',
            ),
          );
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: isDark ? GBTColors.darkBorder : GBTColors.divider,
          ),
          itemBuilder: (context, index) {
            final attempt = filtered[index];
            final name = attempt.targetName ?? attempt.targetId;
            final date = _dateLabel(attempt.attemptedAt);
            final failCode = _translateFailureCode(attempt.failureCode);
            final label = '$name · $date';

            return ListTile(
              dense: true,
              title: Text(
                name,
                style: GBTTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '$date · $failCode',
                style: GBTTypography.labelSmall.copyWith(color: textTertiary),
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: textTertiary,
              ),
              onTap: () => Navigator.of(context).pop((attempt.targetId, label)),
            );
          },
        );
      },
    );
  }

  /// EN: Translate server/local failure codes to Korean labels.
  /// KO: 서버/로컬 실패 코드를 한국어 레이블로 변환합니다.
  String _translateFailureCode(String code) => switch (code.toUpperCase()) {
    'LOCATION_TOO_FAR' => '위치 거리 초과',
    'TIME_WINDOW_EXPIRED' => '인증 시간 만료',
    'GPS_INACCURACY' || 'LOCATION_INACCURATE' => 'GPS 오차',
    'INVALID_TOKEN' || 'JWS_INVALID' => '토큰 오류',
    'NETWORK_ERROR' || 'TIMEOUT' => '네트워크 오류',
    'ALREADY_VERIFIED' => '이미 인증됨',
    _ => '인증 실패',
  };
}

void _showInfoSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

void _showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
    ),
  );
}

String _dateLabel(DateTime dateTime) {
  return dateTime.toLocal().toIso8601String().split('T').first;
}
