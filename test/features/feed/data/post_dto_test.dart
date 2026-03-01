import 'package:flutter_test/flutter_test.dart';

import 'package:girlsbandtabi_app/features/feed/data/dto/post_dto.dart';

void main() {
  test('PostSummaryDto parses swagger keys', () {
    final json = {
      'id': 'post-1',
      'projectId': 'proj-1',
      'authorId': 'user-1',
      'title': '커뮤니티 글 제목',
      'createdAt': '2026-01-28T03:00:00Z',
      'moderationStatus': 'QUARANTINED',
    };

    final dto = PostSummaryDto.fromJson(json);
    expect(dto.id, 'post-1');
    expect(dto.projectId, 'proj-1');
    expect(dto.authorId, 'user-1');
    expect(dto.title, '커뮤니티 글 제목');
    expect(dto.createdAt, isNotNull);
    expect(dto.moderationStatus, 'QUARANTINED');
  });

  test('PostDetailDto parses swagger keys', () {
    final json = {
      'id': 'post-2',
      'projectId': 'proj-2',
      'authorId': 'user-2',
      'title': '상세 글 제목',
      'content': '상세 글 내용',
      'createdAt': '2026-01-28T05:00:00Z',
      'updatedAt': '2026-01-28T06:00:00Z',
      'moderationStatus': 'DELETED',
    };

    final dto = PostDetailDto.fromJson(json);
    expect(dto.id, 'post-2');
    expect(dto.projectId, 'proj-2');
    expect(dto.authorId, 'user-2');
    expect(dto.title, '상세 글 제목');
    expect(dto.content, '상세 글 내용');
    expect(dto.updatedAt, isNotNull);
    expect(dto.moderationStatus, 'DELETED');
  });

  test('PostCursorPageDto parses cursor payload', () {
    final json = {
      'items': [
        {
          'id': 'post-3',
          'projectId': 'proj-3',
          'authorId': 'user-3',
          'title': '커서 글',
          'createdAt': '2026-02-01T00:00:00Z',
          'commentCount': 1,
          'likeCount': 2,
        },
      ],
      'nextCursor': '2026-02-01T00:00:00Z',
      'hasNext': true,
    };

    final dto = PostCursorPageDto.fromJson(json);
    expect(dto.items, hasLength(1));
    expect(dto.items.first.id, 'post-3');
    expect(dto.nextCursor, '2026-02-01T00:00:00Z');
    expect(dto.hasNext, isTrue);
  });

  test('PostBookmarkStatusDto parses bookmark payload', () {
    final json = {
      'postId': 'post-4',
      'isBookmarked': true,
      'bookmarkedAt': '2026-02-01T03:00:00Z',
    };

    final dto = PostBookmarkStatusDto.fromJson(json);
    expect(dto.postId, 'post-4');
    expect(dto.isBookmarked, isTrue);
    expect(dto.bookmarkedAt, isNotNull);
  });

  test('ProjectSubscriptionSummaryDto parses payload', () {
    final json = {
      'projectId': 'proj-id',
      'projectCode': 'bangdream',
      'projectName': 'BanG Dream',
      'subscribedAt': '2026-02-01T04:00:00Z',
    };

    final dto = ProjectSubscriptionSummaryDto.fromJson(json);
    expect(dto.projectId, 'proj-id');
    expect(dto.projectCode, 'bangdream');
    expect(dto.projectName, 'BanG Dream');
    expect(dto.subscribedAt, isNotNull);
  });
}
