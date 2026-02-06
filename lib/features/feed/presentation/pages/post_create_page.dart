/// EN: Community post creation page.
/// KO: 커뮤니티 게시글 작성 페이지.
library;

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
import '../../../uploads/application/uploads_controller.dart';
import '../../../uploads/utils/webp_image_converter.dart';

class PostCreatePage extends ConsumerStatefulWidget {
  const PostCreatePage({super.key});

  @override
  ConsumerState<PostCreatePage> createState() => _PostCreatePageState();
}

class _PostCreatePageState extends ConsumerState<PostCreatePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('글 작성')),
      body: isAuthenticated
          ? _buildForm(context)
          : const _LoginRequiredMessage(),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: GBTSpacing.paddingPage,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '제목'),
              maxLines: 1,
            ),
            const SizedBox(height: GBTSpacing.md),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: '내용'),
              maxLines: 8,
            ),
            const SizedBox(height: GBTSpacing.lg),
            Row(
              children: [
                Text(
                  '사진',
                  style: GBTTypography.labelMedium.copyWith(
                    color: GBTColors.textSecondary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _isSubmitting ? null : _pickImages,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('사진 추가'),
                ),
              ],
            ),
            if (_images.isNotEmpty) ...[
              Wrap(
                spacing: GBTSpacing.sm,
                runSpacing: GBTSpacing.sm,
                children: _images
                    .map(
                      (image) => Chip(
                        label: Text(p.basename(image.path)),
                        onDeleted: _isSubmitting
                            ? null
                            : () {
                                setState(() => _images.remove(image));
                              },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: GBTSpacing.md),
            ],
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: GBTTypography.bodySmall.copyWith(
                  color: GBTColors.error,
                ),
              ),
              const SizedBox(height: GBTSpacing.md),
            ],
            FilledButton.icon(
              onPressed: _isSubmitting ? null : () => _submit(context),
              icon: const Icon(Icons.send),
              label: const Text('등록'),
            ),
          ],
        ),
        if (_isSubmitting)
          Container(
            color: Colors.black.withValues(alpha: 0.1),
            child: const Center(
              child: GBTLoading(message: '게시글을 등록하는 중...'),
            ),
          ),
      ],
    );
  }

  Future<void> _submit(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('제목과 내용을 입력해주세요')),
      );
      return;
    }

    final projectCode = ref.read(selectedProjectKeyProvider);
    if (projectCode == null || projectCode.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('프로젝트를 먼저 선택해주세요')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    List<String> imageUrls = const [];
    if (_images.isNotEmpty) {
      try {
        imageUrls = await _uploadImages();
      } on Failure catch (failure) {
        setState(() => _errorMessage = failure.userMessage);
        setState(() => _isSubmitting = false);
        return;
      } catch (_) {
        setState(() => _errorMessage = '이미지 업로드에 실패했습니다.');
        setState(() => _isSubmitting = false);
        return;
      }
    }
    final contentWithImages = _appendImageMarkdown(content, imageUrls);

    final repository = await ref.read(feedRepositoryProvider.future);
    final result = await repository.createPost(
      projectCode: projectCode,
      title: title,
      content: contentWithImages,
    );

    if (!mounted) return;

    if (result is Success<PostDetail>) {
      await ref.read(postListControllerProvider.notifier).load(
        forceRefresh: true,
      );
      if (!mounted) return;
      router.goNamed(
        AppRoutes.postDetail,
        pathParameters: {'postId': result.data.id},
      );
    } else if (result is Err<PostDetail>) {
      messenger.showSnackBar(
        const SnackBar(content: Text('게시글을 등록하지 못했어요')),
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;
    setState(() => _images.addAll(picked));
  }

  Future<List<String>> _uploadImages() async {
    if (_images.isEmpty) return const [];
    final uploadController = ref.read(uploadsControllerProvider.notifier);
    final uploadUrls = <String>[];

    for (final image in _images) {
      final payload = await convertToWebp(
        path: image.path,
        originalFilename: p.basename(image.path),
      );
      final bytes = payload.bytes;
      final filename = payload.filename;
      final contentType = payload.contentType;

      final uploadResult = await uploadController.uploadImageBytes(
        bytes: bytes,
        filename: filename,
        contentType: contentType,
      );
      if (uploadResult case Err(:final failure)) {
        throw failure;
      }

      final upload = switch (uploadResult) {
        Success(:final data) => data,
        Err(:final failure) => throw failure,
      };

      if (upload.url.isNotEmpty) {
        uploadUrls.add(upload.url);
      }
    }

    return uploadUrls;
  }
}

String _appendImageMarkdown(String content, List<String> urls) {
  if (urls.isEmpty) return content;
  final buffer = StringBuffer(content);
  buffer.writeln('\n');
  for (final url in urls) {
    buffer.writeln('![]($url)');
  }
  return buffer.toString().trim();
}

class _LoginRequiredMessage extends StatelessWidget {
  const _LoginRequiredMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '로그인 후 게시글을 작성할 수 있어요.',
        style: GBTTypography.bodyMedium.copyWith(
          color: GBTColors.textSecondary,
        ),
      ),
    );
  }
}
