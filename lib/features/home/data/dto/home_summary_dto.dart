/// EN: Home summary DTO aligned with Swagger schema.
/// KO: Swagger 스키마에 맞춘 홈 요약 DTO.
library;

import '../../../places/data/dto/place_dto.dart';
import '../../../live_events/data/dto/live_event_dto.dart';
import '../../../feed/data/dto/news_dto.dart';

class HomeSummaryDto {
  const HomeSummaryDto({
    required this.recommendedPlaces,
    required this.trendingLiveEvents,
    required this.latestNews,
  });

  final List<PlaceSummaryDto> recommendedPlaces;
  final List<LiveEventSummaryDto> trendingLiveEvents;
  final List<NewsSummaryDto> latestNews;

  factory HomeSummaryDto.fromJson(Map<String, dynamic> json) {
    return HomeSummaryDto(
      recommendedPlaces: _parseList(
        json['recommendedPlaces'],
        PlaceSummaryDto.fromJson,
      ),
      trendingLiveEvents: _parseList(
        json['trendingLiveEvents'],
        LiveEventSummaryDto.fromJson,
      ),
      latestNews: _parseList(json['latestNews'], NewsSummaryDto.fromJson),
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

List<T> _parseList<T>(
  dynamic raw,
  T Function(Map<String, dynamic>) parser,
) {
  if (raw is! List) return <T>[];
  return raw.whereType<Map<String, dynamic>>().map(parser).toList();
}
