/// EN: Notification navigation resolver helpers.
/// KO: 알림 네비게이션 경로 해석 헬퍼입니다.
library;

const String notificationTypePostCreated = 'POST_CREATED';
const String notificationTypeSystemNotice = 'SYSTEM_NOTICE';

/// EN: Normalize notification type with legacy alias compatibility.
/// KO: 레거시 별칭을 포함해 알림 타입을 정규화합니다.
String normalizeNotificationType(String? rawType) {
  final upper = rawType?.trim().toUpperCase() ?? '';
  return switch (upper) {
    'FOLLOWING_POST' => notificationTypePostCreated,
    'SYSTEM_BROADCAST' || 'SYSTEM' => notificationTypeSystemNotice,
    _ => upper,
  };
}

/// EN: Resolve in-app destination path from notification payload fields.
/// KO: 알림 페이로드 필드로부터 앱 내 목적 경로를 해석합니다.
String? resolveNotificationNavigationPath({
  String? type,
  String? deeplink,
  String? actionUrl,
  String? entityId,
}) {
  final normalizedType = normalizeNotificationType(type);
  final primaryLink = normalizedType == notificationTypeSystemNotice
      ? _firstNonEmpty(actionUrl, deeplink)
      : _firstNonEmpty(deeplink, actionUrl);
  final secondaryLink = normalizedType == notificationTypeSystemNotice
      ? _firstNonEmpty(deeplink, actionUrl)
      : _firstNonEmpty(actionUrl, deeplink);

  final directPath =
      _resolveInAppPath(primaryLink) ?? _resolveInAppPath(secondaryLink);
  if (directPath != null) {
    return directPath;
  }

  final postId =
      _extractPostId(entityId) ??
      _extractPostId(primaryLink) ??
      _extractPostId(secondaryLink);
  if (normalizedType == notificationTypePostCreated &&
      postId != null &&
      postId.isNotEmpty) {
    return '/board/posts/$postId';
  }

  if (normalizedType == notificationTypePostCreated) {
    return '/board';
  }

  if (normalizedType == notificationTypeSystemNotice) {
    return '/notifications';
  }

  return null;
}

String? _resolveInAppPath(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }
  final trimmed = raw.trim();

  if (trimmed.startsWith('/')) {
    return _normalizePath(trimmed);
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null) {
    return null;
  }

  if (uri.scheme.toLowerCase() == 'gbt') {
    final host = uri.host.trim();
    final segments = <String>[
      if (host.isNotEmpty) host,
      ...uri.pathSegments.where((segment) => segment.isNotEmpty),
    ];
    final path = '/${segments.join('/')}';
    return _normalizePath(path, query: uri.query);
  }

  if (uri.hasScheme &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.path.isNotEmpty) {
    return _normalizePath(uri.path, query: uri.query);
  }

  return null;
}

String? _normalizePath(String rawPath, {String? query}) {
  final path = rawPath.startsWith('/') ? rawPath : '/$rawPath';

  if (path.startsWith('/api/v1/projects/')) {
    final postMatch = RegExp(
      r'^/api/v1/projects/[^/]+/posts/([^/?#]+)',
    ).firstMatch(path);
    if (postMatch != null) {
      final postId = postMatch.group(1);
      if (postId != null && postId.isNotEmpty) {
        return '/board/posts/$postId';
      }
    }
  }

  if (path == '/api/v1/notifications' || path == '/notifications') {
    return '/notifications';
  }
  if (path.startsWith('/board/posts/')) {
    return _appendQuery(path, query);
  }
  if (path.startsWith('/info/news/')) {
    return _appendQuery(path, query);
  }
  if (path.startsWith('/users/')) {
    return _appendQuery(path, query);
  }
  if (path.startsWith('/live/')) {
    return _appendQuery(path, query);
  }
  if (path.startsWith('/places/')) {
    return _appendQuery(path, query);
  }
  if (path.startsWith('/notifications')) {
    return _appendQuery(path, query);
  }

  return null;
}

String _appendQuery(String path, String? query) {
  if (query == null || query.isEmpty) {
    return path;
  }
  return '$path?$query';
}

String? _extractPostId(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }
  final trimmed = raw.trim();
  final directUuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );
  if (directUuid.hasMatch(trimmed)) {
    return trimmed;
  }
  final match = RegExp(r'/posts/([0-9a-zA-Z-]{8,})').firstMatch(trimmed);
  return match?.group(1);
}

String? _firstNonEmpty(String? first, String? second) {
  if (first != null && first.trim().isNotEmpty) {
    return first.trim();
  }
  if (second != null && second.trim().isNotEmpty) {
    return second.trim();
  }
  return null;
}
