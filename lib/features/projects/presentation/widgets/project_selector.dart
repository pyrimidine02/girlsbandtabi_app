/// EN: Project selector widget — compact horizontal pill list (Blip-style).
/// KO: 프로젝트 선택 위젯 — 컴팩트 가로 필 리스트 (블립 스타일).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/gbt_animations.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_pressable.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../application/projects_controller.dart';
import '../../domain/entities/project_entities.dart';

/// EN: Full project selector — compact pill row.
/// KO: 전체 프로젝트 선택기 — 컴팩트 필 행.
class ProjectSelector extends ConsumerWidget {
  const ProjectSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectsState = ref.watch(projectsControllerProvider);
    final selection = ref.watch(projectSelectionControllerProvider);

    return projectsState.when(
      loading: () => const _ShimmerPillRow(),
      error: (error, _) {
        final message = error is Failure
            ? error.userMessage
            : '프로젝트를 불러오지 못했어요';
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GBTSpacing.pageHorizontal,
          ),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  message,
                  style: GBTTypography.bodySmall.copyWith(
                    color: isDark
                        ? GBTColors.darkTextSecondary
                        : GBTColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: GBTSpacing.sm),
              TextButton(
                onPressed: () => ref
                    .read(projectsControllerProvider.notifier)
                    .load(forceRefresh: true),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        );
      },
      data: (projects) {
        if (projects.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: GBTSpacing.pageHorizontal,
            ),
            child: Text(
              '등록된 프로젝트가 없습니다',
              style: GBTTypography.bodySmall.copyWith(
                color: isDark
                    ? GBTColors.darkTextSecondary
                    : GBTColors.textSecondary,
              ),
            ),
          );
        }

        _ensureProjectSelection(ref, selection, projects);
        final selectedProject = _resolveSelectedProject(selection, projects);
        return _ProjectPillRow(
          projects: projects,
          selectedProject: selectedProject,
        );
      },
    );
  }
}

/// EN: Compact project selector — same pill row, no extra spacing.
/// KO: 컴팩트 프로젝트 선택기 — 동일한 필 행, 추가 간격 없음.
class ProjectSelectorCompact extends ConsumerWidget {
  const ProjectSelectorCompact({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectsState = ref.watch(projectsControllerProvider);
    final selection = ref.watch(projectSelectionControllerProvider);

    return projectsState.when(
      loading: () => const _ShimmerPillRow(),
      error: (error, _) {
        final message = error is Failure
            ? error.userMessage
            : '프로젝트를 불러오지 못했어요';
        return Text(
          message,
          style: GBTTypography.bodySmall.copyWith(
            color: isDark
                ? GBTColors.darkTextSecondary
                : GBTColors.textSecondary,
          ),
        );
      },
      data: (projects) {
        if (projects.isEmpty) {
          return Text(
            '등록된 프로젝트가 없습니다',
            style: GBTTypography.bodySmall.copyWith(
              color: isDark
                  ? GBTColors.darkTextSecondary
                  : GBTColors.textSecondary,
            ),
          );
        }

        _ensureProjectSelection(ref, selection, projects);
        final selectedProject = _resolveSelectedProject(selection, projects);
        return _ProjectPillRow(
          projects: projects,
          selectedProject: selectedProject,
        );
      },
    );
  }
}

// ========================================
// EN: Horizontal compact pill row
// KO: 가로 컴팩트 필 행
// ========================================

class _ProjectPillRow extends ConsumerWidget {
  const _ProjectPillRow({
    required this.projects,
    required this.selectedProject,
  });

