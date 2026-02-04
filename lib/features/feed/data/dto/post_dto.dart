/// EN: Post DTOs aligned with Swagger schema.
/// KO: Swagger 스키마에 맞춘 게시글 DTO.
library;

class PostSummaryDto {
  const PostSummaryDto({
    required this.id,
    required this.projectId,
    required this.authorId,
    required this.title,
    required this.createdAt,
  });

  final String id;
  final String projectId;
  final String authorId;
  final String title;
  final DateTime createdAt;

  factory PostSummaryDto.fromJson(Map<String, dynamic> json) {
    return PostSummaryDto(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      createdAt: _dateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'authorId': authorId,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
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
    this.content,
    this.updatedAt,
  });

  final String id;
  final String projectId;
  final String authorId;
  final String title;
  final String? content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory PostDetailDto.fromJson(Map<String, dynamic> json) {
    return PostDetailDto(
      id: json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      authorId: json['authorId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String?,
      createdAt: _dateTime(json['createdAt']),
      updatedAt: _dateTimeOrNull(json['updatedAt']),
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
