/// EN: Profile edit page for updating display name/avatar/bio/cover.
/// KO: 표시 이름/아바타/소개/배경 이미지를 수정하는 프로필 편집 페이지.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../../../../core/error/failure.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/theme/gbt_colors.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/common/gbt_image.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';
import '../../../uploads/application/uploads_controller.dart';
import '../../../uploads/domain/entities/upload_entity.dart';
import '../../../uploads/utils/presigned_upload_helper.dart';
import '../../../uploads/utils/webp_image_converter.dart';
import '../../application/settings_controller.dart';
import '../../domain/entities/user_profile.dart';

/// EN: Profile edit page widget.
/// KO: 프로필 편집 페이지 위젯.
class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _bioController;
  final ImagePicker _imagePicker = ImagePicker();
  bool _didSetInitial = false;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  bool _isUploadingCover = false;
  String? _pendingAvatarUrl;
  String? _pendingCoverUrl;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final displayName = _displayNameController.text.trim();
    final bio = _bioController.text.trim();
    if (displayName.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('표시 이름을 입력해주세요')));
      return;
    }

    setState(() => _isSaving = true);

    final profile = ref.read(userProfileControllerProvider).valueOrNull;
    final result = await ref
        .read(userProfileControllerProvider.notifier)
        .updateProfile(
          displayName: displayName,
          avatarUrl: _pendingAvatarUrl ?? profile?.avatarUrl,
          bio: bio.isEmpty ? null : bio,
          coverImageUrl: _pendingCoverUrl ?? profile?.coverImageUrl,
        );

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (result is Success<UserProfile>) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('프로필이 저장되었습니다')));
      context.pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('프로필 저장에 실패했습니다')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('프로필 수정')),
        body: _LoginRequired(onLogin: () => context.push('/login')),
      );
    }

    final state = ref.watch(userProfileControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
        actions: [
          TextButton(
            onPressed:
                _isSaving || _isUploadingAvatar || _isUploadingCover
                    ? null
                    : _saveProfile,
            child: Text(
              '저장',
              style: GBTTypography.bodyMedium.copyWith(
                color: _isSaving || _isUploadingAvatar || _isUploadingCover
                    ? GBTColors.textTertiary
                    : GBTColors.accent,
              ),
            ),
          ),
        ],
      ),
      body: GBTLoadingOverlay(
        isLoading: _isSaving || _isUploadingAvatar || _isUploadingCover,
        child: state.when(
          loading: () => const GBTLoading(message: '프로필을 불러오는 중...'),
          error: (error, _) => Center(
            child: Padding(
              padding: GBTSpacing.paddingPage,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('프로필 정보를 불러오지 못했어요', style: GBTTypography.titleSmall),
                  const SizedBox(height: GBTSpacing.sm),
                  Text(
                    '잠시 후 다시 시도해주세요',
                    style: GBTTypography.bodySmall.copyWith(
                      color: GBTColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.lg),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(userProfileControllerProvider.notifier)
                        .load(forceRefresh: true),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          ),
          data: (profile) {
            if (profile == null) {
              return const SizedBox.shrink();
            }
            if (!_didSetInitial) {
              _displayNameController.text = profile.displayName;
              _bioController.text = profile.bio ?? '';
              _didSetInitial = true;
            }
            return _ProfileForm(
              profile: profile,
              avatarUrl: _pendingAvatarUrl ?? profile.avatarUrl,
              coverUrl: _pendingCoverUrl ?? profile.coverImageUrl,
              displayNameController: _displayNameController,
              bioController: _bioController,
              isUploadingAvatar: _isUploadingAvatar,
              isUploadingCover: _isUploadingCover,
              onChangeAvatar: _changeAvatar,
              onChangeCover: _changeCover,
            );
          },
        ),
      ),
    );
  }

  Future<void> _changeAvatar() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 90,
    );
    if (picked == null) return;

    setState(() => _isUploadingAvatar = true);

    try {
      final payload = await convertToWebp(
        path: picked.path,
        originalFilename: p.basename(picked.path),
        maxWidth: 1024,
        maxHeight: 1024,
        quality: 85,
      );
      final bytes = payload.bytes;
      final filename = payload.filename;
      final contentType = payload.contentType;
      final uploadController =
          ref.read(uploadsControllerProvider.notifier);

      final presignedResult = await uploadController.requestPresignedUrl(
        filename: filename,
        contentType: contentType,
        size: bytes.length,
      );
      if (presignedResult case Err(:final failure)) {
        _handleUploadFailure(failure);
        return;
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
        _handleUploadFailure(failure);
        return;
      }

      await _resolveUploadUrl(
        uploadId: presigned.uploadId,
        onResolved: (url) => _pendingAvatarUrl = url,
        successMessage: '사진이 업로드되었습니다. 저장을 눌러 반영하세요.',
      );
    } on Failure catch (failure) {
      _handleUploadFailure(failure);
    } catch (_) {
      _showMessage('사진 업로드에 실패했습니다.');
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  Future<void> _changeCover() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 90,
    );
    if (picked == null) return;

    setState(() => _isUploadingCover = true);

    try {
      final payload = await convertToWebp(
        path: picked.path,
        originalFilename: p.basename(picked.path),
        maxWidth: 1920,
        maxHeight: 1080,
        quality: 80,
      );
      final bytes = payload.bytes;
      final filename = payload.filename;
      final contentType = payload.contentType;
      final uploadController =
          ref.read(uploadsControllerProvider.notifier);

      final presignedResult = await uploadController.requestPresignedUrl(
        filename: filename,
        contentType: contentType,
        size: bytes.length,
      );
      if (presignedResult case Err(:final failure)) {
        _handleUploadFailure(failure);
        return;
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
        _handleUploadFailure(failure);
        return;
      }

      await _resolveUploadUrl(
        uploadId: presigned.uploadId,
        onResolved: (url) => _pendingCoverUrl = url,
        successMessage: '배경 이미지가 업로드되었습니다. 저장을 눌러 반영하세요.',
      );
    } on Failure catch (failure) {
      _handleUploadFailure(failure);
    } catch (_) {
      _showMessage('배경 이미지 업로드에 실패했습니다.');
    } finally {
      if (mounted) {
        setState(() => _isUploadingCover = false);
      }
    }
  }

  void _handleUploadFailure(Failure failure) {
    if (!mounted) return;
    final message =
        failure is AuthFailure && failure.code == '403'
            ? '아직 준비중입니다.'
            : failure.userMessage;
    _showMessage(message);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _resolveUploadUrl({
    required String uploadId,
    required ValueChanged<String> onResolved,
    required String successMessage,
  }) async {
    final repository = await ref.read(uploadsRepositoryProvider.future);
    final result = await repository.getMyUploads(forceRefresh: true);
    if (result is Err<List<UploadInfo>>) {
      _handleUploadFailure(result.failure);
      return;
    }

    final uploads = (result as Success<List<UploadInfo>>).data;
    final match = uploads.firstWhere(
      (item) => item.uploadId == uploadId,
      orElse: () => const UploadInfo(
        uploadId: '',
        url: '',
        filename: '',
        isApproved: false,
      ),
    );

    if (match.uploadId.isEmpty || match.url.isEmpty) {
      _showMessage('업로드 정보를 가져오지 못했습니다.');
      return;
    }

    if (!mounted) return;
    setState(() => onResolved(match.url));
    _showMessage(successMessage);
  }
}

