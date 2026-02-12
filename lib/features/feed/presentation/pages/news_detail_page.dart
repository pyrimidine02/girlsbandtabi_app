/// EN: News detail page with full article content.
/// KO: 전체 기사 콘텐츠를 포함한 뉴스 상세 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/gbt_animations.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../application/feed_controller.dart';
import '../../domain/entities/feed_entities.dart';

/// EN: News detail page widget.
/// KO: 뉴스 상세 페이지 위젯.
class NewsDetailPage extends ConsumerWidget {
  const NewsDetailPage({super.key, required this.newsId});

  final String newsId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newsDetailControllerProvider(newsId));

    return state.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('뉴스')),
        body: const GBTLoading(message: '뉴스를 불러오는 중...'),
      ),
      error: (error, _) {
        final message = error is Failure ? error.userMessage : '뉴스를 불러오지 못했어요';
        return Scaffold(
          appBar: AppBar(title: const Text('뉴스')),
          body: GBTErrorState(
            message: message,
            onRetry: () => ref
                .read(newsDetailControllerProvider(newsId).notifier)
                .load(forceRefresh: true),
          ),
        );
      },
      data: (news) => _NewsDetailView(news: news),
    );
  }
}

/// EN: News detail view widget.
/// KO: 뉴스 상세 뷰 위젯.
class _NewsDetailView extends StatelessWidget {
  const _NewsDetailView({required this.news});

  final NewsDetail news;

  @override
  Widget build(BuildContext context) {
    final content = news.body;
    // EN: Use theme-aware colors for dark mode compatibility.
    // KO: 다크 모드 호환성을 위해 테마 인식 색상을 사용합니다.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tertiaryColor = isDark
        ? GBTColors.darkTextTertiary
        : GBTColors.textTertiary;
    final bodyColor = isDark
        ? GBTColors.darkTextSecondary
        : GBTColors.textSecondary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _NewsHeaderImage(
                newsId: news.id,
                imageUrl: news.coverImageUrl,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                tooltip: '북마크',
                onPressed: () {
                  // EN: TODO: Toggle bookmark.
                  // KO: TODO: 북마크 토글.
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: '공유',
                onPressed: () {
                  // EN: TODO: Share news.
                  // KO: TODO: 뉴스 공유.
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: GBTSpacing.paddingPage,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.dateLabel,
                    style: GBTTypography.labelSmall.copyWith(
                      color: tertiaryColor,
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.md),
                  Text(news.title, style: GBTTypography.headlineSmall),
                  const SizedBox(height: GBTSpacing.lg),
                  const Divider(),
                  const SizedBox(height: GBTSpacing.lg),
                  SelectableText(
                    content.isNotEmpty ? content : '기사 본문을 불러오지 못했어요.',
                    style: GBTTypography.bodyMedium.copyWith(
                      height: 1.8,
                      color: bodyColor,
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// EN: News header image widget with dark-mode-aware placeholder.
/// KO: 다크 모드 인식 플레이스홀더를 가진 뉴스 헤더 이미지 위젯.
class _NewsHeaderImage extends StatelessWidget {
  const _NewsHeaderImage({required this.newsId, required this.imageUrl});

  final String newsId;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    // EN: Use theme-aware placeholder colors.
    // KO: 테마 인식 플레이스홀더 색상을 사용합니다.
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        color: isDark ? GBTColors.darkSurfaceVariant : GBTColors.surfaceVariant,
        child: Center(
          child: Icon(
            Icons.article,
            size: 64,
            color: isDark ? GBTColors.darkTextTertiary : GBTColors.textTertiary,
          ),
        ),
      );
    }

    return Hero(
      tag: GBTHeroTags.newsImage(newsId),
      child: GBTImage(
        imageUrl: imageUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        semanticLabel: '뉴스 대표 이미지',
      ),
    );
  }
}
