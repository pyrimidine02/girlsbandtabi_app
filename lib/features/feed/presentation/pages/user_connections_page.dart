/// EN: User followers/following page with dense community-style list UX.
/// KO: 커뮤니티형 밀도 리스트 UX를 적용한 사용자 팔로워/팔로잉 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/inputs/gbt_search_bar.dart';
import '../../../../core/widgets/navigation/gbt_segmented_tab_bar.dart';
import '../../application/user_follow_list_controller.dart';
import '../../domain/entities/community_moderation.dart';

enum UserConnectionsTab { followers, following }

class UserConnectionsPage extends ConsumerStatefulWidget {
  const UserConnectionsPage({
    super.key,
    required this.userId,
    this.initialTab = UserConnectionsTab.followers,
    this.displayName,
  });

  final String userId;
  final UserConnectionsTab initialTab;
  final String? displayName;

  @override
  ConsumerState<UserConnectionsPage> createState() =>
      _UserConnectionsPageState();
}

class _UserConnectionsPageState extends ConsumerState<UserConnectionsPage> {
  String _followersQuery = '';
  String _followingQuery = '';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTab == UserConnectionsTab.followers ? 0 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.displayName == null ? '연결' : '${widget.displayName} 연결',
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(44),
            child: GBTSegmentedTabBar(
              height: 44,
              margin: EdgeInsets.symmetric(horizontal: GBTSpacing.md2),
              tabs: [
                Tab(text: '팔로워'),
                Tab(text: '팔로잉'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _ConnectionsTabBody(
              userId: widget.userId,
              isFollowersTab: true,
              query: _followersQuery,
              onQueryChanged: (value) {
                setState(() {
                  _followersQuery = value;
                });
              },
              emptyMessage: '아직 팔로워가 없습니다',
            ),
            _ConnectionsTabBody(
              userId: widget.userId,
              isFollowersTab: false,
              query: _followingQuery,
              onQueryChanged: (value) {
                setState(() {
                  _followingQuery = value;
                });
              },
              emptyMessage: '아직 팔로우한 사용자가 없습니다',
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionsTabBody extends ConsumerWidget {
  const _ConnectionsTabBody({
    required this.userId,
    required this.isFollowersTab,
    required this.query,
    required this.onQueryChanged,
    required this.emptyMessage,
  });

  final String userId;
  final bool isFollowersTab;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = isFollowersTab
        ? userFollowersProvider(userId)
        : userFollowingProvider(userId);
    final state = ref.watch(provider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;

    return Column(
      children: [
        Padding(
          padding: GBTSpacing.paddingPage,
          child: GBTSearchBar(
            hint: '닉네임 또는 소개 검색',
            onChanged: onQueryChanged,
            onClear: () => onQueryChanged(''),
          ),
        ),
        Expanded(
          child: state.when(
            loading: () => const GBTLoading(message: '목록을 불러오는 중...'),
            error: (error, _) {
              final message = error is Failure
                  ? error.userMessage
                  : '목록을 불러오지 못했습니다';
              return GBTErrorState(
                message: message,
                onRetry: () => ref.invalidate(provider),
              );
            },
            data: (items) {
              final filtered = _filter(items, query);
              if (filtered.isEmpty) {
                return GBTEmptyState(
                  message: query.isEmpty ? emptyMessage : '검색 결과가 없습니다',
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(provider);
                  await ref.read(provider.future);
                },
                child: ListView.separated(
                  padding: GBTSpacing.paddingPage,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final joinedLabel = DateFormat(
                      'yyyy.MM.dd',
                    ).format(item.followedAt.toLocal());
                    return InkWell(
                      borderRadius: BorderRadius.circular(GBTSpacing.radiusLg),
                      onTap: () => context.goToUserProfile(item.userId),
                      child: Ink(
                        decoration: BoxDecoration(
                          color: isDark
                              ? GBTColors.darkSurface
                              : GBTColors.surface,
                          borderRadius: BorderRadius.circular(
                            GBTSpacing.radiusLg,
                          ),
                          border: Border.all(
                            color: isDark
                                ? GBTColors.darkBorder
                                : GBTColors.border,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(GBTSpacing.sm),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ConnectionAvatar(url: item.avatarUrl),
                              const SizedBox(width: GBTSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.displayName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GBTTypography.bodyMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: GBTSpacing.xs),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: GBTSpacing.xs,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primaryContainer
                                                .withValues(alpha: 0.4),
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Text(
                                            joinedLabel,
                                            style: GBTTypography.labelSmall
                                                .copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (item.bio != null &&
                                        item.bio!.trim().isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        item.bio!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GBTTypography.bodySmall.copyWith(
                                          color: mutedColor,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: GBTSpacing.sm),
                              FilledButton.tonal(
                                onPressed: () =>
                                    context.goToUserProfile(item.userId),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(72, 34),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: GBTSpacing.sm,
                                  ),
                                ),
                                child: const Text('보기'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: GBTSpacing.sm),
                  itemCount: filtered.length,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<UserFollowSummary> _filter(
    List<UserFollowSummary> items,
    String rawQuery,
  ) {
    final queryLower = rawQuery.trim().toLowerCase();
    if (queryLower.isEmpty) {
      return items;
    }
    return items.where((item) {
      final name = item.displayName.toLowerCase();
      final bio = (item.bio ?? '').toLowerCase();
      return name.contains(queryLower) || bio.contains(queryLower);
    }).toList();
  }
}

class _ConnectionAvatar extends StatelessWidget {
  const _ConnectionAvatar({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (url == null || url!.isEmpty) {
      return CircleAvatar(
        radius: 21,
        backgroundColor: isDark
            ? GBTColors.darkSurfaceVariant
            : GBTColors.surfaceVariant,
        child: Icon(
          Icons.person,
          size: 20,
          color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
        ),
      );
    }
    return ClipOval(
      child: GBTImage(
        imageUrl: url!,
        width: 42,
        height: 42,
        fit: BoxFit.cover,
        semanticLabel: '프로필 이미지',
      ),
    );
  }
}
