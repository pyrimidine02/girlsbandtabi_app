import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/project_service.dart';
import '../../models/project_model.dart';

class ProjectsAdminScreen extends ConsumerStatefulWidget {
  const ProjectsAdminScreen({super.key});

  @override
  ConsumerState<ProjectsAdminScreen> createState() => _ProjectsAdminScreenState();
}

class _ProjectsAdminScreenState extends ConsumerState<ProjectsAdminScreen> {
  final _svc = ProjectService();
  Future<List<Project>>? _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _svc.getProjects(page: 0, size: 100, sort: 'name,asc').then((res) => res.items);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('프로젝트 관리')),
      body: FutureBuilder<List<Project>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) return const Center(child: Text('데이터가 없습니다.'));
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final p = items[i];
                return ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(p.name),
                  subtitle: Text('${p.code} • ${p.status}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        await _openEditor(context, p);
                        _reload();
                      } else if (v == 'delete') {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('삭제'),
                            content: Text('프로젝트 "${p.name}" 를 삭제하시겠습니까?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await _svc.deleteProject(p.id);
                          _reload();
                        }
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _openEditor(context, null);
          _reload();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, Project? current) async {
    final code = TextEditingController(text: current?.code ?? '');
    final name = TextEditingController(text: current?.name ?? '');
    String status = current?.status ?? 'ACTIVE';
    final tz = TextEditingController(text: current?.defaultTimezone ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(current == null ? '프로젝트 추가' : '프로젝트 수정'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: code, decoration: const InputDecoration(labelText: '코드'), enabled: current == null),
              const SizedBox(height: 8),
              TextField(controller: name, decoration: const InputDecoration(labelText: '이름')),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: status,
                items: const [
                  DropdownMenuItem(value: 'ACTIVE', child: Text('ACTIVE')),
                  DropdownMenuItem(value: 'INACTIVE', child: Text('INACTIVE')),
                ],
                onChanged: (v) => status = v ?? 'ACTIVE',
                decoration: const InputDecoration(labelText: '상태'),
              ),
              const SizedBox(height: 8),
              TextField(controller: tz, decoration: const InputDecoration(labelText: '기본 타임존(선택)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              try {
                if (current == null) {
                  await _svc.createProject(code: code.text, name: name.text, status: status, defaultTimezone: tz.text.isEmpty ? null : tz.text);
                } else {
                  await _svc.updateProject(projectId: current.id, code: code.text, name: name.text, status: status, defaultTimezone: tz.text.isEmpty ? null : tz.text);
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

