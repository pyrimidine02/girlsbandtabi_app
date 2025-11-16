import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/content_filter_provider.dart';
import '../../services/admin_service.dart';
import '../../services/news_service.dart';
import '../../services/upload_link_service.dart';
import '../../services/band_service.dart';
import '../../services/project_service.dart';
import '../../models/news_model.dart';
import '../../models/band_model.dart';
import '../../models/project_model.dart';

class NewsAdminScreen extends ConsumerStatefulWidget {
  const NewsAdminScreen({super.key});

  @override
  ConsumerState<NewsAdminScreen> createState() => _NewsAdminScreenState();
}

class _NewsAdminScreenState extends ConsumerState<NewsAdminScreen> {
  final _svc = NewsService();
  Future<PageResponse<News>>? _future;
  final _linkSvc = UploadLinkService();
  final _adminSvc = AdminService();
  final _bandSvc = BandService();
  final _projectService = ProjectService();
  String? _currentProject;
  ProviderSubscription<String?>? _projectSub;
  List<BandUnit> _availableUnits = const [];
  List<Project> _projects = const [];
  bool _projectLoading = true;
  String? _projectError;

  @override
  void initState() {
    super.initState();
    _currentProject = ref.read(selectedProjectProvider);
    _future = Future.value(
      PageResponse<News>(items: const [], page: 0, size: 0, total: 0),
    );
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

  Future<PageResponse<News>> _load(String? project) async {
    final target = project;
    if (target == null || target.isEmpty) {
      return PageResponse(items: const [], page: 0, size: 0, total: 0);
    }
    final response = await _svc.getNewsList(
      projectCode: target,
      page: 0,
      size: 50,
      sort: 'publishedAt,desc',
    );
    final units = await _bandSvc.getBands(
      target,
      page: 0,
      size: 100,
      sort: 'displayName,asc',
    );
    if (mounted) {
      setState(() {
        _availableUnits = units;
      });
    }
    return response;
  }

  void _reload() {
    setState(() {
      _future = _load(_currentProject);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('뉴스 관리')),
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
                  : FutureBuilder<PageResponse<News>>(
                      future: _future,
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final page = snap.data;
                        final items = page?.items ?? [];
                        if (items.isEmpty) {
                          return const Center(child: Text('데이터가 없습니다.'));
                        }
                        return RefreshIndicator(
                          onRefresh: () async => _reload(),
                          child: ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final n = items[i];
                              return ListTile(
                                leading: const Icon(Icons.article_outlined),
                                title: Text(n.title),
                                subtitle: Text(n.publishedAt?.toIso8601String().substring(0, 10) ?? ''),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (v) async {
                                    final project = _currentProject!;
                                    if (v == 'edit') {
                                      await _openEditor(context, project, n);
                                      _reload();
                                    } else if (v == 'delete') {
                                      await _svc.deleteNews(projectCode: project, newsId: n.id);
                                      _reload();
                                    } else if (v == 'image') {
                                      final id = await _askUploadId(context);
                                      if (id != null && id.isNotEmpty) {
                                        try {
                                          await _linkSvc.attachNewsImage(
                                            projectId: project,
                                            newsId: n.id,
                                            uploadId: id,
                                          );
                                        } catch (_) {}
                                        _reload();
                                      }
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(value: 'edit', child: Text('수정')),
                                    PopupMenuItem(value: 'delete', child: Text('삭제')),
                                    PopupMenuItem(value: 'image', child: Text('이미지 연결')),
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
                final project = _currentProject!;
                await _openEditor(context, project, null);
                _reload();
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  Future<String?> _askUploadId(BuildContext context) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('업로드 ID 입력'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'uploadId')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('연결')),
        ],
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, String projectId, News? current) async {
    final title = TextEditingController(text: current?.title ?? '');
    final body = TextEditingController(text: current?.body ?? '');
    String status = current != null ? current.status.name.toUpperCase() : 'PUBLISHED';
    final selectedUnits = <String>{};
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(current == null ? '뉴스 추가' : '뉴스 수정'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: '제목')),
              const SizedBox(height: 8),
              TextField(
                controller: body,
                decoration: const InputDecoration(labelText: '본문'),
                maxLines: 6,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: '상태'),
                items: const [
                  DropdownMenuItem(value: 'PUBLISHED', child: Text('PUBLISHED')),
                  DropdownMenuItem(value: 'DRAFT', child: Text('DRAFT')),
                ],
                onChanged: (value) => status = value ?? status,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '연결 유닛 (선택)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableUnits.isEmpty
                    ? [
                        const Text(
                          '등록된 유닛이 없습니다.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ]
                    : _availableUnits
                        .map(
                          (unit) => FilterChip(
                            label: Text(unit.displayName),
                            selected: selectedUnits.contains(unit.id),
                            onSelected: (value) {
                              setState(() {
                                if (value) {
                                  selectedUnits.add(unit.id);
                                } else {
                                  selectedUnits.remove(unit.id);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              try {
                final parsed = selectedUnits.toList();
                if (current == null) {
                  final created = await _svc.createNews(
                    projectCode: projectId,
                    title: title.text,
                    body: body.text,
                    unitIds: parsed.isEmpty ? null : parsed,
                  );
                  if (parsed.isNotEmpty) {
                    await _adminSvc.replaceNewsUnits(
                      projectId: projectId,
                      newsId: created.id,
                      unitIds: parsed,
                    );
                  }
                } else {
                  await _svc.updateNews(
                    projectCode: projectId,
                    newsId: current.id,
                    title: title.text,
                    body: body.text,
                    status: status,
                    unitIds: parsed.isEmpty ? null : parsed,
                  );
                  if (parsed.isNotEmpty) {
                    await _adminSvc.replaceNewsUnits(
                      projectId: projectId,
                      newsId: current.id,
                      unitIds: parsed,
                    );
                  }
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
