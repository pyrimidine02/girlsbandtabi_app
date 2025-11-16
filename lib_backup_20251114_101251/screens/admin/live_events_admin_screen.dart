import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/content_filter_provider.dart';
import '../../services/live_event_service.dart';
import '../../services/upload_link_service.dart';
import '../../services/admin_service.dart';
import '../../services/band_service.dart';
import '../../services/place_service.dart';
import '../../services/project_service.dart';
import '../../models/live_event_model.dart';
import '../../models/band_model.dart';
import '../../models/place_model.dart' as model;
import '../../models/project_model.dart';

class LiveEventsAdminScreen extends ConsumerStatefulWidget {
  const LiveEventsAdminScreen({super.key});

  @override
  ConsumerState<LiveEventsAdminScreen> createState() => _LiveEventsAdminScreenState();
}

class _LiveEventsAdminScreenState extends ConsumerState<LiveEventsAdminScreen> {
  final _svc = LiveEventService();
  Future<PageResponseLiveEvent>? _future;
  final _linkSvc = UploadLinkService();
  final _adminSvc = AdminService();
  final _bandSvc = BandService();
  final _placeSvc = PlaceService();
  final _projectSvc = ProjectService();
  String? _currentProject;
  ProviderSubscription<String?>? _projectSub;
  List<BandUnit> _availableUnits = const [];
  List<model.PlaceSummary> _availablePlaces = const [];
  List<Project> _projects = const [];
  bool _projectLoading = true;
  String? _projectError;

