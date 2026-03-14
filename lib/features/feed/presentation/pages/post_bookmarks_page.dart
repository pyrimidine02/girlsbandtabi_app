/// EN: Post bookmarks page — lists community posts the user has bookmarked.
/// KO: 북마크한 커뮤니티 게시글 목록 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/localization/locale_text.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/navigation/gbt_app_bar_icon_button.dart';
import '../../../favorites/application/favorites_controller.dart';
import '../../../favorites/domain/entities/favorite_entities.dart';

/// EN: Page showing all community posts the user has bookmarked.
/// KO: 사용자가 북마크한 커뮤니티 게시글 목록 페이지.
class PostBookmarksPage extends ConsumerWidget {
  const PostBookmarksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoritesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n(ko: '북마크한 글', en: 'Bookmarks', ja: 'ブックマーク'),
        ),
        actions: [
          GBTAppBarIconButton(
            icon: Icons.refresh,
            tooltip: context.l10n(ko: '새로고침', en: 'Refresh', ja: '更新'),
            onPressed: () => ref
                .read(favoritesControllerProvider.notifier)
                .load(forceRefresh: true),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(favoritesControllerProvider.notifier)
            .load(forceRefresh: true),
        child: state.when(
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: GBTSpacing.paddingPage,
            children: [
              const SizedBox(height: GBTSpacing.sm),
              GBTLoading(
                message: context.l10n(
                  ko: '북마크를 불러오는 중...',
                  en: 'Loading bookmarks...',
                  ja: 'ブックマークを読み込み中...',
                ),
              ),
            ],
          ),
          error: (error, _) {
            final message = error is Failure
                ? error.userMessage
                : context.l10n(
                    ko: '북마크를 불러오지 못했어요',
                    en: 'Failed to load bookmarks',
                    ja: 'ブックマークを読み込めませんでした',
                  );
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: GBTSpacing.paddingPage,
              children: [
                const SizedBox(height: GBTSpacing.sm),
                GBTErrorState(
                  message: message,
                  onRetry: () => ref
                      .read(favoritesControllerProvider.notifier)
                      .load(forceRefresh: true),
                ),
              ],
            );
          },
          data: (items) {
            final posts = items
                .where((item) => item.type == FavoriteType.post)
                .toList();

            if (posts.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: GBTSpacing.paddingPage,
                children: [
                  const SizedBox(height: GBTSpacing.sm),
                  GBTEmptyState(
                    icon: Icons.bookmark_border_rounded,
                    message: context.l10n(
                      ko: '북마크한 글이 없습니다.\n마음에 드는 게시글을 북마크해보세요.',
                      en: 'No bookmarked posts.\nBookmark posts you like.',
                      ja: 'ブックマークした投稿がありません。\n気に入った投稿をブックマークしてください。',
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                GBTSpacing.pageHorizontal,
                GBTSpacing.sm,
                GBTSpacing.pageHorizontal,
                GBTSpacing.xl,
              ),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: GBTSpacing.sm),
                  child: _BookmarkedPostCard(
                    item: posts[index],
                    onTap: () {
                      final entityId = posts[index].entityId.trim();
                      if (entityId.isEmpty) return;
                      context.goToPostDetail(
                        entityId,
                        projectCode: posts[index].projectCode,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _BookmarkedPostCard extends StatelessWidget {
  const _BookmarkedPostCard({required this.item, required this.onTap});

  final FavoriteItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary;
    final textTertiary =
        isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary;
    final surfaceColor = isDark ? GBTColors.darkSurfaceElevated : Colors.white;
    final borderColor = isDark ? GBTColors.darkBorder : GBTColors.border;

    return Semantics(
      label:
          '${context.l10n(ko: "북마크", en: "Bookmark", ja: "ブックマーク")}: ${item.title ?? context.l10n(ko: "게시글", en: "Post", ja: "投稿")}',
      button: true,
      child: Material(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: borderColor, width: 0.5),
              borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
            ),
            child: Row(
              children: [
                if (item.thumbnailUrl != null &&
                    item.thumbnailUrl!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(GBTSpacing.radiusMd - 1),
                      bottomLeft: Radius.circular(GBTSpacing.radiusMd - 1),
                    ),
                    child: GBTImage(
                      imageUrl: item.thumbnailUrl!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                ] else ...[
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: (isDark
                              ? GBTColors.darkSurfaceVariant
                              : GBTColors.surfaceVariant),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(GBTSpacing.radiusMd - 1),
                        bottomLeft: Radius.circular(GBTSpacing.radiusMd - 1),
                      ),
                    ),
                    child: Icon(
                      Icons.chat_bubble_rounded,
                      size: 28,
                      color: textTertiary.withValues(alpha: 0.5),
                    ),
                  ),
                ],
                const SizedBox(width: GBTSpacing.md),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: GBTSpacing.md,
                    ),
                    child: Text(
                      item.title ??
                          context.l10n(ko: '게시글', en: 'Post', ja: '投稿'),
                      style: GBTTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: GBTSpacing.sm),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: textTertiary,
                ),
                const SizedBox(width: GBTSpacing.sm),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
