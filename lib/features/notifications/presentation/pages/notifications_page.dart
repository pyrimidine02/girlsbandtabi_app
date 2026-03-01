/// EN: Notifications page with grouped notifications.
/// KO: 그룹화된 알림을 포함한 알림 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/layout/gbt_page_intro_card.dart';
import '../../application/notifications_controller.dart';
import '../../domain/entities/notification_entities.dart';

/// EN: Notifications page widget.
/// KO: 알림 페이지 위젯.
class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  bool _showUnreadOnly = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () => ref
                .read(notificationsControllerProvider.notifier)
                .markAllAsRead(),
            tooltip: '전체 읽음 처리',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: '더보기 메뉴',
            onSelected: (value) {
              if (value == 'settings') {
                context.push('/settings/notifications');
              }
              if (value == 'refresh') {
                ref
                    .read(notificationsControllerProvider.notifier)
                    .load(forceRefresh: true);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'settings', child: Text('알림 설정')),
              PopupMenuItem(value: 'refresh', child: Text('새로고침')),
            ],
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
              _NotificationsIntroCard(
                showUnreadOnly: _showUnreadOnly,
                unreadCount: 0,
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
                _NotificationsIntroCard(
                  showUnreadOnly: _showUnreadOnly,
                  unreadCount: 0,
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
            final unreadCount = items.where((item) => !item.isRead).length;
            final visibleItems = _showUnreadOnly
                ? items.where((item) => !item.isRead).toList()
                : items;

            if (visibleItems.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: GBTSpacing.paddingPage,
                children: [
                  _NotificationsIntroCard(
                    showUnreadOnly: _showUnreadOnly,
                    unreadCount: unreadCount,
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
                _NotificationsIntroCard(
                  showUnreadOnly: _showUnreadOnly,
                  unreadCount: unreadCount,
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

class _NotificationsIntroCard extends StatelessWidget {
  const _NotificationsIntroCard({
    required this.showUnreadOnly,
    required this.unreadCount,
    required this.onFilterChanged,
  });

  final bool showUnreadOnly;
  final int unreadCount;
  final ValueChanged<bool> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GBTPageIntroCard(
          icon: Icons.notifications_active_rounded,
          title: '알림 센터',
          description: '활동 소식과 공지 업데이트를 빠르게 확인하세요.',
          trailing: _UnreadChip(count: unreadCount),
        ),
        const SizedBox(height: GBTSpacing.sm),
        Align(
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
        ),
      ],
    );
  }
}

class _UnreadChip extends StatelessWidget {
  const _UnreadChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? GBTColors.darkSurface : GBTColors.surfaceVariant;
    final fg = isDark ? GBTColors.darkTextSecondary : GBTColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.sm,
        vertical: GBTSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
      ),
      child: Text(
        '읽지 않음 $count',
        style: GBTTypography.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
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
