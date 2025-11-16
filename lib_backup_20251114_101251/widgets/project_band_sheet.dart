import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/content_filter_provider.dart';
import '../providers/project_band_providers.dart';
import 'flow_components.dart';

Future<void> showProjectBandSelector(BuildContext context, WidgetRef ref, {VoidCallback? onApplied}) {
  final selectedProject = ref.read(selectedProjectProvider);
  final selectedProjectName = ref.read(selectedProjectNameProvider);
  final selectedBand = ref.read(selectedBandProvider);
  final selectedBandName = ref.read(selectedBandNameProvider);

  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return _ProjectBandSheet(
        initialProject: selectedProject,
        initialProjectName: selectedProjectName,
        initialBand: selectedBand,
        initialBandName: selectedBandName,
        onApplied: onApplied,
      );
    },
  );
}

class _ProjectBandSheet extends ConsumerStatefulWidget {
  const _ProjectBandSheet({
    this.onApplied,
    required this.initialProject,
    required this.initialProjectName,
    required this.initialBand,
    required this.initialBandName,
  });

  final String? initialProject;
  final String? initialProjectName;
  final String? initialBand;
  final String? initialBandName;
  final VoidCallback? onApplied;

  @override
  ConsumerState<_ProjectBandSheet> createState() => _ProjectBandSheetState();
}

class _ProjectBandSheetState extends ConsumerState<_ProjectBandSheet> {
  VoidCallback? get _onApplied => widget.onApplied;
  String? _tempProject;
  String? _tempProjectName;
  String? _tempBand;
  String? _tempBandName;

  @override
  void initState() {
    super.initState();
    _tempProject = widget.initialProject;
    _tempProjectName = widget.initialProjectName;
    _tempBand = widget.initialBand;
    _tempBandName = widget.initialBandName;
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final bandsAsync = _tempProject == null
        ? const AsyncData(<BandInfo>[]) as AsyncValue<List<BandInfo>>
        : ref.watch(bandsProvider(_tempProject!));

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '프로젝트 선택',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          FlowCard(
            padding: EdgeInsets.zero,
            child: projectsAsync.when(
              data: (projects) {
                final items = [
                  _ProjectItem(
                    label: '전체 프로젝트',
                    subtitle: '모든 프로젝트 데이터를 함께 봅니다',
                    isSelected: _tempProject == null,
                    onTap: () {
                      setState(() {
                        _tempProject = null;
                        _tempProjectName = null;
                        _tempBand = null;
                        _tempBandName = null;
                      });
                    },
                  ),
                  ...projects.map(
                    (project) => _ProjectItem(
                      label: project.name,
                      subtitle: '코드: ${project.code} · 상태: ${project.status}',
                      isSelected: _tempProject == project.id,
                      onTap: () {
                        setState(() {
                          _tempProject = project.id;
                          _tempProjectName = project.name;
                          _tempBand = null;
                          _tempBandName = null;
                        });
                      },
                    ),
                  ),
                ];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < items.length; i++) ...[
                      items[i],
                      if (i != items.length - 1)
                        const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                    ],
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline),
                    const SizedBox(height: 12),
                    Text('프로젝트 정보를 불러오지 못했습니다. $e'),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '밴드 선택',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          FlowCard(
            padding: EdgeInsets.zero,
            child: _tempProject == null
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('프로젝트를 먼저 선택해주세요.'),
                  )
                : bandsAsync.when(
                    data: (bands) {
                      final items = [
                        _ProjectItem(
                          label: '전체 밴드',
                          subtitle: '선택한 프로젝트의 모든 밴드',
                          isSelected: _tempBand == null,
                          onTap: () {
                            setState(() {
                              _tempBand = null;
                              _tempBandName = null;
                            });
                          },
                        ),
                        ...bands.map(
                          (band) => _ProjectItem(
                            label: band.name,
                            subtitle: '밴드 ID: ${band.id}',
                            isSelected: _tempBand == band.id,
                            onTap: () {
                              setState(() {
                                _tempBand = band.id;
                                _tempBandName = band.name;
                              });
                            },
                          ),
                        ),
                      ];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0; i < items.length; i++) ...[
                            items[i],
                            if (i != items.length - 1)
                              const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                          ],
                        ],
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('밴드 정보를 불러오지 못했습니다. $e'),
                    ),
                  ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    ref.read(selectedProjectProvider.notifier).state = _tempProject;
                    ref.read(selectedProjectNameProvider.notifier).state = _tempProjectName;
                    ref.read(selectedBandProvider.notifier).state = _tempBand;
                    ref.read(selectedBandNameProvider.notifier).state = _tempBandName;
                    Navigator.of(context).pop();
                    _onApplied?.call();
                  },
                  child: const Text('적용'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectItem extends StatelessWidget {
  const _ProjectItem({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
