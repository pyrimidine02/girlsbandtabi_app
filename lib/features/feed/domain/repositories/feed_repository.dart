/// EN: Feed repository interface for news and community posts.
/// KO: 뉴스 및 커뮤니티 게시글 리포지토리 인터페이스.
library;

import '../../../../core/utils/result.dart';
import '../entities/feed_entities.dart';

abstract class FeedRepository {
  /// EN: Get paginated news for a project.
  /// KO: 프로젝트의 페이지네이션된 뉴스를 가져옵니다.
  Future<Result<List<NewsSummary>>> getNews({
    required String projectId,
    int page = 0,
    int size = 20,
    bool forceRefresh = false,
  });

  /// EN: Get news detail.
  /// KO: 뉴스 상세를 가져옵니다.
  Future<Result<NewsDetail>> getNewsDetail({
    required String projectId,
    required String newsId,
    bool forceRefresh = false,
  });

  /// EN: Get paginated community posts.
  /// KO: 페이지네이션된 커뮤니티 게시글을 가져옵니다.
  Future<Result<List<PostSummary>>> getPosts({
    required String projectCode,
    int page = 0,
    int size = 20,
    bool forceRefresh = false,
  });

  Future<Result<PostDetail>> getPostDetail({
    required String projectCode,
    required String postId,
    bool forceRefresh = false,
  });
}
