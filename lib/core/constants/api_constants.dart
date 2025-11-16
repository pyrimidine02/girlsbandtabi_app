class ApiConstants {
  static const String baseUrl = 'http://localhost:8080';

  // Common bases
  static const String apiBase = '/api/v1';
  static const String admin = '$apiBase/admin';

  // Defaults
  static const String defaultProjectId = 'girls_band_cry';

  // Auth
  static const String login = '$apiBase/auth/login';
  static const String register = '$apiBase/auth/register';
  static const String refresh = '$apiBase/auth/refresh';
  static const String logout = '$apiBase/auth/logout';
  static String oauth2Callback(String provider) => '$apiBase/auth/oauth2/callback/$provider';

  // Users
  static const String users = '$apiBase/users';
  static const String me = '$users/me';
  static const String myVisits = '$users/me/visits';
  static const String visitsSummary = '$users/me/visits/summary';
  static const String myFavorites = '$users/me/favorites';

  // Projects
  static const String projects = '$apiBase/projects';
  static String project(String projectId) => '$projects/$projectId';

  // Places
  static String places(String projectId) => '${project(projectId)}/places';
  static String placeDetail(String projectId, String placeId) => '${places(projectId)}/$placeId';
  static String nearbyPlaces(String projectId) => '${places(projectId)}/nearby';
  static String placesWithinBounds(String projectId) => '${places(projectId)}/within-bounds';
  static String placeVerification(String projectId, String placeId) => '${placeDetail(projectId, placeId)}/verification';

  // Place media management
  static String placeImages(String projectId, String placeId) => '${placeDetail(projectId, placeId)}/images';
  static String placeImagesReorder(String projectId, String placeId) => '${placeImages(projectId, placeId)}:reorder';
  static String placeImagePrimary(String projectId, String placeId, String imageId) => '${placeImages(projectId, placeId)}/$imageId:primary';
  static String placeImage(String projectId, String placeId, String imageId) => '${placeImages(projectId, placeId)}/$imageId';

  // Units
  static String units(String projectId) => '${project(projectId)}/units';
  static String unitDetail(String projectId, String unitCode) => '${units(projectId)}/$unitCode';
  static String unitSearch(String projectId) => '${units(projectId)}/search';

  // Live events
  static String liveEvents(String projectId) => '${project(projectId)}/live-events';
  static String liveEventDetail(String projectId, String eventId) => '${liveEvents(projectId)}/$eventId';
  static String liveEventVerification(String projectId, String eventId) => '${liveEventDetail(projectId, eventId)}/verification';
  static String liveEventBanner(String projectId, String eventId) => '${liveEventDetail(projectId, eventId)}/banner';

  // News
  static String news(String projectId) => '${project(projectId)}/news';
  static String newsDetail(String projectId, String newsId) => '${news(projectId)}/$newsId';
  static String newsImages(String projectId, String newsId) => '${newsDetail(projectId, newsId)}/images';
  static String newsImagesReorder(String projectId, String newsId) => '${newsImages(projectId, newsId)}:reorder';
  static String newsImagePrimary(String projectId, String newsId, String imageId) => '${newsImages(projectId, newsId)}/$imageId:primary';
  static String newsImage(String projectId, String newsId, String imageId) => '${newsImages(projectId, newsId)}/$imageId';

  // Uploads
  static const String uploads = '$apiBase/uploads';
  static const String presignedUrl = '$uploads/presigned-url';
  static String uploadConfirm(String uploadId) => '$uploads/$uploadId/confirm';
  static String upload(String uploadId) => '$uploads/$uploadId';
  static const String myUploads = '$uploads/my';

  // Verification
  static const String verificationConfig = '$apiBase/verification/config';

  // Project roles
  static String projectRoles(String projectId) => '${project(projectId)}/roles';
  static String grantRole(String projectId) => '${projectRoles(projectId)}/grant';
  static String revokeRole(String projectId) => '${projectRoles(projectId)}/revoke';

  // Project admin (per project)
  static String projectAdmin(String projectId) => '${project(projectId)}/admin';
  static String adminPlaceVisits(String projectId, String placeId) => '${projectAdmin(projectId)}/places/$placeId/visits';
  static String adminPlaceVisitsSummary(String projectId, String placeId) => '${adminPlaceVisits(projectId, placeId)}/summary';
  static String adminPlaceVisitsAnomalies(String projectId, String placeId) => '${adminPlaceVisits(projectId, placeId)}/anomalies';
  static String adminPlaceVisitModeration(String projectId, String placeId, String visitId) => '${adminPlaceVisits(projectId, placeId)}/$visitId/moderate';
  static String adminPlaceUnitsReplace(String projectId, String placeId) => '${projectAdmin(projectId)}/places/$placeId/units:replace';
  static String adminNewsUnitsReplace(String projectId, String newsId) => '${projectAdmin(projectId)}/news/$newsId/units:replace';
  static String adminLiveEventUnitsReplace(String projectId, String liveEventId) => '${projectAdmin(projectId)}/live-events/$liveEventId/units:replace';
  static String adminLiveEvents(String projectId) => '${projectAdmin(projectId)}/live-events';

  // Admin (system-wide)
  static const String adminUsers = '$admin/users';
  static String adminUserRole(String userId) => '$adminUsers/$userId/role';
  static const String adminTokensRevoke = '$admin/tokens/revoke';
  static const String adminDashboard = '$admin/dashboard';
  static const String adminAuditLogs = '$admin/audit-logs';
  static const String adminInsightsProjects = '$admin/insights/projects';
  static String adminInsightsProjectUnits(String projectId) => '$admin/insights/projects/$projectId/units';
  static const String adminExports = '$admin/exports';
  static String adminExport(String exportId) => '$adminExports/$exportId';
  static String adminExportDownload(String exportId) => '${adminExport(exportId)}/download';
  static const String adminEventsStream = '$admin/events/stream';
  static const String adminAnalyticsVisitsByPlace = '$admin/analytics/visits/by-place';
  static const String adminAnalyticsVisitsTimeseries = '$admin/analytics/visits/timeseries';
  static const String adminMediaDeletions = '$admin/media-deletions';
  static String adminMediaDeletion(String requestId) => '$adminMediaDeletions/$requestId';
  static String adminMediaDeletionApprove(String requestId) => '${adminMediaDeletion(requestId)}/approve';
  static String adminMediaDeletionReject(String requestId) => '${adminMediaDeletion(requestId)}/reject';

  // Search & discovery
  static const String search = '$apiBase/search';
  static const String homeSummary = '$apiBase/home/summary';

  // Notifications
  static const String notifications = '$apiBase/notifications';
  static String notification(String id) => '$notifications/$id';
  static String notificationRead(String id) => '${notification(id)}/read';
  static const String notificationSettings = '$notifications/settings';

  // Actuator
  static const String health = '/actuator/health';
  static const String info = '/actuator/info';
  static const String metrics = '/actuator/metrics';
}
