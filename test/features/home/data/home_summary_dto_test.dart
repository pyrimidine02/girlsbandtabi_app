import 'package:flutter_test/flutter_test.dart';

import 'package:girlsbandtabi_app/features/home/data/dto/home_summary_dto.dart';

void main() {
  test('HomeSummaryDto parses swagger keys', () {
    final json = {
      'recommendedPlaces': [
        {
          'id': 'place-1',
          'name': 'Tokyo Dome',
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
        },
      ],
      'latestNews': [
        {
          'id': 'news-1',
          'title': 'News Title',
          'publishedAt': '2026-01-28T00:00:00Z',
        },
      ],
    };

    final dto = HomeSummaryDto.fromJson(json);
    expect(dto.recommendedPlaces.length, 1);
    expect(dto.trendingLiveEvents.length, 1);
    expect(dto.latestNews.length, 1);
  });
}
