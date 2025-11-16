import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/content_filter_provider.dart';
import '../../providers/role_provider.dart';
import '../../services/admin_service.dart';
import '../../services/user_service.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final _admin = AdminService();
  final _user = UserService();
  final _placeIdController = TextEditingController();

  Map<String, dynamic>? _health;
  Map<String, dynamic>? _info;
  Map<String, dynamic>? _dashboard;
  List<dynamic> _insightsProjects = const [];
  List<dynamic> _insightsUnits = const [];
  bool _loading = true;
  bool _insightsLoading = false;
  String? _error;
  ProviderSubscription<String?>? _projectSub;

  @override
  void initState() {
    super.initState();
    _load();
    _projectSub = ref.listenManual<String?>(selectedProjectProvider,
        (previous, next) {
      _loadUnitInsights();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUnitInsights());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final h = await _admin.getHealth();
    final i = await _admin.getInfo();
    Map<String, dynamic>? dashboard;
    List<dynamic> projects = const [];
    try {
      dashboard = await _admin.getDashboard();
    } catch (_) {
      dashboard = null;
    }
    try {
      projects = await _admin.getInsightsProjects();
    } catch (_) {
      projects = const [];
    }
    setState(() {
      _health = h;
      _info = i;
      _dashboard = dashboard;
      _insightsProjects = projects;
      _loading = false;
    });
  }

  Future<void> _loadUnitInsights() async {
    final project = ref.read(selectedProjectProvider);
    if (project == null || project.isEmpty) {
      setState(() {
        _insightsUnits = const [];
        _error = '프로젝트를 선택하세요.';
      });
      return;
    }
    setState(() {
      _insightsLoading = true;
      _error = null;
    });
    try {
      final units = await _admin.getInsightsProjectUnits(project);
      setState(() {
        _insightsUnits = units;
        _insightsLoading = false;
      });
    } catch (e) {
      setState(() {
        _insightsLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _placeIdController.dispose();
    _projectSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(userRoleProvider);
    final isAdmin = roleAsync.maybeWhen(
      data: (r) => r == 'ADMIN' || r == 'ProjectAdmin' || r == 'MODERATOR',
      orElse: () => false,
    );
    if (!isAdmin) {
      return const Scaffold(body: Center(child: Text('접근 권한이 없습니다.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('관리자 대시보드')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Quick links
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
            _AdminQuickButton(
              icon: Icons.place_outlined,
              label: '성지 관리',
              onTap: () => context.push('/admin/places'),
            ),
                _AdminQuickButton(
                  icon: Icons.folder_copy_outlined,
                  label: '프로젝트 관리',
                  onTap: () => context.push('/admin/projects'),
                ),
                _AdminQuickButton(
                  icon: Icons.library_books_outlined,
                  label: '뉴스 관리',
                  onTap: () => context.push('/admin/news'),
                ),
                _AdminQuickButton(
                  icon: Icons.queue_music_outlined,
                  label: '밴드 관리',
                  onTap: () => context.push('/admin/bands'),
                ),
                _AdminQuickButton(
                  icon: Icons.event_available_outlined,
                  label: '라이브 관리',
                  onTap: () => context.push('/admin/live-events'),
                ),
            _AdminQuickButton(
              icon: Icons.manage_accounts_outlined,
              label: '역할 관리',
              onTap: () => context.push('/admin/roles'),
            ),
            _AdminQuickButton(
              icon: Icons.analytics_outlined,
              label: '방문 통계',
              onTap: () => context.push('/admin/analytics'),
            ),
            _AdminQuickButton(
              icon: Icons.delete_sweep_outlined,
              label: '미디어 삭제',
              onTap: () => context.push('/admin/media-deletions'),
            ),
            _AdminQuickButton(
              icon: Icons.file_download_outlined,
              label: '데이터 내보내기',
              onTap: () => context.push('/admin/exports'),
            ),
            _AdminQuickButton(
              icon: Icons.vpn_key_outlined,
              label: '토큰 폐기',
              onTap: () => context.push('/admin/tokens'),
            ),
            _AdminQuickButton(
              icon: Icons.people_outline,
              label: '사용자 관리',
              onTap: () => context.push('/admin/users'),
            ),
            _AdminQuickButton(
              icon: Icons.list_alt_outlined,
              label: '감사 로그',
              onTap: () => context.push('/admin/audit-logs'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Service health/info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('서비스 상태', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    if (_loading) const Center(child: CircularProgressIndicator()),
                    if (!_loading) ...[
                      Text('Health: ${_health?['status'] ?? '데이터가 없습니다.'}'),
                      const SizedBox(height: 6),
                      Text('Info: ${_info != null ? '로드됨' : '데이터가 없습니다.'}'),
                    ],
                  ],
                ),
            ),
          ),

          const SizedBox(height: 12),
          if (_dashboard != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('핵심 지표', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _dashboard!.entries
                          .map(
                            (entry) => _DashboardMetricCard(
                              title: entry.key,
                              value: entry.value,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

          if (_insightsProjects.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('프로젝트 인사이트', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    ..._insightsProjects.whereType<Map<String, dynamic>>().map(
                      (item) => ListTile(
                        leading: const Icon(Icons.bar_chart),
                        title: Text(item['projectName']?.toString() ?? item['projectId']?.toString() ?? '프로젝트'),
                        subtitle: Text('방문: ${item['visits'] ?? '-'} • 라이브: ${item['liveEvents'] ?? '-'} • 성지: ${item['places'] ?? '-'}'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('선택된 프로젝트 인사이트', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Text('오류: $_error', style: const TextStyle(color: Colors.red)),
                  if (_insightsLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_insightsUnits.isEmpty)
                    const Text('데이터가 없습니다.')
                  else
                    ..._insightsUnits.whereType<Map<String, dynamic>>().map(
                      (item) => ListTile(
                        leading: const Icon(Icons.queue_music_outlined),
                        title: Text(item['unitName']?.toString() ?? item['unitId']?.toString() ?? '유닛'),
                        subtitle: Text('방문: ${item['visits'] ?? '-'} • 라이브: ${item['liveEvents'] ?? '-'}'),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          // Visit records (example)
          Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('장소별 방문 기록 간단 조회', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _placeIdController,
                      decoration: const InputDecoration(
                        labelText: 'Place ID 입력',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: () async {
                          if (_placeIdController.text.trim().isEmpty) return;
                          try {
                            final summary = await _user.getVisitSummary(_placeIdController.text.trim());
                            if (!context.mounted) return;
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('방문 요약'),
                                content: Text('최근 방문: ${summary.lastVisit?.toIso8601String().substring(0,10) ?? '-'}\n총 방문: ${summary.totalVisits}\n내 방문: ${summary.userVisits}'),
                                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기'))],
                              ),
                            );
                          } catch (_) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('데이터가 없습니다.')));
                          }
                        },
                        child: const Text('조회'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            // My recent visits (as example list)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('내 최근 방문(예시)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    FutureBuilder(
                      future: _user.getMyVisits(page: 0, size: 5),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final items = snapshot.data ?? [];
                        if (items.isEmpty) return const Text('데이터가 없습니다.');
                        return Column(
                          children: items
                              .map((v) => ListTile(
                                    leading: const Icon(Icons.place_outlined),
                                    title: Text(v.place.name),
                                    subtitle: Text(v.visitDate.toIso8601String().substring(0, 10)),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardMetricCard extends StatelessWidget {
  final String title;
  final dynamic value;
  const _DashboardMetricCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            value?.toString() ?? '-',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _AdminQuickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AdminQuickButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.08)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}