class _ProfileForm extends StatelessWidget {
  const _ProfileForm({
    required this.profile,
    required this.displayNameController,
    required this.bioController,
    required this.avatarUrl,
    required this.coverUrl,
    required this.isUploadingAvatar,
    required this.isUploadingCover,
    required this.onChangeAvatar,
    required this.onChangeCover,
  });

  final UserProfile profile;
  final TextEditingController displayNameController;
  final TextEditingController bioController;
  final String? avatarUrl;
  final String? coverUrl;
  final bool isUploadingAvatar;
  final bool isUploadingCover;
  final VoidCallback onChangeAvatar;
  final VoidCallback onChangeCover;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: GBTSpacing.paddingPage,
      children: [
        Text(
          '배경 이미지',
          style: GBTTypography.labelMedium.copyWith(
            color: GBTColors.textSecondary,
          ),
        ),
        const SizedBox(height: GBTSpacing.xs),
        _ProfileCoverPreview(
          coverUrl: coverUrl,
          isUploading: isUploadingCover,
        ),
        const SizedBox(height: GBTSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: isUploadingCover ? null : onChangeCover,
            child: Text(isUploadingCover ? '업로드 중...' : '배경 이미지 변경'),
          ),
        ),
        const SizedBox(height: GBTSpacing.lg),
        Center(
          child: Column(
            children: [
              _ProfileAvatar(
                avatarUrl: avatarUrl,
                isUploading: isUploadingAvatar,
              ),
              const SizedBox(height: GBTSpacing.sm),
              TextButton(
                onPressed: isUploadingAvatar ? null : onChangeAvatar,
                child: Text(isUploadingAvatar ? '업로드 중...' : '사진 변경'),
              ),
            ],
          ),
        ),
        const SizedBox(height: GBTSpacing.lg),
        Text(
          '표시 이름',
          style: GBTTypography.labelMedium.copyWith(
            color: GBTColors.textSecondary,
          ),
        ),
        const SizedBox(height: GBTSpacing.xs),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
            hintText: '표시 이름을 입력하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
            ),
          ),
        ),
        const SizedBox(height: GBTSpacing.lg),
        Text(
          '소개',
          style: GBTTypography.labelMedium.copyWith(
            color: GBTColors.textSecondary,
          ),
        ),
        const SizedBox(height: GBTSpacing.xs),
        TextField(
          controller: bioController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '간단한 소개를 입력하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
            ),
          ),
        ),
        const SizedBox(height: GBTSpacing.lg),
        Text(
          '이메일',
          style: GBTTypography.labelMedium.copyWith(
            color: GBTColors.textSecondary,
          ),
        ),
        const SizedBox(height: GBTSpacing.xs),
        Text(profile.email, style: GBTTypography.bodyMedium),
        const SizedBox(height: GBTSpacing.lg),
        Text(
          '권한',
          style: GBTTypography.labelMedium.copyWith(
            color: GBTColors.textSecondary,
          ),
        ),
        const SizedBox(height: GBTSpacing.xs),
        Text(profile.role, style: GBTTypography.bodyMedium),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.avatarUrl, this.isUploading = false});

  final String? avatarUrl;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    final avatar = avatarUrl == null || avatarUrl!.isEmpty
        ? CircleAvatar(
            radius: 40,
            backgroundColor: GBTColors.surfaceVariant,
            child: Icon(
              Icons.person,
              size: 40,
              color: GBTColors.textTertiary,
            ),
          )
        : ClipOval(
            child: GBTImage(
              imageUrl: avatarUrl!,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              semanticLabel: '프로필 이미지',
            ),
          );

    if (!isUploading) {
      return avatar;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        avatar,
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ],
    );
  }
}

