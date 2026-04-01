/// EN: Zukan collection detail page — stamp grid for one collection.
/// KO: 도감 컬렉션 상세 페이지 — 하나의 컬렉션 스탬프 그리드.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/locale_text.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../../core/widgets/navigation/gbt_standard_app_bar.dart';
import '../../application/zukan_controller.dart';
import '../../domain/entities/zukan_collection.dart';

/// EN: Displays the stamp grid detail for a single zukan collection.
/// KO: 단일 도감 컬렉션의 스탬프 그리드 상세를 표시합니다.
class ZukanDetailPage extends ConsumerWidget {
  const ZukanDetailPage({super.key, required this.collectionId});

  final String collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final collectionAsync = ref.watch(
      zukanCollectionDetailProvider(collectionId),
    );
    final appBarTitle = collectionAsync.maybeWhen(
      data: (collection) => collection?.title,
      orElse: () => null,
    );

    return Scaffold(
      backgroundColor: isDark ? GBTColors.darkBackground : GBTColors.background,
      appBar: gbtStandardAppBar(
        context,
        title: appBarTitle?.isNotEmpty == true
            ? appBarTitle!
            : context.l10n(ko: '도감', en: 'Collection', ja: '図鑑'),
      ),
      body: collectionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => GBTEmptyState(
          message: context.l10n(
            ko: '도감을 불러오지 못했어요',
            en: 'Could not load collection',
            ja: '図鑑を読み込めませんでした',
          ),
          actionLabel: context.l10n(ko: '다시 시도', en: 'Retry', ja: '再試行'),
          onAction: () =>
              ref.refresh(zukanCollectionDetailProvider(collectionId)),
        ),
        data: (collection) => collection == null
            ? GBTEmptyState(
                message: context.l10n(
                  ko: '도감을 찾을 수 없어요',
                  en: 'Collection not found',
                  ja: '図鑑が見つかりません',
                ),
              )
            : _CollectionDetail(collection: collection),
      ),
    );
  }
}

/// EN: Scrollable body with progress header, reward banner, and stamp grid.
/// KO: 진행 헤더, 보상 배너, 스탬프 그리드를 포함한 스크롤 가능한 본문.
class _CollectionDetail extends StatelessWidget {
  const _CollectionDetail({required this.collection});

  final ZukanCollection collection;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressColor = collection.isCompleted
        ? const Color(0xFF059669)
        : (isDark ? GBTColors.darkPrimary : GBTColors.primary);

