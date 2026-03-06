/// EN: Shared compose components for post create/edit pages.
/// KO: 게시글 작성/수정 페이지 공용 컴포넌트 모음입니다.
library;

import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/widgets/common/gbt_image.dart';

/// EN: Appends markdown image blocks to post content.
/// KO: 게시글 본문 뒤에 이미지 마크다운 블록을 추가합니다.
String appendImageMarkdownContent(String content, List<String> urls) {
  if (urls.isEmpty) {
    return content;
  }

  final buffer = StringBuffer(content);
  buffer.writeln('\n');
  for (final url in urls) {
    buffer.writeln('![]($url)');
  }
  return buffer.toString().trim();
}

/// EN: Intro card for compose pages.
/// KO: 작성/수정 페이지 상단 소개 카드입니다.
class PostComposeIntroCard extends StatelessWidget {
  const PostComposeIntroCard({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.edit_note_outlined,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(GBTSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
            ),
            child: Icon(icon, size: 18, color: colorScheme.primary),
          ),
          const SizedBox(width: GBTSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GBTTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: GBTSpacing.xxs),
                Text(
                  description,
                  style: GBTTypography.bodySmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// EN: Inline banner for recovering an unsent local draft.
/// KO: 미전송 임시저장 글 복구를 위한 인라인 배너입니다.
class PostComposeDraftRecoveryBanner extends StatelessWidget {
  const PostComposeDraftRecoveryBanner({
    super.key,
    required this.savedAt,
    required this.projectCode,
    required this.onRestore,
    required this.onDiscard,
  });

  final DateTime savedAt;
  final String? projectCode;
  final VoidCallback onRestore;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hour = savedAt.hour.toString().padLeft(2, '0');
    final minute = savedAt.minute.toString().padLeft(2, '0');
    final projectLabel = projectCode?.isNotEmpty == true
        ? ' · $projectCode'
        : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(GBTSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.26),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '임시 저장된 글이 있어요',
            style: GBTTypography.labelLarge.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: GBTSpacing.xxs),
          Text(
            '저장 시각 $hour:$minute$projectLabel',
            style: GBTTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: GBTSpacing.xs),
          Row(
            children: [
              FilledButton.tonal(onPressed: onRestore, child: const Text('복구')),
              const SizedBox(width: GBTSpacing.xs),
              TextButton(onPressed: onDiscard, child: const Text('삭제')),
            ],
          ),
        ],
      ),
    );
  }
}

/// EN: Compose progress card (title/content/image completion).
/// KO: 작성 진행률 카드(제목/내용/이미지 완료 상태)입니다.
class PostComposeStatusCard extends StatelessWidget {
  const PostComposeStatusCard({
    super.key,
    required this.completionRatio,
    required this.hasTitle,
    required this.hasContent,
    required this.hasImage,
  });

  final double completionRatio;
  final bool hasTitle;
  final bool hasContent;
  final bool hasImage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(GBTSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: colorScheme.primary, size: 18),
              const SizedBox(width: GBTSpacing.xs),
              Text(
                '작성 가이드',
                style: GBTTypography.titleSmall.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${(completionRatio * 100).round()}%',
                style: GBTTypography.labelMedium.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: GBTSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
            child: LinearProgressIndicator(
              value: completionRatio,
              minHeight: 6,
              backgroundColor: colorScheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: GBTSpacing.sm),
          Wrap(
            spacing: GBTSpacing.sm,
            runSpacing: GBTSpacing.sm,
            children: [
              _PostComposeGuideChip(label: '제목', isDone: hasTitle),
              _PostComposeGuideChip(label: '내용 30자+', isDone: hasContent),
              _PostComposeGuideChip(label: '이미지(선택)', isDone: hasImage),
            ],
          ),
        ],
      ),
    );
  }
}

class _PostComposeGuideChip extends StatelessWidget {
  const _PostComposeGuideChip({required this.label, required this.isDone});

