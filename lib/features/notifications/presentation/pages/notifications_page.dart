/// EN: Notifications page with grouped notifications.
/// KO: 그룹화된 알림을 포함한 알림 페이지.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/navigation/gbt_app_bar_icon_button.dart';
import '../../application/notifications_controller.dart';
import '../../domain/entities/notification_entities.dart';

/// EN: Notifications page widget.
/// KO: 알림 페이지 위젯.
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage>
    with WidgetsBindingObserver {
  bool _showUnreadOnly = false;
  Timer? _foregroundRefreshTimer;
  bool _isAppResumed = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _foregroundRefreshTimer = Timer.periodic(
      const Duration(seconds: 40),
      (_) => _refreshNotificationsIfVisible(),
    );
  }

  @override
  void dispose() {
    _foregroundRefreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isAppResumed = state == AppLifecycleState.resumed;
    if (_isAppResumed) {
      _refreshNotificationsIfVisible();
    }
  }

  void _refreshNotificationsIfVisible() {
    if (!mounted || !_isAppResumed) return;
    final route = ModalRoute.of(context);
    if (route != null && !route.isCurrent) return;

    ref.read(notificationsControllerProvider.notifier).refreshInBackground();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        actions: [
          GBTAppBarIconButton(
            icon: Icons.done_all,
            tooltip: '전체 읽음 처리',
            onPressed: () => ref
                .read(notificationsControllerProvider.notifier)
                .markAllAsRead(),
          ),
          GBTAppBarIconButton(
            icon: Icons.refresh,
            tooltip: '새로고침',
            onPressed: () => ref
                .read(notificationsControllerProvider.notifier)
                .load(forceRefresh: true),
          ),
          GBTAppBarIconButton(
            icon: Icons.settings_outlined,
            tooltip: '알림 설정',
            onPressed: () => context.push('/settings/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(notificationsControllerProvider.notifier)
            .load(forceRefresh: true),
        child: state.when(
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: GBTSpacing.paddingPage,
            children: [
              _FilterRow(
                showUnreadOnly: _showUnreadOnly,
                onFilterChanged: (next) {
                  setState(() => _showUnreadOnly = next);
                },
              ),
              const SizedBox(height: GBTSpacing.md),
              const GBTLoading(message: '알림을 불러오는 중...'),
            ],
          ),
          error: (error, _) {
            final message = error is Failure
                ? error.userMessage
                : '알림을 불러오지 못했어요';
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: GBTSpacing.paddingPage,
              children: [
                _FilterRow(
                  showUnreadOnly: _showUnreadOnly,
                  onFilterChanged: (next) {
                    setState(() => _showUnreadOnly = next);
                  },
                ),
                const SizedBox(height: GBTSpacing.md),
                GBTErrorState(
                  message: message,
                  onRetry: () => ref
                      .read(notificationsControllerProvider.notifier)
                      .load(forceRefresh: true),
                ),
              ],
            );
          },
          data: (items) {
            final visibleItems = _showUnreadOnly
                ? items.where((item) => !item.isRead).toList()
                : items;

            if (visibleItems.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: GBTSpacing.paddingPage,
                children: [
                  _FilterRow(
                    showUnreadOnly: _showUnreadOnly,
                    onFilterChanged: (next) {
                      setState(() => _showUnreadOnly = next);
                    },
                  ),
                  const SizedBox(height: GBTSpacing.md),
                  GBTEmptyState(
                    icon: Icons.notifications_none,
                    message: _showUnreadOnly
                        ? '읽지 않은 알림이 없습니다.'
                        : '새 알림이 없습니다.',
                  ),
                ],
              );
            }

            final grouped = _groupBySection(visibleItems);

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: GBTSpacing.paddingPage,
              children: [
                _FilterRow(
                  showUnreadOnly: _showUnreadOnly,
                  onFilterChanged: (next) {
                    setState(() => _showUnreadOnly = next);
                  },
                ),
                const SizedBox(height: GBTSpacing.md),
                for (final entry in grouped.entries) ...[
                  _SectionHeader(title: entry.key),
                  ...entry.value.map(
                    (item) => _NotificationItem(
                      item: item,
                      onTap: () => ref
                          .read(notificationsControllerProvider.notifier)
                          .markAsRead(item.id),
                    ),
                  ),
                ],
                const SizedBox(height: GBTSpacing.xl),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// EN: Compact unread filter row — replaces intro card.
/// KO: 읽지 않음 필터 행 — 인트로 카드 대체.
class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.showUnreadOnly,
    required this.onFilterChanged,
  });

  final bool showUnreadOnly;
  final ValueChanged<bool> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SegmentedButton<bool>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment<bool>(value: false, label: Text('전체')),
          ButtonSegment<bool>(value: true, label: Text('읽지 않음')),
        ],
        selected: <bool>{showUnreadOnly},
        onSelectionChanged: (selection) {
          onFilterChanged(selection.first);
        },
      ),
    );
  }
}

Map<String, List<NotificationItem>> _groupBySection(
  List<NotificationItem> items,
) {
  final now = DateTime.now();
  final today = <NotificationItem>[];
  final week = <NotificationItem>[];
  final older = <NotificationItem>[];

  for (final item in items) {
    final diff = now.difference(item.createdAt.toLocal());
    if (diff.inDays == 0) {
      today.add(item);
    } else if (diff.inDays < 7) {
      week.add(item);
    } else {
      older.add(item);
    }
  }

  final map = <String, List<NotificationItem>>{};
  if (today.isNotEmpty) map['오늘'] = today;
  if (week.isNotEmpty) map['이번 주'] = week;
  if (older.isNotEmpty) map['이전'] = older;
  return map;
}

/// EN: Section header widget.
/// KO: 섹션 헤더 위젯.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        GBTSpacing.md,
        GBTSpacing.md,
        GBTSpacing.md,
        GBTSpacing.sm,
      ),
      color: isDark
          ? GBTColors.darkSurfaceVariant.withValues(alpha: 0.5)
          : GBTColors.surfaceVariant.withValues(alpha: 0.5),
      child: Text(
        title,
        style: GBTTypography.labelMedium.copyWith(
          color: isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// EN: Notification item widget.
/// KO: 알림 아이템 위젯.
class _NotificationItem extends StatelessWidget {
  const _NotificationItem({required this.item, required this.onTap});

  final NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // EN: Use neutral icon color instead of brand secondary.
    // KO: 브랜드 보조색 대신 뉴트럴 아이콘 색상을 사용합니다.
    final iconColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;
    final tertiaryColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;

    // EN: Determine status label for accessibility
    // KO: 접근성을 위한 상태 라벨 결정
    final readStatus = item.isRead ? '읽음' : '읽지 않음';

    return Semantics(
      label: '$readStatus 알림: ${item.title}. ${item.body}',
      button: true,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: iconColor.withValues(alpha: 0.12),
          child: Icon(Icons.notifications, color: iconColor, size: 20),
        ),
        title: Text(
          item.title,
          style: GBTTypography.bodyMedium.copyWith(
            fontWeight: item.isRead ? FontWeight.w400 : FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          item.body,
          style: GBTTypography.bodySmall.copyWith(color: tertiaryColor),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: item.isRead
            ? null
            : Semantics(
                label: '읽지 않은 알림 표시',
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    // EN: Use primary purple for unread dot (CTA/status indicator).
                    // KO: 읽지 않음 점에는 기본 보라색 사용 (CTA/상태 표시).
                    color: isDark ? GBTColors.darkPrimary : GBTColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
      ),
    );
  }
}
