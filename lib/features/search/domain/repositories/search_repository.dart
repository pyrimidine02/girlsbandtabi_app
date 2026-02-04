/// EN: Search repository interface.
/// KO: 검색 리포지토리 인터페이스.
library;

import '../../../../core/utils/result.dart';
import '../entities/search_entities.dart';

abstract class SearchRepository {
  Future<Result<List<SearchItem>>> search({
    required String query,
    bool forceRefresh = false,
  });
}
