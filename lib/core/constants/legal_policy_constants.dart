/// EN: Legal policy metadata and public document links.
/// KO: 법률 정책 메타데이터와 공개 문서 링크입니다.
library;

import 'package:flutter/material.dart';

import '../localization/locale_text.dart';

enum LegalPolicyType { termsOfService, privacyPolicy, locationTerms }

class LegalPolicyInfo {
  const LegalPolicyInfo({
    required this.type,
    required this.version,
    required this.effectiveDate,
    required this.url,
  });

  final LegalPolicyType type;
  final String version;
  final String effectiveDate;
  final String url;
}

class LegalPolicyConstants {
  LegalPolicyConstants._();

  // EN: Replace URLs with production policy pages when legal team publishes them.
  // KO: 법무팀 정책 문서 공개 후 운영 URL로 교체해야 합니다.
  static const List<LegalPolicyInfo> policies = [
    LegalPolicyInfo(
      type: LegalPolicyType.termsOfService,
      version: 'v2026.03.06',
      effectiveDate: '2026-03-06',
      url: 'https://girlsbandtabi.app/policies/terms',
    ),
    LegalPolicyInfo(
      type: LegalPolicyType.privacyPolicy,
      version: 'v2026.03.06',
      effectiveDate: '2026-03-06',
      url: 'https://girlsbandtabi.app/policies/privacy',
    ),
    LegalPolicyInfo(
      type: LegalPolicyType.locationTerms,
      version: 'v2026.03.06',
      effectiveDate: '2026-03-06',
      url: 'https://girlsbandtabi.app/policies/location',
    ),
  ];

  static LegalPolicyInfo byType(LegalPolicyType type) {
    return policies.firstWhere((policy) => policy.type == type);
  }
}

extension LegalPolicyTypeLabel on LegalPolicyType {
  String label(BuildContext context) {
    return switch (this) {
      LegalPolicyType.termsOfService => context.l10n(
        ko: '이용약관',
        en: 'Terms of service',
        ja: '利用規約',
      ),
      LegalPolicyType.privacyPolicy => context.l10n(
        ko: '개인정보 처리방침',
        en: 'Privacy policy',
        ja: 'プライバシーポリシー',
      ),
      LegalPolicyType.locationTerms => context.l10n(
        ko: '위치정보 이용약관',
        en: 'Location terms',
        ja: '位置情報利用規約',
      ),
    };
  }
}
