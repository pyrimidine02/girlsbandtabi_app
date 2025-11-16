class HomeSummary {
  const HomeSummary({
    required this.recommendedPlaces,
    required this.trendingLiveEvents,
    required this.latestNews,
    this.stats,
    this.raw = const {},
  });

  factory HomeSummary.fromJson(Map<String, dynamic> json) {
    final recommended = <HomeSummaryPlace>[];
    for (final entry in _extractList(json, const [
      'recommendedPlaces',
      'recommended',
      'places',
    ])) {
      if (entry is Map<String, dynamic>) {
        final place = HomeSummaryPlace.fromJson(entry);
        if (place.isValid) {
          recommended.add(place);
        }
      }
    }

    final liveEvents = <HomeSummaryLive>[];
    for (final entry in _extractList(json, const [
      'trendingLiveEvents',
      'trendingLive',
      'liveEvents',
    ])) {
      if (entry is Map<String, dynamic>) {
        final live = HomeSummaryLive.fromJson(entry);
        if (live.isValid) {
          liveEvents.add(live);
        }
      }
    }

    final newsList = <HomeSummaryNews>[];
    for (final entry in _extractList(json, const [
      'latestNews',
      'news',
    ])) {
      if (entry is Map<String, dynamic>) {
        final news = HomeSummaryNews.fromJson(entry);
        if (news.isValid) {
          newsList.add(news);
        }
      }
    }

    final statsMap = _extractMap(json, const ['userStats', 'stats']);

    return HomeSummary(
      recommendedPlaces: recommended,
      trendingLiveEvents: liveEvents,
      latestNews: newsList,
      stats: statsMap != null ? HomeSummaryStats.fromJson(statsMap) : null,
      raw: json,
    );
  }

  static List<dynamic> _extractList(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is List) {
        return value;
      }
    }
    return const [];
  }

  static Map<String, dynamic>? _extractMap(
    Map<String, dynamic> source,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = source[key];
      if (value is Map<String, dynamic>) {
        return value;
      }
    }
    return null;
  }

  final List<HomeSummaryPlace> recommendedPlaces;
  final List<HomeSummaryLive> trendingLiveEvents;
  final List<HomeSummaryNews> latestNews;
  final HomeSummaryStats? stats;
  final Map<String, dynamic> raw;

  const HomeSummary.empty()
      : recommendedPlaces = const [],
        trendingLiveEvents = const [],
        latestNews = const [],
        stats = null,
        raw = const {};

  HomeSummary copyWith({
    List<HomeSummaryPlace>? recommendedPlaces,
    List<HomeSummaryLive>? trendingLiveEvents,
    List<HomeSummaryNews>? latestNews,
    HomeSummaryStats? stats,
  }) {
    return HomeSummary(
      recommendedPlaces: recommendedPlaces ?? this.recommendedPlaces,
      trendingLiveEvents: trendingLiveEvents ?? this.trendingLiveEvents,
      latestNews: latestNews ?? this.latestNews,
      stats: stats ?? this.stats,
      raw: raw,
    );
  }
}

class HomeSummaryPlace {
  const HomeSummaryPlace({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.projectId,
    this.unitIds = const [],
    this.latitude,
    this.longitude,
  });

  factory HomeSummaryPlace.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const HomeSummaryPlace(id: '', title: '');
    }
    final id = (json['id'] ?? json['placeId'])?.toString();
    final title = json['name']?.toString() ?? json['title']?.toString();
    if (id == null || id.isEmpty || title == null || title.isEmpty) {
      return const HomeSummaryPlace(id: '', title: '');
    }
    final unitsRaw = json['unitIds'] ?? json['units'];
    final unitIds = unitsRaw is List
        ? unitsRaw.map((e) => e.toString()).toList(growable: false)
        : const <String>[];
    String? imageUrl;
    if (json['imageUrl'] != null) {
      imageUrl = json['imageUrl'].toString();
    } else if (json['thumbnailUrl'] != null) {
      imageUrl = json['thumbnailUrl'].toString();
    } else if (json['primaryImage'] is Map) {
      final primary = json['primaryImage'] as Map;
      if (primary['url'] != null) {
        imageUrl = primary['url'].toString();
      }
    }
    return HomeSummaryPlace(
      id: id,
      title: title,
      description: json['description']?.toString() ?? json['summary']?.toString(),
      imageUrl: imageUrl,
      projectId:
          json['projectId']?.toString() ?? json['projectCode']?.toString(),
      unitIds: unitIds,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? projectId;
  final List<String> unitIds;
  final double? latitude;
  final double? longitude;

  bool get isValid => id.isNotEmpty;
}