    return ListView(
      padding: const EdgeInsets.all(GBTSpacing.pageHorizontal),
      children: [
        // EN: Progress summary header
        // KO: 진행 요약 헤더
        Container(
          padding: const EdgeInsets.all(GBTSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? GBTColors.darkSurface : GBTColors.surface,
            borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (collection.description != null) ...[
                Text(
                  collection.description!,
                  style: GBTTypography.bodySmall.copyWith(
                    color: isDark
                        ? GBTColors.darkTextSecondary
                        : GBTColors.textSecondary,
                  ),
                ),
                const SizedBox(height: GBTSpacing.sm),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${collection.stampedCount} / ${collection.totalCount}',
                    style: GBTTypography.titleMedium.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (collection.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        context.l10n(ko: '완료!', en: 'Complete!', ja: '完了!'),
                        style: GBTTypography.labelSmall.copyWith(
                          color: const Color(0xFF059669),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: GBTSpacing.xs),
              LinearProgressIndicator(
                value: collection.progressRatio,
                backgroundColor: isDark
                    ? GBTColors.darkSurfaceVariant
                    : GBTColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),

        // EN: Reward banner — only shown when collection is complete
        // KO: 보상 배너 — 컬렉션 완료 시에만 표시
        if (collection.isCompleted && collection.rewardDescription != null) ...[
          const SizedBox(height: GBTSpacing.md),
          Container(
            padding: const EdgeInsets.all(GBTSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9C3),
              borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
            ),
            child: Row(
              children: [
                const Text('🏅', style: TextStyle(fontSize: 24)),
                const SizedBox(width: GBTSpacing.sm),
                Expanded(
                  child: Text(
                    collection.rewardDescription!,
                    style: GBTTypography.bodySmall.copyWith(
                      color: const Color(0xFF78350F),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: GBTSpacing.md),

        Text(
          context.l10n(ko: '스탬프', en: 'Stamps', ja: 'スタンプ'),
          style: GBTTypography.titleMedium.copyWith(
            color: isDark ? GBTColors.darkTextPrimary : GBTColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: GBTSpacing.sm),

        // EN: Stamp grid — 3 columns, non-scrollable (inside ListView)
        // KO: 스탬프 그리드 — 3열, 비스크롤 (ListView 내부)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: GBTSpacing.sm,
            mainAxisSpacing: GBTSpacing.sm,
            childAspectRatio: 0.8,
          ),
          itemCount: collection.stamps.length,
          itemBuilder: (context, index) {
            return _StampItem(stamp: collection.stamps[index]);
          },
        ),

        const SizedBox(height: GBTSpacing.xl),
      ],
    );
  }
}

/// EN: Individual stamp cell in the 3-column stamp grid.
/// KO: 3열 스탬프 그리드의 개별 스탬프 셀.
class _StampItem extends StatelessWidget {
  const _StampItem({required this.stamp});

  final ZukanStamp stamp;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isStamped = stamp.isStamped;

    return Semantics(
      button: isStamped,
      label: stamp.placeName,
      hint: isStamped
          ? context.l10n(
              ko: '방문 완료. 탭하면 장소 상세 보기',
              en: 'Visited. Tap for place detail',
              ja: '訪問済み。タップで場所の詳細表示',
            )
          : context.l10n(ko: '미방문', en: 'Not yet visited', ja: '未訪問'),
      child: InkWell(
        // EN: Tapping a stamped cell opens place detail; unvisited cells are not interactive.
        // KO: 스탬프된 셀을 탭하면 장소 상세를 열고, 미방문 셀은 인터랙션 없음.
        onTap: isStamped ? () => context.goToPlaceDetail(stamp.placeId) : null,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? GBTColors.darkSurface : GBTColors.surface,
            borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
            border: isStamped
                ? Border.all(
                    color: isDark ? GBTColors.darkPrimary : GBTColors.primary,
                    width: 1.5,
                  )
                : null,
          ),
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(GBTSpacing.radiusSm),
                    topRight: Radius.circular(GBTSpacing.radiusSm),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // EN: Show place image only if stamped and image URL available
                      // KO: 스탬프됐고 이미지 URL이 있을 때만 장소 이미지 표시
                      if (stamp.placeImageUrl != null && isStamped)
                        GBTImage(
                          imageUrl: stamp.placeImageUrl!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          semanticLabel: stamp.placeName,
                        )
                      else
                        Container(
                          color: isDark
                              ? GBTColors.darkSurfaceVariant
                              : GBTColors.surfaceVariant,
                          child: Icon(
                            isStamped
                                ? Icons.location_on_outlined
                                : Icons.lock_outline,
                            color: isStamped
                                ? (isDark
                                      ? GBTColors.darkPrimary
                                      : GBTColors.primary)
                                : (isDark
                                      ? GBTColors.darkTextTertiary
                                      : GBTColors.textTertiary),
                            size: 28,
                          ),
                        ),

                      // EN: Dark scrim + lock icon overlay for unvisited stamps
                      // KO: 미방문 스탬프에 대한 어두운 스크림 + 잠금 아이콘 오버레이
                      if (!isStamped)
                        Positioned.fill(
                          child: ColoredBox(
                            color: Colors.black.withValues(alpha: 0.35),
                            child: const Icon(
                              Icons.lock_outline,
                              color: Colors.white60,
                              size: 24,
                            ),
                          ),
                        ),

                      // EN: Completion badge for stamped cells
                      // KO: 스탬프된 셀의 완료 배지
                      if (isStamped)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? GBTColors.darkPrimary
                                  : GBTColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // EN: Place name label below the image
              // KO: 이미지 아래 장소 이름 라벨
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: GBTSpacing.xs,
                  vertical: GBTSpacing.xxs,
                ),
                child: Text(
                  stamp.placeName,
                  style: GBTTypography.labelSmall.copyWith(
                    color: isDark
                        ? GBTColors.darkTextPrimary
                        : GBTColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
