/// EN: Home summary DTO aligned with server response schema.
/// KO: 서버 응답 스키마에 맞춘 홈 요약 DTO.
library;

/// EN: Home summary returned from the /api/v1/home/summary endpoint.
/// KO: /api/v1/home/summary 엔드포인트에서 반환되는 홈 요약.
///
/// EN: The server returns lightweight summary items (not the full
/// PlaceSummaryDto / LiveEventSummaryDto / NewsSummaryDto), so we
/// use dedicated inner DTOs that match the actual response shape.
/// KO: 서버는 경량 요약 항목을 반환하므로(전체 DTO가 아님),
/// 실제 응답 형태에 맞는 전용 내부 DTO를 사용합니다.
class HomeSummaryDto {
  const HomeSummaryDto({
    required this.recommendedPlaces,
    required this.trendingLiveEvents,
    required this.latestNews,
  });

  final List<HomeRecommendedPlaceDto> recommendedPlaces;
  final List<HomeTrendingLiveEventDto> trendingLiveEvents;
  final List<HomeLatestNewsDto> latestNews;

  factory HomeSummaryDto.fromJson(Map<String, dynamic> json) {
    return HomeSummaryDto(
      recommendedPlaces: _parseList(
        json['recommendedPlaces'],
        HomeRecommendedPlaceDto.fromJson,
      ),
      trendingLiveEvents: _parseList(
        json['trendingLiveEvents'],
        HomeTrendingLiveEventDto.fromJson,
      ),
      latestNews: _parseList(
        json['latestNews'],
        HomeLatestNewsDto.fromJson,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommendedPlaces': recommendedPlaces.map((e) => e.toJson()).toList(),
      'trendingLiveEvents':
          trendingLiveEvents.map((e) => e.toJson()).toList(),
      'latestNews': latestNews.map((e) => e.toJson()).toList(),
    };
  }
}

// ========================================
// EN: Recommended Place (lightweight)
// KO: 추천 장소 (경량)
// ========================================

/// EN: Lightweight place item returned by the home summary endpoint.
/// KO: 홈 요약 엔드포인트에서 반환되는 경량 장소 항목.
///
/// Server response shape:
/// ```json
/// { "id": "uuid", "name": "장소명", "count": 5 }
/// ```
class HomeRecommendedPlaceDto {
  const HomeRecommendedPlaceDto({
    required this.id,
    required this.name,
    required this.count,
  });

  final String id;
  final String name;
  final int count;

  factory HomeRecommendedPlaceDto.fromJson(Map<String, dynamic> json) {
    return HomeRecommendedPlaceDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      count: _int(json['count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'count': count};
  }
}

// ========================================
// EN: Trending Live Event (lightweight)
// KO: 트렌딩 라이브 이벤트 (경량)
// ========================================

/// EN: Lightweight live event item from the home summary endpoint.
/// KO: 홈 요약 엔드포인트에서 반환되는 경량 라이브 이벤트 항목.
///
/// Server response shape:
/// ```json
/// {
///   "id": "uuid", "title": "...", "startTime": "...",
///   "showStartTime": "...", "doorsOpenTime": null,
///   "ticketUrl": null, "projectIds": ["uuid"],
///   "bannerUrl": "https://..." (optional)
/// }
/// ```
class HomeTrendingLiveEventDto {
  const HomeTrendingLiveEventDto({
    required this.id,
    required this.title,
    required this.startTime,
    required this.showStartTime,
    required this.projectIds,
    this.doorsOpenTime,
    this.ticketUrl,
    this.bannerUrl,
  });

  final String id;
  final String title;
  final DateTime startTime;
  final DateTime showStartTime;
  final DateTime? doorsOpenTime;
  final String? ticketUrl;
  final List<String> projectIds;

  // EN: Poster/banner image URL — tries multiple field names for compatibility.
  // KO: 포스터/배너 이미지 URL — 호환성을 위해 여러 필드명을 시도합니다.
  final String? bannerUrl;

  factory HomeTrendingLiveEventDto.fromJson(Map<String, dynamic> json) {
    // EN: Accept several field names the server may use for the poster image.
    // KO: 서버가 포스터 이미지에 사용할 수 있는 여러 필드명을 허용합니다.
    final rawBannerUrl = json['bannerUrl'] as String? ??
        json['banner_url'] as String? ??
        json['posterUrl'] as String? ??
        json['thumbnailUrl'] as String?;

    return HomeTrendingLiveEventDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      startTime: _dateTime(json['startTime']),
      showStartTime: _dateTime(json['showStartTime']),
      doorsOpenTime: _dateTimeOrNull(json['doorsOpenTime']),
      ticketUrl: json['ticketUrl'] as String?,
      projectIds: _stringList(json['projectIds']),
      bannerUrl: rawBannerUrl?.isNotEmpty == true ? rawBannerUrl : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'startTime': startTime.toIso8601String(),
      'showStartTime': showStartTime.toIso8601String(),
      'doorsOpenTime': doorsOpenTime?.toIso8601String(),
      'ticketUrl': ticketUrl,
      'projectIds': projectIds,
      if (bannerUrl != null) 'bannerUrl': bannerUrl,
    };
  }
}

// ========================================
// EN: Latest News (lightweight)
// KO: 최신 소식 (경량)
// ========================================

/// EN: Lightweight news item from the home summary endpoint.
/// KO: 홈 요약 엔드포인트에서 반환되는 경량 뉴스 항목.
///
/// Server response shape:
/// ```json
/// { "id": "uuid", "title": "..." }
/// ```
class HomeLatestNewsDto {
  const HomeLatestNewsDto({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  factory HomeLatestNewsDto.fromJson(Map<String, dynamic> json) {
    return HomeLatestNewsDto(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title};
  }
}

// ========================================
// EN: Parsing helpers
// KO: 파싱 헬퍼
// ========================================

List<T> _parseList<T>(dynamic raw, T Function(Map<String, dynamic>) parser) {
  if (raw is! List) return <T>[];
  return raw.whereType<Map<String, dynamic>>().map(parser).toList();
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

DateTime _dateTime(dynamic value) {
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}

DateTime? _dateTimeOrNull(dynamic value) {
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value.whereType<String>().toList();
  }
  return <String>[];
}
