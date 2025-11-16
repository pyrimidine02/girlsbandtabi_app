import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/content_filter_provider.dart';
import '../providers/project_band_providers.dart';

Future<void> openProjectBandSelector(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return Consumer(builder: (context, ref, _) {
        final projectsAsync = ref.watch(projectsProvider);
        final selectedProject = ref.watch(selectedProjectProvider);
        final selectedBand = ref.watch(selectedBandProvider);
        return StatefulBuilder(builder: (context, setState) {
          String? tempProject = selectedProject;
          String? tempBand = selectedBand;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('프로젝트 선택', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.layers_outlined),
                  title: const Text('전체'),
                  trailing: tempProject == null ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      tempProject = null;
                      tempBand = null;
                    });
                  },
                ),
                projectsAsync.when(
                  data: (projects) => Column(
                    children: projects
                        .map((p) => ListTile(
                              leading: const Icon(Icons.folder_outlined),
                              title: Text(p.name),
                              subtitle: Text(p.code),
                              trailing: tempProject == p.id ? const Icon(Icons.check) : null,
                              onTap: () {
                                setState(() {
                                  tempProject = p.id;
                                  tempBand = null;
                                });
                              },
                            ))
                        .toList(),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, st) => const SizedBox.shrink(),
                ),
                if (tempProject != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Icon(Icons.queue_music_rounded, size: 18),
                      SizedBox(width: 6),
                      Text('밴드 선택', style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ref.watch(bandsProvider(tempProject!)).when(
                    data: (bands) => Column(
                      children: [
                        ListTile(
                          dense: true,
                          title: const Text('전체'),
                          trailing: tempBand == null ? const Icon(Icons.check) : null,
                          onTap: () => setState(() => tempBand = null),
                        ),
                        ...bands.map((b) => ListTile(
                              dense: true,
                              title: Text(b.name),
                              trailing: tempBand == b.id ? const Icon(Icons.check) : null,
                              onTap: () => setState(() => tempBand = b.id),
                            )),
                      ],
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    error: (e, st) => const SizedBox.shrink(),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('닫기'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        ref.read(selectedProjectProvider.notifier).state = tempProject;
                        ref.read(selectedBandProvider.notifier).state = tempBand;
                        Navigator.pop(context);
                      },
                      child: const Text('적용'),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      });
    },
  );
}
