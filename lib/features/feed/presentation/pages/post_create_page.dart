/// EN: Community post creation page.
/// KO: 커뮤니티 게시글 작성 페이지.
library;

import 'dart:async';
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
import '../widgets/post_compose_components.dart';

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
  static const String _draftStorageKey = 'feed_post_create_draft_v1';

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  late final PostComposeAutosaveConfig _autosaveConfig;
  late final PostComposeAutosaveController _autosaveController;
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

  PostComposeAutosaveState get _autosaveState {
    return ref.read(postComposeAutosaveControllerProvider(_autosaveConfig));
  }

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
    _autosaveConfig = const PostComposeAutosaveConfig(
      storageKey: _draftStorageKey,
    );
    _autosaveController = ref.read(
      postComposeAutosaveControllerProvider(_autosaveConfig).notifier,
    );
    _titleController.addListener(_onFormChanged);
    _contentController.addListener(_onFormChanged);
    unawaited(_autosaveController.loadRecoverableDraft());
  }

  @override
  void dispose() {
    if (!_isSubmitting) {
      unawaited(
        _autosaveController.saveSnapshot(
          title: _titleController.text,
          content: _contentController.text,
          imagePaths: _images
              .map((image) => image.path)
              .toList(growable: false),
          hasData: _hasDraft,
          silent: true,
        ),
      );
    }
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
    _scheduleDraftSave();
    setState(() {});
  }

  void _scheduleDraftSave() {
    if (_isSubmitting) {
      return;
    }
    _autosaveController.scheduleSave(
      title: _titleController.text,
      content: _contentController.text,
      imagePaths: _images.map((image) => image.path).toList(growable: false),
      hasData: _hasDraft,
    );
  }

  void _restoreDraft() {
    final draft = _autosaveState.recoverableDraft;
    if (draft == null) {
      return;
    }

    final existingImagePaths = draft.imagePaths
        .where((path) => File(path).existsSync())
        .take(_maxImageCount)
        .toList(growable: false);

    setState(() {
      _titleController.text = draft.title;
      _contentController.text = draft.content;
      _images
        ..clear()
        ..addAll(existingImagePaths.map((path) => XFile(path)));
    });
    _autosaveController.consumeRecoverableDraft(message: '임시 저장 글을 복구했어요');

    _scheduleDraftSave();
    _showMessage('임시 저장 글을 복구했어요.');
  }

  Future<void> _discardRecoverableDraft() async {
    await _autosaveController.clearSavedDraft(silent: true);
    _showMessage('임시 저장 글을 삭제했어요.');
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
        content: const Text('현재 입력 내용은 임시 저장되어 다음에 복구할 수 있어요.'),
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
            : const PostComposeLoginRequiredMessage(),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    // EN: Use theme-aware colors for improved dark mode readability.
    // KO: 다크 모드 가독성을 위해 테마 기반 색상을 사용합니다.
    final colorScheme = Theme.of(context).colorScheme;
    final projectCode = ref.watch(selectedProjectKeyProvider);
    final autosaveState = ref.watch(
      postComposeAutosaveControllerProvider(_autosaveConfig),
    );

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
                    const PostComposeIntroCard(
                      title: '게시글을 작성해요',
                      description: '핵심 정보와 사진을 함께 올리면 피드에서 더 잘 보여요.',
                      icon: Icons.edit_note_outlined,
                    ),
                    const SizedBox(height: GBTSpacing.md),
                    PostComposeStatusCard(
                      completionRatio: _completionRatio,
                      hasTitle: _titleController.text.trim().isNotEmpty,
                      hasContent: _contentController.text.trim().length >= 30,
                      hasImage: _images.isNotEmpty,
                    ),
                    const SizedBox(height: GBTSpacing.md),
                    const ProjectSelectorCompact(),
                    const SizedBox(height: GBTSpacing.md),
                    PostComposeProjectBadge(projectCode: projectCode),
                    if (autosaveState.recoverableDraft != null) ...[
                      const SizedBox(height: GBTSpacing.md),
                      PostComposeDraftRecoveryBanner(
                        savedAt: autosaveState.recoverableDraft!.savedAt,
                        projectCode:
                            autosaveState.recoverableDraft!.projectCode,
                        onRestore: _restoreDraft,
                        onDiscard: _discardRecoverableDraft,
                      ),
                    ],
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
                    PostComposeImageSection(
                      imageCount: _images.length,
                      maxImageCount: _maxImageCount,
                      isSubmitting: _isSubmitting,
                      onPickImages: _pickImages,
                      onClearAll: _images.isEmpty
                          ? null
                          : () {
                              setState(_images.clear);
                              _scheduleDraftSave();
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
                                return PostComposePickedImageTile(
                                  imagePath: image.path,
                                  filename: p.basename(image.path),
                                  onPreview: () => _previewImage(image),
                                  onRemove: _isSubmitting
                                      ? null
                                      : () {
                                          setState(() {
                                            _images.remove(image);
                                          });
                                          _scheduleDraftSave();
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (autosaveState.autosaveMessage != null) ...[
                          Text(
                            autosaveState.autosaveMessage!,
                            style: GBTTypography.labelSmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: GBTSpacing.xs),
                        ],
                        FilledButton.icon(
                          onPressed: _canSubmit ? () => _submit(context) : null,
                          icon: const Icon(Icons.send),
                          label: Text(_submitButtonLabel),
                        ),
                      ],
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
    final contentWithImages = appendImageMarkdownContent(content, imageUrls);

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
      await _autosaveController.clearSavedDraft(silent: true);
      if (!mounted) {
        return;
      }
      router.pushReplacementNamed(
        AppRoutes.postDetail,
        pathParameters: {'postId': data.id},
      );
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
    _scheduleDraftSave();

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
