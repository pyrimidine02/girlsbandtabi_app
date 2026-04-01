/// EN: Zukan collections list page.
/// KO: 도감 컬렉션 목록 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/locale_text.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/navigation/gbt_standard_app_bar.dart';
import '../../application/zukan_controller.dart';
import '../../domain/entities/zukan_collection.dart';

/// EN: Displays the full list of zukan stamp collections for the selected project.
/// KO: 선택된 프로젝트의 전체 도감 스탬프 컬렉션 목록을 표시합니다.
class ZukanPage extends ConsumerWidget {
  const ZukanPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectId = ref.watch(selectedProjectKeyProvider);
    // EN: Use null when projectId is absent so the API returns all collections.
    // KO: projectId가 없을 때 null을 사용해 API가 모든 컬렉션을 반환하도록 합니다.
    final pid = (projectId?.isNotEmpty == true) ? projectId : null;
    final collectionsAsync = ref.watch(zukanCollectionsProvider(pid));

    return Scaffold(
      backgroundColor: isDark ? GBTColors.darkBackground : GBTColors.background,
      appBar: gbtStandardAppBar(
        context,
        title: context.l10n(
          ko: '성지순례 도감',
          en: 'Place Collection',
          ja: '聖地巡礼図鑑',
        ),
      ),
      body: collectionsAsync.when(
        loading: () => _ZukanShimmerList(),
        error: (_, __) => GBTEmptyState(
          message: context.l10n(
            ko: '도감을 불러오지 못했어요',
            en: 'Could not load collections',
            ja: '図鑑を読み込めませんでした',
          ),
          actionLabel: context.l10n(ko: '다시 시도', en: 'Retry', ja: '再試行'),
          onAction: () => ref.refresh(zukanCollectionsProvider(pid)),
        ),
        data: (collections) => collections.isEmpty
            ? GBTEmptyState(
                message: context.l10n(
                  ko: '아직 도감이 없어요',
                  en: 'No collections yet',
                  ja: '図鑑はまだありません',
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(GBTSpacing.pageHorizontal),
                itemCount: collections.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: GBTSpacing.md),
                    child: _CollectionCard(
                      collection: collections[index],
                      onTap: () => context.pushNamed(
                        AppRoutes.zukanDetail,
                        pathParameters: {'collectionId': collections[index].id},
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// EN: Shimmer placeholder list shown while collections are loading.
/// KO: 컬렉션 로딩 중 표시되는 쉬머 플레이스홀더 목록.
class _ZukanShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(GBTSpacing.pageHorizontal),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: GBTSpacing.md),
        child: GBTShimmer(
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: GBTColors.surfaceVariant,
              borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
            ),
          ),
        ),
      ),
    );
  }
}

/// EN: Card widget representing a single zukan collection summary.
/// KO: 단일 도감 컬렉션 요약을 나타내는 카드 위젯.
class _CollectionCard extends StatelessWidget {
  const _CollectionCard({required this.collection, required this.onTap});

  final ZukanCollectionSummary collection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressColor = collection.isCompleted
        ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
        : (isDark ? GBTColors.darkPrimary : GBTColors.primary);

    return Semantics(
      button: true,
      label: collection.title,
      hint: context.l10n(
        ko: '${collection.stampedCount}/${collection.totalCount} 방문. 탭하면 상세 보기',
        en: '${collection.stampedCount}/${collection.totalCount} visited. Tap for detail',
        ja: '${collection.stampedCount}/${collection.totalCount}訪問。タップで詳細表示',
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? GBTColors.darkSurface : GBTColors.surface,
            borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
          ),
          child: Row(
            children: [
              // EN: Cover image or placeholder icon
              // KO: 커버 이미지 또는 플레이스홀더 아이콘
              if (collection.coverImageUrl != null)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(GBTSpacing.radiusMd),
                    bottomLeft: Radius.circular(GBTSpacing.radiusMd),
                  ),
                  child: GBTImage(
                    imageUrl: collection.coverImageUrl!,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    semanticLabel: collection.title,
                  ),
                )
              else
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: isDark
                        ? GBTColors.darkPrimary.withValues(alpha: 0.15)
                        : GBTColors.primary.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(GBTSpacing.radiusMd),
                      bottomLeft: Radius.circular(GBTSpacing.radiusMd),
                    ),
                  ),
                  child: Icon(
                    Icons.photo_album_outlined,
                    color: isDark ? GBTColors.darkPrimary : GBTColors.primary,
                    size: 32,
                  ),
                ),

              // EN: Title, progress count, and progress bar
              // KO: 제목, 진행 카운트, 진행 바
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(GBTSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              collection.title,
                              style: GBTTypography.bodyMedium.copyWith(
                                color: isDark
                                    ? GBTColors.darkTextPrimary
                                    : GBTColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (collection.isCompleted)
                            const Icon(
                              Icons.verified,
                              color: Color(0xFF059669),
                              size: 18,
                            ),
                        ],
                      ),
                      const SizedBox(height: GBTSpacing.xs),
                      Text(
                        context.l10n(
                          ko: '${collection.stampedCount} / ${collection.totalCount}곳 방문',
                          en: '${collection.stampedCount} / ${collection.totalCount} visited',
                          ja: '${collection.stampedCount} / ${collection.totalCount}箇所訪問',
                        ),
                        style: GBTTypography.bodySmall.copyWith(
                          color: isDark
                              ? GBTColors.darkTextSecondary
                              : GBTColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: GBTSpacing.xs),
                      LinearProgressIndicator(
                        value: collection.progressRatio,
                        backgroundColor: isDark
                            ? GBTColors.darkSurfaceVariant
                            : GBTColors.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressColor,
                        ),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
                ),
              ),

              // EN: Trailing chevron
              // KO: 오른쪽 화살표
              Padding(
                padding: const EdgeInsets.only(right: GBTSpacing.sm),
                child: Icon(
                  Icons.chevron_right,
                  color: isDark
                      ? GBTColors.darkTextTertiary
                      : GBTColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
