/// EN: Home summary domain entities.
/// KO: 홈 요약 도메인 엔티티.
library;

import 'package:intl/intl.dart';

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
    this.visitCount = 0,
    this.imageUrl,
    this.location,
  });

  final String id;
  final String name;
  final int visitCount;
  final String? imageUrl;
  final String? location;

  factory HomePlaceItem.fromDto(HomeRecommendedPlaceDto dto) {
    return HomePlaceItem(
      id: dto.id,
      name: dto.name,
      visitCount: dto.count,
    );
  }
}

class HomeEventItem {
  const HomeEventItem({
    required this.id,
    required this.title,
    required this.dateLabel,
    this.posterUrl,
    this.ticketUrl,
    this.isLive = false,
  });

  final String id;
  final String title;
  final String dateLabel;
  final String? posterUrl;
  final String? ticketUrl;
  final bool isLive;

  factory HomeEventItem.fromDto(HomeTrendingLiveEventDto dto) {
    return HomeEventItem(
      id: dto.id,
      title: dto.title,
      dateLabel: _formatDate(dto.showStartTime),
      ticketUrl: dto.ticketUrl,
      isLive: false,
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

  factory HomeNewsItem.fromDto(HomeLatestNewsDto dto) {
    return HomeNewsItem(
      id: dto.id,
      title: dto.title,
    );
  }
}

String _formatDate(DateTime dateTime) {
  return DateFormat('M월 d일').format(dateTime.toLocal());
}