  final List<Project> projects;
  final Project selectedProject;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.pageHorizontal,
      ),
      child: Row(
        children: [
          for (int i = 0; i < projects.length; i++) ...[
            if (i > 0) const SizedBox(width: GBTSpacing.sm),
            _ProjectPill(
              project: projects[i],
              isSelected: projects[i].id == selectedProject.id,
              onTap: () => _onSelectProject(ref, projects[i]),
            ),
          ],
        ],
      ),
    );
  }

  void _onSelectProject(WidgetRef ref, Project project) {
    final targetProjectKey = _projectKeyFor(project);
    ref
        .read(projectSelectionControllerProvider.notifier)
        .selectProject(targetProjectKey, projectId: project.id);
    ref
        .read(projectUnitsControllerProvider(targetProjectKey).notifier)
        .load(forceRefresh: true);
  }
}

// ========================================
// EN: Single pill item — compact inline avatar + name
// KO: 단일 필 항목 — 컴팩트 인라인 아바타 + 이름
// ========================================

class _ProjectPill extends StatelessWidget {
  const _ProjectPill({
    required this.project,
    required this.isSelected,
    required this.onTap,
  });

  final Project project;
  final bool isSelected;
  final VoidCallback onTap;

  // EN: Deterministic palette — each project gets a stable color via hashCode.
  // KO: 결정적 팔레트 — 각 프로젝트가 hashCode로 고정 색상을 받음.
  static const _avatarPalette = [
    Color(0xFF6366F1), // indigo
    Color(0xFF3B82F6), // blue
    Color(0xFFEC4899), // pink
    Color(0xFFF59E0B), // amber
    Color(0xFF10B981), // emerald
    Color(0xFF8B5CF6), // violet
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final paletteColor =
        _avatarPalette[project.name.hashCode.abs() % _avatarPalette.length];

    // EN: Colors per state.
    // KO: 상태별 색상.
    final Color bgColor;
    final Color textColor;

    if (isSelected) {
      bgColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;
      textColor = isDark ? GBTColors.darkBackground : GBTColors.textInverse;
    } else {
      bgColor = isDark
          ? GBTColors.darkSurfaceVariant
          : GBTColors.surfaceVariant;
      textColor = isDark
          ? GBTColors.darkTextSecondary
          : GBTColors.textSecondary;
    }

    return Semantics(
      label: '${project.name} 프로젝트${isSelected ? ', 선택됨' : ''}',
      button: true,
      selected: isSelected,
      child: GBTPressable(
        onTap: onTap,
        hapticType: GBTHapticType.selection,
        child: AnimatedContainer(
          duration: GBTAnimations.normal,
          curve: GBTAnimations.defaultCurve,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.md),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // EN: Small avatar circle (20px).
              // KO: 작은 아바타 원 (20px).
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.3)
                      : paletteColor,
                ),
                alignment: Alignment.center,
                child: Text(
                  project.name.isNotEmpty ? project.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? textColor : Colors.white,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: GBTSpacing.xs),
              // EN: Project name.
              // KO: 프로젝트 이름.
              AnimatedDefaultTextStyle(
                duration: GBTAnimations.normal,
                curve: GBTAnimations.defaultCurve,
                style: GBTTypography.labelLarge.copyWith(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(
                  project.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================================
// EN: Shimmer loading pills
// KO: 쉬머 로딩 필
// ========================================

class _ShimmerPillRow extends StatelessWidget {
  const _ShimmerPillRow();

  static const _widths = [80.0, 96.0, 72.0, 88.0];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? GBTColors.darkSurfaceVariant
        : GBTColors.surfaceVariant;

    return GBTShimmer(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: GBTSpacing.pageHorizontal,
        ),
        child: Row(
          children: [
            for (int i = 0; i < _widths.length; i++) ...[
              if (i > 0) const SizedBox(width: GBTSpacing.sm),
              Container(
                width: _widths[i],
                height: 36,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ========================================
// EN: Top-level helpers
// KO: 톱레벨 헬퍼
// ========================================

void _ensureProjectSelection(
  WidgetRef ref,
  ProjectSelectionState selection,
  List<Project> projects,
) {
  if (selection.projectKey != null) return;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref
        .read(projectSelectionControllerProvider.notifier)
        .selectProject(
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
