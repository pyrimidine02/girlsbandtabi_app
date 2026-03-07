/// EN: Feed domain entities for news and community posts.
/// KO: 뉴스/커뮤니티 도메인 엔티티.
library;

import 'package:intl/intl.dart';

import '../../data/dto/news_dto.dart';
import '../../data/dto/post_comment_dto.dart';
import '../../data/dto/post_dto.dart';
import 'community_moderation.dart';

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
    final cover =
        dto.coverImage?.url ?? (images.isNotEmpty ? images.first : null);

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
    this.imageUrls = const [],
    this.tags = const [],
    this.content,
    this.topic,
    this.thumbnailUrl,
    this.authorName,
    this.authorAvatarUrl,
    this.commentCount,
    this.likeCount,
    this.moderationStatus,
  });

  final String id;
  final String projectId;
  final String authorId;
  final String title;
  final DateTime createdAt;
  final List<String> imageUrls;
  final List<String> tags;
  final String? content;
  final String? topic;
  final String? thumbnailUrl;
  final String? authorName;
  final String? authorAvatarUrl;
  final int? commentCount;
  final int? likeCount;
  final ContentModerationStatus? moderationStatus;

  String get timeAgoLabel => _formatTimeAgo(createdAt);

  factory PostSummary.fromDto(PostSummaryDto dto) {
    return PostSummary(
      id: dto.id,
      projectId: dto.projectId,
      authorId: dto.authorId,
      title: dto.title,
      createdAt: dto.createdAt,
      imageUrls: dto.imageUrls,
      tags: dto.tags,
      content: dto.content,
      topic: dto.topic,
      thumbnailUrl: dto.thumbnailUrl,
      authorName: dto.authorName,
      authorAvatarUrl: dto.authorAvatarUrl,
      commentCount: dto.commentCount,
      likeCount: dto.likeCount,
      moderationStatus: ContentModerationStatusX.fromApiValue(
        dto.moderationStatus,
      ),
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
    this.tags = const [],
    this.content,
    this.topic,
    this.updatedAt,
    this.authorName,
    this.authorAvatarUrl,
    this.commentCount,
    this.likeCount,
    this.moderationStatus,
  });

  final String id;
  final String projectId;
  final String authorId;
  final String title;
  final DateTime createdAt;
  final List<String> imageUrls;
  final List<String> tags;
  final String? content;
  final String? topic;
  final DateTime? updatedAt;
  final String? authorName;
  final String? authorAvatarUrl;
  final int? commentCount;
  final int? likeCount;
  final ContentModerationStatus? moderationStatus;

  String get timeAgoLabel => _formatTimeAgo(createdAt);

  factory PostDetail.fromDto(PostDetailDto dto) {
    return PostDetail(
      id: dto.id,
      projectId: dto.projectId,
      authorId: dto.authorId,
      title: dto.title,
      createdAt: dto.createdAt,
      imageUrls: dto.imageUrls,
      tags: dto.tags,
      content: dto.content,
      topic: dto.topic,
      updatedAt: dto.updatedAt,
      authorName: dto.authorName,
      authorAvatarUrl: dto.authorAvatarUrl,
      commentCount: dto.commentCount,
      likeCount: dto.likeCount,
      moderationStatus: ContentModerationStatusX.fromApiValue(
        dto.moderationStatus,
      ),
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
    this.parentCommentId,
    this.depth,
    this.replyCount,
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
  final String? parentCommentId;
  final int? depth;
  final int? replyCount;

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
      parentCommentId: dto.parentCommentId,
      depth: dto.depth,
      replyCount: dto.replyCount,
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

class PostBookmarkStatus {
  const PostBookmarkStatus({
    required this.postId,
    required this.isBookmarked,
    this.bookmarkedAt,
  });

  final String postId;
  final bool isBookmarked;
  final DateTime? bookmarkedAt;

  factory PostBookmarkStatus.fromDto(PostBookmarkStatusDto dto) {
    return PostBookmarkStatus(
      postId: dto.postId,
      isBookmarked: dto.isBookmarked,
      bookmarkedAt: dto.bookmarkedAt,
    );
  }
}

/// EN: Single topic/tag option item for compose metadata.
/// KO: 작성 메타데이터에서 사용하는 단일 토픽/태그 옵션 항목입니다.
class PostTaxonomyOption {
  const PostTaxonomyOption({
    required this.id,
    required this.name,
    this.sortOrder,
  });

  final String id;
  final String name;
  final int? sortOrder;

  factory PostTaxonomyOption.fromDto(PostTaxonomyOptionDto dto) {
    return PostTaxonomyOption(
      id: dto.id,
      name: dto.name,
      sortOrder: dto.sortOrder,
    );
  }
}

/// EN: Topic/tag option payload for compose and edit pages.
/// KO: 작성/수정 페이지에서 사용하는 토픽/태그 옵션 페이로드입니다.
class PostComposeOptions {
  const PostComposeOptions({this.topics = const [], this.tags = const []});

  final List<PostTaxonomyOption> topics;
  final List<PostTaxonomyOption> tags;

  factory PostComposeOptions.fromDto(PostComposeOptionsDto dto) {
    return PostComposeOptions(
      topics: dto.topics
          .map(PostTaxonomyOption.fromDto)
          .toList(growable: false),
      tags: dto.tags.map(PostTaxonomyOption.fromDto).toList(growable: false),
    );
  }
}

class PostCursorPage {
  const PostCursorPage({
    required this.items,
    required this.hasNext,
    this.nextCursor,
  });

  final List<PostSummary> items;
  final String? nextCursor;
  final bool hasNext;

  factory PostCursorPage.fromDto(PostCursorPageDto dto) {
    return PostCursorPage(
      items: dto.items.map(PostSummary.fromDto).toList(),
      nextCursor: dto.nextCursor,
      hasNext: dto.hasNext,
    );
  }
}

class CommentThreadNode {
  const CommentThreadNode({
    required this.comment,
    required this.replies,
    required this.hasMoreReplies,
  });

  final PostComment comment;
  final List<CommentThreadNode> replies;
  final bool hasMoreReplies;

  factory CommentThreadNode.fromDto(CommentThreadNodeDto dto) {
    return CommentThreadNode(
      comment: PostComment.fromDto(dto.comment),
      replies: dto.replies.map(CommentThreadNode.fromDto).toList(),
      hasMoreReplies: dto.hasMoreReplies,
    );
  }
}

class ProjectSubscriptionSummary {
  const ProjectSubscriptionSummary({
    required this.projectId,
    required this.projectCode,
    required this.projectName,
    required this.subscribedAt,
  });

  final String projectId;
  final String projectCode;
  final String projectName;
  final DateTime subscribedAt;

  factory ProjectSubscriptionSummary.fromDto(
    ProjectSubscriptionSummaryDto dto,
  ) {
    return ProjectSubscriptionSummary(
      projectId: dto.projectId,
      projectCode: dto.projectCode,
      projectName: dto.projectName,
      subscribedAt: dto.subscribedAt,
    );
  }
}

String _formatTimeAgo(DateTime? dateTime) {
  final locale = Intl.getCurrentLocale();
  final languageCode = locale.split(RegExp(r'[_-]')).first;
  if (dateTime == null) {
    if (languageCode == 'en') return 'just now';
    if (languageCode == 'ja') return 'たった今';
    return '방금 전';
  }
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) {
    if (languageCode == 'en') return 'just now';
    if (languageCode == 'ja') return 'たった今';
    return '방금 전';
  }
  if (diff.inMinutes < 60) {
    if (languageCode == 'en') return '${diff.inMinutes}m ago';
    if (languageCode == 'ja') return '${diff.inMinutes}分前';
    return '${diff.inMinutes}분 전';
  }
  if (diff.inHours < 24) {
    if (languageCode == 'en') return '${diff.inHours}h ago';
    if (languageCode == 'ja') return '${diff.inHours}時間前';
    return '${diff.inHours}시간 전';
  }
  if (diff.inDays < 7) {
    if (languageCode == 'en') return '${diff.inDays}d ago';
    if (languageCode == 'ja') return '${diff.inDays}日前';
    return '${diff.inDays}일 전';
  }
  return DateFormat('yyyy.MM.dd').format(dateTime.toLocal());
}
