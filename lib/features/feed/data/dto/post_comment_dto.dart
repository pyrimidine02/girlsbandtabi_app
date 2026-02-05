/// EN: Post comment DTOs for community posts.
/// KO: 커뮤니티 게시글 댓글 DTO.
library;

class PostCommentDto {
  const PostCommentDto({
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

  factory PostCommentDto.fromJson(Map<String, dynamic> json) {
    final authorProfile = _authorProfile(json['authorProfile']);
    final resolvedAuthorName =
        json['authorName'] as String? ??
        json['authorDisplayName'] as String? ??
        authorProfile?.displayName;
    final resolvedAvatarUrl =
        json['authorAvatarUrl'] as String? ??
        json['authorProfileImageUrl'] as String? ??
        authorProfile?.avatarUrl;

    return PostCommentDto(
      id: json['id'] as String? ?? '',
      postId: json['postId'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: _dateTime(json['createdAt']),
      updatedAt: _dateTimeOrNull(json['updatedAt']),
      authorName: resolvedAuthorName,
      authorAvatarUrl: resolvedAvatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'projectId': projectId,
      'authorId': authorId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      if (authorName != null) 'authorName': authorName,
      if (authorAvatarUrl != null) 'authorAvatarUrl': authorAvatarUrl,
    };
  }
}

class PostCreateRequestDto {
  const PostCreateRequestDto({required this.title, required this.content});

  final String title;
  final String content;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }
}

class PostCommentCreateRequestDto {
  const PostCommentCreateRequestDto({required this.content});

  final String content;

  Map<String, dynamic> toJson() {
    return {'content': content};
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

_AuthorProfileDto? _authorProfile(dynamic value) {
  if (value is Map<String, dynamic>) {
    return _AuthorProfileDto.fromJson(value);
  }
  return null;
}

class _AuthorProfileDto {
  const _AuthorProfileDto({required this.displayName, this.avatarUrl});

  final String displayName;
  final String? avatarUrl;

  factory _AuthorProfileDto.fromJson(Map<String, dynamic> json) {
    return _AuthorProfileDto(
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}
