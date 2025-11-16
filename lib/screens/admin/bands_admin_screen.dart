import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/content_filter_provider.dart';
import '../../services/band_service.dart';
import '../../services/project_service.dart';
import '../../models/band_model.dart';
import '../../models/project_model.dart';

class BandsAdminScreen extends ConsumerStatefulWidget {
  const BandsAdminScreen({super.key});

  @override
  ConsumerState<BandsAdminScreen> createState() => _BandsAdminScreenState();
}

class _BandsAdminScreenState extends ConsumerState<BandsAdminScreen> {
  final _svc = BandService();
  final _projectService = ProjectService();
  Future<List<BandUnit>>? _future;
  String? _currentProject;
  ProviderSubscription<String?>? _projectSub;
  List<Project> _projects = const [];
  bool _projectLoading = true;
  String? _projectError;

  @override
  void initState() {
    super.initState();
    _currentProject = ref.read(selectedProjectProvider);
    _future = Future.value(const []);
    _projectSub = ref.listenManual<String?>(selectedProjectProvider,
        (previous, next) {
      if (_currentProject == next) return;
      setState(() {
        _currentProject = next;
        _future = _load(next);
      });
    });
    _loadProjects();
  }

  @override
  void dispose() {
    _projectSub?.close();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _projectLoading = true;
      _projectError = null;
    });
    try {
      final projects = await _projectService.getProjects(
        page: 0,
        size: 100,
        sort: 'name,asc',
      ).then((res) => res.items);
      setState(() {
        _projects = projects;
        _projectLoading = false;
      });
      final initial =
          _currentProject ?? (projects.isNotEmpty ? projects.first.code : null);
      if (initial != null && initial.isNotEmpty) {
        _selectProject(initial);
      }
    } catch (e) {
      setState(() {
        _projectLoading = false;
        _projectError = e.toString();
      });
    }
  }

  void _selectProject(String projectCode) {
    if (_currentProject == projectCode) return;
    setState(() {
      _currentProject = projectCode;
      _future = _load(projectCode);
    });
    ref.read(selectedProjectProvider.notifier).state = projectCode;
  }

  Future<List<BandUnit>> _load(String? project) async {
    final target = project;
    if (target == null || target.isEmpty) {
      return [];
    }
    return _svc.getBands(target, page: 0, size: 100, sort: 'displayName,asc');
  }

  void _reload() {
    setState(() {
      _future = _load(_currentProject);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('밴드 관리')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '프로젝트',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  tooltip: '프로젝트 새로고침',
                  onPressed: _projectLoading ? null : _loadProjects,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_projectLoading)
              const Center(child: CircularProgressIndicator()),
            if (_projectError != null)
              Text(_projectError!, style: const TextStyle(color: Colors.red)),
            if (!_projectLoading && _projects.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _projects
                      .map(
                        (p) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text('${p.name} (${p.code})'),
                            selected: _currentProject == p.code,
                            onSelected: (_) => _selectProject(p.code),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: _currentProject == null
                  ? const Center(child: Text('프로젝트를 선택하세요.'))
                  : FutureBuilder<List<BandUnit>>(
                      future: _future,
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final items = snap.data ?? [];
                        if (items.isEmpty) {
                          return const Center(child: Text('데이터가 없습니다.'));
                        }
                        return RefreshIndicator(
                          onRefresh: () async => _reload(),
                          child: ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final b = items[i];
                              return ListTile(
                                leading: const Icon(Icons.queue_music_outlined),
                                title: Text(b.displayName),
                                subtitle: Text('코드: ${b.code}'),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (v) async {
                                    final project = _currentProject!;
                                    if (v == 'edit') {
                                      await _openEditor(context, b);
                                      _reload();
                                    } else if (v == 'delete') {
                                      await _svc.deleteBand(project, b.code);
                                      _reload();
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(value: 'edit', child: Text('수정')),
                                    PopupMenuItem(value: 'delete', child: Text('삭제')),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _currentProject == null
          ? null
          : FloatingActionButton(
              onPressed: () async {
                await _openEditor(context, null);
                _reload();
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  Future<void> _openEditor(BuildContext context, BandUnit? current) async {
    final code = TextEditingController(text: current?.code ?? '');
    final name = TextEditingController(text: current?.displayName ?? '');
    final project = _currentProject;
    if (project == null || project.isEmpty) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(current == null ? '밴드 추가' : '밴드 수정'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: code, decoration: const InputDecoration(labelText: '코드'), enabled: current == null),
              const SizedBox(height: 8),
              TextField(controller: name, decoration: const InputDecoration(labelText: '이름')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              try {
                if (current == null) {
                  await _svc.createBand(project, code: code.text, displayName: name.text);
                } else {
                  await _svc.updateBand(project, current.code, displayName: name.text);
                }
              } catch (_) {}
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
