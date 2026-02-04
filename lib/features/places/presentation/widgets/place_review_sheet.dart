/// EN: Place review sheet for comments and photo uploads.
/// KO: 방문 후기 및 사진 업로드 시트.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../../../core/error/failure.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../uploads/application/uploads_controller.dart';
import '../../../uploads/utils/presigned_upload_helper.dart';
import '../../../uploads/utils/webp_image_converter.dart';
import '../../application/places_controller.dart';

class PlaceReviewSheet extends ConsumerStatefulWidget {
  const PlaceReviewSheet({super.key, required this.placeId});

  final String placeId;

  @override
  ConsumerState<PlaceReviewSheet> createState() => _PlaceReviewSheetState();
}

class _PlaceReviewSheetState extends ConsumerState<PlaceReviewSheet> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        !_isSubmitting && _controller.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        left: GBTSpacing.md,
        right: GBTSpacing.md,
        top: GBTSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + GBTSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: GBTColors.border,
                borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
              ),
            ),
          ),
          const SizedBox(height: GBTSpacing.md),
          Text('방문 후기 작성', style: GBTTypography.titleMedium),
          const SizedBox(height: GBTSpacing.sm),
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: '방문 후기를 남겨주세요',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: GBTSpacing.sm),
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
            const SizedBox(height: GBTSpacing.sm),
          ],
          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: GBTTypography.bodySmall.copyWith(
                color: GBTColors.error,
              ),
            ),
            const SizedBox(height: GBTSpacing.sm),
          ],
          if (_isSubmitting)
            const GBTLoading(message: '후기를 등록하는 중...')
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: canSubmit ? _submit : null,
                child: const Text('등록'),
              ),
            ),
          const SizedBox(height: GBTSpacing.sm),
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;
    setState(() => _images.addAll(picked));
  }

  Future<void> _submit() async {
    final body = _controller.text.trim();
    if (body.isEmpty) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final uploadIds = await _uploadImages();
      final repository = await ref.read(placesRepositoryProvider.future);
      final result = await repository.createPlaceComment(
        placeId: widget.placeId,
        body: body,
        photoUploadIds: uploadIds,
        tags: const [],
        isPublic: true,
      );

      if (result case Err(:final failure)) {
        _handleFailure(failure);
        return;
      }

      await ref
          .read(placeCommentsControllerProvider(widget.placeId).notifier)
          .load(forceRefresh: true);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on Failure catch (failure) {
      _handleFailure(failure);
    } catch (_) {
      setState(() {
        _errorMessage = '이미지 업로드에 실패했습니다.';
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<List<String>> _uploadImages() async {
    if (_images.isEmpty) return <String>[];
    final uploadController =
        ref.read(uploadsControllerProvider.notifier);
    final uploadIds = <String>[];

    for (final image in _images) {
      final payload = await convertToWebp(
        path: image.path,
        originalFilename: p.basename(image.path),
      );
      final bytes = payload.bytes;
      final filename = payload.filename;
      final contentType = payload.contentType;

      final presignedResult = await uploadController.requestPresignedUrl(
        filename: filename,
        contentType: contentType,
        size: bytes.length,
      );
      if (presignedResult case Err(:final failure)) {
        throw failure;
      }

      final presigned = switch (presignedResult) {
        Success(:final data) => data,
        Err(:final failure) => throw failure,
      };
      await uploadToPresignedUrl(
        url: presigned.url,
        bytes: bytes,
        contentType: contentType,
        headers: presigned.headers,
      );

      final confirmResult =
          await uploadController.confirmUpload(presigned.uploadId);
      if (confirmResult case Err(:final failure)) {
        throw failure;
      }

      uploadIds.add(presigned.uploadId);
    }

    return uploadIds;
  }

  void _handleFailure(Failure failure) {
    setState(() {
      if (failure is AuthFailure && failure.code == '403') {
        _errorMessage = '아직 준비중입니다.';
      } else {
        _errorMessage = failure.userMessage;
      }
    });
  }
}
