/// EN: Band filter sheet for selecting project units.
/// KO: 프로젝트 유닛을 밴드로 선택하는 필터 시트.
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

/// EN: Open the band filter sheet for a project.
/// KO: 프로젝트 밴드 필터 시트를 엽니다.
Future<void> showBandFilterSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String projectKey,
  required List<String> selectedBandIds,
  required ValueChanged<List<String>> onApply,
}) async {
  final controller = projectUnitsControllerProvider(projectKey);
  final state = ref.read(controller);
  if (state is! AsyncData<List<Unit>>) {
    await ref.read(controller.notifier).load(forceRefresh: true);
  }

  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _BandFilterSheet(
      projectKey: projectKey,
      initialSelection: selectedBandIds,
      onApply: onApply,
    ),
  );
}

class _BandFilterSheet extends ConsumerStatefulWidget {
  const _BandFilterSheet({
    required this.projectKey,
    required this.initialSelection,
    required this.onApply,
  });

  final String projectKey;
  final List<String> initialSelection;
  final ValueChanged<List<String>> onApply;

  @override
  ConsumerState<_BandFilterSheet> createState() => _BandFilterSheetState();
}

class _BandFilterSheetState extends ConsumerState<_BandFilterSheet> {
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelection.toSet();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectUnitsControllerProvider(widget.projectKey));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(GBTSpacing.md),
        child: state.when(
          loading: () => const GBTLoading(message: '밴드를 불러오는 중...'),
          error: (error, _) {
            final message = error is Failure
                ? error.userMessage
                : '밴드를 불러오지 못했어요';
            return Column(
              mainAxisSize: MainAxisSize.min,
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
                      .read(
                        projectUnitsControllerProvider(
                          widget.projectKey,
                        ).notifier,
                      )
                      .load(forceRefresh: true),
                  child: const Text('다시 시도'),
                ),
              ],
            );
          },
          data: (units) {
            if (units.isEmpty) {
              return const Center(child: Text('밴드 정보가 없습니다'));
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('밴드 선택', style: GBTTypography.titleMedium),
                const SizedBox(height: GBTSpacing.md),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: units.length,
                    itemBuilder: (context, index) {
                      final unit = units[index];
                      final isSelected = _selected.contains(unit.id);
                      final name = unit.code.isNotEmpty
                          ? unit.code
                          : unit.displayName;
                      final description = unit.displayName != name
                          ? unit.displayName
                          : '';
                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selected.add(unit.id);
                            } else {
                              _selected.remove(unit.id);
                            }
                          });
                        },
                        isThreeLine: description.isNotEmpty,
                        title: Text(name),
                        subtitle: description.isNotEmpty
                            ? Text(
                                description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            : null,
                      );
                    },
                  ),
                ),
                const SizedBox(height: GBTSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _selected.clear());
                        },
                        child: const Text('초기화'),
                      ),
                    ),
                    const SizedBox(width: GBTSpacing.sm),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          widget.onApply(_selected.toList());
                          Navigator.of(context).pop();
                        },
                        child: const Text('적용'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