  final String label;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.sm,
        vertical: GBTSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDone
            ? colorScheme.primary.withValues(alpha: 0.14)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
        border: Border.all(
          color: isDone
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: isDone ? colorScheme.primary : colorScheme.outline,
          ),
          const SizedBox(width: GBTSpacing.xs),
          Text(
            label,
            style: GBTTypography.labelSmall.copyWith(
              color: isDone ? colorScheme.primary : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// EN: Badge showing the currently selected project.
/// KO: 현재 선택 프로젝트를 보여주는 배지입니다.
class PostComposeProjectBadge extends StatelessWidget {
  const PostComposeProjectBadge({super.key, required this.projectCode});

  final String? projectCode;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.md,
        vertical: GBTSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            Icons.folder_outlined,
            color: colorScheme.onSurfaceVariant,
            size: 18,
          ),
          const SizedBox(width: GBTSpacing.xs),
          Expanded(
            child: Text(
              projectCode == null || projectCode!.isEmpty
                  ? '프로젝트를 선택해주세요'
                  : '현재 프로젝트: $projectCode',
              style: GBTTypography.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// EN: Image picker section used by compose forms.
/// KO: 작성 폼에서 사용하는 이미지 섹션입니다.
class PostComposeImageSection extends StatelessWidget {
  const PostComposeImageSection({
    super.key,
    required this.imageCount,
    required this.maxImageCount,
    required this.isSubmitting,
    required this.onPickImages,
    required this.onClearAll,
    required this.imageGrid,
  });

  final int imageCount;
  final int maxImageCount;
  final bool isSubmitting;
  final VoidCallback onPickImages;
  final VoidCallback? onClearAll;
  final Widget? imageGrid;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(GBTSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '사진',
                style: GBTTypography.labelLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: GBTSpacing.xs),
              Text(
                '$imageCount/$maxImageCount',
                style: GBTTypography.labelSmall.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: isSubmitting || imageCount >= maxImageCount
                    ? null
                    : onPickImages,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('추가'),
              ),
              if (onClearAll != null)
                TextButton(
                  onPressed: isSubmitting ? null : onClearAll,
                  child: const Text('전체 삭제'),
                ),
            ],
          ),
          const SizedBox(height: GBTSpacing.xs),
          Text(
            '장소 사진을 추가하면 게시글 전달력이 좋아져요.',
            style: GBTTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (imageGrid != null) ...[
            const SizedBox(height: GBTSpacing.md),
            imageGrid!,
          ] else ...[
            const SizedBox(height: GBTSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: GBTSpacing.lg),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.35,
                ),
                borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.photo_size_select_actual_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: GBTSpacing.xs),
                  Text(
                    '최대 $maxImageCount장 첨부 가능',
                    style: GBTTypography.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// EN: Preview tile for selected image files.
/// KO: 선택한 이미지 파일 미리보기 타일입니다.
class PostComposePickedImageTile extends StatelessWidget {
  const PostComposePickedImageTile({
    super.key,
    required this.imagePath,
    required this.filename,
    required this.onPreview,
    this.onRemove,
  });

  final String imagePath;
  final String filename;
  final VoidCallback onPreview;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: '$filename 미리보기',
      child: Material(
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPreview,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GBTSpacing.xs,
                    vertical: GBTSpacing.xxs,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0xB3000000)],
                    ),
                  ),
                  child: Text(
                    filename,
                    style: GBTTypography.caption.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Positioned(
                top: GBTSpacing.xs,
                right: GBTSpacing.xs,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: IconButton.filled(
                    padding: EdgeInsets.zero,
                    onPressed: onRemove,
                    iconSize: 14,
                    icon: const Icon(Icons.close),
                    tooltip: '사진 제거',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// EN: Preview tile for existing remote image URLs.
/// KO: 기존 원격 이미지 URL 미리보기 타일입니다.
class PostComposeRemoteImageTile extends StatelessWidget {
  const PostComposeRemoteImageTile({
    super.key,
    required this.imageUrl,
    required this.filename,
    required this.onPreview,
    this.onRemove,
  });

  final String imageUrl;
  final String filename;
  final VoidCallback onPreview;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: '$filename 미리보기',
      child: Material(
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPreview,
          child: Stack(
            children: [
              Positioned.fill(
                child: GBTImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: Container(
                    color: colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GBTSpacing.xs,
                    vertical: GBTSpacing.xxs,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0xB3000000)],
                    ),
                  ),
                  child: Text(
                    filename,
                    style: GBTTypography.caption.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (onRemove != null)
                Positioned(
                  top: GBTSpacing.xs,
                  right: GBTSpacing.xs,
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: IconButton.filled(
                      padding: EdgeInsets.zero,
                      onPressed: onRemove,
                      iconSize: 14,
                      icon: const Icon(Icons.close),
                      tooltip: '사진 제거',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// EN: Login required message widget with icon and descriptive text.
/// KO: 아이콘과 설명 텍스트를 포함한 로그인 필요 메시지 위젯.
class PostComposeLoginRequiredMessage extends StatelessWidget {
  const PostComposeLoginRequiredMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: GBTSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 48,
              color: isDark
                  ? GBTColors.darkTextTertiary
                  : GBTColors.textTertiary,
            ),
            const SizedBox(height: GBTSpacing.md),
            Text(
              '로그인 후 게시글을 작성할 수 있어요.',
              style: GBTTypography.bodyMedium.copyWith(
                color: isDark
                    ? GBTColors.darkTextSecondary
                    : GBTColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