class HomeSummaryLive {
  const HomeSummaryLive({
    required this.id,
    required this.title,
    this.status,
    this.startTime,
    this.bannerUrl,
    this.unitNames = const [],
    this.projectId,
    this.placeId,
  });

  factory HomeSummaryLive.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const HomeSummaryLive(id: '', title: '');
    }
    final id = (json['id'] ?? json['liveEventId'])?.toString();
    final title = json['title']?.toString();
    if (id == null || id.isEmpty || title == null || title.isEmpty) {
      return const HomeSummaryLive(id: '', title: '');
    }
    final startRaw = json['startTime'] ?? json['startAt'] ?? json['start_date'];
    DateTime? startTime;
    if (startRaw != null) {
      startTime = DateTime.tryParse(startRaw.toString());
    }
    final unitsRaw = json['units'];
    final unitNames = unitsRaw is List
        ? unitsRaw
            .map((unit) =>
                unit is Map && unit['displayName'] != null
                    ? unit['displayName'].toString()
                    : unit.toString())
            .toList(growable: false)
        : const <String>[];
    String? bannerUrl;
    if (json['bannerUrl'] != null) {
      bannerUrl = json['bannerUrl'].toString();
    } else if (json['banner'] is Map) {
      final banner = json['banner'] as Map;
      if (banner['url'] != null) {
        bannerUrl = banner['url'].toString();
      }
    }
    return HomeSummaryLive(
      id: id,
      title: title,
      status: json['status']?.toString(),
      startTime: startTime,
      bannerUrl: bannerUrl,
      unitNames: unitNames,
      projectId:
          json['projectId']?.toString() ?? json['projectCode']?.toString(),
      placeId: json['placeId']?.toString(),
    );
  }

  final String id;
  final String title;
  final String? status;
  final DateTime? startTime;
  final String? bannerUrl;
  final List<String> unitNames;
  final String? projectId;
  final String? placeId;

  bool get isValid => id.isNotEmpty;
}

class HomeSummaryNews {
  const HomeSummaryNews({
    required this.id,
    required this.title,
    this.summary,
    this.publishedAt,
    this.thumbnailUrl,
    this.projectId,
  });

  factory HomeSummaryNews.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const HomeSummaryNews(id: '', title: '');
    }
    final id = (json['id'] ?? json['newsId'])?.toString();
    final title = json['title']?.toString();
    if (id == null || id.isEmpty || title == null || title.isEmpty) {
      return const HomeSummaryNews(id: '', title: '');
    }
    final publishedRaw = json['publishedAt'] ??
        json['published_at'] ??
        json['createdAt'];
    DateTime? publishedAt;
    if (publishedRaw != null) {
      publishedAt = DateTime.tryParse(publishedRaw.toString());
    }
    String? thumbnailUrl;
    if (json['thumbnailUrl'] != null) {
      thumbnailUrl = json['thumbnailUrl'].toString();
    } else if (json['thumbnail'] is Map) {
      final thumbnail = json['thumbnail'] as Map;
      if (thumbnail['url'] != null) {
        thumbnailUrl = thumbnail['url'].toString();
      }
    } else if (json['coverImage'] is Map) {
      final cover = json['coverImage'] as Map;
      if (cover['url'] != null) {
        thumbnailUrl = cover['url'].toString();
      }
    }
    return HomeSummaryNews(
      id: id,
      title: title,
      summary: json['summary']?.toString() ??
          json['excerpt']?.toString() ??
          json['body']?.toString(),
      publishedAt: publishedAt,
      thumbnailUrl: thumbnailUrl,
      projectId:
          json['projectId']?.toString() ?? json['projectCode']?.toString(),
    );
  }

  final String id;
  final String title;
  final String? summary;
  final DateTime? publishedAt;
  final String? thumbnailUrl;
  final String? projectId;

  bool get isValid => id.isNotEmpty;
}

class HomeSummaryStats {
  const HomeSummaryStats({
    this.visits,
    this.liveEvents,
    this.favorites,
    this.news,
  });

  factory HomeSummaryStats.fromJson(Map<String, dynamic> json) {
    int? toInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return HomeSummaryStats(
      visits: toInt(json['visits'] ?? json['totalVisits']),
      liveEvents: toInt(json['liveEvents'] ?? json['liveCount']),
      favorites: toInt(json['favorites'] ?? json['favoriteCount']),
      news: toInt(json['news'] ?? json['newsCount']),
    );
  }

  final int? visits;
  final int? liveEvents;
  final int? favorites;
  final int? news;
}
