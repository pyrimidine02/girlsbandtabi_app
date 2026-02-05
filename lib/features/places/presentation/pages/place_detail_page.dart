/// EN: Place detail page with photos, info, and verification
/// KO: 사진, 정보, 인증을 포함한 장소 상세 페이지
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../favorites/application/favorites_controller.dart';
import '../../../favorites/domain/entities/favorite_entities.dart';
import '../../../projects/application/projects_controller.dart';
import '../../../settings/application/settings_controller.dart';
import '../../../uploads/application/uploads_controller.dart';
import '../../../verification/application/verification_controller.dart';
import '../../../verification/presentation/widgets/verification_sheet.dart';
import '../../application/places_controller.dart';
import '../../domain/entities/place_comment_entities.dart';
import '../../domain/entities/place_entities.dart';
import '../../domain/entities/place_guide_entities.dart';
import '../widgets/place_review_sheet.dart';

/// EN: Place detail page widget
/// KO: 장소 상세 페이지 위젯
class PlaceDetailPage extends ConsumerWidget {
  const PlaceDetailPage({super.key, required this.placeId});

  final String placeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(placeDetailControllerProvider(placeId));
    Future<void> handleRefresh() async {
      await _refreshAll(ref);
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: handleRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: state.when(
            loading: () => [
              const SliverFillRemaining(
                child: Center(
                  child: GBTLoading(message: '장소 정보를 불러오는 중...'),
                ),
              ),
            ],
            error: (error, _) {
              final message = error is Failure
                  ? error.userMessage
                  : '장소 정보를 불러오지 못했어요';
              return [
                SliverFillRemaining(
                  child: Center(
                    child: GBTErrorState(
                      message: message,
                      onRetry: () => ref
                          .read(
                            placeDetailControllerProvider(placeId).notifier,
                          )
                          .load(forceRefresh: true),
                    ),
                  ),
                ),
              ];
            },
            data: (place) => _buildContent(context, ref, place),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshAll(WidgetRef ref) async {
    await Future.wait([
      ref
          .read(placeDetailControllerProvider(placeId).notifier)
          .load(forceRefresh: true),
      ref
          .read(placeGuidesControllerProvider(placeId).notifier)
          .load(forceRefresh: true),
      ref
          .read(placeCommentsControllerProvider(placeId).notifier)
          .load(forceRefresh: true),
      ref.read(favoritesControllerProvider.notifier).load(forceRefresh: true),
    ]);
  }

  List<Widget> _buildContent(
    BuildContext context,
    WidgetRef ref,
    PlaceDetail place,
  ) {
    final selection = ref.watch(projectSelectionControllerProvider);
    final favoritesState = ref.watch(favoritesControllerProvider);
    final profileState = ref.watch(userProfileControllerProvider);
    final isFavorite = favoritesState.maybeWhen(
      data: (items) => items.any(
        (item) => item.entityId == place.id && item.type == FavoriteType.place,
      ),
      orElse: () => place.isFavorite,
    );
    final isAdmin = profileState.maybeWhen(
      data: (profile) => _isAdminRole(profile?.role),
      orElse: () => false,
    );
    final projectKey = selection.projectKey;
    final unitsState =
        projectKey != null && projectKey.isNotEmpty
            ? ref.watch(projectUnitsControllerProvider(projectKey))
            : null;
    final guidesState = ref.watch(placeGuidesControllerProvider(place.id));
    final commentsState = ref.watch(placeCommentsControllerProvider(place.id));

    return [
      SliverAppBar(
        expandedHeight: 250,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          background: place.heroImageUrl != null
              ? GBTImage(
                  imageUrl: place.heroImageUrl!,
                  fit: BoxFit.cover,
                  semanticLabel: place.name,
                )
              : Container(
                  color: GBTColors.surfaceVariant,
                  child: Center(
                    child: Icon(
                      Icons.image,
                      size: 64,
                      color: GBTColors.textTertiary,
                    ),
                  ),
                ),
        ),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              ref
                  .read(favoritesControllerProvider.notifier)
                  .toggleFavorite(
                    entityId: place.id,
                    type: FavoriteType.place,
                    isCurrentlyFavorite: isFavorite,
                  );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // EN: TODO: Share place
              // KO: TODO: 장소 공유
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
              Text(place.name, style: GBTTypography.headlineSmall),
              const SizedBox(height: GBTSpacing.xs),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: GBTColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      place.address,
                      style: GBTTypography.bodyMedium.copyWith(
                        color: GBTColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GBTSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    _showVerificationSheet(context, ref, place.id);
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('방문 인증하기'),
                ),
              ),
              const SizedBox(height: GBTSpacing.lg),
              const Divider(),
              const SizedBox(height: GBTSpacing.lg),
              Text(
                '소개',
                style: GBTTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GBTSpacing.sm),
              Text(
                place.description ?? '소개 정보가 없습니다.',
                style: GBTTypography.bodyMedium.copyWith(
                  color: GBTColors.textSecondary,
                ),
              ),
              const SizedBox(height: GBTSpacing.lg),
              Text(
                '장소 분류',
                style: GBTTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GBTSpacing.sm),
              if (place.tags.isEmpty && place.types.isEmpty)
                Text(
                  '장소 분류 정보가 없습니다.',
                  style: GBTTypography.bodySmall.copyWith(
                    color: GBTColors.textSecondary,
                  ),
                )
              else
                Wrap(
                  spacing: GBTSpacing.sm,
                  children: (place.tags.isNotEmpty
                          ? place.tags
                          : place.types.map(_formatPlaceType))
                      .map((category) => Chip(label: Text(category)))
                      .toList(),
                ),
              const SizedBox(height: GBTSpacing.lg),
              Text(
                '관련 밴드',
                style: GBTTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GBTSpacing.sm),
              if (unitsState == null)
                Text(
                  '관련 밴드 정보가 없습니다.',
                  style: GBTTypography.bodySmall.copyWith(
                    color: GBTColors.textSecondary,
                  ),
                )
              else
                unitsState.when(
                  loading: () => const GBTLoading(message: '관련 밴드 불러오는 중...'),
                  error: (error, _) {
                    final message = error is Failure
                        ? error.userMessage
                        : '관련 밴드를 불러오지 못했어요';
                    return Text(
                      message,
                      style: GBTTypography.bodySmall.copyWith(
                        color: GBTColors.textSecondary,
                      ),
                    );
                  },
                  data: (units) {
                    if (units.isEmpty) {
                      return Text(
                        '관련 밴드 정보가 없습니다.',
                        style: GBTTypography.bodySmall.copyWith(
                          color: GBTColors.textSecondary,
                        ),
                      );
                    }
                    return Wrap(
                      spacing: GBTSpacing.sm,
                      children: units
                          .map(
                            (unit) => Chip(
                              label: Text(
                                unit.code.isNotEmpty
                                    ? unit.code
                                    : unit.displayName,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              const SizedBox(height: GBTSpacing.lg),
              Text(
                '장소 가이드',
                style: GBTTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GBTSpacing.sm),
              _GuideSection(
                state: guidesState,
                onRetry: () => ref
                    .read(placeGuidesControllerProvider(place.id).notifier)
                    .load(forceRefresh: true),
              ),
              const SizedBox(height: GBTSpacing.lg),
              Text(
                '방문 후기',
                style: GBTTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GBTSpacing.sm),
              _CommentSection(
                placeId: place.id,
                state: commentsState,
                onRetry: () => ref
                    .read(placeCommentsControllerProvider(place.id).notifier)
                    .load(forceRefresh: true),
                isAdmin: isAdmin,
              ),
              const SizedBox(height: GBTSpacing.lg),
              Text(
                '방문 현황',
                style: GBTTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GBTSpacing.sm),
              Row(
                children: [
                  _StatCard(
                    icon: Icons.people,
                    label: '총 방문',
                    value: place.visitCount?.toString() ?? '-',
                  ),
                  const SizedBox(width: GBTSpacing.md),
                  _StatCard(
                    icon: Icons.favorite,
                    label: '좋아요',
                    value: place.favoriteCount?.toString() ?? '-',
                  ),
                ],
              ),
              const SizedBox(height: GBTSpacing.xxl),
            ],
          ),
        ),
      ),
    ];
  }
}

/// EN: Stat card widget
/// KO: 통계 카드 위젯
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: GBTSpacing.paddingMd,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(height: GBTSpacing.xs),
            Text(
              value,
              style: GBTTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: GBTTypography.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatPlaceType(String type) {
  return type.replaceAll('_', ' ');
}

class _GuideSection extends StatelessWidget {
  const _GuideSection({required this.state, required this.onRetry});

  final AsyncValue<List<PlaceGuideSummary>> state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => const GBTLoading(message: '가이드를 불러오는 중...'),
      error: (error, _) {
        if (_isForbidden(error)) {
          return _SectionMessage(message: '아직 준비중입니다.');
        }
        final message = error is Failure
            ? error.userMessage
            : '가이드를 불러오지 못했어요';
        return _SectionMessage(message: message, onRetry: onRetry);
      },
      data: (guides) {
        if (guides.isEmpty) {
          return _SectionMessage(message: '등록된 가이드가 없습니다.');
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: guides.length,
          separatorBuilder: (_, __) => const Divider(height: GBTSpacing.md),
          itemBuilder: (context, index) {
            final guide = guides[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(guide.title.isNotEmpty ? guide.title : '가이드'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (guide.preview.isNotEmpty)
                    Text(
                      guide.preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (guide.updatedAtLabel.isNotEmpty)
                    Text(
                      guide.updatedAtLabel,
                      style: GBTTypography.labelSmall.copyWith(
                        color: GBTColors.textSecondary,
                      ),
                    ),
                ],
              ),
              trailing:
                  guide.hasImages ? const Icon(Icons.photo_outlined) : null,
              onTap: () {},
            );
          },
        );
      },
    );
  }
}

class _CommentSection extends ConsumerStatefulWidget {
  const _CommentSection({
    required this.placeId,
    required this.state,
    required this.onRetry,
    required this.isAdmin,
  });

  final String placeId;
  final AsyncValue<List<PlaceComment>> state;
  final VoidCallback onRetry;
  final bool isAdmin;

  @override
  ConsumerState<_CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends ConsumerState<_CommentSection> {
  final Set<String> _approvingIds = {};
  final Set<String> _rejectedIds = {};

  @override
  Widget build(BuildContext context) {
    return widget.state.when(
      loading: () => const GBTLoading(message: '후기를 불러오는 중...'),
      error: (error, _) {
        if (_isForbidden(error)) {
          return _SectionMessage(message: '아직 준비중입니다.');
        }
        final message = error is Failure
            ? error.userMessage
            : '후기를 불러오지 못했어요';
        return _SectionMessage(message: message, onRetry: widget.onRetry);
      },
      data: (comments) {
        if (comments.isEmpty) {
          return _SectionMessage(message: '등록된 후기가 없습니다.');
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          separatorBuilder: (_, __) => const Divider(height: GBTSpacing.md),
          itemBuilder: (context, index) {
            final comment = comments[index];
            final authorLabel =
                comment.authorId.isNotEmpty ? '방문자' : '익명 방문자';
            final isApproving = _approvingIds.contains(comment.id);
            final isRejected = _rejectedIds.contains(comment.id);
            final isFullyApproved = comment.photoUploadIds.isNotEmpty &&
                comment.photoUrls.length >= comment.photoUploadIds.length;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(authorLabel),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (comment.body.isNotEmpty)
                        Text(
                          comment.body,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (comment.createdAtLabel.isNotEmpty)
                        Text(
                          comment.createdAtLabel,
                          style: GBTTypography.labelSmall.copyWith(
                            color: GBTColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  trailing: comment.replyCount > 0
                      ? Text(
                          '답글 ${comment.replyCount}',
                          style: GBTTypography.labelSmall.copyWith(
                            color: GBTColors.textSecondary,
                          ),
                        )
                      : null,
                ),
                if (comment.photoUrls.isNotEmpty)
                  Wrap(
                    spacing: GBTSpacing.xs,
                    runSpacing: GBTSpacing.xs,
                    children: comment.photoUrls
                        .map(
                          (url) => ClipRRect(
                            borderRadius: BorderRadius.circular(
                              GBTSpacing.radiusSm,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _showPhotoPreview(url),
                                child: GBTImage(
                                  imageUrl: url,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  semanticLabel: '방문 후기 사진',
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                if (widget.isAdmin && comment.photoUploadIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: GBTSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isRejected)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: GBTSpacing.xs),
                            child: Text(
                              '반려됨',
                              style: GBTTypography.labelSmall.copyWith(
                                color: GBTColors.textSecondary,
                              ),
                            ),
                          )
                        else if (isFullyApproved)
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: GBTSpacing.xs),
                            child: Text(
                              '승인됨',
                              style: GBTTypography.labelSmall.copyWith(
                                color: GBTColors.textSecondary,
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed:
                                  isApproving || isFullyApproved || isRejected
                                      ? null
                                      : () => _approvePhotos(
                                            comment,
                                            isApproved: true,
                                          ),
                              child:
                                  Text(isApproving ? '처리 중...' : '사진 승인'),
                            ),
                            const SizedBox(width: GBTSpacing.sm),
                            OutlinedButton(
                              onPressed:
                                  isApproving || isFullyApproved || isRejected
                                      ? null
                                      : () => _approvePhotos(
                                            comment,
                                            isApproved: false,
                                          ),
                              child: const Text('사진 반려'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _approvePhotos(
    PlaceComment comment, {
    required bool isApproved,
  }) async {
    if (comment.photoUploadIds.isEmpty) return;
    setState(() => _approvingIds.add(comment.id));

    final uploadController = ref.read(uploadsControllerProvider.notifier);
    for (final uploadId in comment.photoUploadIds) {
      final result = await uploadController.approveUpload(
        uploadId: uploadId,
        isApproved: isApproved,
      );
      if (result case Err(:final failure)) {
        _showMessage(failure.userMessage);
        if (mounted) {
          setState(() => _approvingIds.remove(comment.id));
        }
        return;
      }
      if (!isApproved) {
        final deleteResult = await uploadController.deleteUpload(uploadId);
        if (deleteResult case Err(:final failure)) {
          _showMessage(failure.userMessage);
          if (mounted) {
            setState(() => _approvingIds.remove(comment.id));
          }
          return;
        }
      }
    }

    if (mounted) {
      setState(() => _approvingIds.remove(comment.id));
    }
    await ref
        .read(placeCommentsControllerProvider(widget.placeId).notifier)
        .load(forceRefresh: true);
    if (mounted) {
      setState(() {
        if (isApproved) {
          _rejectedIds.remove(comment.id);
        } else {
          _rejectedIds.add(comment.id);
        }
      });
    }
    _showMessage(isApproved ? '사진 승인 완료' : '사진 반려 완료');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showPhotoPreview(String url) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Dialog(
            insetPadding: const EdgeInsets.all(GBTSpacing.md),
            backgroundColor: Colors.transparent,
            child: InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                child: GBTImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  semanticLabel: '방문 후기 사진 확대',
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionMessage extends StatelessWidget {
  const _SectionMessage({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: GBTTypography.bodySmall.copyWith(
            color: GBTColors.textSecondary,
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: GBTSpacing.xs),
          TextButton(
            onPressed: onRetry,
            child: const Text('다시 시도'),
          ),
        ],
      ],
    );
  }
}

bool _isForbidden(Object error) {
  return error is AuthFailure && error.code == '403';
}

bool _isAdminRole(String? role) {
  if (role == null) return false;
  final normalized = role.toUpperCase();
  return normalized.contains('ADMIN') || normalized.contains('MODERATOR');
}

void _showVerificationSheet(
  BuildContext context,
  WidgetRef ref,
  String placeId,
) {
  ref.read(verificationControllerProvider.notifier).reset();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => VerificationSheet(
      title: '방문 인증',
      description: '현재 위치를 확인해 방문 인증을 진행합니다.',
      onVerify: () => ref
          .read(verificationControllerProvider.notifier)
          .verifyPlace(placeId),
      onWriteReview: () => _showReviewSheet(context, placeId),
    ),
  );
}

void _showReviewSheet(BuildContext context, String placeId) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => PlaceReviewSheet(placeId: placeId),
  );
}
