enum NewsStatus { published, draft }

class News {
  final String id;
  final String title;
  final String? body;
  final NewsStatus status;
  final DateTime? publishedAt;

  News({
    required this.id,
    required this.title,
    this.body,
    this.status = NewsStatus.published,
    this.publishedAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String?,
      status: _statusFromString(json['status'] as String?),
      publishedAt: json['publishedAt'] != null ? DateTime.tryParse(json['publishedAt'] as String) : null,
    );
  }

  static NewsStatus _statusFromString(String? raw) {
    final normalized = raw?.toUpperCase();
    switch (normalized) {
      case 'DRAFT':
        return NewsStatus.draft;
      case 'PUBLISHED':
      default:
        return NewsStatus.published;
    }
  }
}

class PageResponse<T> {
  final List<T> items;
  final int page;
  final int size;
  final int total;
  final int? totalPages;
  final bool hasNext;
  final bool hasPrevious;

  const PageResponse({
    required this.items,
    required this.page,
    required this.size,
    required this.total,
    this.totalPages,
    this.hasNext = false,
    this.hasPrevious = false,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final rawItems = json['items'] as List<dynamic>? ??
        json['data'] as List<dynamic>? ??
        const <dynamic>[];
    final list = rawItems.map(fromJsonT).toList();
    final pagination = json['pagination'] as Map<String, dynamic>?;
    final page = (pagination?['currentPage'] as num?)?.toInt() ??
        (json['page'] as num?)?.toInt() ?? 0;
    final size = (pagination?['pageSize'] as num?)?.toInt() ??
        (json['size'] as num?)?.toInt() ?? list.length;
    final total = (pagination?['totalItems'] as num?)?.toInt() ??
        (json['total'] as num?)?.toInt() ?? list.length;
    final totalPages = (pagination?['totalPages'] as num?)?.toInt() ??
        (json['totalPages'] as num?)?.toInt();
    final hasNext = pagination?['hasNext'] as bool? ??
        (json['hasNext'] as bool?) ?? false;
    final hasPrevious = pagination?['hasPrevious'] as bool? ??
        (json['hasPrevious'] as bool?) ?? false;

    return PageResponse(
      items: list,
      page: page,
      size: size,
      total: total,
      totalPages: totalPages,
      hasNext: hasNext,
      hasPrevious: hasPrevious,
    );
  }
}
