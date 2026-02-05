/// EN: Feed domain entities for news and community posts.
/// KO: 뉴스/커뮤니티 도메인 엔티티.
library;

import 'package:intl/intl.dart';

import '../../data/dto/news_dto.dart';
import '../../data/dto/post_comment_dto.dart';
import '../../data/dto/post_dto.dart';

class NewsSummary {
  const NewsSummary({
    required this.id,
    required this.title,
    required this.publishedAt,
    this.thumbnailUrl,
  });

  final String id;
  final String title;
  final DateTime publishedAt;
  final String? thumbnailUrl;

  String get dateLabel {
    return DateFormat('yyyy.MM.dd').format(publishedAt.toLocal());
  }

  factory NewsSummary.fromDto(NewsSummaryDto dto) {
    return NewsSummary(
      id: dto.id,
      title: dto.title,
      publishedAt: dto.publishedAt,
      thumbnailUrl: dto.thumbnailUrl,
    );
  }
}

class NewsDetail {
  const NewsDetail({
    required this.id,
    required this.title,
    required this.body,
    required this.status,
    required this.publishedAt,
    this.coverImageUrl,
    this.imageUrls = const [],
  });

  final String id;
  final String title;
  final String body;
  final String status;
  final DateTime publishedAt;
  final String? coverImageUrl;
  final List<String> imageUrls;

  String get dateLabel {
    return DateFormat('yyyy.MM.dd').format(publishedAt.toLocal());
  }

  factory NewsDetail.fromDto(NewsDetailDto dto) {
    final images = dto.images.map((image) => image.url).toList();
    final cover = dto.coverImage?.url ?? (images.isNotEmpty ? images.first : null);

    return NewsDetail(
      id: dto.id,
      title: dto.title,
      body: dto.body,
      status: dto.status,
      publishedAt: dto.publishedAt,
      coverImageUrl: cover,
      imageUrls: images,
    );
  }
}

class PostSummary {
  const PostSummary({
    required this.id,
    required this.projectId,
    required this.authorId,
    required this.title,
    required this.createdAt,
    this.authorName,
    this.authorAvatarUrl,
    this.commentCount,
    this.likeCount,
  });

  final String id;
  final String projectId;
  final String authorId;
  final String title;
  final DateTime createdAt;
  final String? authorName;
  final String? authorAvatarUrl;
  final int? commentCount;
  final int? likeCount;

  String get timeAgoLabel => _formatTimeAgo(createdAt);

  factory PostSummary.fromDto(PostSummaryDto dto) {
    return PostSummary(
      id: dto.id,
      projectId: dto.projectId,
      authorId: dto.authorId,
      title: dto.title,
      createdAt: dto.createdAt,
      authorName: dto.authorName,
      authorAvatarUrl: dto.authorAvatarUrl,
      commentCount: dto.commentCount,
      likeCount: dto.likeCount,
    );
  }
}

class PostDetail {
  const PostDetail({
    required this.id,
    required this.projectId,
    required this.authorId,
    required this.title,
    required this.createdAt,
    this.imageUrls = const [],
    this.content,
    this.updatedAt,
    this.authorName,
    this.authorAvatarUrl,
    this.commentCount,
    this.likeCount,
  });

  final String id;
  final String projectId;
  final String authorId;
  final String title;
  final DateTime createdAt;
  final List<String> imageUrls;
  final String? content;
  final DateTime? updatedAt;
  final String? authorName;
  final String? authorAvatarUrl;
  final int? commentCount;
  final int? likeCount;

  String get timeAgoLabel => _formatTimeAgo(createdAt);

  factory PostDetail.fromDto(PostDetailDto dto) {
    return PostDetail(
      id: dto.id,
      projectId: dto.projectId,
      authorId: dto.authorId,
      title: dto.title,
      createdAt: dto.createdAt,
      imageUrls: dto.imageUrls,
      content: dto.content,
      updatedAt: dto.updatedAt,
      authorName: dto.authorName,
      authorAvatarUrl: dto.authorAvatarUrl,
      commentCount: dto.commentCount,
      likeCount: dto.likeCount,
    );
  }
}

class PostComment {
  const PostComment({
    required this.id,
    required this.postId,
    required this.projectId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.authorName,
    this.authorAvatarUrl,
  });

  final String id;
  final String postId;
  final String projectId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? authorName;
  final String? authorAvatarUrl;

  String get timeAgoLabel => _formatTimeAgo(createdAt);

  factory PostComment.fromDto(PostCommentDto dto) {
    return PostComment(
      id: dto.id,
      postId: dto.postId,
      projectId: dto.projectId,
      authorId: dto.authorId,
      content: dto.content,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      authorName: dto.authorName,
      authorAvatarUrl: dto.authorAvatarUrl,
    );
  }
}

class PostLikeStatus {
  const PostLikeStatus({
    required this.postId,
    required this.isLiked,
    required this.likeCount,
  });

  final String postId;
  final bool isLiked;
  final int likeCount;

  factory PostLikeStatus.fromDto(PostLikeStatusDto dto) {
    return PostLikeStatus(
      postId: dto.postId,
      isLiked: dto.isLiked,
      likeCount: dto.likeCount,
    );
  }
}

String _formatTimeAgo(DateTime? dateTime) {
  if (dateTime == null) return '방금 전';
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return '방금 전';
  if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
  if (diff.inHours < 24) return '${diff.inHours}시간 전';
  if (diff.inDays < 7) return '${diff.inDays}일 전';
  return DateFormat('yyyy.MM.dd').format(dateTime.toLocal());
}
