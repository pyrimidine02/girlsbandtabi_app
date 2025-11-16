import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../providers/content_filter_provider.dart';
import '../../providers/project_band_providers.dart';
import '../../providers/role_provider.dart';
import '../../widgets/flow_components.dart';
import '../../widgets/project_band_sheet.dart';

class AllScreen extends ConsumerWidget {
  const AllScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.currentUser;
    final projectsAsync = ref.watch(projectsProvider);
    final selectedProjectName = ref.watch(selectedProjectNameProvider);
    final roleAsync = ref.watch(userRoleProvider);
    final isAdmin = roleAsync.maybeWhen(
      data: (role) => role == 'ADMIN' || role == 'ProjectAdmin' || role == 'MODERATOR',
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FlowGradientBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
            children: [
              FlowCard(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    Theme.of(context).colorScheme.secondary.withValues(alpha: 0.16),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FlowPill(
                      label: selectedProjectName ?? '전체 프로젝트',
                      leading: const Icon(Icons.layers_outlined, size: 16),
                      trailing:
                          const Icon(Icons.chevron_right_rounded, size: 18),
                      onTap: () => showProjectBandSelector(
                        context,
                        ref,
                        onApplied: () {
                          ref.invalidate(projectsProvider);
                        },
                      ),
                      backgroundColor:
                          Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.12),
                          child: Text(
                            (user?.displayName ?? '게스트').characters.first,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? '게스트',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? '로그인이 필요합니다',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    projectsAsync.when(
                      data: (projects) => Text(
                        '${projects.length}개의 프로젝트에 연결되어 있습니다.',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => Text(
                        '프로젝트 정보를 불러오지 못했습니다.',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FlowSectionHeader(title: '내 활동'),
              const SizedBox(height: 12),
              FlowCard(
                child: Column(
                  children: [
                    _MenuItem(
                      icon: Icons.history_rounded,
                      title: '방문 기록',
                      subtitle: '성지순례 기록을 확인합니다',
                      onTap: () => context.push('/profile/visits'),
                    ),
                    const Divider(),
                    _MenuItem(
                      icon: Icons.favorite_rounded,
                      title: '즐겨찾기',
                      subtitle: '관심 있는 장소와 라이브를 확인합니다',
                      onTap: () => context.push('/favorites'),
                    ),
                    const Divider(),
                    _MenuItem(
                      icon: Icons.photo_library_rounded,
                      title: '내 업로드',
                      subtitle: '올려둔 사진과 자료를 관리합니다',
                      onTap: () => context.push('/uploads/my'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FlowSectionHeader(title: '설정과 도구'),
              const SizedBox(height: 12),
              FlowCard(
                child: Column(
                  children: [
                    _MenuItem(
                      icon: Icons.notifications_active_outlined,
                      title: '알림 센터',
                      subtitle: '중요한 알림과 소식을 확인합니다',
                      onTap: () => context.push('/notifications'),
                    ),
                    const Divider(),
                    _MenuItem(
                      icon: Icons.settings,
                      title: '환경설정',
                      subtitle: '앱 테마 및 계정 설정을 변경합니다',
                      onTap: () => context.push('/settings'),
                    ),
                    const Divider(),
                    _MenuItem(
                      icon: Icons.help_outline_rounded,
                      title: '도움말',
                      subtitle: '가이드와 자주 묻는 질문',
                      onTap: () => context.push('/help'),
                    ),
                  ],
                ),
              ),
              if (isAdmin) ...[
                const SizedBox(height: 24),
                FlowSectionHeader(title: '관리자 도구'),
                const SizedBox(height: 12),
                FlowCard(
                  child: Column(
                    children: [
                      _MenuItem(
                        icon: Icons.dashboard_customize_rounded,
                        title: '관리자 대시보드',
                        subtitle: '운영 현황과 통계를 확인합니다',
                        onTap: () => context.push('/admin'),
                      ),
                      const Divider(),
                      _MenuItem(
                        icon: Icons.people_alt_rounded,
                        title: '사용자 관리',
                        subtitle: '회원 및 권한을 관리합니다',
                        onTap: () => context.push('/admin/users'),
                      ),
                      const Divider(),
                      _MenuItem(
                        icon: Icons.file_download_rounded,
                        title: '데이터 내보내기',
                        subtitle: 'CSV 등으로 데이터 추출',
                        onTap: () => context.push('/admin/exports'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
