import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/content_filter_provider.dart';
import '../../core/constants/api_constants.dart';
import '../../models/place_model.dart' as model;
import '../../models/band_model.dart';
import '../../models/project_model.dart';
import '../../services/admin_service.dart';
import '../../services/place_service.dart';
import '../../services/upload_link_service.dart';
import '../../services/band_service.dart';
import '../../services/project_service.dart';

class PlacesAdminScreen extends ConsumerStatefulWidget {
  const PlacesAdminScreen({super.key});

  @override
  ConsumerState<PlacesAdminScreen> createState() => _PlacesAdminScreenState();
}

class _PlacesAdminScreenState extends ConsumerState<PlacesAdminScreen> {
  final _service = PlaceService();
  final _linkService = UploadLinkService();
  final _adminService = AdminService();
  final _bandService = BandService();
  final _projectService = ProjectService();

  Future<List<model.PlaceSummary>> _future =
      Future<List<model.PlaceSummary>>.value(const <model.PlaceSummary>[]);
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
    if (_currentProject != null && _currentProject!.isNotEmpty) {
      _future = _load(_currentProject);
    }
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
    setState(() {
      _currentProject = projectCode;
      _future = _load(projectCode);
    });
    ref.read(selectedProjectProvider.notifier).state = projectCode;
  }

  Future<List<model.PlaceSummary>> _load(String? projectId) async {
    final targetProject = projectId ?? ApiConstants.defaultProjectId;
    try {
      final page = await _service.getPlaces(
        projectId: targetProject,
        page: 0,
        size: 50,
        sort: 'createdAt,desc',
      );
      final units = await _bandService.getBands(
        targetProject,
        page: 0,
        size: 100,
        sort: 'displayName,asc',
      );
      if (mounted) {
        setState(() {
          _availableUnits = units;
        });
      }
      return page.places;
    } catch (_) {
      return [];
    }
  }

  void _refresh() {
    if (_currentProject == null || _currentProject!.isEmpty) {
      return;
    }
    setState(() {
      _future = _load(_currentProject);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('성지 관리')),
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
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _projectError!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
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
                  : FutureBuilder<List<model.PlaceSummary>>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final items = snapshot.data ?? [];
                        if (items.isEmpty) {
                          return const Center(child: Text('데이터가 없습니다.'));
                        }
                        return RefreshIndicator(
                          onRefresh: () async => _refresh(),
                          child: ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final p = items[index];
                              return ListTile(
                                leading: const Icon(Icons.place_outlined),
                                title: Text(p.name),
                                subtitle: Text(
                                  '${p.type} • ${p.latitude.toStringAsFixed(4)}, ${p.longitude.toStringAsFixed(4)}',
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (v) async {
                                    final project = _currentProject!;
                                    if (v == 'edit') {
                                      await _openEditDialog(context, p.id);
                                      _refresh();
                                    } else if (v == 'delete') {
                                      final ok = await _confirmDelete(context);
                                      if (ok == true) {
                                        try {
                                          await _service.deletePlace(
                                            projectId: project,
                                            placeId: p.id,
                                          );
                                        } catch (_) {}
                                        _refresh();
                                      }
                                    } else if (v == 'image') {
                                      final uploadId = await _askUploadId(context);
                                      if (uploadId != null && uploadId.isNotEmpty) {
                                        try {
                                          await _linkService.attachPlaceImage(
                                            projectId: project,
                                            placeId: p.id,
                                            uploadId: uploadId,
                                            isPrimary: true,
                                          );
                                        } catch (_) {}
                                        _refresh();
                                      }
                                    } else if (v == 'units') {
                                      await _openUnitDialog(context, p.id, project);
                                      _refresh();
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(value: 'edit', child: Text('수정')),
                                    PopupMenuItem(value: 'delete', child: Text('삭제')),
                                    PopupMenuItem(value: 'image', child: Text('대표 이미지 연결')),
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
                await _openCreateDialog(context, project);
                _refresh();
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

  Future<void> _openCreateDialog(BuildContext context, String projectId) async {
    final res = await showDialog<_PlaceFormResult>(
      context: context,
      builder: (_) => _PlaceFormDialog(
        availableUnits: _availableUnits,
        selectedUnitIds: const [],
      ),
    );
    if (res != null) {
      try {
        final created = await _service.createPlace(
          projectId: projectId,
          request: model.PlaceCreateRequest(
            name: res.name,
            description: res.description,
            latitude: res.lat,
            longitude: res.lon,
            type: res.type,
            address: res.address,
          ),
        );
        if (res.unitIds.isNotEmpty) {
          await _adminService.replacePlaceUnits(
            projectId: projectId,
            placeId: created.id,
            unitIds: res.unitIds,
          );
        }
      } catch (_) {}
    }
  }

  Future<void> _openEditDialog(BuildContext context, String placeId) async {
    final project = _currentProject;
    if (project == null || project.isEmpty) return;
    final fullPlace = await _service.getPlaceDetail(projectId: project, placeId: placeId);
    final res = await showDialog<_PlaceFormResult>(
      context: context,
      builder: (_) => _PlaceFormDialog(
        availableUnits: _availableUnits,
        selectedUnitIds: const [],
        initial: _PlaceFormResult(
          name: fullPlace.name,
          description: fullPlace.description,
          lat: fullPlace.latitude,
          lon: fullPlace.longitude,
          type: fullPlace.type,
          address: fullPlace.address,
          unitIds: const [],
        ),
      ),
    );
    if (res != null) {
      try {
        await _service.updatePlace(
          projectId: _currentProject ?? ApiConstants.defaultProjectId,
          placeId: fullPlace.id,
          request: model.PlaceCreateRequest(
            name: res.name,
            description: res.description,
            latitude: res.lat,
            longitude: res.lon,
            type: res.type,
            address: res.address,
          ),
        );
        if (res.unitIds.isNotEmpty) {
          await _adminService.replacePlaceUnits(
            projectId: _currentProject ?? ApiConstants.defaultProjectId,
            placeId: fullPlace.id,
            unitIds: res.unitIds,
          );
        }
      } catch (_) {}
    }
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('삭제'),
        content: const Text('정말 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
        ],
      ),
    );
  }

  Future<void> _openUnitDialog(BuildContext context, String placeId, String projectId) async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('유닛 연결'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: '유닛 ID 목록',
            helperText: '쉼표로 구분하여 입력 (예: unit-a,unit-b)',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              final parsed = ctrl.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              if (parsed.isNotEmpty) {
                await _adminService.replacePlaceUnits(
                  projectId: projectId,
                  placeId: placeId,
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

class _PlaceFormDialog extends StatefulWidget {
  final _PlaceFormResult? initial;
  final List<BandUnit> availableUnits;
  final List<String> selectedUnitIds;
  const _PlaceFormDialog({
    this.initial,
    required this.availableUnits,
    required this.selectedUnitIds,
  });

  @override
  State<_PlaceFormDialog> createState() => _PlaceFormDialogState();
}

class _PlaceFormDialogState extends State<_PlaceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _desc;
  late TextEditingController _lat;
  late TextEditingController _lon;
  late TextEditingController _addr;
  model.PlaceType _type = model.PlaceType.concertVenue;
  late Set<String> _selectedUnitIds;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initial?.name ?? '');
    _desc = TextEditingController(text: widget.initial?.description ?? '');
    _lat = TextEditingController(text: widget.initial?.lat.toString() ?? '');
    _lon = TextEditingController(text: widget.initial?.lon.toString() ?? '');
    _addr = TextEditingController(text: widget.initial?.address ?? '');
    _type = widget.initial?.type ?? model.PlaceType.concertVenue;
    _selectedUnitIds = {...widget.selectedUnitIds};
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _lat.dispose();
    _lon.dispose();
    _addr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? '성지 추가' : '성지 수정'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: '이름'),
                validator: (v) => v == null || v.isEmpty ? '필수' : null,
              ),
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(labelText: '설명'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _lat,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                      decoration: const InputDecoration(labelText: '위도'),
                      validator: (v) => v == null || double.tryParse(v) == null ? '숫자' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _lon,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                      decoration: const InputDecoration(labelText: '경도'),
                      validator: (v) => v == null || double.tryParse(v) == null ? '숫자' : null,
                    ),
                  ),
                ],
              ),
              DropdownButtonFormField<model.PlaceType>(
                initialValue: _type,
                items: model.PlaceType.values
                    .map((e) => DropdownMenuItem(value: e, child: Text(e.toString().split('.').last)))
                    .toList(),
                onChanged: (v) => setState(() => _type = v ?? _type),
                decoration: const InputDecoration(labelText: '유형'),
              ),
              TextFormField(
                controller: _addr,
                decoration: const InputDecoration(labelText: '주소'),
              ),
              const SizedBox(height: 12),
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
                children: widget.availableUnits.isEmpty
                    ? [
                        const Text('등록된 유닛이 없습니다.',
                            style: TextStyle(color: Colors.grey)),
                      ]
                    : widget.availableUnits
                        .map(
                          (unit) => FilterChip(
                            label: Text(unit.displayName),
                            selected: _selectedUnitIds.contains(unit.id),
                            onSelected: (value) {
                              setState(() {
                                if (value) {
                                  _selectedUnitIds.add(unit.id);
                                } else {
                                  _selectedUnitIds.remove(unit.id);
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
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) return;
            final res = _PlaceFormResult(
              name: _name.text,
              description: _desc.text,
              lat: double.parse(_lat.text),
              lon: double.parse(_lon.text),
              type: _type,
              address: _addr.text.isEmpty ? null : _addr.text,
              unitIds: _selectedUnitIds.toList(),
            );
            Navigator.pop(context, res);
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}

class _PlaceFormResult {
  final String name;
  final String description;
  final double lat;
  final double lon;
  final model.PlaceType type;
  final String? address;
  final List<String> unitIds;
  _PlaceFormResult({
    required this.name,
    required this.description,
    required this.lat,
    required this.lon,
    required this.type,
    this.address,
    this.unitIds = const [],
  });
}
