import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/news_model.dart';

class NewsService {
  NewsService();

  final ApiClient _api = ApiClient.instance;

  Future<PageResponse<News>> getNewsList({
    required String projectCode,
    int page = 0,
    int size = 10,
    String? sort,
    List<String>? unitIds,
    bool includeShared = false,
  }) async {
    final envelope = await _api.get(
      ApiConstants.news(projectCode),
      queryParameters: {
        'page': page,
        'size': size,
        if (sort != null) 'sort': sort,
        if (unitIds != null && unitIds.isNotEmpty) 'unitIds': unitIds.join(','),
        if (includeShared) 'includeShared': true,
      },
    );

    final raw = envelope.data;
    final list = raw is List
        ? raw
        : (raw is Map<String, dynamic>
            ? (raw['items'] as List?) ?? const <dynamic>[]
            : const <dynamic>[]);

    final items = list
        .whereType<Map<String, dynamic>>()
        .map(News.fromJson)
        .toList(growable: false);

    final pagination = envelope.pagination;
    return PageResponse<News>(
      items: items,
      page: pagination?.currentPage ?? page,
      size: pagination?.pageSize ?? size,
      total: pagination?.totalItems ?? items.length,
      totalPages: pagination?.totalPages,
      hasNext: pagination?.hasNext ?? false,
      hasPrevious: pagination?.hasPrevious ?? false,
    );
  }

  Future<News> getNewsDetail({
    required String projectCode,
    required String newsId,
  }) async {
    final envelope = await _api.get(
      ApiConstants.newsDetail(projectCode, newsId),
    );
    return News.fromJson(envelope.requireDataAsMap());
  }

  Future<News> createNews({
    required String projectCode,
    required String title,
    required String body,
    List<String>? unitIds,
  }) async {
    final envelope = await _api.post(
      ApiConstants.news(projectCode),
      data: {
        'title': title,
        'body': body,
        if (unitIds != null && unitIds.isNotEmpty) 'unitIds': unitIds,
      },
    );
    return News.fromJson(envelope.requireDataAsMap());
  }

  Future<News> updateNews({
    required String projectCode,
    required String newsId,
    String? title,
    String? body,
    String? status,
    List<String>? unitIds,
  }) async {
    final payload = <String, dynamic>{
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (status != null) 'status': status,
      if (unitIds != null) 'unitIds': unitIds,
    };

    final envelope = await _api.put(
      ApiConstants.newsDetail(projectCode, newsId),
      data: payload,
    );
    return News.fromJson(envelope.requireDataAsMap());
  }

  Future<void> deleteNews({
    required String projectCode,
    required String newsId,
  }) async {
    await _api.delete(ApiConstants.newsDetail(projectCode, newsId));
  }
}
