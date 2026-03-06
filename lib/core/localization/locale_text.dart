/// EN: Lightweight locale text helper for app-level copy.
/// KO: 앱 레벨 문구용 경량 로케일 텍스트 헬퍼.
library;

import 'package:flutter/widgets.dart';

/// EN: BuildContext extension for simple localized copy selection.
/// KO: 단순 다국어 문구 선택을 위한 BuildContext 확장입니다.
extension LocaleTextX on BuildContext {
  /// EN: Returns localized text by current language code (`ko`, `en`, `ja`).
  /// KO: 현재 언어 코드(`ko`, `en`, `ja`)에 맞는 문구를 반환합니다.
  String l10n({required String ko, String? en, String? ja}) {
    final languageCode = Localizations.localeOf(this).languageCode;
    switch (languageCode) {
      case 'ja':
        return (ja != null && ja.isNotEmpty) ? ja : (en ?? ko);
      case 'en':
        return (en != null && en.isNotEmpty) ? en : ko;
      default:
        return ko;
    }
  }
}
