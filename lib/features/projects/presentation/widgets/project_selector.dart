/// EN: Project selector widget.
/// KO: 프로젝트 선택 위젯.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../application/projects_controller.dart';
import '../../domain/entities/project_entities.dart';

class ProjectSelector extends ConsumerWidget {
  const ProjectSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final projectsState = ref.watch(projectsControllerProvider);
    final selection = ref.watch(projectSelectionControllerProvider);

    return projectsState.when(
      loading: () => const GBTLoading(message: '프로젝트를 불러오는 중...'),
      error: (error, _) {
        final message = error is Failure
            ? error.userMessage
            : '프로젝트를 불러오지 못했어요';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: GBTTypography.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: GBTSpacing.sm),
            TextButton(
              onPressed: () => ref
                  .read(projectsControllerProvider.notifier)
                  .load(forceRefresh: true),
              child: const Text('다시 시도'),
            ),
          ],
        );
      },
      data: (projects) {
        if (projects.isEmpty) {
          return Text(
            '등록된 프로젝트가 없습니다',
            style: GBTTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          );
        }

        _ensureProjectSelection(ref, selection, projects);
        final selectedProject = _resolveSelectedProject(selection, projects);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '프로젝트 선택',
              style: GBTTypography.labelMedium.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: GBTSpacing.xs),
            _ProjectDropdown(
              projects: projects,
              selectedProject: selectedProject,
            ),
            const SizedBox(height: GBTSpacing.sm),
          ],
        );
      },
    );
  }
}

class ProjectSelectorCompact extends ConsumerStatefulWidget {
  const ProjectSelectorCompact({super.key});

  @override
  ConsumerState<ProjectSelectorCompact> createState() =>
      _ProjectSelectorCompactState();
}

class _ProjectSelectorCompactState
    extends ConsumerState<ProjectSelectorCompact> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final projectsState = ref.watch(projectsControllerProvider);
    final selection = ref.watch(projectSelectionControllerProvider);

    return projectsState.when(
      loading: () => const GBTLoading(message: '프로젝트를 불러오는 중...'),
      error: (error, _) {
        final message = error is Failure
            ? error.userMessage
            : '프로젝트를 불러오지 못했어요';
        return Text(
          message,
          style: GBTTypography.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        );
      },
      data: (projects) {
        if (projects.isEmpty) {
          return Text(
            '등록된 프로젝트가 없습니다',
            style: GBTTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          );
        }

        _ensureProjectSelection(ref, selection, projects);
        final selectedProject = _resolveSelectedProject(selection, projects);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: GBTSpacing.sm,
                  vertical: GBTSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    Text(
                      '프로젝트',
                      style: GBTTypography.labelSmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: GBTSpacing.sm),
                    Expanded(
                      child: Text(
                        selectedProject.name,
                        style: GBTTypography.labelMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: GBTSpacing.sm),
                child: _ProjectDropdown(
                  projects: projects,
                  selectedProject: selectedProject,
                  onSelected: () => setState(() => _expanded = false),
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        );
      },
    );
  }
}

class _ProjectDropdown extends ConsumerWidget {
  const _ProjectDropdown({
    required this.projects,
    required this.selectedProject,
    this.onSelected,
  });

  final List<Project> projects;
  final Project selectedProject;
  final VoidCallback? onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Project>(
          value: selectedProject,
          isExpanded: true,
          items: projects
              .map(
                (project) => DropdownMenuItem<Project>(
                  value: project,
                  child: Text(project.name),
                ),
              )
              .toList(),
          onChanged: (project) {
            ref
                .read(projectSelectionControllerProvider.notifier)
                .selectProject(
                  project != null ? _projectKeyFor(project) : null,
                  projectId: project?.id,
                );
            if (project != null) {
              final targetProjectKey = _projectKeyFor(project);
              ref
                  .read(
                    projectUnitsControllerProvider(
                      targetProjectKey,
                    ).notifier,
                  )
                  .load(forceRefresh: true);
            }
            onSelected?.call();
          },
        ),
      ),
    );
  }
}

void _ensureProjectSelection(
  WidgetRef ref,
  ProjectSelectionState selection,
  List<Project> projects,
) {
  if (selection.projectKey != null) return;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(projectSelectionControllerProvider.notifier).selectProject(
          _projectKeyFor(projects.first),
          projectId: projects.first.id,
        );
  });
}

Project _resolveSelectedProject(
  ProjectSelectionState selection,
  List<Project> projects,
) {
  return projects.firstWhere(
    (project) =>
        project.code == selection.projectKey ||
        project.id == selection.projectKey,
    orElse: () => projects.first,
  );
}

String _projectKeyFor(Project project) {
  return project.code.isNotEmpty ? project.code : project.id;
}
