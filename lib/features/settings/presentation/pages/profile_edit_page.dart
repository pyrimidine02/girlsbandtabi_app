/// EN: Profile edit page for updating display name/avatar.
/// KO: 표시 이름/프로필을 수정하는 프로필 편집 페이지.
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
  final ImagePicker _imagePicker = ImagePicker();
  bool _didSetInitial = false;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  String? _pendingAvatarUrl;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final displayName = _displayNameController.text.trim();
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
                _isSaving || _isUploadingAvatar ? null : _saveProfile,
            child: Text(
              '저장',
              style: GBTTypography.bodyMedium.copyWith(
                color: _isSaving || _isUploadingAvatar
                    ? GBTColors.textTertiary
                    : GBTColors.accent,
              ),
            ),
          ),
        ],
      ),
      body: GBTLoadingOverlay(
        isLoading: _isSaving || _isUploadingAvatar,
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
              _didSetInitial = true;
            }
            return _ProfileForm(
              profile: profile,
              avatarUrl: _pendingAvatarUrl ?? profile.avatarUrl,
              displayNameController: _displayNameController,
              isUploadingAvatar: _isUploadingAvatar,
              onChangeAvatar: _changeAvatar,
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
        _handleAvatarFailure(failure);
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
        _handleAvatarFailure(failure);
        return;
      }

      await _resolveAvatarUrl(presigned.uploadId);
    } on Failure catch (failure) {
      _handleAvatarFailure(failure);
    } catch (_) {
      _showMessage('사진 업로드에 실패했습니다.');
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  void _handleAvatarFailure(Failure failure) {
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

  Future<void> _resolveAvatarUrl(String uploadId) async {
    final repository = await ref.read(uploadsRepositoryProvider.future);
    final result = await repository.getMyUploads(forceRefresh: true);
    if (result is Err<List<UploadInfo>>) {
      _handleAvatarFailure(result.failure);
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
    setState(() => _pendingAvatarUrl = match.url);
    _showMessage('사진이 업로드되었습니다. 저장을 눌러 반영하세요.');
  }
}

class _ProfileForm extends StatelessWidget {
  const _ProfileForm({
    required this.profile,
    required this.displayNameController,
    required this.avatarUrl,
    required this.isUploadingAvatar,
    required this.onChangeAvatar,
  });

  final UserProfile profile;
  final TextEditingController displayNameController;
  final String? avatarUrl;
  final bool isUploadingAvatar;
  final VoidCallback onChangeAvatar;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: GBTSpacing.paddingPage,
      children: [
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
