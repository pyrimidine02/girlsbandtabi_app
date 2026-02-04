/// EN: News detail page with full article content.
/// KO: 전체 기사 콘텐츠를 포함한 뉴스 상세 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
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

class _NewsDetailView extends StatelessWidget {
  const _NewsDetailView({required this.news});

  final NewsDetail news;

  @override
  Widget build(BuildContext context) {
    final content = news.body;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _NewsHeaderImage(imageUrl: news.coverImageUrl),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () {
                  // EN: TODO: Toggle bookmark.
                  // KO: TODO: 북마크 토글.
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
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
                  Row(
                    children: [
                      Text(
                        news.dateLabel,
                        style: GBTTypography.labelSmall.copyWith(
                          color: GBTColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GBTSpacing.md),
                  Text(news.title, style: GBTTypography.headlineSmall),
                  const SizedBox(height: GBTSpacing.lg),
                  const Divider(),
                  const SizedBox(height: GBTSpacing.lg),
                  Text(
                    content.isNotEmpty
                        ? content
                        : '기사 본문을 불러오지 못했어요.',
                    style: GBTTypography.bodyMedium.copyWith(
                      height: 1.8,
                      color: GBTColors.textSecondary,
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

class _NewsHeaderImage extends StatelessWidget {
  const _NewsHeaderImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        color: GBTColors.surfaceVariant,
        child: Center(
          child: Icon(Icons.article, size: 64, color: GBTColors.textTertiary),
        ),
      );
    }

    return GBTImage(
      imageUrl: imageUrl!,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      semanticLabel: '뉴스 대표 이미지',
    );
  }
}
