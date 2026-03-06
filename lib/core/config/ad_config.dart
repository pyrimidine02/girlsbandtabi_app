/// EN: Ad runtime configuration for hybrid sponsored slots.
/// KO: 하이브리드 스폰서 슬롯을 위한 광고 런타임 설정입니다.
library;

import 'package:flutter/foundation.dart';

class AdConfig {
  AdConfig._();

  /// EN: AdMob app IDs (override with real values for release builds).
  /// KO: AdMob 앱 ID(릴리스에서는 실제 값으로 교체 필요).
  static const String androidAppId = String.fromEnvironment(
    'ADMOB_ANDROID_APP_ID',
    defaultValue: 'ca-app-pub-3940256099942544~3347511713',
  );
  static const String iosAppId = String.fromEnvironment(
    'ADMOB_IOS_APP_ID',
    defaultValue: 'ca-app-pub-3940256099942544~1458002511',
  );

  static const String _androidHomeNativeUnitId = String.fromEnvironment(
    'ADMOB_ANDROID_NATIVE_HOME_UNIT_ID',
    defaultValue: '',
  );
  static const String _iosHomeNativeUnitId = String.fromEnvironment(
    'ADMOB_IOS_NATIVE_HOME_UNIT_ID',
    defaultValue: '',
  );
  static const String _androidBoardNativeUnitId = String.fromEnvironment(
    'ADMOB_ANDROID_NATIVE_BOARD_UNIT_ID',
    defaultValue: '',
  );
  static const String _iosBoardNativeUnitId = String.fromEnvironment(
    'ADMOB_IOS_NATIVE_BOARD_UNIT_ID',
    defaultValue: '',
  );

  static const String _androidTestNativeUnitId =
      'ca-app-pub-3940256099942544/2247696110';
  static const String _iosTestNativeUnitId =
      'ca-app-pub-3940256099942544/3986624511';

  /// EN: Resolve slot-specific AdMob unit ID.
  /// KO: 슬롯별 AdMob 유닛 ID를 해석합니다.
  static String? resolveNativeUnitId(String slotKey) {
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    final configured = switch (slotKey) {
      'home_primary' => isIos ? _iosHomeNativeUnitId : _androidHomeNativeUnitId,
      'board_feed' => isIos ? _iosBoardNativeUnitId : _androidBoardNativeUnitId,
      _ => '',
    };

    if (configured.trim().isNotEmpty) {
      return configured.trim();
    }

    // EN: Use test ad unit in debug/profile when production unit is absent.
    // KO: 프로덕션 유닛이 없으면 debug/profile에서 테스트 유닛을 사용합니다.
    if (!kReleaseMode) {
      return isIos ? _iosTestNativeUnitId : _androidTestNativeUnitId;
    }
    return null;
  }
}
