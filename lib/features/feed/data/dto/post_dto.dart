/// EN: Post DTOs aligned with Swagger schema.
/// KO: Swagger 스키마에 맞춘 게시글 DTO.
library;

class AuthorProfileDto {
  const AuthorProfileDto({
    required this.id,
    required this.displayName,
    this.avatarUrl,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;

  factory AuthorProfileDto.fromJson(Map<String, dynamic> json) {
    return AuthorProfileDto(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

class PostLikeStatusDto {
  const PostLikeStatusDto({
    required this.postId,
    required this.isLiked,
    required this.likeCount,
  });

  final String postId;
  final bool isLiked;
  final int likeCount;

  factory PostLikeStatusDto.fromJson(Map<String, dynamic> json) {
    return PostLikeStatusDto(
      postId: json['postId'] as String? ?? '',
      isLiked: json['isLiked'] as bool? ?? false,
      likeCount: _intOrNull(json['likeCount']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'postId': postId, 'isLiked': isLiked, 'likeCount': likeCount};
  }
}

class PostBookmarkStatusDto {
  const PostBookmarkStatusDto({
    required this.postId,
    required this.isBookmarked,
    this.bookmarkedAt,
  });

  final String postId;
  final bool isBookmarked;
  final DateTime? bookmarkedAt;

  factory PostBookmarkStatusDto.fromJson(Map<String, dynamic> json) {
    return PostBookmarkStatusDto(
      postId: json['postId'] as String? ?? '',
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      bookmarkedAt: _dateTimeOrNull(json['bookmarkedAt']),
    );
  }
}

class PostCursorPageDto {
  const PostCursorPageDto({
    required this.items,
    required this.hasNext,
    this.nextCursor,
  });

  final List<PostSummaryDto> items;
  final String? nextCursor;
  final bool hasNext;

  factory PostCursorPageDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map<String, dynamic>>()
              .map(PostSummaryDto.fromJson)
              .toList()
        : <PostSummaryDto>[];

    return PostCursorPageDto(
      items: items,
      nextCursor: json['nextCursor'] as String?,
      hasNext: json['hasNext'] as bool? ?? false,
    );
  }
}

class ProjectSubscriptionSummaryDto {
  const ProjectSubscriptionSummaryDto({
    required this.projectId,
    required this.projectCode,
    required this.projectName,
    required this.subscribedAt,
  });

  final String projectId;
  final String projectCode;
  final String projectName;
  final DateTime subscribedAt;

  factory ProjectSubscriptionSummaryDto.fromJson(Map<String, dynamic> json) {
    return ProjectSubscriptionSummaryDto(
      projectId: json['projectId'] as String? ?? '',
      projectCode: json['projectCode'] as String? ?? '',
      projectName: json['projectName'] as String? ?? '',
      subscribedAt: _dateTime(json['subscribedAt']),
    );
  }
}

class PostSummaryDto {
  const PostSummaryDto({
    required this.id,
    required this.projectId,
    required this.authorId,
    required this.title,
    required this.createdAt,
    this.imageUrls = const [],
    this.content,
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
  final String? content;
  final String? thumbnailUrl;
  final String? authorName;
  final String? authorAvatarUrl;
  final int? commentCount;
  final int? likeCount;
  final String? moderationStatus;

  factory PostSummaryDto.fromJson(Map<String, dynamic> json) {
    final authorProfile = _authorProfile(json['authorProfile']);
    final resolvedAuthorName =
        json['authorName'] as String? ??
        json['authorDisplayName'] as String? ??
        authorProfile?.displayName;
    final resolvedAvatarUrl =
        json['authorAvatarUrl'] as String? ??
        json['authorProfileImageUrl'] as String? ??
        authorProfile?.avatarUrl;

    // EN: Resolve thumbnail URL from various possible field names.
    // KO: 다양한 필드명에서 썸네일 URL을 해석합니다.
    final resolvedThumbnail =
        json['thumbnailUrl'] as String? ??
        json['coverImageUrl'] as String? ??
        json['firstImageUrl'] as String? ??
        json['thumbnail'] as String?;

    // EN: Try multiple keys for image arrays.
    // KO: 이미지 배열을 여러 키에서 시도합니다.
    var imageUrls = _imageUrls(
      json['images'] ??
          json['imageUrls'] ??
          json['attachments'] ??
          json['media'],
    );

    // EN: If no image URLs from array fields, fall back to thumbnail.
    // KO: 배열 필드에 이미지가 없으면 썸네일을 폴백으로 사용합니다.
    if (imageUrls.isEmpty &&
        resolvedThumbnail != null &&
        resolvedThumbnail.isNotEmpty) {
      imageUrls = [resolvedThumbnail];
    }

    final resolvedContent = _firstNonEmptyString([
      json['content'],
      json['body'],
      json['text'],
      json['excerpt'],
      json['summary'],
      json['description'],
    ]);

    return PostSummaryDto(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      createdAt: _dateTime(json['createdAt']),
      imageUrls: imageUrls,
      content: resolvedContent,
      thumbnailUrl: resolvedThumbnail,
      authorName: resolvedAuthorName,
      authorAvatarUrl: resolvedAvatarUrl,
      commentCount:
          _intOrNull(
            json['commentCount'] ??
                json['commentsCount'] ??
                json['comment_count'],
          ) ??
          0,
      likeCount:
          _intOrNull(
            json['likeCount'] ??
                json['likesCount'] ??
                json['favoriteCount'] ??
                json['favorite_count'],
          ) ??
          0,
      moderationStatus: json['moderationStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'authorId': authorId,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      if (imageUrls.isNotEmpty) 'imageUrls': imageUrls,
      if (content != null) 'content': content,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (authorName != null) 'authorName': authorName,
      if (authorAvatarUrl != null) 'authorAvatarUrl': authorAvatarUrl,
      if (commentCount != null) 'commentCount': commentCount,
      if (likeCount != null) 'likeCount': likeCount,
      if (moderationStatus != null) 'moderationStatus': moderationStatus,
    };
  }
}

class PostDetailDto {
  const PostDetailDto({
    required this.id,
    required this.projectId,
    required this.authorId,
    required this.title,
    required this.createdAt,
    required this.imageUrls,
    this.content,
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
  final List<String> imageUrls;
  final String? content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? authorName;
  final String? authorAvatarUrl;
  final int? commentCount;
  final int? likeCount;
  final String? moderationStatus;

  factory PostDetailDto.fromJson(Map<String, dynamic> json) {
    final authorProfile = _authorProfile(json['authorProfile']);
    final resolvedAuthorName =
        json['authorName'] as String? ??
        json['authorDisplayName'] as String? ??
        authorProfile?.displayName;
    final resolvedAvatarUrl =
        json['authorAvatarUrl'] as String? ??
        json['authorProfileImageUrl'] as String? ??
        authorProfile?.avatarUrl;

    final resolvedContent = _firstNonEmptyString([
      json['content'],
      json['body'],
      json['text'],
      json['excerpt'],
      json['summary'],
      json['description'],
    ]);

    return PostDetailDto(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: resolvedContent,
      createdAt: _dateTime(json['createdAt']),
      updatedAt: _dateTimeOrNull(json['updatedAt']),
      imageUrls: _imageUrls(json['images'] ?? json['imageUrls']),
      authorName: resolvedAuthorName,
      authorAvatarUrl: resolvedAvatarUrl,
      commentCount:
          _intOrNull(
            json['commentCount'] ??
                json['commentsCount'] ??
                json['comment_count'],
          ) ??
          0,
      likeCount:
          _intOrNull(
            json['likeCount'] ??
                json['likesCount'] ??
                json['favoriteCount'] ??
                json['favorite_count'],
          ) ??
          0,
      moderationStatus: json['moderationStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'authorId': authorId,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      if (imageUrls.isNotEmpty) 'imageUrls': imageUrls,
      if (authorName != null) 'authorName': authorName,
      if (authorAvatarUrl != null) 'authorAvatarUrl': authorAvatarUrl,
      if (commentCount != null) 'commentCount': commentCount,
      if (likeCount != null) 'likeCount': likeCount,
      if (moderationStatus != null) 'moderationStatus': moderationStatus,
    };
  }
}

DateTime _dateTime(dynamic value) {
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}

DateTime? _dateTimeOrNull(dynamic value) {
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}

List<String> _imageUrls(dynamic raw) {
  final urls = <String>[];
  if (raw is List) {
    for (final item in raw) {
      if (item is String && item.isNotEmpty) {
        urls.add(item);
      } else if (item is Map<String, dynamic>) {
        // EN: Try multiple keys for the image URL inside an object.
        // KO: 객체 내부에서 이미지 URL을 여러 키로 시도합니다.
        final url =
            item['url'] as String? ??
            item['imageUrl'] as String? ??
            item['src'] as String? ??
            item['thumbnailUrl'] as String?;
        if (url is String && url.isNotEmpty) {
          urls.add(url);
        }
      }
    }
  }
  return urls;
}

int? _intOrNull(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? _firstNonEmptyString(List<dynamic> values) {
  for (final value in values) {
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
  }
  return null;
}

AuthorProfileDto? _authorProfile(dynamic value) {
  if (value is Map<String, dynamic>) {
    return AuthorProfileDto.fromJson(value);
  }
  return null;
}
