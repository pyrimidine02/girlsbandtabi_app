import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../services/news_service.dart';
import '../models/news_model.dart';
import 'content_filter_provider.dart';

final newsServiceProvider = Provider<NewsService>((ref) => NewsService());

final newsListProvider = FutureProvider.autoDispose<PageResponse<News>>((ref) async {
  final service = ref.watch(newsServiceProvider);
  final projectId = ref.watch(selectedProjectProvider) ?? ApiConstants.defaultProjectId;
  final unitId = ref.watch(selectedBandProvider);
  return service.getNewsList(
    projectCode: projectId,
    page: 0,
    size: 10,
    sort: 'publishedAt,desc',
    unitIds: unitId != null ? [unitId] : null,
    includeShared: true,
  );
});
