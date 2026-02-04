/// EN: Feed domain entities for news and community posts.
/// KO: 뉴스/커뮤니티 도메인 엔티티.
library;

import 'package:intl/intl.dart';

import '../../data/dto/news_dto.dart';
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
  });

  final String id;
  final String projectId;
  final String authorId;
  final String title;
  final DateTime createdAt;

  String get timeAgoLabel => _formatTimeAgo(createdAt);

  factory PostSummary.fromDto(PostSummaryDto dto) {
    return PostSummary(
      id: dto.id,
      projectId: dto.projectId,
      authorId: dto.authorId,
      title: dto.title,
      createdAt: dto.createdAt,
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
    this.content,
    this.updatedAt,
  });

  final String id;
  final String projectId;
  final String authorId;
  final String title;
  final DateTime createdAt;
  final String? content;
  final DateTime? updatedAt;

  String get timeAgoLabel => _formatTimeAgo(createdAt);

  factory PostDetail.fromDto(PostDetailDto dto) {
    return PostDetail(
      id: dto.id,
      projectId: dto.projectId,
      authorId: dto.authorId,
      title: dto.title,
      createdAt: dto.createdAt,
      content: dto.content,
      updatedAt: dto.updatedAt,
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
