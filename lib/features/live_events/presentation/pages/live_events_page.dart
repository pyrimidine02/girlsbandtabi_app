/// EN: Live events list page with calendar and list view
/// KO: 캘린더 및 리스트 뷰를 포함한 라이브 이벤트 목록 페이지
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/gbt_animations.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/widgets/navigation/gbt_app_bar_icon_button.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/cards/gbt_event_card.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/navigation/gbt_profile_action.dart';
import '../../../../core/widgets/navigation/gbt_segmented_tab_bar.dart';
import '../../application/live_events_controller.dart';
import '../../domain/entities/live_event_entities.dart';
import '../../../projects/application/projects_controller.dart';
import '../../../projects/domain/entities/project_entities.dart';
import '../../../projects/presentation/widgets/project_selector.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    return Scaffold(
      appBar: AppBar(
        // EN: titleSpacing 0 — spacing is controlled inline in the Row.
        // KO: titleSpacing 0 — 간격은 Row 안에서 직접 제어.
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: GBTSpacing.md),
            Text(
              '라이브',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.sm),
              child: Container(
                width: 1,
                height: 16,
                color: isDark ? GBTColors.darkBorder : GBTColors.border,
              ),
            ),
            // EN: Project selector fills remaining AppBar title space.
            // KO: 프로젝트 선택기가 남은 AppBar 타이틀 공간을 채움.
            const Expanded(child: ProjectSelectorCompact()),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: GBTSegmentedTabBar(
            controller: _tabController,
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: GBTSpacing.md2),
            padding: const EdgeInsets.all(2),
            borderRadius: GBTSpacing.radiusSm,
            indicatorBorderRadius: GBTSpacing.radiusSm,
            indicatorShadow: false,
            labelStyle: GBTTypography.tabLabel,
            unselectedLabelStyle: GBTTypography.labelMedium,
            labelPadding: const EdgeInsets.symmetric(horizontal: GBTSpacing.sm),
            tabs: const [
              Tab(text: '예정'),
              Tab(text: '완료'),
            ],
          ),
        ),
        actions: [
          GBTAppBarIconButton(
            icon: Icons.calendar_month_outlined,
            onPressed: () {
              _showCalendar(eventsState);
            },
            tooltip: '캘린더로 라이브 이벤트 보기',
          ),
          const GBTProfileAction(),
        ],
      ),
      body: Column(
        children: [
          // EN: Inline band chip filter — replaces the two-row (ProjectSelector + BandFilterBar) layout.
          // KO: 인라인 밴드 칩 필터 — 기존 두 줄(ProjectSelector + BandFilterBar) 레이아웃을 대체.
          _BandChipFilterRow(
            unitsState: unitsState,
            selectedBandIds: selectedBandIds,
            onSelectAll: () {
              ref.read(selectedLiveBandIdsProvider.notifier).state = [];
            },
            onToggleBand: (id) {
              final current = ref.read(selectedLiveBandIdsProvider);
              if (current.contains(id)) {
                ref.read(selectedLiveBandIdsProvider.notifier).state =
                    current.where((e) => e != id).toList();
              } else {
                ref.read(selectedLiveBandIdsProvider.notifier).state = [
                  ...current,
                  id,
                ];
              }
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _EventList(
                  isUpcoming: true,
                  state: eventsState,
                  onRefresh: () => ref
                      .read(liveEventsListControllerProvider.notifier)
                      .load(forceRefresh: true),
                  onRetry: () => ref
                      .read(liveEventsListControllerProvider.notifier)
                      .load(forceRefresh: true),
                ),
                _EventList(
                  isUpcoming: false,
                  state: eventsState,
                  onRefresh: () => ref
                      .read(liveEventsListControllerProvider.notifier)
                      .load(forceRefresh: true),
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

  void _showCalendar(AsyncValue<List<LiveEventSummary>> state) {
    final events = state.maybeWhen(data: (items) => items, orElse: () => null);
    if (events == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('라이브 정보를 불러오는 중입니다')));
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

    final eventDateKeys = events
        .map((event) => _dateKey(event.showStartTime.toLocal()))
        .toSet();

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
            final filtered =
                events
                    .where(
                      (event) => _isSameDate(
                        event.showStartTime.toLocal(),
                        selectedDate,
                      ),
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
                            selectedDate = DateTime(
                              date.year,
                              date.month,
                              date.day,
                            );
                            visibleMonth = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                            );
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
                                icon: Icons.event_busy,
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
                                    eventId: event.id,
                                    title: event.title,
                                    subtitle: event.statusLabel,
                                    meta: event.metaLabel,
                                    date: event.dateLabel,
                                    dDayLabel: event.dDayLabel,
                                    posterUrl: event.bannerUrl,
                                    isLive:
                                        event.statusLabel.toLowerCase() ==
                                        'live',
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
    required this.onRefresh,
    required this.onRetry,
  });

  final bool isUpcoming;
  final AsyncValue<List<LiveEventSummary>> state;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: state.when(
        loading: () => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: GBTSpacing.sm),
          children: [
            GBTListSkeleton(
              itemCount: 4,
              padding: EdgeInsets.zero,
              spacing: GBTSpacing.sm,
              itemBuilder: (_) => const GBTEventCardSkeleton(),
            ),
          ],
        ),
        error: (error, _) {
          final message = error is Failure
              ? error.userMessage
              : '라이브 이벤트를 불러오지 못했어요';
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: GBTSpacing.paddingPage,
            children: [
              const SizedBox(height: GBTSpacing.lg),
              GBTErrorState(message: message, onRetry: onRetry),
            ],
          );
        },
        data: (events) {
          final filtered =
              events.where((event) => event.isUpcoming == isUpcoming).toList()
                ..sort((a, b) {
                  final first = a.showStartTime;
                  final second = b.showStartTime;
                  return isUpcoming
                      ? first.compareTo(second)
                      : second.compareTo(first);
                });

          if (filtered.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: GBTSpacing.paddingPage,
              children: [
                const SizedBox(height: GBTSpacing.lg),
                GBTEmptyState(
                  icon: isUpcoming ? Icons.event_available : Icons.event_busy,
                  message: isUpcoming
                      ? '예정된 라이브 이벤트가 없습니다'
                      : '완료된 라이브 이벤트가 없습니다',
                ),
              ],
            );
          }

          // EN: Render today/live events as featured cards, rest as list cards
          // KO: 오늘/LIVE 이벤트는 피처드 카드로, 나머지는 일반 카드로 표시
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              GBTSpacing.md,
              GBTSpacing.sm,
              GBTSpacing.md,
              GBTSpacing.xl,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final event = filtered[index];
              final isLive = event.statusLabel.toLowerCase() == 'live';
              final isTodayEvent = event.dDayLabel == 'D-day';
              final timeStr = DateFormat('HH:mm').format(
                event.showStartTime.toLocal(),
              );

              // EN: Featured card for live or today events (upcoming tab only)
              // KO: 업커밍 탭에서 LIVE·오늘 이벤트는 피처드 카드로 강조
              if (isUpcoming && (isLive || isTodayEvent)) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: GBTSpacing.md),
                  child: GBTFeaturedEventCard(
                    eventId: event.id,
                    title: event.title,
                    subtitle: event.statusLabel,
                    meta: '$timeStr · ${event.metaLabel}',
                    date: event.dateLabel,
                    posterUrl: event.bannerUrl,
                    isLive: isLive,
                    onTap: () => context.goToLiveDetail(event.id),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: GBTSpacing.sm),
                child: GBTEventCard(
                  eventId: event.id,
                  title: event.title,
                  subtitle: event.statusLabel,
                  meta: '$timeStr · ${event.metaLabel}',
                  date: event.dateLabel,
                  dDayLabel: event.dDayLabel,
                  posterUrl: event.bannerUrl,
                  isLive: isLive,
                  isUpcoming: event.isUpcoming,
                  onTap: () => context.goToLiveDetail(event.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ========================================
// EN: Inline band chip filter row
// KO: 인라인 밴드 칩 필터 행
// ========================================

/// EN: Horizontal scrollable band filter chips — "전체" + one chip per unit.
/// KO: 가로 스크롤 밴드 필터 칩 — "전체" + 유닛별 칩.
class _BandChipFilterRow extends StatelessWidget {
  const _BandChipFilterRow({
    required this.unitsState,
    required this.selectedBandIds,
    required this.onSelectAll,
    required this.onToggleBand,
  });

  final AsyncValue<List<Unit>> unitsState;
  final List<String> selectedBandIds;
  final VoidCallback onSelectAll;
  final ValueChanged<String> onToggleBand;

  @override
  Widget build(BuildContext context) {
    return unitsState.when(
      // EN: Skip filter row while loading — no height penalty.
      // KO: 로딩 중에는 필터 행 표시 안 함 — 레이아웃 높이 페널티 없음.
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (units) {
        if (units.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: GBTSpacing.md,
              vertical: GBTSpacing.xs2,
            ),
            children: [
              _BandChip(
                label: '전체',
                isSelected: selectedBandIds.isEmpty,
                onTap: onSelectAll,
              ),
              ...units.map((unit) {
                final label =
                    unit.code.isNotEmpty ? unit.code : unit.displayName;
                return Padding(
                  padding: const EdgeInsets.only(left: GBTSpacing.xs2),
                  child: _BandChip(
                    label: label,
                    isSelected: selectedBandIds.contains(unit.id),
                    onTap: () => onToggleBand(unit.id),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

/// EN: Single band filter chip with animated selected state.
/// KO: 애니메이션 선택 상태를 가진 단일 밴드 필터 칩.
class _BandChip extends StatelessWidget {
  const _BandChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? GBTColors.darkPrimary : GBTColors.primary;
    final bgColor = isSelected
        ? primaryColor.withValues(alpha: isDark ? 0.20 : 0.10)
        : (isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant);
    final textColor = isSelected
        ? primaryColor
        : (isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary);
    final borderColor = isSelected ? primaryColor : Colors.transparent;

    return Semantics(
      label: '$label 밴드${isSelected ? ', 선택됨' : ''}',
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: GBTAnimations.fast,
          curve: GBTAnimations.defaultCurve,
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.md),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: GBTAnimations.fast,
              curve: GBTAnimations.defaultCurve,
              style: GBTTypography.labelMedium.copyWith(
                color: textColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ),
        ),
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
              tooltip: '이전 달',
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
            Text(monthLabel, style: Theme.of(context).textTheme.titleSmall),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: '다음 달',
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
    final background = isSelected ? colorScheme.primary : Colors.transparent;
    final textColor = isSelected
        ? colorScheme.onPrimary
        : colorScheme.onSurface;
    final dotColor = isSelected ? colorScheme.onPrimary : colorScheme.primary;

    // EN: Format date for accessibility label
    // KO: 접근성 라벨을 위한 날짜 포맷
    final dateLabel = DateFormat('M월 d일').format(date);
    final eventLabel = hasEvent ? ', 이벤트 있음' : '';
    final selectedLabel = isSelected ? ', 선택됨' : '';

    return Semantics(
      label: '$dateLabel$eventLabel$selectedLabel',
      button: true,
      selected: isSelected,
      child: Material(
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
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
      ),
    );
  }
}

bool _isSameMonth(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month;
}
