/// EN: API endpoint constants and configurations
/// KO: API 엔드포인트 상수 및 구성
library;

/// EN: API endpoint paths
/// KO: API 엔드포인트 경로
class ApiEndpoints {
  ApiEndpoints._();

  // EN: API version prefix
  // KO: API 버전 접두사
  static const String apiVersion = '/api/v1';

  // ============================================================
  // EN: Auth endpoints (8.1)
  // KO: 인증 엔드포인트 (8.1)
  // ============================================================
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String refresh = '$apiVersion/auth/refresh';
  static const String logout = '$apiVersion/auth/logout';
  static const String emailVerifications = '$apiVersion/auth/email-verifications';
  static const String emailVerificationsConfirm =
      '$apiVersion/auth/email-verifications/confirm';
  static String oauthCallback(String provider) =>
      '$apiVersion/auth/oauth2/callback/$provider';

  // ============================================================
  // EN: User endpoints (8.2)
  // KO: 사용자 엔드포인트 (8.2)
  // ============================================================
  static const String userMe = '$apiVersion/users/me';
  static const String userVisits = '$apiVersion/users/me/visits';
  static const String userVisitsSummary = '$apiVersion/users/me/visits/summary';
  static const String usersSearch = '$apiVersion/users/search';
  static String userProfile(String userId) => '$apiVersion/users/$userId';
  static String userBlocked(String userId) =>
      '${userProfile(userId)}/blocked';
  static const String userBlocks = '$apiVersion/users/me/blocks';
  static String userBlock(String targetUserId) =>
      '$userBlocks/$targetUserId';

  // ============================================================
  // EN: Favorites endpoints (8.14)
  // KO: 즐겨찾기 엔드포인트 (8.14)
  // ============================================================
  static const String userFavorites = '$apiVersion/users/me/favorites';

  // ============================================================
  // EN: Notification endpoints (8.2)
  // KO: 알림 엔드포인트 (8.2)
  // ============================================================
  static const String notifications = '$apiVersion/notifications';
  static String notificationRead(String id) => '$notifications/$id/read';
  static const String notificationSettings = '$notifications/settings';

  // ============================================================
  // EN: Verification endpoints (8.3)
  // KO: 검증 엔드포인트 (8.3)
  // ============================================================
  static const String verificationConfig = '$apiVersion/verification/config';
  static const String verificationChallenge =
      '$apiVersion/verification/challenge';

  // ============================================================
  // EN: Home/Search endpoints (8.4)
  // KO: 홈/검색 엔드포인트 (8.4)
  // ============================================================
  static const String homeSummary = '$apiVersion/home/summary';
  static const String search = '$apiVersion/search';

  // ============================================================
  // EN: Project endpoints (8.5)
  // KO: 프로젝트 엔드포인트 (8.5)
  // ============================================================
  static const String projects = '$apiVersion/projects';
  static String project(String projectId) => '$projects/$projectId';

  // EN: Unit endpoints
  // KO: 유닛 엔드포인트
  static String projectUnits(String projectId) => '${project(projectId)}/units';
  static String projectUnit(String projectId, String bandCode) =>
      '${projectUnits(projectId)}/$bandCode';
  static String projectUnitsSearch(String projectId) =>
      '${projectUnits(projectId)}/search';

  // ============================================================
  // EN: Place endpoints (8.6)
  // KO: 장소 엔드포인트 (8.6)
  // ============================================================
  static String places(String projectId) => '${project(projectId)}/places';
  static String place(String projectId, String placeId) =>
      '${places(projectId)}/$placeId';
  static String placesWithinBounds(String projectId) =>
      '${places(projectId)}/within-bounds';
  static String placesNearby(String projectId) => '${places(projectId)}/nearby';

  // EN: Place verification
  // KO: 장소 인증
  static String placeVerification(String projectId, String placeId) =>
      '${place(projectId, placeId)}/verification';

