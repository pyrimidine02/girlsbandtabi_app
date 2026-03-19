/// EN: Calendar events page — monthly view of otaku events.
/// KO: 캘린더 이벤트 페이지 — 오타쿠 이벤트 월간 보기.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/locale_text.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../application/calendar_controller.dart';
import '../../domain/entities/calendar_event.dart';

/// EN: Displays calendar events for the selected month.
/// KO: 선택된 월의 캘린더 이벤트를 표시합니다.
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  void _prevMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectId = ref.watch(selectedProjectKeyProvider);
    final query = (
      year: _selectedMonth.year,
      month: _selectedMonth.month,
      projectId: projectId?.isNotEmpty == true ? projectId : null,
    );
    final eventsAsync = ref.watch(calendarEventsProvider(query));

    return Scaffold(
      backgroundColor:
          isDark ? GBTColors.darkBackground : GBTColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? GBTColors.darkSurface : GBTColors.surface,
        title: Text(
          context.l10n(
            ko: '이벤트 캘린더',
            en: 'Event Calendar',
            ja: 'イベントカレンダー',
          ),
          style: GBTTypography.titleLarge.copyWith(
            color: isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // EN: Month navigation header
          // KO: 월 네비게이션 헤더
          _MonthHeader(
            selectedMonth: _selectedMonth,
            onPrev: _prevMonth,
            onNext: _nextMonth,
          ),
          const Divider(height: 1),
          Expanded(
            child: eventsAsync.when(
              loading: () => _CalendarShimmer(),
              error: (_, __) => GBTEmptyState(
                message: context.l10n(
                  ko: '이벤트를 불러오지 못했어요',
                  en: 'Could not load events',
                  ja: 'イベントを読み込めませんでした',
                ),
                icon: Icons.cloud_off_outlined,
              ),
              data: (events) => events.isEmpty
                  ? GBTEmptyState(
                      message: context.l10n(
                        ko: '이번 달 이벤트가 없어요',
                        en: 'No events this month',
                        ja: '今月のイベントはありません',
                      ),
                      icon: Icons.event_busy_outlined,
                    )
                  : _EventList(events: events),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// EN: Month navigation header widget
// KO: 월 네비게이션 헤더 위젯
// ──────────────────────────────────────────────────────────────

/// EN: Header row with previous/next month navigation and the current month label.
/// KO: 이전/다음 월 네비게이션과 현재 월 라벨이 있는 헤더 행입니다.
class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.selectedMonth,
    required this.onPrev,
    required this.onNext,
  });

  final DateTime selectedMonth;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = DateFormat('yyyy년 MM월').format(selectedMonth);

    return Container(
      color: isDark ? GBTColors.darkSurface : GBTColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.pageHorizontal,
        vertical: GBTSpacing.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Semantics(
            button: true,
            label: '이전 달',
            child: IconButton(
              onPressed: onPrev,
              icon: const Icon(Icons.chevron_left),
              color: isDark
                  ? GBTColors.darkTextPrimary
                  : GBTColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GBTTypography.titleMedium.copyWith(
              color: isDark
                  ? GBTColors.darkTextPrimary
                  : GBTColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          Semantics(
            button: true,
            label: '다음 달',
            child: IconButton(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
              color: isDark
                  ? GBTColors.darkTextPrimary
                  : GBTColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// EN: Shimmer placeholder for loading state
// KO: 로딩 상태용 쉬머 플레이스홀더
// ──────────────────────────────────────────────────────────────

/// EN: Shimmer skeleton shown while calendar events are loading.
/// KO: 캘린더 이벤트 로딩 중 표시되는 쉬머 스켈레톤입니다.
class _CalendarShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.all(GBTSpacing.pageHorizontal),
      itemCount: 8,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: GBTSpacing.sm),
        child: GBTShimmer(
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: isDark
                  ? GBTColors.darkSurfaceVariant
                  : GBTColors.surfaceVariant,
              borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// EN: Event list — groups events by date
// KO: 이벤트 목록 — 날짜별로 이벤트 그룹화
// ──────────────────────────────────────────────────────────────

/// EN: Scrollable list of events grouped by date.
/// KO: 날짜별로 그룹화된 이벤트의 스크롤 가능한 목록입니다.
class _EventList extends StatelessWidget {
  const _EventList({required this.events});

  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    // EN: Group events by date label using insertion-ordered map.
    // KO: 삽입 순서 맵을 사용해 날짜 라벨별로 이벤트를 그룹화합니다.
    final grouped = <String, List<CalendarEvent>>{};
    for (final event in events) {
      final key = DateFormat('MM월 dd일 (E)', 'ko').format(event.date);
      grouped.putIfAbsent(key, () => []).add(event);
    }

    final dateKeys = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.pageHorizontal,
        vertical: GBTSpacing.sm,
      ),
      itemCount: dateKeys.length,
      itemBuilder: (context, index) {
        final dateLabel = dateKeys[index];
        final dayEvents = grouped[dateLabel]!;
        return _DateSection(dateLabel: dateLabel, events: dayEvents);
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────
// EN: Date section — label + list of event tiles
// KO: 날짜 섹션 — 라벨과 이벤트 타일 목록
// ──────────────────────────────────────────────────────────────

/// EN: A section grouping events under a single date label.
/// KO: 단일 날짜 라벨 아래 이벤트를 묶는 섹션입니다.
class _DateSection extends StatelessWidget {
  const _DateSection({required this.dateLabel, required this.events});

  final String dateLabel;
  final List<CalendarEvent> events;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: GBTSpacing.md,
            bottom: GBTSpacing.xs,
          ),
          child: Text(
            dateLabel,
            style: GBTTypography.labelMedium.copyWith(
              color: isDark
                  ? GBTColors.darkTextSecondary
                  : GBTColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...events.map((event) => _EventTile(event: event)),
        const SizedBox(height: GBTSpacing.xs),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────
// EN: Individual event tile
// KO: 개별 이벤트 타일
// ──────────────────────────────────────────────────────────────

/// EN: A single calendar event row with a colour-coded left border and icon.
/// KO: 색상으로 구분된 왼쪽 테두리와 아이콘이 있는 단일 캘린더 이벤트 행입니다.
class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final CalendarEvent event;

  Color _typeColor(CalendarEventType type, bool isDark) {
    return switch (type) {
      CalendarEventType.characterBirthday => isDark
          ? const Color(0xFFEC4899)
          : const Color(0xFFDB2777),
      CalendarEventType.voiceActorBirthday => isDark
          ? const Color(0xFFA78BFA)
          : const Color(0xFF7C3AED),
      CalendarEventType.release => isDark
          ? const Color(0xFF34D399)
          : const Color(0xFF059669),
      CalendarEventType.live => isDark
          ? const Color(0xFFFBBF24)
          : const Color(0xFFD97706),
      CalendarEventType.ticketSale => isDark
          ? const Color(0xFF60A5FA)
          : const Color(0xFF2563EB),
      CalendarEventType.streaming => isDark
          ? const Color(0xFF38BDF8)
          : const Color(0xFF0284C7),
      CalendarEventType.general => isDark
          ? GBTColors.darkTextSecondary
          : GBTColors.textSecondary,
    };
  }

  IconData _typeIcon(CalendarEventType type) {
    return switch (type) {
      CalendarEventType.characterBirthday => Icons.cake_outlined,
      CalendarEventType.voiceActorBirthday => Icons.mic_outlined,
      CalendarEventType.release => Icons.album_outlined,
      CalendarEventType.live => Icons.music_note_outlined,
      CalendarEventType.ticketSale => Icons.confirmation_number_outlined,
      CalendarEventType.streaming => Icons.live_tv_outlined,
      CalendarEventType.general => Icons.event_outlined,
    };
  }

  String _typeLabel(CalendarEventType type, BuildContext context) {
    return switch (type) {
      CalendarEventType.characterBirthday => context.l10n(
          ko: '캐릭터 생일',
          en: 'Character Birthday',
          ja: 'キャラ誕生日',
        ),
      CalendarEventType.voiceActorBirthday => context.l10n(
          ko: '성우 생일',
          en: 'VA Birthday',
          ja: '声優誕生日',
        ),
      CalendarEventType.release => context.l10n(
          ko: '발매',
          en: 'Release',
          ja: '発売',
        ),
      CalendarEventType.live => context.l10n(
          ko: '라이브',
          en: 'Live',
          ja: 'ライブ',
        ),
      CalendarEventType.ticketSale => context.l10n(
          ko: '티켓 판매',
          en: 'Ticket Sale',
          ja: 'チケット販売',
        ),
      CalendarEventType.streaming => context.l10n(
          ko: '방송',
          en: 'Streaming',
          ja: '放送',
        ),
      CalendarEventType.general => context.l10n(
          ko: '이벤트',
          en: 'Event',
          ja: 'イベント',
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _typeColor(event.type, isDark);
    final typeLabel = _typeLabel(event.type, context);

    return Semantics(
      label: '${event.title}, $typeLabel',
      child: Padding(
        padding: const EdgeInsets.only(bottom: GBTSpacing.xs),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? GBTColors.darkSurface : GBTColors.surface,
            borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
            border: Border(
              left: BorderSide(color: color, width: 3),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: GBTSpacing.md,
              vertical: GBTSpacing.xxs,
            ),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_typeIcon(event.type), color: color, size: 18),
            ),
            title: Text(
              event.title,
              style: GBTTypography.bodyMedium.copyWith(
                color: isDark
                    ? GBTColors.darkTextPrimary
                    : GBTColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              typeLabel,
              style: GBTTypography.bodySmall.copyWith(color: color),
            ),
            dense: true,
          ),
        ),
      ),
    );
  }
}
