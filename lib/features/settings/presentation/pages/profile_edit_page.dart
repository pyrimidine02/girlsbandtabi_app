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
  static const int _maxDisplayNameLength = 30;
  static const int _maxBioLength = 200;

  late final TextEditingController _displayNameController;
  late final TextEditingController _bioController;
  final ImagePicker _imagePicker = ImagePicker();

  bool _didSetInitial = false;
  bool _isHydrating = false;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  bool _isUploadingCover = false;

  String? _initialDisplayName;
  String? _initialBio;
  String? _initialAvatarUrl;
  String? _initialCoverUrl;

  String? _pendingAvatarUrl;
  String? _pendingCoverUrl;

  bool get _isBusy => _isSaving || _isUploadingAvatar || _isUploadingCover;

  bool get _hasPendingChanges {
    if (!_didSetInitial) {
      return false;
    }

    final currentDisplayName = _displayNameController.text.trim();
    final currentBio = _normalizeOptional(_bioController.text);
    final baselineDisplayName = (_initialDisplayName ?? '').trim();
    final baselineBio = _normalizeOptional(_initialBio ?? '');

    final currentAvatar = _pendingAvatarUrl ?? _initialAvatarUrl;
    final currentCover = _pendingCoverUrl ?? _initialCoverUrl;

    return currentDisplayName != baselineDisplayName ||
        currentBio != baselineBio ||
        currentAvatar != _initialAvatarUrl ||
        currentCover != _initialCoverUrl;
  }

  bool get _canSaveProfile {
    return !_isBusy &&
        _hasPendingChanges &&
        _displayNameController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _bioController = TextEditingController();
    _displayNameController.addListener(_onFormChanged);
    _bioController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    _displayNameController.removeListener(_onFormChanged);
    _bioController.removeListener(_onFormChanged);
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (!mounted || _isHydrating) {
      return;
    }
    setState(() {});
  }

  String? _normalizeOptional(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _hydrateFromProfile(UserProfile profile) {
    _isHydrating = true;
    _displayNameController.text = profile.displayName;
    _bioController.text = profile.bio ?? '';
    _isHydrating = false;

    _initialDisplayName = profile.displayName;
    _initialBio = profile.bio;
    _initialAvatarUrl = profile.avatarUrl;
    _initialCoverUrl = profile.coverImageUrl;
    _pendingAvatarUrl = null;
    _pendingCoverUrl = null;
    _didSetInitial = true;
  }

  Future<bool> _handleWillPop() async {
    if (_isBusy) {
      return false;
    }

    if (!_hasPendingChanges) {
      return true;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('저장하지 않고 나갈까요?'),
        content: const Text('프로필 변경 사항이 사라집니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('계속 수정'),
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

  Future<void> _saveProfile() async {
    final displayName = _displayNameController.text.trim();
    final bio = _normalizeOptional(_bioController.text);

    if (displayName.isEmpty) {
      _showMessage('표시 이름을 입력해주세요');
      return;
    }
    if (!_hasPendingChanges) {
      _showMessage('변경된 내용이 없어요');
      return;
    }

    setState(() => _isSaving = true);

    final profile = ref.read(userProfileControllerProvider).valueOrNull;
    final result = await ref
        .read(userProfileControllerProvider.notifier)
        .updateProfile(
          displayName: displayName,
          avatarUrl: _pendingAvatarUrl ?? profile?.avatarUrl,
          bio: bio,
          coverImageUrl: _pendingCoverUrl ?? profile?.coverImageUrl,
        );

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);

    if (result case Success<UserProfile>(:final data)) {
      _hydrateFromProfile(data);
      _showMessage('프로필이 저장되었습니다');
      context.pop();
      return;
    }

    _showMessage('프로필 저장에 실패했습니다');
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

    return PopScope<Object?>(
      canPop: !_isBusy && !_hasPendingChanges,
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
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('프로필 수정'),
            actions: [
              Semantics(
                button: true,
                label: _isSaving ? '저장 중' : '프로필 저장',
                enabled: _canSaveProfile,
                child: TextButton(
                  onPressed: _canSaveProfile ? _saveProfile : null,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(
                      GBTSpacing.touchTarget,
                      GBTSpacing.touchTarget,
                    ),
                  ),
                  child: Text(
                    _isSaving ? '저장 중' : '저장',
                    style: GBTTypography.bodyMedium.copyWith(
                      color: _canSaveProfile
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: GBTLoadingOverlay(
            isLoading: _isBusy,
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
                  _hydrateFromProfile(profile);
                }

                final avatarUrl = _pendingAvatarUrl ?? profile.avatarUrl;
                final coverUrl = _pendingCoverUrl ?? profile.coverImageUrl;
                final hasPendingAvatar = avatarUrl != profile.avatarUrl;
                final hasPendingCover = coverUrl != profile.coverImageUrl;

                return _ProfileForm(
                  profile: profile,
                  avatarUrl: avatarUrl,
                  coverUrl: coverUrl,
                  displayNameController: _displayNameController,
                  bioController: _bioController,
                  maxDisplayNameLength: _maxDisplayNameLength,
                  maxBioLength: _maxBioLength,
                  hasPendingChanges: _hasPendingChanges,
                  hasPendingAvatar: hasPendingAvatar,
                  hasPendingCover: hasPendingCover,
                  isUploadingAvatar: _isUploadingAvatar,
                  isUploadingCover: _isUploadingCover,
                  onChangeAvatar: _changeAvatar,
                  onChangeCover: _changeCover,
                  onRefresh: () => ref
                      .read(userProfileControllerProvider.notifier)
                      .load(forceRefresh: true),
                );
              },
            ),
          ),
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
    if (picked == null) {
      return;
    }

    setState(() => _isUploadingAvatar = true);

    try {
      final payload = await convertToWebp(
        path: picked.path,
        originalFilename: p.basename(picked.path),
        maxWidth: 1024,
        maxHeight: 1024,
        quality: 85,
      );
      final uploadController = ref.read(uploadsControllerProvider.notifier);

      final uploadResult = await uploadController.uploadImageBytes(
        bytes: payload.bytes,
        filename: payload.filename,
        contentType: payload.contentType,
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

      if (!mounted) {
        return;
      }
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
    if (picked == null) {
      return;
    }

    setState(() => _isUploadingCover = true);

    try {
      final payload = await convertToWebp(
        path: picked.path,
        originalFilename: p.basename(picked.path),
        maxWidth: 1920,
        maxHeight: 1080,
        quality: 80,
      );
      final uploadController = ref.read(uploadsControllerProvider.notifier);

      final uploadResult = await uploadController.uploadImageBytes(
        bytes: payload.bytes,
        filename: payload.filename,
        contentType: payload.contentType,
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

      if (!mounted) {
        return;
      }
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
    if (!mounted) {
      return;
    }
    final message = failure is AuthFailure && failure.code == '403'
        ? '아직 준비중입니다.'
        : failure.userMessage;
    _showMessage(message);
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
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
    required this.maxDisplayNameLength,
    required this.maxBioLength,
    required this.hasPendingChanges,
    required this.hasPendingAvatar,
    required this.hasPendingCover,
    required this.isUploadingAvatar,
    required this.isUploadingCover,
    required this.onChangeAvatar,
    required this.onChangeCover,
    required this.onRefresh,
  });

  final UserProfile profile;
  final TextEditingController displayNameController;
  final TextEditingController bioController;
  final String? avatarUrl;
  final String? coverUrl;
  final int maxDisplayNameLength;
  final int maxBioLength;
  final bool hasPendingChanges;
  final bool hasPendingAvatar;
  final bool hasPendingCover;
  final bool isUploadingAvatar;
  final bool isUploadingCover;
  final VoidCallback onChangeAvatar;
  final VoidCallback onChangeCover;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: GBTSpacing.paddingPage,
        children: [
          _PendingChangesBanner(hasPendingChanges: hasPendingChanges),
          const SizedBox(height: GBTSpacing.md),
          _ProfileSectionCard(
            title: '프로필 이미지',
            description: '이미지를 변경한 뒤 저장 버튼을 눌러야 최종 반영됩니다.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileCoverPreview(
                  coverUrl: coverUrl,
                  isUploading: isUploadingCover,
                ),
                const SizedBox(height: GBTSpacing.sm),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: isUploadingCover ? null : onChangeCover,
                      icon: const Icon(Icons.image_outlined),
                      label: Text(isUploadingCover ? '업로드 중...' : '배경 변경'),
                    ),
                    if (hasPendingCover) ...[
                      const SizedBox(width: GBTSpacing.sm),
                      const _PendingBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: GBTSpacing.lg),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _ProfileAvatar(
                      avatarUrl: avatarUrl,
                      isUploading: isUploadingAvatar,
                    ),
                    const SizedBox(width: GBTSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '프로필 사진',
                            style: GBTTypography.titleSmall.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: GBTSpacing.xxs),
                          Text(
                            '정사각형 이미지를 권장합니다.',
                            style: GBTTypography.bodySmall.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: GBTSpacing.sm),
                          Wrap(
                            spacing: GBTSpacing.sm,
                            runSpacing: GBTSpacing.sm,
                            children: [
                              OutlinedButton.icon(
                                onPressed: isUploadingAvatar
                                    ? null
                                    : onChangeAvatar,
                                icon: const Icon(Icons.camera_alt_outlined),
                                label: Text(
                                  isUploadingAvatar ? '업로드 중...' : '사진 변경',
                                ),
                              ),
                              if (hasPendingAvatar) const _PendingBadge(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: GBTSpacing.md),
          _ProfileSectionCard(
            title: '기본 정보',
            description: '작성한 정보는 댓글과 게시글 작성자 정보에 표시됩니다.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: displayNameController,
                  maxLength: maxDisplayNameLength,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: '표시 이름',
                    hintText: '표시 이름을 입력하세요',
                    helperText: '최대 $maxDisplayNameLength자',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                    ),
                  ),
                ),
                const SizedBox(height: GBTSpacing.md),
                TextField(
                  controller: bioController,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: maxBioLength,
                  decoration: InputDecoration(
                    labelText: '소개',
                    hintText: '간단한 소개를 입력하세요',
                    helperText: '최대 $maxBioLength자',
                    alignLabelWithHint: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.subject_outlined),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: GBTSpacing.md),
          _ProfileSectionCard(
            title: '계정 정보',
            description: '이메일과 권한 정보는 읽기 전용입니다.',
            child: Column(
              children: [
                _ReadOnlyInfoRow(
                  label: '이메일',
                  value: profile.email,
                  icon: Icons.mail_outline,
                ),
                const SizedBox(height: GBTSpacing.sm),
                _ReadOnlyInfoRow(
                  label: '권한',
                  value: profile.role,
                  icon: Icons.verified_user_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: GBTSpacing.xl),
        ],
      ),
    );
  }
}

class _PendingChangesBanner extends StatelessWidget {
  const _PendingChangesBanner({required this.hasPendingChanges});

  final bool hasPendingChanges;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final backgroundColor = hasPendingChanges
        ? GBTColors.warningLight
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45);
    final iconColor = hasPendingChanges
        ? GBTColors.warningDark
        : colorScheme.onSurfaceVariant;
    final message = hasPendingChanges
        ? '저장되지 않은 변경 사항이 있어요. 저장 버튼을 눌러 반영하세요.'
        : '변경 사항이 없습니다. 필요한 항목만 수정해도 됩니다.';

    return Container(
      padding: const EdgeInsets.all(GBTSpacing.sm),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: iconColor),
          const SizedBox(width: GBTSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: GBTTypography.bodySmall.copyWith(color: iconColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionCard extends StatelessWidget {
  const _ProfileSectionCard({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(GBTSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GBTTypography.titleMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: GBTSpacing.xs),
            Text(
              description,
              style: GBTTypography.bodySmall.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: GBTSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _PendingBadge extends StatelessWidget {
  const _PendingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GBTSpacing.sm,
        vertical: GBTSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: GBTColors.warningLight,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusFull),
      ),
      child: Text(
        '저장 대기',
        style: GBTTypography.labelSmall.copyWith(color: GBTColors.warningDark),
      ),
    );
  }
}

class _ReadOnlyInfoRow extends StatelessWidget {
  const _ReadOnlyInfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(GBTSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(GBTSpacing.radiusSm),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: GBTSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GBTTypography.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: GBTSpacing.xxs),
                Text(
                  value,
                  style: GBTTypography.bodyMedium.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
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