  // ============================================================
  // EN: Place Photos endpoints (8.7)
  // KO: 장소 사진 엔드포인트 (8.7)
  // ============================================================
  static String placePhotos(String placeId) =>
      '$apiVersion/places/$placeId/photos';
  static String placePhotosBatch(String placeId) =>
      '${placePhotos(placeId)}/batch';
  static String placePhotosAll(String placeId) =>
      '${placePhotos(placeId)}/all';
  static String placePhotosFeatured(String placeId) =>
      '${placePhotos(placeId)}/featured';
  static String placePhotosPending(String placeId) =>
      '${placePhotos(placeId)}/pending';
  static String placePhoto(String placeId, String photoId) =>
      '${placePhotos(placeId)}/$photoId';
  static String placePhotoApprove(String placeId, String photoId) =>
      '${placePhoto(placeId, photoId)}/approve';

  // ============================================================
  // EN: Place Guides endpoints (8.8)
  // KO: 장소 가이드 엔드포인트 (8.8)
  // ============================================================
  static String placeGuides(String placeId) =>
      '$apiVersion/places/$placeId/guides';
  static String placeGuidesBatch(String placeId) =>
      '${placeGuides(placeId)}/batch';
  static String placeGuidesAll(String placeId) =>
      '${placeGuides(placeId)}/all';
  static String placeGuide(String placeId, String guideId) =>
      '${placeGuides(placeId)}/$guideId';
  static String placeGuidePreview(String placeId, String guideId) =>
      '${placeGuide(placeId, guideId)}/preview';
  static String placeGuidePublish(String placeId, String guideId) =>
      '${placeGuide(placeId, guideId)}/publish';
  static String placeGuidesUnpublished(String placeId) =>
      '${placeGuides(placeId)}/unpublished';
  static String placeGuidesHighPriority(String placeId) =>
      '${placeGuides(placeId)}/high-priority';
  static String placeGuidesSearch(String placeId) =>
      '${placeGuides(placeId)}/search';

  // ============================================================
  // EN: Place Comments endpoints (8.9)
  // KO: 장소 댓글 엔드포인트 (8.9)
  // ============================================================
  static String placeComments(String placeId) =>
      '$apiVersion/places/$placeId/comments';
  static String placeCommentsBatch(String placeId) =>
      '${placeComments(placeId)}/batch';
  static String placeCommentThread(String placeId, String threadId) =>
      '${placeComments(placeId)}/threads/$threadId';
  static String placeComment(String placeId, String commentId) =>
      '${placeComments(placeId)}/$commentId';
  static String placeCommentReply(String placeId, String commentId) =>
      '${placeComment(placeId, commentId)}/reply';
  static String placeCommentModerate(String placeId, String commentId) =>
      '${placeComment(placeId, commentId)}/moderate';
  static String placeCommentsTagsPopular(String placeId) =>
      '${placeComments(placeId)}/tags/popular';
  static String placeCommentsFilterAccessibility(String placeId) =>
      '${placeComments(placeId)}/filter/accessibility';
  static String placeCommentsFilterRoutes(String placeId) =>
      '${placeComments(placeId)}/filter/routes';
  static String placeCommentsFilterAdvice(String placeId) =>
      '${placeComments(placeId)}/filter/advice';
  static String placeCommentsFilterPhotos(String placeId) =>
      '${placeComments(placeId)}/filter/photos';
  static String placeCommentsPinned(String placeId) =>
      '${placeComments(placeId)}/pinned';
  static String placeCommentsSearch(String placeId) =>
      '${placeComments(placeId)}/search';
  static String placeCommentsStats(String placeId) =>
      '${placeComments(placeId)}/stats';

  // ============================================================
  // EN: Region Navigation endpoints (8.11)
  // KO: 지역 네비게이션 엔드포인트 (8.11)
  // ============================================================
  static const String regionsTree = '$apiVersion/regions/tree';
  static const String regionsCountries = '$apiVersion/regions/countries';
  static String regionsChildren(String parentCode) =>
      '$apiVersion/regions/$parentCode/children';
  static String regionsPlaces(String regionCode) =>
      '$apiVersion/regions/$regionCode/places';
  static const String regionsPopular = '$apiVersion/regions/popular';
  static const String regionsSearch = '$apiVersion/regions/search';

