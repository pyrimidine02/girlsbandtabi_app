/// EN: Project selector widget.
/// KO: 프로젝트 선택 위젯.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../application/projects_controller.dart';
import '../../domain/entities/project_entities.dart';

class ProjectSelector extends ConsumerWidget {
  const ProjectSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                color: GBTColors.textSecondary,
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
              color: GBTColors.textSecondary,
            ),
          );
        }

        if (selection.projectKey == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(projectSelectionControllerProvider.notifier)
                .selectProject(
                  _projectKeyFor(projects.first),
                  projectId: projects.first.id,
                );
          });
        }

        final selectedProject = projects.firstWhere(
          (project) =>
              project.code == selection.projectKey ||
              project.id == selection.projectKey,
          orElse: () => projects.first,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '프로젝트 선택',
              style: GBTTypography.labelMedium.copyWith(
                color: GBTColors.textSecondary,
              ),
            ),
            const SizedBox(height: GBTSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.sm),
              decoration: BoxDecoration(
                color: GBTColors.surfaceVariant,
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
                  },
                ),
              ),
            ),
            const SizedBox(height: GBTSpacing.sm),
          ],
        );
      },
    );
  }
}

String _projectKeyFor(Project project) {
  return project.code.isNotEmpty ? project.code : project.id;
}
