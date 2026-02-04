/// EN: Media URL resolver for public CDN access.
/// KO: 공개 CDN 접근을 위한 미디어 URL 변환기.
library;

const _publicMediaHost = 'r2.pyrimidines.org';
const _legacyR2Suffix = 'r2.cloudflarestorage.com';
const _legacyBuckets = <String>{'girlsbandtabi', 'girlsbandtabi-dev'};

/// EN: Normalize legacy R2 URLs into public CDN URLs.
/// KO: 레거시 R2 URL을 공개 CDN URL로 정규화합니다.
String resolveMediaUrl(String rawUrl) {
  if (rawUrl.isEmpty) return rawUrl;

  final uri = Uri.tryParse(rawUrl);
  if (uri == null || uri.host.isEmpty) return rawUrl;

  final isLegacyR2 = uri.host.endsWith(_legacyR2Suffix);
  final isPublicR2 = uri.host == _publicMediaHost;
  if (!isLegacyR2 && !isPublicR2) return rawUrl;

  final decodedPath = Uri.decodeFull(uri.path);
  final segments = decodedPath
      .split('/')
      .where((segment) => segment.isNotEmpty)
      .toList();
  if (segments.isEmpty) return rawUrl;

  if (_legacyBuckets.contains(segments.first)) {
    segments.removeAt(0);
  }

  final normalizedPath = '/${segments.join('/')}';
  return Uri(
    scheme: 'https',
    host: _publicMediaHost,
    path: normalizedPath,
  ).toString();
}