  // ============================================================
  // EN: Project Places Regions endpoints (8.10)
  // KO: 프로젝트 장소 지역 엔드포인트 (8.10)
  // ============================================================
  static String placesRegionsAvailable(String projectId) =>
      '${places(projectId)}/regions/available';
  static String placesRegionsFilter(String projectId) =>
      '${places(projectId)}/regions/filter';
  static String placesRegionsStats(String projectId) =>
      '${places(projectId)}/regions/stats';
  static String placesRegionsBreadcrumb(String projectId, String regionCode) =>
      '${places(projectId)}/regions/breadcrumb/$regionCode';
  static String placesRegionsMapBounds(String projectId) =>
      '${places(projectId)}/regions/map-bounds';
  static String placesRegionsFavorites(String projectId) =>
      '${places(projectId)}/regions/favorites';

  // ============================================================
  // EN: Unified Search endpoints (8.13)
  // KO: 통합 검색 엔드포인트 (8.13)
  // ============================================================
  static String placesSearchUnified(String projectId) =>
      '${places(projectId)}/search/unified';
  static String placesSearchAutocomplete(String projectId) =>
      '${places(projectId)}/search/autocomplete';
  static String placesSearchSuggestions(String projectId) =>
      '${places(projectId)}/search/suggestions';
  static String placesSearchRegionsStats(String projectId) =>
      '${places(projectId)}/search/regions/stats';
  static String placesSearchPopular(String projectId) =>
      '${places(projectId)}/search/popular';
  static String placesSearchFiltersAvailable(String projectId) =>
      '${places(projectId)}/search/filters/available';
  static String placesSearchQuickFilters(String projectId) =>
      '${places(projectId)}/search/quick-filters';

  // ============================================================
  // EN: Place region search endpoints (8.12)
  // KO: 장소 지역 검색 엔드포인트 (8.12)
  // ============================================================
  static const String placeRegionSearchExamples =
      '$apiVersion/search/place-region/demo/search-examples';
  static const String placeRegionPlacesByMultipleRegions =
      '$apiVersion/search/place-region/places/by-multiple-regions';
  static const String placeRegionPlacesByRegionName =
      '$apiVersion/search/place-region/places/by-region-name';
  static String placeRegionPlacesByRegion(String regionCode) =>
      '$apiVersion/search/place-region/places/by-region/$regionCode';
  static String placeRegionPlaceHierarchy(String placeId) =>
      '$apiVersion/search/place-region/places/$placeId/region-hierarchy';
  static String placeRegionStats(String regionCode) =>
      '$apiVersion/search/place-region/regions/$regionCode/stats';

  // ============================================================
  // EN: Live event endpoints (8.15)
  // KO: 라이브 이벤트 엔드포인트 (8.15)
  // ============================================================
  static String liveEvents(String projectId) =>
      '${project(projectId)}/live-events';
  static String liveEvent(String projectId, String liveEventId) =>
      '${liveEvents(projectId)}/$liveEventId';
  static String liveEventVerification(String projectId, String liveEventId) =>
      '${liveEvent(projectId, liveEventId)}/verification';

  // ============================================================
  // EN: Community endpoints (8.16) - Uses projectCode!
  // KO: 커뮤니티 엔드포인트 (8.16) - projectCode 사용!
  // ============================================================
  static String posts(String projectCode) =>
      '$apiVersion/projects/$projectCode/posts';
  static String post(String projectCode, String postId) =>
      '${posts(projectCode)}/$postId';
  static String postComments(String projectCode, String postId) =>
      '${post(projectCode, postId)}/comments';
  static String postComment(
    String projectCode,
    String postId,
    String commentId,
  ) =>
      '${postComments(projectCode, postId)}/$commentId';
  static String postLike(String projectCode, String postId) =>
      '${post(projectCode, postId)}/like';
  static String postsByAuthor(String projectCode, String userId) =>
      '${posts(projectCode)}/by-author/$userId';
  static String commentsByAuthor(String projectCode, String userId) =>
      '$apiVersion/projects/$projectCode/comments/by-author/$userId';

  // EN: Community reports endpoints.
  // KO: 커뮤니티 신고 엔드포인트.
  static const String communityReports = '$apiVersion/community/reports';
  static const String communityReportsMe =
      '$apiVersion/community/reports/me';
  static String communityReport(String reportId) =>
      '$communityReports/$reportId';

  // ============================================================
  // EN: News endpoints (8.17)
  // KO: 뉴스 엔드포인트 (8.17)
  // ============================================================
  static String news(String projectId) => '${project(projectId)}/news';
  static String newsDetail(String projectId, String newsId) =>
      '${news(projectId)}/$newsId';

