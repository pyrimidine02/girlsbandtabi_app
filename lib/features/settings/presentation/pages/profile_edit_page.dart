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
    final colorScheme = Theme.of(context).colorScheme;
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (!isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('프로필 수정')),
        body: _LoginRequired(onLogin: () => context.push('/login')),
      );
    }

    final state = ref.watch(userProfileControllerProvider);
    final isBusy = _isSaving || _isUploadingAvatar || _isUploadingCover;

    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
        actions: [
          Semantics(
            button: true,
            label: isBusy ? '저장 중' : '프로필 저장',
            enabled: !isBusy,
            child: TextButton(
              onPressed: isBusy ? null : _saveProfile,
              style: TextButton.styleFrom(
                minimumSize: const Size(
                  GBTSpacing.touchTarget,
                  GBTSpacing.touchTarget,
                ),
              ),
              child: Text(
                '저장',
                style: GBTTypography.bodyMedium.copyWith(
                  // EN: Use theme-aware color for dark mode
                  // KO: 다크 모드를 위해 테마 인식 색상 사용
                  color: isBusy
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: GBTLoadingOverlay(
        isLoading: isBusy,
        message: _isSaving
            ? '프로필 저장 중...'
            : _isUploadingAvatar
            ? '프로필 사진 업로드 중...'
            : _isUploadingCover
            ? '배경 이미지 업로드 중...'
            : null,
        child: state.when(
          loading: () => const GBTLoading(message: '프로필을 불러오는 중...'),
          error: (error, _) => Center(
            child: Padding(
              padding: GBTSpacing.paddingPage,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // EN: Error icon for visual context
                  // KO: 시각적 맥락을 위한 오류 아이콘
                  Icon(
                    Icons.error_outline,
                    size: GBTSpacing.xxl,
                    color: colorScheme.error,
                    semanticLabel: '오류 아이콘',
                  ),
                  const SizedBox(height: GBTSpacing.md),
                  Text(
                    '프로필 정보를 불러오지 못했어요',
                    style: GBTTypography.titleSmall.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.sm),
                  Text(
                    '잠시 후 다시 시도해주세요',
                    style: GBTTypography.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: GBTSpacing.lg),
                  Semantics(
                    button: true,
                    label: '프로필 정보 다시 불러오기',
                    child: ElevatedButton(
                      onPressed: () => ref
                          .read(userProfileControllerProvider.notifier)
                          .load(forceRefresh: true),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(
                          GBTSpacing.touchTarget,
                          GBTSpacing.touchTarget,
                        ),
                      ),
                      child: const Text('다시 시도'),
                    ),
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
      final uploadController = ref.read(uploadsControllerProvider.notifier);

      final uploadResult = await uploadController.uploadImageBytes(
        bytes: bytes,
        filename: filename,
        contentType: contentType,
      );
      if (uploadResult case Err(:final failure)) {
        _handleUploadFailure(failure);
        return;
      }

      final upload = switch (uploadResult) {
        Success(:final data) => data,
        Err(:final failure) => throw failure,
      };

      if (upload.url.isEmpty) {
        _showMessage('업로드 정보를 가져오지 못했습니다.');
        return;
      }

      if (!mounted) return;
      setState(() => _pendingAvatarUrl = upload.url);
      _showMessage('사진이 업로드되었습니다. 저장을 눌러 반영하세요.');
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
      final uploadController = ref.read(uploadsControllerProvider.notifier);

      final uploadResult = await uploadController.uploadImageBytes(
        bytes: bytes,
        filename: filename,
        contentType: contentType,
      );
      if (uploadResult case Err(:final failure)) {
        _handleUploadFailure(failure);
        return;
      }

      final upload = switch (uploadResult) {
        Success(:final data) => data,
        Err(:final failure) => throw failure,
      };

      if (upload.url.isEmpty) {
        _showMessage('업로드 정보를 가져오지 못했습니다.');
        return;
      }

      if (!mounted) return;
      setState(() => _pendingCoverUrl = upload.url);
      _showMessage('배경 이미지가 업로드되었습니다. 저장을 눌러 반영하세요.');
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
    final message = failure is AuthFailure && failure.code == '403'
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
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: GBTSpacing.paddingPage,
      children: [
        Text(
          '배경 이미지',
          style: GBTTypography.labelMedium.copyWith(
            // EN: Use theme-aware secondary text color
            // KO: 테마 인식 보조 텍스트 색상 사용
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: GBTSpacing.xs),
        _ProfileCoverPreview(coverUrl: coverUrl, isUploading: isUploadingCover),
        const SizedBox(height: GBTSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: Semantics(
            button: true,
            label: isUploadingCover ? '배경 이미지 업로드 중' : '배경 이미지 변경',
            child: TextButton(
              onPressed: isUploadingCover ? null : onChangeCover,
              style: TextButton.styleFrom(
                minimumSize: const Size(
                  GBTSpacing.touchTarget,
                  GBTSpacing.touchTarget,
                ),
              ),
              child: Text(isUploadingCover ? '업로드 중...' : '배경 이미지 변경'),
            ),
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
              Semantics(
                button: true,
                label: isUploadingAvatar ? '프로필 사진 업로드 중' : '프로필 사진 변경',
                child: TextButton(
                  onPressed: isUploadingAvatar ? null : onChangeAvatar,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(
                      GBTSpacing.touchTarget,
                      GBTSpacing.touchTarget,
                    ),
                  ),
                  child: Text(isUploadingAvatar ? '업로드 중...' : '사진 변경'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: GBTSpacing.lg),
        Text(
          '표시 이름',
          style: GBTTypography.labelMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
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
          // EN: Limit display name length to prevent overflow
          // KO: 오버플로 방지를 위해 표시 이름 길이 제한
          maxLength: 30,
        ),
        const SizedBox(height: GBTSpacing.lg),
        Text(
          '소개',
          style: GBTTypography.labelMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: GBTSpacing.xs),
        TextField(
          controller: bioController,
          maxLines: 3,
          // EN: Limit bio length to prevent overflow
          // KO: 오버플로 방지를 위해 소개 길이 제한
          maxLength: 200,
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
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: GBTSpacing.xs),
        Text(
          profile.email,
          style: GBTTypography.bodyMedium.copyWith(
            color: colorScheme.onSurface,
          ),
          // EN: Prevent overflow on long email addresses
          // KO: 긴 이메일 주소에서 오버플로 방지
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: GBTSpacing.lg),
        Text(
          '권한',
          style: GBTTypography.labelMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: GBTSpacing.xs),
        Text(
          profile.role,
          style: GBTTypography.bodyMedium.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final avatar = avatarUrl == null || avatarUrl!.isEmpty
        ? CircleAvatar(
            radius: 40,
            backgroundColor: isDark
                ? GBTColors.darkSurfaceVariant
                : GBTColors.surfaceVariant,
            child: Icon(
              Icons.person,
              size: 40,
              color: isDark
                  ? GBTColors.darkTextTertiary
                  : GBTColors.textTertiary,
              semanticLabel: '기본 프로필 이미지',
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

    // EN: Dark-mode-aware overlay alpha for upload indicator
    // KO: 업로드 표시를 위한 다크 모드 인식 오버레이 알파
    final overlayAlpha = isDark ? 0.5 : 0.35;

    return Semantics(
      label: '프로필 이미지 업로드 중',
      child: Stack(
        alignment: Alignment.center,
        children: [
          avatar,
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: overlayAlpha),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final preview = ClipRRect(
      borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
      child: coverUrl == null || coverUrl!.isEmpty
          ? Container(
              height: 140,
              color: isDark
                  ? GBTColors.darkSurfaceVariant
                  : GBTColors.surfaceVariant,
              alignment: Alignment.center,
              child: Text(
                '배경 이미지 없음',
                style: GBTTypography.labelSmall.copyWith(
                  color: isDark
                      ? GBTColors.darkTextTertiary
                      : GBTColors.textTertiary,
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

    // EN: Dark-mode-aware overlay alpha for upload indicator
    // KO: 업로드 표시를 위한 다크 모드 인식 오버레이 알파
    final overlayAlpha = isDark ? 0.5 : 0.35;

    return Semantics(
      label: '배경 이미지 업로드 중',
      child: Stack(
        alignment: Alignment.center,
        children: [
          preview,
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: overlayAlpha),
              borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
            ),
          ),
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }
}

class _LoginRequired extends StatelessWidget {
  const _LoginRequired({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: GBTSpacing.paddingPage,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: GBTSpacing.touchTarget,
              color: isDark
                  ? GBTColors.darkTextTertiary
                  : GBTColors.textTertiary,
              semanticLabel: '잠금 아이콘',
            ),
            const SizedBox(height: GBTSpacing.md),
            Text(
              '로그인이 필요합니다',
              style: GBTTypography.titleSmall.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: GBTSpacing.sm),
            Text(
              '프로필을 수정하려면 로그인해주세요.',
              style: GBTTypography.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: GBTSpacing.lg),
            Semantics(
              button: true,
              label: '로그인 페이지로 이동',
              child: ElevatedButton(
                onPressed: onLogin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(
                    GBTSpacing.touchTarget,
                    GBTSpacing.touchTarget,
                  ),
                ),
                child: const Text('로그인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
