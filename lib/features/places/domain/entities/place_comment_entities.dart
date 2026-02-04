/// EN: Place comment domain entities.
/// KO: 장소 댓글 도메인 엔티티.
library;

import 'package:intl/intl.dart';

import '../../data/dto/place_comment_dto.dart';

class PlaceComment {
  const PlaceComment({
    required this.id,
    required this.authorId,
    required this.body,
    required this.createdAt,
    required this.replyCount,
    required this.isAdminNote,
    required this.isPinnedByAdmin,
    required this.tags,
    required this.photoUploadIds,
    required this.photoUrls,
  });

  final String id;
  final String authorId;
  final String body;
  final DateTime? createdAt;
  final int replyCount;
  final bool isAdminNote;
  final bool isPinnedByAdmin;
  final List<String> tags;
  final List<String> photoUploadIds;
  final List<String> photoUrls;

  factory PlaceComment.fromDto(PlaceCommentDetailDto dto) {
    final rawBody = dto.bodyMarkdown.isNotEmpty
        ? dto.bodyMarkdown
        : _stripHtml(dto.bodyHtml ?? '');
    return PlaceComment(
      id: dto.id,
      authorId: dto.authorSubjectId,
      body: rawBody.trim(),
      createdAt: dto.createdAt,
      replyCount: dto.replyCount,
      isAdminNote: dto.isAdminNote,
      isPinnedByAdmin: dto.isPinnedByAdmin,
      tags: dto.tags,
      photoUploadIds: dto.photoUploadIds,
      photoUrls: dto.photos.map((photo) => photo.url).toList(),
    );
  }

  String get createdAtLabel {
    if (createdAt == null) return '';
    return DateFormat('yyyy.MM.dd').format(createdAt!.toLocal());
  }
}

String _stripHtml(String input) {
  return input.replaceAll(RegExp(r'<[^>]*>'), '');
}