  // ============================================================
  // EN: Upload endpoints (8.18)
  // KO: 업로드 엔드포인트 (8.18)
  // ============================================================
  static const String uploadsPresignedUrl =
      '$apiVersion/uploads/presigned-url';
  static String uploadsConfirm(String uploadId) =>
      '$apiVersion/uploads/$uploadId/confirm';
  static const String uploadsMy = '$apiVersion/uploads/my';
  static String uploadsDelete(String uploadId) =>
      '$apiVersion/uploads/$uploadId';
  static String uploadsApprove(String uploadId) =>
      '$apiVersion/uploads/$uploadId/approve';

  // ============================================================
  // EN: Media Link endpoints (8.19)
  // KO: 미디어 링크 엔드포인트 (8.19)
  // ============================================================
  static String placeImagesLink(String projectId, String placeId) =>
      '${place(projectId, placeId)}/images';
  static String placeImageDelete(
    String projectId,
    String placeId,
    String imageId,
  ) =>
      '${placeImagesLink(projectId, placeId)}/$imageId';
  static String placeImagePrimary(
    String projectId,
    String placeId,
    String imageId,
  ) =>
      '${placeImageDelete(projectId, placeId, imageId)}:primary';
  static String placeImagesReorder(String projectId, String placeId) =>
      '${placeImagesLink(projectId, placeId)}:reorder';

  static String newsImagesLink(String projectId, String newsId) =>
      '${newsDetail(projectId, newsId)}/images';
  static String newsImageDelete(
    String projectId,
    String newsId,
    String imageId,
  ) =>
      '${newsImagesLink(projectId, newsId)}/$imageId';
  static String newsImagePrimary(
    String projectId,
    String newsId,
    String imageId,
  ) =>
      '${newsImageDelete(projectId, newsId, imageId)}:primary';
  static String newsImagesReorder(String projectId, String newsId) =>
      '${newsImagesLink(projectId, newsId)}:reorder';

  static String liveEventBannerLink(
    String projectId,
    String liveEventId,
  ) =>
      '${liveEvent(projectId, liveEventId)}/banner';

  // ============================================================
  // EN: Ranking endpoints (8.20)
  // KO: 랭킹 엔드포인트 (8.20)
  // ============================================================
  static String rankingsMostVisited(String projectId) =>
      '${project(projectId)}/rankings/most-visited';
  static String rankingsMostLiked(String projectId) =>
      '${project(projectId)}/rankings/most-liked';
  static String rankingsTrending(String projectId) =>
      '${project(projectId)}/rankings/trending';
  static String rankingsUsers(String projectId) =>
      '${project(projectId)}/rankings/users';

  // ============================================================
  // EN: Admin User/Role endpoints (8.21)
  // KO: 어드민 사용자/권한 엔드포인트 (8.21)
  // ============================================================
  static const String adminUsers = '$apiVersion/admin/users';
  static String adminUserRole(String userId) => '$adminUsers/$userId/role';
  static const String adminTokensRevoke = '$apiVersion/admin/tokens/revoke';
  static String projectRoles(String projectId) =>
      '${project(projectId)}/roles';
  static String projectRolesGrant(String projectId) =>
      '${projectRoles(projectId)}/grant';
  static String projectRolesRevoke(String projectId) =>
      '${projectRoles(projectId)}/revoke';
  static const String adminPasswordSecurityConfig =
      '$apiVersion/admin/password-security/config';
  static const String adminPasswordSecurityTest =
      '$apiVersion/admin/password-security/test';
  static const String adminCircuitBreakers =
      '$apiVersion/admin/circuit-breakers';
  static const String adminCircuitBreakersRedis =
      '$apiVersion/admin/circuit-breakers/redis';
  static const String adminCircuitBreakersDatabase =
      '$apiVersion/admin/circuit-breakers/database';

