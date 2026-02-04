/// EN: Home summary domain entities.
/// KO: 홈 요약 도메인 엔티티.
library;

import 'package:intl/intl.dart';

import '../../../feed/data/dto/news_dto.dart';
import '../../../live_events/data/dto/live_event_dto.dart';
import '../../../places/data/dto/place_dto.dart';
import '../../data/dto/home_summary_dto.dart';

class HomeSummary {
  const HomeSummary({
    required this.recommendedPlaces,
    required this.trendingLiveEvents,
    required this.latestNews,
  });

  final List<HomePlaceItem> recommendedPlaces;
  final List<HomeEventItem> trendingLiveEvents;
  final List<HomeNewsItem> latestNews;

  bool get isEmpty =>
      recommendedPlaces.isEmpty &&
      trendingLiveEvents.isEmpty &&
      latestNews.isEmpty;

  factory HomeSummary.fromDto(HomeSummaryDto dto) {
    return HomeSummary(
      recommendedPlaces: dto.recommendedPlaces
          .map((item) => HomePlaceItem.fromDto(item))
          .toList(),
      trendingLiveEvents: dto.trendingLiveEvents
          .map((item) => HomeEventItem.fromDto(item))
          .toList(),
      latestNews: dto.latestNews
          .map((item) => HomeNewsItem.fromDto(item))
          .toList(),
    );
  }
}

class HomePlaceItem {
  const HomePlaceItem({
    required this.id,
    required this.name,
    required this.location,
    this.imageUrl,
    this.distanceLabel,
    this.isVerified = false,
    this.isFavorite = false,
    this.rating,
  });

  final String id;
  final String name;
  final String location;
  final String? imageUrl;
  final String? distanceLabel;
  final bool isVerified;
  final bool isFavorite;
  final double? rating;

  factory HomePlaceItem.fromDto(PlaceSummaryDto dto) {
    return HomePlaceItem(
      id: dto.id,
      name: dto.name,
      location: dto.regionSummary?.primaryName ?? '',
      imageUrl: dto.thumbnailUrl,
      distanceLabel: null,
      isVerified: false,
      isFavorite: false,
      rating: null,
    );
  }
}

class HomeEventItem {
  const HomeEventItem({
    required this.id,
    required this.title,
    required this.artistName,
    required this.venue,
    required this.dateLabel,
    this.posterUrl,
    this.isLive = false,
  });

  final String id;
  final String title;
  final String artistName;
  final String venue;
  final String dateLabel;
  final String? posterUrl;
  final bool isLive;

  factory HomeEventItem.fromDto(LiveEventSummaryDto dto) {
    return HomeEventItem(
      id: dto.id,
      title: dto.title,
      artistName: dto.status,
      venue: '프로젝트 ${dto.projectIds.length} · 유닛 ${dto.unitIds.length}',
      dateLabel: _formatDate(dto.showStartTime),
      posterUrl: dto.bannerUrl,
      isLive: dto.status.toLowerCase() == 'live',
    );
  }
}

class HomeNewsItem {
  const HomeNewsItem({
    required this.id,
    required this.title,
    this.summary,
    this.imageUrl,
    this.publishedAt,
  });

  final String id;
  final String title;
  final String? summary;
  final String? imageUrl;
  final DateTime? publishedAt;

  factory HomeNewsItem.fromDto(NewsSummaryDto dto) {
    return HomeNewsItem(
      id: dto.id,
      title: dto.title,
      summary: null,
      imageUrl: dto.thumbnailUrl,
      publishedAt: dto.publishedAt,
    );
  }
}

String _formatDate(DateTime dateTime) {
  return DateFormat('M월 d일').format(dateTime.toLocal());
}
