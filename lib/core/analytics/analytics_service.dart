/// EN: Analytics wrapper for app event tracking (no-op implementation).
/// KO: 앱 이벤트 추적을 위한 분석 래퍼 (비활성 구현).
///
/// EN: This is a placeholder that logs events locally.
///     Replace with Sentry, PostHog, or other analytics service later.
/// KO: 이벤트를 로컬에 기록하는 플레이스홀더입니다.
///     나중에 Sentry, PostHog 또는 다른 분석 서비스로 교체하세요.
library;

import '../logging/app_logger.dart';

/// EN: Analytics service singleton (currently no-op, logs to console).
/// KO: 분석 서비스 싱글톤 (현재 비활성, 콘솔에 로깅).
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService _instance = AnalyticsService._();

  /// EN: Access the analytics service instance.
  /// KO: 분석 서비스 인스턴스 접근.
  static AnalyticsService get instance => _instance;

  /// EN: Whether analytics is enabled.
  /// KO: 분석 기능이 활성화되어 있는지 여부.
  bool get isEnabled => false;

  /// EN: Log screen view.
  /// KO: 화면 조회 이벤트 기록.
  Future<void> logScreenView(String screenName) async {
    AppLogger.debug('Screen view: $screenName', tag: 'Analytics');
  }

  /// EN: Log a custom event.
  /// KO: 커스텀 이벤트 기록.
  Future<void> logEvent(String name, Map<String, Object?>? params) async {
    AppLogger.debug('Event: $name, params: $params', tag: 'Analytics');
  }

  /// EN: Log place visit event.
  /// KO: 장소 방문 이벤트 기록.
  Future<void> logPlaceVisit(String placeId, {String? placeName}) async {
    await logEvent('place_visit', {
      'place_id': placeId,
      if (placeName != null) 'place_name': placeName,
    });
  }

  /// EN: Log live event view.
  /// KO: 라이브 이벤트 조회 기록.
  Future<void> logLiveEventView(String eventId, {String? eventName}) async {
    await logEvent('live_event_view', {
      'event_id': eventId,
      if (eventName != null) 'event_name': eventName,
    });
  }

  /// EN: Log verification completion.
  /// KO: 인증 완료 이벤트 기록.
  Future<void> logVerificationComplete(String type, String entityId) async {
    await logEvent('verification_complete', {
      'type': type,
      'entity_id': entityId,
    });
  }

  /// EN: Log verification failure.
  /// KO: 인증 실패 이벤트 기록.
  Future<void> logVerificationFailed(String type, String errorCode) async {
    await logEvent('verification_failed', {
      'type': type,
      'error_code': errorCode,
    });
  }

  /// EN: Log search event.
  /// KO: 검색 이벤트 기록.
  Future<void> logSearch(String query, {int? resultCount}) async {
    await logEvent('search', {
      'query': query,
      if (resultCount != null) 'result_count': resultCount,
    });
  }

  /// EN: Log favorite add/remove.
  /// KO: 즐겨찾기 추가/삭제 이벤트 기록.
  Future<void> logFavoriteChange({
    required String entityType,
    required String entityId,
    required bool added,
  }) async {
    await logEvent(added ? 'favorite_add' : 'favorite_remove', {
      'entity_type': entityType,
      'entity_id': entityId,
    });
  }

  /// EN: Log post creation event.
  /// KO: 게시글 작성 이벤트 기록.
  Future<void> logPostCreate(String category) async {
    await logEvent('post_create', {'category': category});
  }

  /// EN: Log login event.
  /// KO: 로그인 이벤트 기록.
  Future<void> logLogin(String method) async {
    await logEvent('login', {'method': method});
  }

  /// EN: Log signup event.
  /// KO: 회원가입 이벤트 기록.
  Future<void> logSignup(String method) async {
    await logEvent('signup', {'method': method});
  }
}
