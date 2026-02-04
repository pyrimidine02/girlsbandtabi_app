/// EN: Live events list page with calendar and list view
/// KO: 캘린더 및 리스트 뷰를 포함한 라이브 이벤트 목록 페이지
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/widgets/cards/gbt_event_card.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../application/live_events_controller.dart';
import '../../domain/entities/live_event_entities.dart';
import '../../../projects/application/projects_controller.dart';
import '../../../projects/domain/entities/project_entities.dart';
import '../../../projects/presentation/widgets/band_filter_sheet.dart';

/// EN: Live events page widget
/// KO: 라이브 이벤트 페이지 위젯
class LiveEventsPage extends ConsumerStatefulWidget {
  const LiveEventsPage({super.key});

  @override
  ConsumerState<LiveEventsPage> createState() => _LiveEventsPageState();
}

class _LiveEventsPageState extends ConsumerState<LiveEventsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(liveEventsListControllerProvider);
    final selectedBandIds = ref.watch(selectedLiveBandIdsProvider);
    final projectKey = ref.watch(selectedProjectKeyProvider);
    final projectId = ref.watch(selectedProjectIdProvider);
    final resolvedProjectKey = projectKey?.isNotEmpty == true
        ? projectKey!
        : (projectId ?? '');
    final unitsState = resolvedProjectKey.isNotEmpty
        ? ref.watch(projectUnitsControllerProvider(resolvedProjectKey))
        : const AsyncValue<List<Unit>>.data([]);
    final bandLabel = _resolveBandLabel(unitsState, selectedBandIds);

    return Scaffold(
      appBar: AppBar(
        title: const Text('라이브'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '예정'),
            Tab(text: '완료'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              _showCalendar(eventsState);
            },
            tooltip: '캘린더',
          ),
          IconButton(
            icon: const Icon(Icons.groups),
            onPressed: () => _showBandFilter(
              resolvedProjectKey,
              selectedBandIds,
            ),
            tooltip: '밴드 선택',
          ),
        ],
      ),
      body: Column(
        children: [
          _BandFilterBar(
            label: bandLabel,
            hasSelection: selectedBandIds.isNotEmpty,
            onSelect: () => _showBandFilter(
              resolvedProjectKey,
              selectedBandIds,
            ),
            onClear: () {
              ref.read(selectedLiveBandIdsProvider.notifier).state = [];
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _EventList(
                  isUpcoming: true,
                  state: eventsState,
                  onRetry: () => ref
                      .read(liveEventsListControllerProvider.notifier)
                      .load(forceRefresh: true),
                ),
                _EventList(
                  isUpcoming: false,
                  state: eventsState,
                  onRetry: () => ref
                      .read(liveEventsListControllerProvider.notifier)
                      .load(forceRefresh: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBandFilter(
    String projectKey,
    List<String> selectedBandIds,
  ) {
    if (projectKey.isEmpty) return;
    showBandFilterSheet(
      context: context,
      ref: ref,
      projectKey: projectKey,
      selectedBandIds: selectedBandIds,
      onApply: (ids) {
        ref.read(selectedLiveBandIdsProvider.notifier).state = ids;
      },
    );
  }

  String _resolveBandLabel(
    AsyncValue<List<Unit>> unitsState,
    List<String> selectedBandIds,
  ) {
    if (selectedBandIds.isEmpty) {
      return '전체 밴드';
    }

    return unitsState.maybeWhen(
      data: (units) {
        final names = units
            .where((unit) => selectedBandIds.contains(unit.id))
            .map((unit) => unit.code.isNotEmpty ? unit.code : unit.displayName)
            .toList();
        if (names.isEmpty) {
          return '밴드 ${selectedBandIds.length}개';
        }
        if (names.length == 1) {
          return names.first;
        }
        return '${names.first} 외 ${names.length - 1}';
      },
      orElse: () => '밴드 ${selectedBandIds.length}개',
    );
  }

  void _showCalendar(AsyncValue<List<LiveEventSummary>> state) {
    final events = state.maybeWhen(
      data: (items) => items,
      orElse: () => null,
    );
    if (events == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('라이브 정보를 불러오는 중입니다')),
      );
      return;
    }

    final now = DateTime.now();
    final earliest = events.isEmpty
        ? now.subtract(const Duration(days: 365))
        : events
            .map((event) => event.showStartTime.toLocal())
            .reduce((a, b) => a.isBefore(b) ? a : b);
    final latest = events.isEmpty
        ? now.add(const Duration(days: 365))
        : events
            .map((event) => event.showStartTime.toLocal())
            .reduce((a, b) => a.isAfter(b) ? a : b);
    final firstDate = earliest.isBefore(now)
        ? earliest
        : now.subtract(const Duration(days: 365));
    final lastDate = latest.isAfter(now)
        ? latest
        : now.add(const Duration(days: 365));

    final eventDateKeys =
        events.map((event) => _dateKey(event.showStartTime.toLocal())).toSet();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        var selectedDate = DateTime(now.year, now.month, now.day);
        var visibleMonth = DateTime(selectedDate.year, selectedDate.month);
        final minMonth = DateTime(firstDate.year, firstDate.month);
        final maxMonth = DateTime(lastDate.year, lastDate.month);
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = events
                .where(
                  (event) =>
                      _isSameDate(event.showStartTime.toLocal(), selectedDate),
                )
                .toList()
              ..sort((a, b) => a.showStartTime.compareTo(b.showStartTime));
            final dateLabel = DateFormat('yyyy.MM.dd').format(selectedDate);

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GBTSpacing.md,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '캘린더',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '$dateLabel · ${filtered.length}개',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: GBTSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GBTSpacing.md,
                      ),
                      child: _EventCalendar(
                        selectedDate: selectedDate,
                        visibleMonth: visibleMonth,
                        minMonth: minMonth,
                        maxMonth: maxMonth,
                        eventDateKeys: eventDateKeys,
                        onSelectDate: (date) {
                          setModalState(() {
                            selectedDate =
                                DateTime(date.year, date.month, date.day);
                            visibleMonth =
                                DateTime(selectedDate.year, selectedDate.month);
                          });
                        },
                        onChangeMonth: (month) {
                          setModalState(() {
                            visibleMonth = month;
                          });
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: GBTEmptyState(
                                message: '해당 날짜에 라이브 이벤트가 없습니다',
                              ),
                            )
                          : ListView.builder(
                              padding: GBTSpacing.paddingPage,
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final event = filtered[index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: GBTSpacing.md,
                                  ),
                                  child: GBTEventCard(
                                    title: event.title,
                                    subtitle: event.statusLabel,
                                    meta: event.metaLabel,
                                    date: event.dateLabel,
                                    dDayLabel: event.dDayLabel,
                                    posterUrl: event.bannerUrl,
                                    isLive:
                                        event.statusLabel.toLowerCase() == 'live',
                                    isUpcoming: event.isUpcoming,
                                    onTap: () =>
                                        context.goToLiveDetail(event.id),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// EN: Event list widget
/// KO: 이벤트 리스트 위젯
class _EventList extends StatelessWidget {
  const _EventList({
    required this.isUpcoming,
    required this.state,
    required this.onRetry,
  });

  final bool isUpcoming;
  final AsyncValue<List<LiveEventSummary>> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => ListView(
        padding: GBTSpacing.paddingPage,
        children: const [
          SizedBox(height: GBTSpacing.lg),
          GBTLoading(message: '라이브 이벤트를 불러오는 중...'),
        ],
      ),
      error: (error, _) {
        final message = error is Failure
            ? error.userMessage
            : '라이브 이벤트를 불러오지 못했어요';
        return ListView(
          padding: GBTSpacing.paddingPage,
          children: [
            const SizedBox(height: GBTSpacing.lg),
            GBTErrorState(message: message, onRetry: onRetry),
          ],
        );
      },
      data: (events) {
        final filtered = events
            .where((event) => event.isUpcoming == isUpcoming)
            .toList()
          ..sort((a, b) {
            final first = a.showStartTime;
            final second = b.showStartTime;
            return isUpcoming
                ? first.compareTo(second)
                : second.compareTo(first);
          });

        if (filtered.isEmpty) {
          return ListView(
            padding: GBTSpacing.paddingPage,
            children: [
              const SizedBox(height: GBTSpacing.lg),
              GBTEmptyState(
                message: isUpcoming ? '예정된 라이브 이벤트가 없습니다' : '완료된 라이브 이벤트가 없습니다',
              ),
            ],
          );
        }

        return ListView.builder(
          padding: GBTSpacing.paddingPage,
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final event = filtered[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: GBTSpacing.md),
              child: GBTEventCard(
                title: event.title,
                subtitle: event.statusLabel,
                meta: event.metaLabel,
                date: event.dateLabel,
                dDayLabel: event.dDayLabel,
                posterUrl: event.bannerUrl,
                isLive: event.statusLabel.toLowerCase() == 'live',
                isUpcoming: event.isUpcoming,
                onTap: () => context.goToLiveDetail(event.id),
              ),
            );
          },
        );
      },
    );
  }
}

class _BandFilterBar extends StatelessWidget {
  const _BandFilterBar({
    required this.label,
    required this.hasSelection,
    required this.onSelect,
    required this.onClear,
  });

  final String label;
  final bool hasSelection;
  final VoidCallback onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GBTSpacing.md,
        GBTSpacing.sm,
        GBTSpacing.md,
        GBTSpacing.xs,
      ),
      child: Row(
        children: [
          if (hasSelection)
            InputChip(
              label: Text(label),
              onDeleted: onClear,
            )
          else
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const Spacer(),
          TextButton.icon(
            onPressed: onSelect,
            icon: const Icon(Icons.groups),
            label: const Text('밴드 선택'),
          ),
        ],
      ),
    );
  }
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _dateKey(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class _EventCalendar extends StatelessWidget {
  const _EventCalendar({
    required this.selectedDate,
    required this.visibleMonth,
    required this.minMonth,
    required this.maxMonth,
    required this.eventDateKeys,
    required this.onSelectDate,
    required this.onChangeMonth,
  });

  final DateTime selectedDate;
  final DateTime visibleMonth;
  final DateTime minMonth;
  final DateTime maxMonth;
  final Set<String> eventDateKeys;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<DateTime> onChangeMonth;

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('yyyy년 M월').format(visibleMonth);
    final canGoPrev = !_isSameMonth(visibleMonth, minMonth);
    final canGoNext = !_isSameMonth(visibleMonth, maxMonth);
    final daysInMonth = DateUtils.getDaysInMonth(
      visibleMonth.year,
      visibleMonth.month,
    );
    final firstWeekday = DateTime(
      visibleMonth.year,
      visibleMonth.month,
      1,
    ).weekday;
    final leadingEmpty = firstWeekday % 7;
    final totalCells = leadingEmpty + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final totalSlots = rows * 7;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: canGoPrev
                  ? () {
                      final prevMonth = DateTime(
                        visibleMonth.year,
                        visibleMonth.month - 1,
                      );
                      onChangeMonth(prevMonth);
                    }
                  : null,
            ),
            Text(
              monthLabel,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: canGoNext
                  ? () {
                      final nextMonth = DateTime(
                        visibleMonth.year,
                        visibleMonth.month + 1,
                      );
                      onChangeMonth(nextMonth);
                    }
                  : null,
            ),
          ],
        ),
        const SizedBox(height: GBTSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _WeekdayLabel('일'),
            _WeekdayLabel('월'),
            _WeekdayLabel('화'),
            _WeekdayLabel('수'),
            _WeekdayLabel('목'),
            _WeekdayLabel('금'),
            _WeekdayLabel('토'),
          ],
        ),
        const SizedBox(height: GBTSpacing.xs),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalSlots,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final dayNumber = index - leadingEmpty + 1;
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox.shrink();
            }
            final date = DateTime(
              visibleMonth.year,
              visibleMonth.month,
              dayNumber,
            );
            final isSelected = _isSameDate(date, selectedDate);
            final hasEvent = eventDateKeys.contains(_dateKey(date));
            return _CalendarDayCell(
              date: date,
              isSelected: isSelected,
              hasEvent: hasEvent,
              onTap: () => onSelectDate(date),
            );
          },
        ),
      ],
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.date,
    required this.isSelected,
    required this.hasEvent,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool hasEvent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background =
        isSelected ? colorScheme.primary : Colors.transparent;
    final textColor =
        isSelected ? colorScheme.onPrimary : colorScheme.onSurface;
    final dotColor =
        isSelected ? colorScheme.onPrimary : colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${date.day}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textColor,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
              const SizedBox(height: 2),
              if (hasEvent)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isSameMonth(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month;
}