  @override
  void initState() {
    super.initState();
    _currentProject = ref.read(selectedProjectProvider);
    _future = Future.value(
      PageResponseLiveEvent(items: const [], page: 0, size: 0, total: 0),
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
      final projects = await _projectSvc.getProjects(
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

  Future<PageResponseLiveEvent> _load(String? projectId) async {
    final target = projectId;
    if (target == null || target.isEmpty) {
      return PageResponseLiveEvent(items: const [], page: 0, size: 0, total: 0);
    }
    final response = await _svc.getLiveEvents(
      projectId: target,
      page: 0,
      size: 100,
      sort: 'startTime,desc',
    );
    final units = await _bandSvc.getBands(target, page: 0, size: 100, sort: 'displayName,asc');
    final placesPage = await _placeSvc.getPlaces(
      projectId: target,
      page: 0,
      size: 100,
      sort: 'name,asc',
    );
    if (mounted) {
      setState(() {
        _availableUnits = units;
        _availablePlaces = placesPage.places;
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
      appBar: AppBar(title: const Text('라이브 관리')),
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
                  : FutureBuilder<PageResponseLiveEvent>(
                      future: _future,
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final items = snap.data?.items ?? [];
                        if (items.isEmpty) {
                          return const Center(child: Text('데이터가 없습니다.'));
                        }
                        return RefreshIndicator(
                          onRefresh: () async => _reload(),
                          child: ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final e = items[i];
                              return ListTile(
                                leading: const Icon(Icons.event_available_outlined),
                                title: Text(e.title),
                                subtitle: Text(e.startTime.toIso8601String().substring(0, 16)),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (v) async {
                                    final project = _currentProject!;
                                    if (v == 'edit') {
                                      await _openEditor(context, project, e);
                                      _reload();
                                    } else if (v == 'delete') {
                                      await _svc.deleteLiveEvent(
                                        projectId: project,
                                        eventId: e.id,
                                      );
                                      _reload();
                                    } else if (v == 'banner') {
                                      final id = await _askUploadId(context);
                                      if (id != null && id.isNotEmpty) {
                                        try {
                                          await _linkSvc.attachLiveBanner(
                                            projectId: project,
                                            liveEventId: e.id,
                                            uploadId: id,
                                          );
                                        } catch (_) {}
                                        _reload();
                                      }
                                    } else if (v == 'units') {
                                      await _openUnitDialog(context, project, e.id);
                                      _reload();
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(value: 'edit', child: Text('수정')),
                                    PopupMenuItem(value: 'delete', child: Text('삭제')),
                                    PopupMenuItem(value: 'banner', child: Text('배너 연결')),
                                    PopupMenuItem(value: 'units', child: Text('유닛 연결')),
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

  Future<void> _openEditor(BuildContext context, String projectId, LiveEvent? current) async {
    final title = TextEditingController(text: current?.title ?? '');
    final description = TextEditingController(text: current?.description ?? '');
    final start = TextEditingController(
      text: current?.startTime.toIso8601String() ?? DateTime.now().toIso8601String(),
    );
    final end = TextEditingController(text: current?.endTime?.toIso8601String() ?? '');
    String status = current?.status ?? 'UPCOMING';
    final selectedUnits = <String>{};
    String? selectedPlaceId = current?.placeId;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(current == null ? '라이브 추가' : '라이브 수정'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: '제목')),
              const SizedBox(height: 8),
              TextField(
                controller: description,
                decoration: const InputDecoration(labelText: '설명 (선택)'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              TextField(controller: start, decoration: const InputDecoration(labelText: '시작시각(ISO8601)')),
              const SizedBox(height: 8),
              TextField(controller: end, decoration: const InputDecoration(labelText: '종료시각(ISO8601, 선택)')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: status,
                items: const [
                  DropdownMenuItem(value: 'UPCOMING', child: Text('UPCOMING')),
                  DropdownMenuItem(value: 'ONGOING', child: Text('ONGOING')),
                  DropdownMenuItem(value: 'COMPLETED', child: Text('COMPLETED')),
                ],
                decoration: const InputDecoration(labelText: '상태'),
                onChanged: (value) => status = value ?? status,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: selectedPlaceId,
                decoration: const InputDecoration(labelText: '연결 성지(선택)'),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('선택 안 함')),
                  ..._availablePlaces.map(
                    (place) => DropdownMenuItem<String?>(
                      value: place.id,
                      child: Text(place.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() => selectedPlaceId = value);
                },
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
                        const Text('등록된 유닛이 없습니다.',
                            style: TextStyle(color: Colors.grey)),
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
                  final created = await _svc.createLiveEvent(
                    projectId: projectId,
                    title: title.text,
                    startTime: DateTime.parse(start.text),
                    endTime: end.text.isEmpty ? null : DateTime.parse(end.text),
                    unitIds: parsed.isEmpty ? null : parsed,
                    description: description.text.isEmpty ? null : description.text,
                    placeId: selectedPlaceId,
                  );
                  if (parsed.isNotEmpty) {
                    await _adminSvc.replaceLiveEventUnits(
                      projectId: projectId,
                      liveEventId: created.id,
                      unitIds: parsed,
                    );
                  }
                } else {
                  await _svc.updateLiveEvent(
                    projectId: projectId,
                    eventId: current.id,
                    title: title.text,
                    startTime: DateTime.tryParse(start.text),
                    endTime: end.text.isEmpty ? null : DateTime.tryParse(end.text),
                    unitIds: parsed.isEmpty ? null : parsed,
                    description: description.text.isEmpty ? null : description.text,
                    placeId: selectedPlaceId,
                    status: status,
                  );
                  if (parsed.isNotEmpty) {
                    await _adminSvc.replaceLiveEventUnits(
                      projectId: projectId,
                      liveEventId: current.id,
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

  Future<void> _openUnitDialog(BuildContext context, String projectId, String liveEventId) async {
    final selected = <String>{};
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('유닛 연결'),
        content: SizedBox(
          width: 420,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableUnits.isEmpty
                ? [
                    const Text('등록된 유닛이 없습니다.',
                        style: TextStyle(color: Colors.grey)),
                  ]
                : _availableUnits
                    .map(
                      (unit) => FilterChip(
                        label: Text(unit.displayName),
                        selected: selected.contains(unit.id),
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              selected.add(unit.id);
                            } else {
                              selected.remove(unit.id);
                            }
                          });
                        },
                      ),
                    )
                    .toList(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              final parsed = selected.toList();
              if (parsed.isNotEmpty) {
                await _adminSvc.replaceLiveEventUnits(
                  projectId: projectId,
                  liveEventId: liveEventId,
                  unitIds: parsed,
                );
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