  // ============================================================
  // EN: Admin Monitoring/Analytics endpoints (8.22)
  // KO: 어드민 모니터링/분석 엔드포인트 (8.22)
  // ============================================================
  static const String adminDashboard = '$apiVersion/admin/dashboard';
  static const String adminAuditLogs = '$apiVersion/admin/audit-logs';
  static const String adminExports = '$apiVersion/admin/exports';
  static String adminExport(String id) => '$adminExports/$id';
  static String adminExportDownload(String id) => '${adminExport(id)}/download';
  static const String adminInsightsProjects =
      '$apiVersion/admin/insights/projects';
  static String adminInsightsProjectUnits(String projectId) =>
      '$adminInsightsProjects/$projectId/units';
  static const String adminAnalyticsVisitsByPlace =
      '$apiVersion/admin/analytics/visits/by-place';
  static const String adminAnalyticsVisitsTimeseries =
      '$apiVersion/admin/analytics/visits/timeseries';

  // ============================================================
  // EN: Admin Place/LiveEvent Operations endpoints (8.23)
  // KO: 어드민 장소/라이브 이벤트 운영 엔드포인트 (8.23)
  // ============================================================
  static String adminPlaceVisits(String projectId, String placeId) =>
      '${project(projectId)}/admin/places/$placeId/visits';
  static String adminPlaceVisitsSummary(String projectId, String placeId) =>
      '${adminPlaceVisits(projectId, placeId)}/summary';
  static String adminPlaceVisitsAnomalies(String projectId, String placeId) =>
      '${adminPlaceVisits(projectId, placeId)}/anomalies';
  static String adminPlaceVisitModerate(
          String projectId, String placeId, String visitId) =>
      '${adminPlaceVisits(projectId, placeId)}/$visitId/moderate';
  static String adminLiveEvents(String projectId) =>
      '${project(projectId)}/admin/live-events';
  static String adminPlaceUnitsReplace(String projectId, String placeId) =>
      '${project(projectId)}/admin/places/$placeId/units:replace';
  static String adminNewsUnitsReplace(String projectId, String newsId) =>
      '${project(projectId)}/admin/news/$newsId/units:replace';
  static String adminLiveEventUnitsReplace(
    String projectId,
    String liveEventId,
  ) =>
      '${project(projectId)}/admin/live-events/$liveEventId/units:replace';

  // ============================================================
  // EN: Admin SSE endpoints (8.24)
  // KO: 어드민 SSE 엔드포인트 (8.24)
  // ============================================================
  static const String adminStreamActivity =
      '$apiVersion/admin/stream/activity';
  static const String adminEventsStream = '$apiVersion/admin/events/stream';

  // ============================================================
  // EN: Health check endpoints (8.25)
  // KO: 헬스 체크 엔드포인트 (8.25)
  // ============================================================
  static const String health = '$apiVersion/health';
  static const String healthDetailed = '$apiVersion/health/detailed';
  static const String healthReady = '$apiVersion/health/ready';
  static const String healthLive = '$apiVersion/health/live';
}

/// EN: API timeout configurations (in milliseconds)
/// KO: API 타임아웃 구성 (밀리초)
class ApiTimeouts {
  ApiTimeouts._();

  static const int connectTimeout = 15000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 15000;
}

/// EN: API header constants
/// KO: API 헤더 상수
class ApiHeaders {
  ApiHeaders._();

  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const String clientType = 'X-Client-Type';
  static const String clientTypeMobile = 'mobile';
  static const String correlationId = 'X-Correlation-ID';
  static const String responseTime = 'X-Response-Time';
  static const String xsrfToken = 'X-XSRF-TOKEN';
}

/// EN: Pagination defaults
/// KO: 페이지네이션 기본값
class ApiPagination {
  ApiPagination._();

  static const int defaultPage = 0;
  static const int defaultSize = 20;
  static const int maxSize = 100;
}

/// EN: Cache control configurations
/// KO: 캐시 컨트롤 구성
class ApiCache {
  ApiCache._();

  /// EN: Default cache TTL in seconds
  /// KO: 기본 캐시 TTL (초)
  static const int defaultTtl = 300; // 5 minutes

  /// EN: Project list cache TTL
  /// KO: 프로젝트 목록 캐시 TTL
  static const int projectsTtl = 300; // 5 minutes

  /// EN: Place detail cache TTL
  /// KO: 장소 상세 캐시 TTL
  static const int placeDetailTtl = 600; // 10 minutes

  /// EN: Home summary cache TTL
  /// KO: 홈 요약 캐시 TTL
  static const int homeSummaryTtl = 300; // 5 minutes
}
