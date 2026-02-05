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

  /// EN: Create a community post.
  /// KO: 커뮤니티 게시글을 생성합니다.
  Future<Result<PostDetail>> createPost({
    required String projectCode,
    required String title,
    required String content,
  });

  /// EN: Update a community post.
  /// KO: 커뮤니티 게시글을 수정합니다.
  Future<Result<PostDetail>> updatePost({
    required String projectCode,
    required String postId,
    required String title,
    required String content,
  });

  /// EN: Delete a community post.
  /// KO: 커뮤니티 게시글을 삭제합니다.
  Future<Result<void>> deletePost({
    required String projectCode,
    required String postId,
  });

  /// EN: Get comments for a post.
  /// KO: 게시글 댓글을 가져옵니다.
  Future<Result<List<PostComment>>> getPostComments({
    required String projectCode,
    required String postId,
    int page = 0,
    int size = 20,
    bool forceRefresh = false,
  });

  /// EN: Create a comment for a post.
  /// KO: 게시글 댓글을 생성합니다.
  Future<Result<PostComment>> createPostComment({
    required String projectCode,
    required String postId,
    required String content,
  });

  /// EN: Update a comment for a post.
  /// KO: 게시글 댓글을 수정합니다.
  Future<Result<PostComment>> updatePostComment({
    required String projectCode,
    required String postId,
    required String commentId,
    required String content,
  });

  /// EN: Delete a comment for a post.
  /// KO: 게시글 댓글을 삭제합니다.
  Future<Result<void>> deletePostComment({
    required String projectCode,
    required String postId,
    required String commentId,
  });

  /// EN: Get posts authored by a specific user.
  /// KO: 특정 사용자가 작성한 게시글을 가져옵니다.
  Future<Result<List<PostSummary>>> getPostsByAuthor({
    required String projectCode,
    required String userId,
    int page,
    int size,
    bool forceRefresh,
  });

  /// EN: Get comments authored by a specific user.
  /// KO: 특정 사용자가 작성한 댓글을 가져옵니다.
  Future<Result<List<PostComment>>> getCommentsByAuthor({
    required String projectCode,
    required String userId,
    int page,
    int size,
    bool forceRefresh,
  });

  /// EN: Get post like status.
  /// KO: 게시글 좋아요 상태를 가져옵니다.
  Future<Result<PostLikeStatus>> getPostLikeStatus({
    required String projectCode,
    required String postId,
  });

  /// EN: Like a post.
  /// KO: 게시글에 좋아요를 누릅니다.
  Future<Result<PostLikeStatus>> likePost({
    required String projectCode,
    required String postId,
  });

  /// EN: Unlike a post.
  /// KO: 게시글 좋아요를 취소합니다.
  Future<Result<PostLikeStatus>> unlikePost({
    required String projectCode,
    required String postId,
  });
}