class _ProfileCoverPreview extends StatelessWidget {
  const _ProfileCoverPreview({
    required this.coverUrl,
    this.isUploading = false,
  });

  final String? coverUrl;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    final preview = ClipRRect(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      child: coverUrl == null || coverUrl!.isEmpty
          ? Container(
              height: 140,
              color: GBTColors.surfaceVariant,
              alignment: Alignment.center,
              child: Text(
                '배경 이미지 없음',
                style: GBTTypography.labelSmall.copyWith(
                  color: GBTColors.textTertiary,
                ),
              ),
            )
          : GBTImage(
              imageUrl: coverUrl!,
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
              semanticLabel: '프로필 배경 이미지',
            ),
    );

    if (!isUploading) {
      return preview;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        preview,
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
          ),
        ),
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ],
    );
  }
}

class _LoginRequired extends StatelessWidget {
  const _LoginRequired({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: GBTSpacing.paddingPage,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: GBTColors.textTertiary),
            const SizedBox(height: GBTSpacing.md),
            Text('로그인이 필요합니다', style: GBTTypography.titleSmall),
            const SizedBox(height: GBTSpacing.sm),
            Text(
              '프로필을 수정하려면 로그인해주세요.',
              style: GBTTypography.bodySmall.copyWith(
                color: GBTColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: GBTSpacing.lg),
            ElevatedButton(onPressed: onLogin, child: const Text('로그인')),
          ],
        ),
      ),
    );
  }
}
