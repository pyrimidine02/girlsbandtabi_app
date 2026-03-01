import 'package:flutter_test/flutter_test.dart';

import 'package:girlsbandtabi_app/features/home/data/dto/home_summary_dto.dart';

void main() {
  test('HomeSummaryDto parses swagger keys', () {
    final json = {
      'recommendedPlaces': [
        {
          'id': 'place-1',
          'name': 'Tokyo Dome',
          'thumbnailUrl': 'https://example.com/place.png',
          'location': '도쿄',
          'types': ['VENUE'],
          'latitude': 35.7056,
          'longitude': 139.7519,
        },
      ],
      'trendingLiveEvents': [
        {
          'id': 'event-1',
          'title': 'Live Show',
          'showStartTime': '2026-02-01T00:00:00Z',
          'status': 'UPCOMING',
          'projectIds': ['proj-1'],
          'unitIds': ['unit-1'],
          'banner': {'url': 'https://example.com/live-poster.png'},
        },
      ],
      'latestNews': [
        {
          'id': 'news-1',
          'title': 'News Title',
          'summary': 'summary',
          'imageUrl': 'https://example.com/news.png',
          'publishedAt': '2026-01-28T00:00:00Z',
        },
      ],
    };

    final dto = HomeSummaryDto.fromJson(json);
    expect(dto.recommendedPlaces.length, 1);
    expect(dto.trendingLiveEvents.length, 1);
    expect(dto.latestNews.length, 1);
    expect(
      dto.recommendedPlaces.first.imageUrl,
      'https://example.com/place.png',
    );
    expect(
      dto.trendingLiveEvents.first.bannerUrl,
      'https://example.com/live-poster.png',
    );
    expect(dto.latestNews.first.imageUrl, 'https://example.com/news.png');
  });
}
