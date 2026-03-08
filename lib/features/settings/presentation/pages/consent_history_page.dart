/// EN: Consent history page showing legal consent records.
/// KO: 법률 동의 이력을 표시하는 페이지입니다.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/localization/locale_text.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/theme/gbt_spacing.dart';
import '../../../../core/theme/gbt_typography.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/feedback/gbt_loading.dart';

class ConsentHistoryPage extends ConsumerWidget {
  const ConsentHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(consentHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n(ko: '동의 이력', en: 'Consent history', ja: '同意履歴'),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(consentHistoryProvider);
          await ref.read(consentHistoryProvider.future);
        },
        child: state.when(
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 120),
              GBTLoading(
                message: context.l10n(
                  ko: '동의 이력을 불러오는 중...',
                  en: 'Loading consent history...',
                  ja: '同意履歴を読み込み中...',
                ),
              ),
            ],
          ),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const SizedBox(height: 120),
              GBTErrorState(
                message: context.l10n(
                  ko: '동의 이력을 불러오지 못했습니다.',
                  en: 'Failed to load consent history.',
                  ja: '同意履歴を読み込めませんでした。',
                ),
                onRetry: () => ref.invalidate(consentHistoryProvider),
              ),
            ],
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  GBTEmptyState(
                    icon: Icons.history_toggle_off_rounded,
                    message: context.l10n(
                      ko: '저장된 동의 이력이 없습니다.',
                      en: 'No consent history found.',
                      ja: '保存された同意履歴はありません。',
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.all(GBTSpacing.md),
              itemBuilder: (context, index) =>
                  _ConsentHistoryTile(item: items[index]),
              separatorBuilder: (_, _) => const SizedBox(height: GBTSpacing.sm),
              itemCount: items.length,
            );
          },
        ),
      ),
    );
  }
}

final consentHistoryProvider = FutureProvider<List<_ConsentHistoryItem>>((
  ref,
) async {
  final apiClient = ref.read(apiClientProvider);
  final remoteResult = await apiClient.get<List<_ConsentHistoryItem>>(
    ApiEndpoints.userConsents,
    queryParameters: const {'page': 0, 'size': 50, 'sort': 'agreedAt,desc'},
    fromJson: _parseConsentItems,
  );

  final storage = await ref.read(localStorageProvider.future);
  final localList =
      storage.getJsonList(LocalStorageKeys.userConsents) ?? const [];
  final localItems = localList.map(_ConsentHistoryItem.fromJson).toList();

  if (remoteResult is Success<List<_ConsentHistoryItem>>) {
    final remoteItems = _sortConsentItems(remoteResult.data);
    if (remoteItems.isNotEmpty) {
      return remoteItems;
    }
  }

  return _sortConsentItems(localItems);
});

List<_ConsentHistoryItem> _parseConsentItems(dynamic json) {
  if (json is List) {
    return json
        .whereType<Map<String, dynamic>>()
        .map(_ConsentHistoryItem.fromJson)
        .toList(growable: false);
  }

  if (json is Map<String, dynamic>) {
    final items = json['items'];
    if (items is List) {
      return items
          .whereType<Map<String, dynamic>>()
          .map(_ConsentHistoryItem.fromJson)
          .toList(growable: false);
    }
  }

  return const [];
}

List<_ConsentHistoryItem> _sortConsentItems(List<_ConsentHistoryItem> items) {
  final sorted = List<_ConsentHistoryItem>.from(items);
  sorted.sort((a, b) {
    final bTime = DateTime.tryParse(b.agreedAt);
    final aTime = DateTime.tryParse(a.agreedAt);
    if (aTime == null && bTime == null) return 0;
    if (aTime == null) return 1;
    if (bTime == null) return -1;
    return bTime.compareTo(aTime);
  });
  return sorted;
}

class _ConsentHistoryItem {
  const _ConsentHistoryItem({
    required this.type,
    required this.version,
    required this.agreed,
    required this.agreedAt,
    this.label,
  });

  final String type;
  final String version;
  final bool agreed;
  final String agreedAt;
  final String? label;

  factory _ConsentHistoryItem.fromJson(Map<String, dynamic> json) {
    return _ConsentHistoryItem(
      type: (json['type'] as String?) ?? 'UNKNOWN',
      version: (json['version'] as String?) ?? '-',
      agreed: (json['agreed'] as bool?) ?? false,
      agreedAt: (json['agreedAt'] as String?) ?? '-',
      label: json['label'] as String?,
    );
  }
}

class _ConsentHistoryTile extends StatelessWidget {
  const _ConsentHistoryTile({required this.item});

  final _ConsentHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(GBTSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(GBTSpacing.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                item.agreed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 16,
                color: item.agreed
                    ? (isDark ? Colors.lightGreenAccent : Colors.green)
                    : colorScheme.error,
              ),
              const SizedBox(width: GBTSpacing.xs),
              Expanded(
                child: Text(
                  _consentLabel(context, item.type, item.label),
                  style: GBTTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: GBTSpacing.xs),
          Text(
            context.l10n(
              ko: '버전: ${item.version}',
              en: 'Version: ${item.version}',
              ja: 'バージョン: ${item.version}',
            ),
            style: GBTTypography.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            context.l10n(
              ko: '동의 시각: ${_formatConsentDate(item.agreedAt)}',
              en: 'Agreed at: ${_formatConsentDate(item.agreedAt)}',
              ja: '同意時刻: ${_formatConsentDate(item.agreedAt)}',
            ),
            style: GBTTypography.labelSmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _consentLabel(BuildContext context, String type, String? fallback) {
    final normalized = type.trim().toUpperCase();
    switch (normalized) {
      case 'TERMS_OF_SERVICE':
        return context.l10n(
          ko: '이용약관 동의',
          en: 'Terms of service',
          ja: '利用規約への同意',
        );
      case 'PRIVACY_POLICY':
        return context.l10n(
          ko: '개인정보 처리방침 동의',
          en: 'Privacy policy',
          ja: 'プライバシーポリシーへの同意',
        );
      case 'AGE_OVER_14':
        return context.l10n(
          ko: '만 14세 이상 확인',
          en: 'Age 14+ confirmation',
          ja: '14歳以上確認',
        );
      default:
        return fallback ??
            context.l10n(ko: '동의 항목', en: 'Consent item', ja: '同意項目');
    }
  }

  String _formatConsentDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    final local = parsed.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }
}
