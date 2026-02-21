/// EN: Community post creation page.
/// KO: 커뮤니티 게시글 작성 페이지.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../../../core/error/failure.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../application/feed_controller.dart';
import '../../domain/entities/feed_entities.dart';
import '../../../projects/presentation/widgets/project_selector.dart';
import '../../../uploads/application/uploads_controller.dart';
import '../../../uploads/domain/entities/upload_entity.dart';
import '../../../uploads/utils/webp_image_converter.dart';

/// EN: Community post creation page widget.
/// KO: 커뮤니티 게시글 작성 페이지 위젯.
class PostCreatePage extends ConsumerStatefulWidget {
  const PostCreatePage({super.key});

  @override
  ConsumerState<PostCreatePage> createState() => _PostCreatePageState();
}

class _PostCreatePageState extends ConsumerState<PostCreatePage> {
  static const int _maxTitleLength = 60;
  static const int _maxContentLength = 3000;
  static const int _maxImageCount = 6;

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _hasDraft {
    return _titleController.text.trim().isNotEmpty ||
        _contentController.text.trim().isNotEmpty ||
        _images.isNotEmpty;
  }

  bool get _canSubmit {
    return _titleController.text.trim().isNotEmpty &&
        _contentController.text.trim().isNotEmpty &&
        !_isSubmitting;
  }

  int get _remainingImageSlots => _maxImageCount - _images.length;

  double get _completionRatio {
    var steps = 0;
    if (_titleController.text.trim().isNotEmpty) {
      steps += 1;
    }
    if (_contentController.text.trim().length >= 30) {
      steps += 1;
    }
    if (_images.isNotEmpty) {
      steps += 1;
    }
    return steps / 3;
  }

