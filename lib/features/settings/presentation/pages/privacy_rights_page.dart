/// EN: Privacy and data-rights page for user self-service actions.
/// KO: 사용자 셀프서비스 개인정보/권리행사 페이지입니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/localization/locale_text.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/result.dart';
import '../../../auth/application/auth_controller.dart';

class PrivacyRightsPage extends ConsumerStatefulWidget {
  const PrivacyRightsPage({super.key});

  @override
  ConsumerState<PrivacyRightsPage> createState() => _PrivacyRightsPageState();
}

class _PrivacyRightsPageState extends ConsumerState<PrivacyRightsPage> {
  bool _isLoading = true;
  bool _autoTranslationEnabled = true;
  bool _isSavingTranslation = false;
  bool _isDeletingAccount = false;
  final TextEditingController _restrictionReasonController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrivacyState();
  }

  @override
  void dispose() {
    _restrictionReasonController.dispose();
    super.dispose();
  }

  Future<void> _loadPrivacyState() async {
    final storage = await ref.read(localStorageProvider.future);
    final value = storage.getBool(LocalStorageKeys.autoTranslationEnabled);
    if (!mounted) return;
    setState(() {
      _autoTranslationEnabled = value ?? true;
      _isLoading = false;
    });
  }

  Future<void> _toggleAutoTranslation(bool value) async {
    setState(() {
      _autoTranslationEnabled = value;
      _isSavingTranslation = true;
    });

    final storage = await ref.read(localStorageProvider.future);
    await storage.setBool(LocalStorageKeys.autoTranslationEnabled, value);

    final apiClient = ref.read(apiClientProvider);
    final result = await apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.userPrivacySettings,
      data: {'allowAutoTranslation': value},
      fromJson: (json) =>
          json is Map<String, dynamic> ? json : <String, dynamic>{},
    );

    if (!mounted) return;
    setState(() => _isSavingTranslation = false);

    if (result is Err<Map<String, dynamic>>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n(
              ko: '서버 연동이 준비되지 않아 로컬 설정만 반영되었습니다.',
              en: 'Server sync is not ready. Applied locally only.',
              ja: 'サーバー連携未対応のため、ローカル設定のみ反映しました。',
            ),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n(
            ko: '자동번역 설정이 저장되었습니다.',
            en: 'Auto-translation setting saved.',
            ja: '自動翻訳設定を保存しました。',
          ),
        ),
      ),
    );
  }

  Future<void> _requestProcessingRestriction() async {
    final reason = _restrictionReasonController.text.trim();
    if (reason.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n(
              ko: '처리정지 사유를 10자 이상 입력해주세요.',
              en: 'Please enter at least 10 characters for the reason.',
              ja: '処理停止理由を10文字以上入力してください。',
            ),
          ),
        ),
      );
      return;
    }

    final now = DateTime.now().toIso8601String();
    final apiClient = ref.read(apiClientProvider);
    final remoteResult = await apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.userPrivacyRequests,
      data: {'requestType': 'PROCESSING_RESTRICTION', 'reason': reason},
      fromJson: (json) =>
          json is Map<String, dynamic> ? json : <String, dynamic>{},
    );

    final storage = await ref.read(localStorageProvider.future);
    final history =
        storage.getJsonList(LocalStorageKeys.privacyRequestHistory) ??
        <Map<String, dynamic>>[];
    history.insert(0, {
      'requestType': 'PROCESSING_RESTRICTION',
      'reason': reason,
      'requestedAt': now,
      'synced': remoteResult is Success<Map<String, dynamic>>,
    });
    await storage.setJsonList(LocalStorageKeys.privacyRequestHistory, history);

    _restrictionReasonController.clear();
    if (!mounted) return;
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          remoteResult is Success<Map<String, dynamic>>
              ? context.l10n(
                  ko: '처리정지 요청이 접수되었습니다.',
                  en: 'Restriction request submitted.',
                  ja: '処理停止要請を受け付けました。',
                )
              : context.l10n(
                  ko: '처리정지 요청을 로컬에 저장했습니다. 서버 연동은 추후 반영됩니다.',
                  en: 'Stored request locally. Server sync will be applied later.',
                  ja: '要求をローカル保存しました。サーバー連携は後で反映されます。',
                ),
        ),
      ),
    );
  }

  Future<void> _showProcessingRestrictionDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            context.l10n(
              ko: '처리정지 요청',
              en: 'Request processing restriction',
              ja: '処理停止要請',
            ),
          ),
          content: TextField(
            controller: _restrictionReasonController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: context.l10n(
                ko: '요청 사유를 입력해주세요 (최소 10자)',
                en: 'Enter the reason (minimum 10 characters)',
                ja: '要請理由を入力してください（10文字以上）',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n(ko: '취소', en: 'Cancel', ja: 'キャンセル')),
            ),
            FilledButton(
              onPressed: _requestProcessingRestriction,
              child: Text(
                context.l10n(ko: '요청하기', en: 'Submit request', ja: '要請する'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            context.l10n(ko: '회원 탈퇴', en: 'Delete account', ja: 'アカウント削除'),
          ),
          content: Text(
            context.l10n(
              ko: '탈퇴 시 계정 접근이 차단되며, 일부 데이터는 관련 법령 및 운영정책에 따라 일정 기간 보관 후 파기됩니다.\n정말 진행할까요?',
              en: 'Deleting your account blocks access. Some data may be retained for a limited legal/operational period before deletion.\nDo you want to continue?',
              ja: '退会するとアカウントアクセスが停止されます。一部データは法令・運用方針に基づき一定期間保管後に削除されます。\n続行しますか？',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n(ko: '취소', en: 'Cancel', ja: 'キャンセル')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text(
                context.l10n(ko: '탈퇴 진행', en: 'Delete account', ja: '削除する'),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;
    if (!mounted) return;

    setState(() => _isDeletingAccount = true);

    final apiClient = ref.read(apiClientProvider);
    final result = await apiClient.delete<void>(
      ApiEndpoints.userMe,
      fromJson: (_) {},
    );

    if (!mounted) return;

    if (result is Err<void>) {
      setState(() => _isDeletingAccount = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n(
              ko: '탈퇴 처리에 실패했습니다. 잠시 후 다시 시도해주세요.',
              en: 'Failed to delete account. Please try again shortly.',
              ja: 'アカウント削除に失敗しました。しばらくしてから再試行してください。',
            ),
          ),
        ),
      );
      return;
    }

    await ref.read(authControllerProvider.notifier).logout();
    if (!mounted) return;
    setState(() => _isDeletingAccount = false);
    context.go('/login');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n(
            ko: '탈퇴가 완료되었습니다.',
            en: 'Your account has been deleted.',
            ja: 'アカウント削除が完了しました。',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            context.l10n(
              ko: '개인정보 및 권리행사',
              en: 'Privacy and rights',
              ja: 'プライバシーと権利行使',
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n(
            ko: '개인정보 및 권리행사',
            en: 'Privacy and rights',
            ja: 'プライバシーと権利行使',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(GBTSpacing.md),
        children: [
          _SectionCard(
            title: context.l10n(
              ko: '자동번역 전송 설정',
              en: 'Auto-translation transfer',
              ja: '自動翻訳転送設定',
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _autoTranslationEnabled,
              onChanged: _isSavingTranslation ? null : _toggleAutoTranslation,
              title: Text(
                context.l10n(
                  ko: '커뮤니티 자동번역 허용',
                  en: 'Allow community auto-translation',
                  ja: 'コミュニティ自動翻訳を許可',
                ),
                style: GBTTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                context.l10n(
                  ko: '끄면 외부 번역 서비스 전송을 중단합니다.',
                  en: 'When off, external translation transfer is disabled.',
                  ja: 'オフにすると外部翻訳サービスへの転送を停止します。',
                ),
                style: GBTTypography.bodySmall,
              ),
            ),
          ),
          const SizedBox(height: GBTSpacing.md),
          _SectionCard(
            title: context.l10n(
              ko: '정보주체 권리행사',
              en: 'Data subject rights',
              ja: '情報主体の権利行使',
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.visibility_outlined),
                  title: Text(
                    context.l10n(
                      ko: '내 데이터 열람',
                      en: 'View my data',
                      ja: 'マイデータ閲覧',
                    ),
                  ),
                  subtitle: Text(
                    context.l10n(
                      ko: '프로필/방문기록/즐겨찾기로 이동',
                      en: 'Open profile/visits/favorites',
                      ja: 'プロフィール・訪問履歴・お気に入りへ移動',
                    ),
                    style: GBTTypography.bodySmall,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showDataViewLinks(),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.pause_circle_outline_rounded),
                  title: Text(
                    context.l10n(
                      ko: '처리정지 요청',
                      en: 'Request processing restriction',
                      ja: '処理停止要請',
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: _showProcessingRestrictionDialog,
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.red,
                  ),
                  title: Text(
                    context.l10n(
                      ko: '회원 탈퇴',
                      en: 'Delete account',
                      ja: 'アカウント削除',
                    ),
                    style: const TextStyle(color: Colors.red),
                  ),
                  trailing: _isDeletingAccount
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right_rounded),
                  onTap: _isDeletingAccount ? null : _deleteAccount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDataViewLinks() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline_rounded),
                title: Text(
                  context.l10n(ko: '프로필 정보', en: 'Profile', ja: 'プロフィール'),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  this.context.push('/settings/profile');
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline_rounded),
                title: Text(
                  context.l10n(ko: '방문 기록', en: 'Visit history', ja: '訪問履歴'),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  this.context.push('/visits');
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite_border_rounded),
                title: Text(
                  context.l10n(ko: '즐겨찾기', en: 'Favorites', ja: 'お気に入り'),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  this.context.push('/favorites');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GBTSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GBTTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: GBTSpacing.sm),
          child,
        ],
      ),
    );
  }
}
