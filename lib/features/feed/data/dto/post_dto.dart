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
    return {
      'postId': postId,
      'isLiked': isLiked,
      'likeCount': likeCount,
    };
  }
}

class PostSummaryDto {
  const PostSummaryDto({
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

    return PostSummaryDto(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      createdAt: _dateTime(json['createdAt']),
      authorName: resolvedAuthorName,
      authorAvatarUrl: resolvedAvatarUrl,
      commentCount: _intOrNull(
            json['commentCount'] ??
            json['commentsCount'] ??
            json['comment_count'],
          ) ??
          0,
      likeCount: _intOrNull(
            json['likeCount'] ??
            json['likesCount'] ??
            json['favoriteCount'] ??
            json['favorite_count'],
          ) ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'authorId': authorId,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      if (authorName != null) 'authorName': authorName,
      if (authorAvatarUrl != null) 'authorAvatarUrl': authorAvatarUrl,
      if (commentCount != null) 'commentCount': commentCount,
      if (likeCount != null) 'likeCount': likeCount,
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

    return PostDetailDto(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String?,
      createdAt: _dateTime(json['createdAt']),
      updatedAt: _dateTimeOrNull(json['updatedAt']),
      imageUrls: _imageUrls(json['images'] ?? json['imageUrls']),
      authorName: resolvedAuthorName,
      authorAvatarUrl: resolvedAvatarUrl,
      commentCount: _intOrNull(
            json['commentCount'] ??
            json['commentsCount'] ??
            json['comment_count'],
          ) ??
          0,
      likeCount: _intOrNull(
            json['likeCount'] ??
            json['likesCount'] ??
            json['favoriteCount'] ??
            json['favorite_count'],
          ) ??
          0,
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
        final url = item['url'];
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

AuthorProfileDto? _authorProfile(dynamic value) {
  if (value is Map<String, dynamic>) {
    return AuthorProfileDto.fromJson(value);
  }
  return null;
}
