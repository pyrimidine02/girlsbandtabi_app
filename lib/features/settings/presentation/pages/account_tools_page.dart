/// EN: Account tools page for blocks, role requests, and appeals.
/// KO: 차단/권한요청/이의제기를 관리하는 계정 도구 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/layout/gbt_page_intro_card.dart';
import '../../../projects/application/projects_controller.dart';
import '../../../projects/domain/entities/project_entities.dart';
import '../../../settings/application/settings_controller.dart';
import '../../../settings/domain/entities/account_tools.dart';

enum _AccountToolsTab { blocks, roleRequests, appeals }

class AccountToolsPage extends ConsumerStatefulWidget {
  const AccountToolsPage({super.key});

  @override
  ConsumerState<AccountToolsPage> createState() => _AccountToolsPageState();
}

class _AccountToolsPageState extends ConsumerState<AccountToolsPage> {
  _AccountToolsTab _tab = _AccountToolsTab.blocks;
  final _justificationController = TextEditingController();
  final _appealTargetIdController = TextEditingController();
  final _appealDescriptionController = TextEditingController();

  String _requestedRole = 'EDITOR';
  String _appealTargetType = 'PLACE_VISIT';
  String _appealReason = 'FALSE_REJECTION';
  String? _selectedProjectId;

  @override
  void dispose() {
    _justificationController.dispose();
    _appealTargetIdController.dispose();
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
    final projectsState = ref.watch(projectsControllerProvider);
    final blocksState = ref.watch(userBlocksControllerProvider);
    final roleRequestsState = ref.watch(projectRoleRequestsControllerProvider);
    final appealsState = ref.watch(verificationAppealsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('계정 도구'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
            onPressed: _refreshCurrentTab,
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(
              GBTSpacing.md,
              GBTSpacing.md,
              GBTSpacing.md,
              GBTSpacing.sm,
            ),
            child: GBTPageIntroCard(
              icon: Icons.build_circle_outlined,
              title: '계정 관리',
              description: '차단 사용자, 프로젝트 권한 요청, 인증 이의제기를 한 곳에서 관리하세요.',
            ),
          ),
          Padding(
            padding: GBTSpacing.paddingHorizontalMd,
            child: SegmentedButton<_AccountToolsTab>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: _AccountToolsTab.blocks,
                  icon: Icon(Icons.block_outlined, size: 18),
                  label: Text('차단'),
                ),
                ButtonSegment(
                  value: _AccountToolsTab.roleRequests,
                  icon: Icon(Icons.verified_user_outlined, size: 18),
                  label: Text('권한 요청'),
                ),
                ButtonSegment(
                  value: _AccountToolsTab.appeals,
                  icon: Icon(Icons.gavel_outlined, size: 18),
                  label: Text('이의제기'),
                ),
              ],
              selected: {_tab},
              onSelectionChanged: (selection) {
                setState(() => _tab = selection.first);
              },
            ),
          ),
          const SizedBox(height: GBTSpacing.sm),
          Expanded(
            child: switch (_tab) {
              _AccountToolsTab.blocks => _BlocksTab(
                state: blocksState,
                onRefresh: _refreshCurrentTab,
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
                targetIdController: _appealTargetIdController,
                descriptionController: _appealDescriptionController,
                onTargetTypeChanged: (value) {
                  setState(() => _appealTargetType = value);
                },
                onReasonChanged: (value) {
                  setState(() => _appealReason = value);
                },
                onSubmit: () async {
                  final targetId = _appealTargetIdController.text.trim();
                  if (targetId.isEmpty) {
                    _showErrorSnackBar(context, '대상 ID를 입력해주세요');
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
                  _appealTargetIdController.clear();
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

class _BlocksTab extends StatelessWidget {
  const _BlocksTab({
    required this.state,
    required this.onRefresh,
    required this.onUnblock,
  });

  final AsyncValue<List<UserBlock>> state;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String targetUserId) onUnblock;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: state.when(
        loading: () => ListView(
          physics: AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 80),
            const GBTLoading(message: '차단 목록을 불러오는 중...'),
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
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 80),
                const GBTEmptyState(message: '차단한 사용자가 없습니다'),
              ],
            );
          }
          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: GBTSpacing.paddingHorizontalMd,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: GBTSpacing.sm),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    child: ClipOval(
                      child: item.blockedUser.avatarUrl != null
                          ? GBTImage(
                              imageUrl: item.blockedUser.avatarUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            )
                          : Text(item.blockedUser.displayName.characters.first),
                    ),
                  ),
                  title: Text(item.blockedUser.displayName),
                  subtitle: Text(
                    '${_dateLabel(item.createdAt)}'
                    '${item.reason != null ? ' · ${item.reason}' : ''}',
                  ),
                  trailing: TextButton(
                    onPressed: () => onUnblock(item.blockedUser.id),
                    child: const Text('해제'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RoleRequestsTab extends StatelessWidget {
  const _RoleRequestsTab({
    required this.state,
    required this.projectsState,
    required this.selectedProjectId,
    required this.requestedRole,
    required this.justificationController,
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

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: GBTSpacing.paddingHorizontalMd,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(GBTSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '권한 요청 보내기',
                    style: GBTTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: initialProjectId,
                    decoration: const InputDecoration(labelText: '프로젝트'),
                    items: projects
                        .map<DropdownMenuItem<String>>(
                          (project) => DropdownMenuItem<String>(
                            value: project.id,
                            child: Text(project.name),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) {
                        onProjectChanged(value);
                      }
                    },
                  ),
                  const SizedBox(height: GBTSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: requestedRole,
                    decoration: const InputDecoration(labelText: '요청 권한'),
                    items: const [
                      DropdownMenuItem(value: 'VIEWER', child: Text('VIEWER')),
                      DropdownMenuItem(value: 'EDITOR', child: Text('EDITOR')),
                      DropdownMenuItem(
                        value: 'MODERATOR',
                        child: Text('MODERATOR'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) {
                        onRoleChanged(value);
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
                  const SizedBox(height: GBTSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: onSubmit,
                      icon: const Icon(Icons.send, size: 18),
                      label: const Text('요청 제출'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: GBTSpacing.md),
          Text(
            '내 권한 요청',
            style: GBTTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: GBTSpacing.sm),
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
                      (item) => Card(
                        margin: const EdgeInsets.only(bottom: GBTSpacing.sm),
                        child: ListTile(
                          title: Text(
                            item.projectName ?? item.projectSlug ?? '프로젝트',
                          ),
                          subtitle: Text(
                            '${item.requestedRole} · ${_dateLabel(item.createdAt)}',
                          ),
                          trailing: item.canCancel
                              ? TextButton(
                                  onPressed: () => onCancel(item.id),
                                  child: const Text('취소'),
                                )
                              : _StatusBadge(status: item.status),
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

class _AppealsTab extends StatelessWidget {
  const _AppealsTab({
    required this.state,
    required this.targetType,
    required this.reason,
    required this.targetIdController,
    required this.descriptionController,
    required this.onTargetTypeChanged,
    required this.onReasonChanged,
    required this.onSubmit,
    required this.onRefresh,
  });

  final AsyncValue<List<VerificationAppeal>> state;
  final String targetType;
  final String reason;
  final TextEditingController targetIdController;
  final TextEditingController descriptionController;
  final ValueChanged<String> onTargetTypeChanged;
  final ValueChanged<String> onReasonChanged;
  final VoidCallback onSubmit;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: GBTSpacing.paddingHorizontalMd,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(GBTSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '인증 이의제기 제출',
                    style: GBTTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: targetType,
                    decoration: const InputDecoration(labelText: '대상 유형'),
                    items: const [
                      DropdownMenuItem(
                        value: 'PLACE_VISIT',
                        child: Text('장소 방문 인증'),
                      ),
                      DropdownMenuItem(
                        value: 'LIVE_EVENT',
                        child: Text('라이브 출석 인증'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) {
                        onTargetTypeChanged(value);
                      }
                    },
                  ),
                  const SizedBox(height: GBTSpacing.sm),
                  TextField(
                    controller: targetIdController,
                    decoration: const InputDecoration(
                      labelText: '대상 인증 ID',
                      hintText: 'UUID를 입력하세요',
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: reason,
                    decoration: const InputDecoration(labelText: '사유'),
                    items: const [
                      DropdownMenuItem(
                        value: 'FALSE_REJECTION',
                        child: Text('오탐 거절'),
                      ),
                      DropdownMenuItem(
                        value: 'GPS_INACCURACY',
                        child: Text('GPS 오차'),
                      ),
                      DropdownMenuItem(
                        value: 'NETWORK_ISSUE',
                        child: Text('네트워크 문제'),
                      ),
                      DropdownMenuItem(
                        value: 'DEVICE_ISSUE',
                        child: Text('기기 문제'),
                      ),
                      DropdownMenuItem(
                        value: 'LOCATION_ERROR',
                        child: Text('위치 오류'),
                      ),
                      DropdownMenuItem(value: 'OTHER', child: Text('기타')),
                    ],
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) {
                        onReasonChanged(value);
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
                  const SizedBox(height: GBTSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: onSubmit,
                      icon: const Icon(Icons.send, size: 18),
                      label: const Text('이의제기 제출'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: GBTSpacing.md),
          Text(
            '내 이의제기 내역',
            style: GBTTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: GBTSpacing.sm),
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
                      (item) => Card(
                        margin: const EdgeInsets.only(bottom: GBTSpacing.sm),
                        child: ListTile(
                          title: Text('${item.targetType} · ${item.reason}'),
                          subtitle: Text(_dateLabel(item.createdAt)),
                          trailing: _StatusBadge(status: item.status),
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
      'APPROVED' => Colors.green,
      'REJECTED' => Colors.red,
      'IN_REVIEW' => Colors.blue,
      _ => Colors.orange,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.sm,
        vertical: GBTSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
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