  String get _submitButtonLabel {
    if (_canSubmit) {
      return '게시글 등록';
    }
    if (_titleController.text.trim().isEmpty) {
      return '제목을 입력해주세요';
    }
    if (_contentController.text.trim().isEmpty) {
      return '내용을 입력해주세요';
    }
    return '등록 중...';
  }

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onFormChanged);
    _contentController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFormChanged);
    _contentController.removeListener(_onFormChanged);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<bool> _handleWillPop() async {
    if (_isSubmitting) {
      return false;
    }
    if (!_hasDraft) {
      return true;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('작성 중인 내용을 나갈까요?'),
        content: const Text('저장하지 않은 내용이 사라집니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('계속 작성'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('나가기'),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return PopScope<Object?>(
      canPop: !_isSubmitting && !_hasDraft,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        final shouldPop = await _handleWillPop();
        if (!mounted || !shouldPop) {
          return;
        }
        Navigator.of(this.context).pop(result);
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('글 작성')),
        body: isAuthenticated
            ? _buildForm(context)
            : const _LoginRequiredMessage(),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    // EN: Use theme-aware colors for improved dark mode readability.
    // KO: 다크 모드 가독성을 위해 테마 기반 색상을 사용합니다.
    final colorScheme = Theme.of(context).colorScheme;
    final projectCode = ref.watch(selectedProjectKeyProvider);

    return Stack(
      children: [
        GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: GBTSpacing.paddingPage,
                  children: [
                    _ComposeStatusCard(
                      completionRatio: _completionRatio,
                      hasTitle: _titleController.text.trim().isNotEmpty,
                      hasContent: _contentController.text.trim().length >= 30,
                      hasImage: _images.isNotEmpty,
                    ),
                    const SizedBox(height: GBTSpacing.md),
                    const ProjectSelectorCompact(),
                    const SizedBox(height: GBTSpacing.md),
                    _ProjectBadge(projectCode: projectCode),
                    const SizedBox(height: GBTSpacing.lg),
                    TextField(
                      controller: _titleController,
                      maxLength: _maxTitleLength,
                      maxLines: 1,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: '제목',
                        hintText: '예: 도쿄 성지순례 후기',
                        helperText: '핵심 요약 위주로 작성하면 잘 보여요.',
                        prefixIcon: const Icon(Icons.title),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.35),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            GBTSpacing.radiusMd,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: GBTSpacing.sm),
                    TextField(
                      controller: _contentController,
                      maxLength: _maxContentLength,
                      minLines: 8,
                      maxLines: 14,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        labelText: '내용',
                        hintText: '방문 팁, 이동 경로, 주의사항을 함께 남겨주세요.',
                        helperText: '30자 이상 작성하면 내용 전달력이 좋아집니다.',
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 76),
                          child: Icon(Icons.notes_outlined),
                        ),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.35),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            GBTSpacing.radiusMd,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: GBTSpacing.md),
                    _ImageSection(
                      imageCount: _images.length,
                      maxImageCount: _maxImageCount,
                      isSubmitting: _isSubmitting,
                      onPickImages: _pickImages,
                      onClearAll: _images.isEmpty
                          ? null
                          : () {
                              setState(_images.clear);
                            },
                      imageGrid: _images.isEmpty
                          ? null
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _images.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: GBTSpacing.sm,
                                    mainAxisSpacing: GBTSpacing.sm,
                                    childAspectRatio: 1,
                                  ),
                              itemBuilder: (context, index) {
                                final image = _images[index];
                                return _PickedImageTile(
                                  imagePath: image.path,
                                  filename: p.basename(image.path),
                                  onPreview: () => _previewImage(image),
                                  onRemove: _isSubmitting
                                      ? null
                                      : () {
                                          setState(() {
                                            _images.remove(image);
                                          });
                                        },
                                );
                              },
                            ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: GBTSpacing.md),
                      Semantics(
                        liveRegion: true,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(GBTSpacing.sm),
                          decoration: BoxDecoration(
                            color: GBTColors.errorLight,
                            borderRadius: BorderRadius.circular(
                              GBTSpacing.radiusSm,
                            ),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: GBTTypography.bodySmall.copyWith(
                              color: GBTColors.errorDark,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: GBTSpacing.xl),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    GBTSpacing.md,
                    GBTSpacing.sm,
                    GBTSpacing.md,
                    GBTSpacing.sm,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _canSubmit ? () => _submit(context) : null,
                      icon: const Icon(Icons.send),
                      label: Text(_submitButtonLabel),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isSubmitting)
          Container(
            color: Colors.black.withValues(alpha: 0.22),
            child: const Center(child: GBTLoading(message: '게시글을 등록하는 중...')),
          ),
      ],
    );
  }

  void _previewImage(XFile image) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(GBTSpacing.lg),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
          child: Container(
            color: Colors.black,
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Image.file(
                      File(image.path),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Text(
                          '이미지를 표시할 수 없습니다',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: GBTSpacing.xs,
                  top: GBTSpacing.xs,
                  child: IconButton.filledTonal(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: '닫기',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('제목과 내용을 입력해주세요')));
      return;
    }

    final projectCode = ref.read(selectedProjectKeyProvider);
    if (projectCode == null || projectCode.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('프로젝트를 먼저 선택해주세요')));
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    var imageUploadIds = const <String>[];
    var imageUrls = const <String>[];
    if (_images.isNotEmpty) {
      try {
        final uploads = await _uploadImages();
        // EN: Collect both IDs (for the server) and URLs (for markdown embed).
        // KO: 서버용 ID와 마크다운 삽입용 URL을 모두 수집합니다.
        imageUploadIds = uploads.map((u) => u.uploadId).toList();
        imageUrls = uploads.map((u) => u.url).toList();
      } on Failure catch (failure) {
        setState(() {
          _errorMessage = failure.userMessage;
          _isSubmitting = false;
        });
        return;
      } catch (_) {
        setState(() {
          _errorMessage = '이미지 업로드에 실패했습니다.';
          _isSubmitting = false;
        });
        return;
      }
    }
    final contentWithImages = _appendImageMarkdown(content, imageUrls);

    final repository = await ref.read(feedRepositoryProvider.future);
    final result = await repository.createPost(
      projectCode: projectCode,
      title: title,
      content: contentWithImages,
      imageUploadIds: imageUploadIds,
    );

    if (!mounted) {
      return;
    }

    if (result case Success<PostDetail>(:final data)) {
      await ref
          .read(postListControllerProvider.notifier)
          .load(forceRefresh: true);
      if (!mounted) {
        return;
      }
      router.goNamed(AppRoutes.postDetail, pathParameters: {'postId': data.id});
    } else if (result case Err<PostDetail>(:final failure)) {
      messenger.showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }

    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
  }

  Future<void> _pickImages() async {
    if (_remainingImageSlots <= 0) {
      _showMessage('이미지는 최대 $_maxImageCount장까지 첨부할 수 있어요.');
      return;
    }

    final picked = await _picker.pickMultiImage(
      maxHeight: 2160,
      maxWidth: 2160,
      imageQuality: 92,
    );

    if (picked.isEmpty || !mounted) {
      return;
    }

    final existingPaths = _images.map((image) => image.path).toSet();
    final uniquePicked = <XFile>[];
    for (final image in picked) {
      if (existingPaths.add(image.path)) {
        uniquePicked.add(image);
      }
    }

    if (uniquePicked.isEmpty) {
      _showMessage('이미 추가된 사진입니다.');
      return;
    }

    final addable = uniquePicked.take(_remainingImageSlots).toList();
    final droppedCount = uniquePicked.length - addable.length;

    setState(() {
      _images.addAll(addable);
    });

    if (droppedCount > 0) {
      _showMessage('$_maxImageCount장까지만 첨부할 수 있어요.');
    }
  }

  Future<List<UploadInfo>> _uploadImages() async {
    if (_images.isEmpty) return const [];

    final uploadController = ref.read(uploadsControllerProvider.notifier);
    final uploads = <UploadInfo>[];

    for (final image in _images) {
      final payload = await convertToWebp(
        path: image.path,
        originalFilename: p.basename(image.path),
      );

      final uploadResult = await uploadController.uploadImageBytes(
        bytes: payload.bytes,
        filename: payload.filename,
        contentType: payload.contentType,
      );

      final upload = switch (uploadResult) {
        Success(:final data) => data,
        Err(:final failure) => throw failure,
      };

      if (upload.url.isNotEmpty) {
        uploads.add(upload);
      }
    }

    return uploads;
  }
}

String _appendImageMarkdown(String content, List<String> urls) {
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

class _ComposeStatusCard extends StatelessWidget {
  const _ComposeStatusCard({
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
              _GuideChip(label: '제목', isDone: hasTitle),
              _GuideChip(label: '내용 30자+', isDone: hasContent),
              _GuideChip(label: '이미지(선택)', isDone: hasImage),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuideChip extends StatelessWidget {
  const _GuideChip({required this.label, required this.isDone});

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

class _ProjectBadge extends StatelessWidget {
  const _ProjectBadge({required this.projectCode});

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

class _ImageSection extends StatelessWidget {
  const _ImageSection({
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

class _PickedImageTile extends StatelessWidget {
  const _PickedImageTile({
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

/// EN: Login required message widget with icon and descriptive text.
/// KO: 아이콘과 설명 텍스트를 포함한 로그인 필요 메시지 위젯.
class _LoginRequiredMessage extends StatelessWidget {
  const _LoginRequiredMessage();

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
